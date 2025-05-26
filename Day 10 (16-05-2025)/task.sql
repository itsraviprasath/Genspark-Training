-- EdTech Platform

-- Schema Creation

-- Address-related tables
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE districts (
    district_id SERIAL PRIMARY KEY,
    district VARCHAR(100) NOT NULL,
    country_id INT REFERENCES countries(country_id)
);

CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    district_id INT REFERENCES districts(district_id)
);

CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    address TEXT NOT NULL,
    city_id INT REFERENCES cities(city_id)
);

-- Students table
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(12) NOT NULL,
    address_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trainers table
CREATE TABLE trainers (
    trainer_id SERIAL PRIMARY KEY,
    trainer_name VARCHAR(50) NOT NULL,
    expertise VARCHAR(20),
    address_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses table
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(50) NOT NULL,
    category VARCHAR(30),
    duration_days INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER SEQUENCE courses_course_id_seq RESTART WITH 100;

-- Enrollments table
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    enroll_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER SEQUENCE enrollments_enrollment_id_seq RESTART WITH 300;

-- Certificates table
CREATE TABLE certificates (
    certificate_id SERIAL PRIMARY KEY,
    enrollment_id INT REFERENCES enrollments(enrollment_id) ON DELETE SET NULL,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    serial_no TEXT UNIQUE
);
ALTER SEQUENCE certificates_certificate_id_seq RESTART WITH 400;

-- Many-to-many relationship between courses and trainers
CREATE TABLE course_trainer (
    course_id INT,
    trainer_id INT,
    PRIMARY KEY(course_id, trainer_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id) ON DELETE CASCADE
);

-- Data Insertion

-- Insert students
INSERT INTO students (name, email, phone) VALUES
('Ravi', 'ravi@gmsil.com', '9876543210'),
('Renu', 'renu@gmail.com', '9012345678');

-- Insert trainers
INSERT INTO trainers (trainer_name, expertise) VALUES
('Dr. Ram', 'DevOps'),
('Mr. Prasath', 'CP');

-- Insert courses
INSERT INTO courses (course_name, category, duration_days) VALUES
('Docker', 'DevOps', 30),
('LLM', 'AI', 45);

-- Assign trainers to courses
INSERT INTO course_trainer (course_id, trainer_id) VALUES
(100, 200),
(101, 201);

-- Enroll students
INSERT INTO enrollments (student_id, course_id) VALUES
(1, 100),
(2, 101);

-- Issue certificates
INSERT INTO certificates (enrollment_id, serial_no) VALUES
(302, 'CERT-RAVI-101'),
(303, 'CERT-RENU-102');

-- Indexes

CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_students_name ON students(name);
CREATE INDEX idx_trainers_name ON trainers(trainer_name);
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);

-- Query Practice

-- 1. List students and their enrolled courses
SELECT s.name AS student_name, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id;

-- 2. Students who received certificates along with trainer names
SELECT s.name AS student_name, t.trainer_name, cert.serial_no
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN certificates cert ON cert.enrollment_id = e.enrollment_id
JOIN course_trainer ct ON ct.course_id = e.course_id
JOIN trainers t ON t.trainer_id = ct.trainer_id;

-- 3. Number of students per course
SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses c
JOIN enrollments e ON e.course_id = c.course_id
GROUP BY c.course_name;

-- Functions & Stored Procedures

-- 1. Function to get certified students for a course
CREATE OR REPLACE FUNCTION get_certified_students(p_course_id INT)
RETURNS TABLE (
    student_id INT,
    student_name VARCHAR,
    serial_id TEXT,
    course_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.student_id, s.name, cert.serial_no, crs.course_name
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN courses crs ON e.course_id = crs.course_id
    JOIN certificates cert ON e.enrollment_id = cert.enrollment_id
    WHERE e.course_id = p_course_id;
END;
$$ LANGUAGE plpgsql;

-- 2. Procedure to enroll a student and optionally issue a certificate
CREATE OR REPLACE PROCEDURE sp_enroll_student(
    p_student_id INT,
    p_course_id INT,
    p_status INT
)
AS $$
DECLARE
    v_enrollment_id INT;
BEGIN
    INSERT INTO enrollments (student_id, course_id)
    VALUES (p_student_id, p_course_id)
    RETURNING enrollment_id INTO v_enrollment_id;

    IF p_status = 1 THEN
        INSERT INTO certificates (enrollment_id, serial_no)
        VALUES (v_enrollment_id, 'CERT-' || p_student_id || '-' || p_course_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Enrollment failed: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 3. Procedure using cursor to list uncertified students
CREATE OR REPLACE PROCEDURE sp_list_uncertified_student(p_course_id INT)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT s.student_id, s.name, s.email, e.enrollment_id
        FROM students s
        JOIN enrollments e ON s.student_id = e.student_id
        WHERE e.course_id = p_course_id
          AND s.student_id NOT IN (
              SELECT student_id FROM get_certified_students(p_course_id)
          );
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Student_ID: %, Name: %, Email: %, Enrollment_ID: %',
                     rec.student_id, rec.name, rec.email, rec.enrollment_id;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE plpgsql;

-- 4. Transaction procedure: enroll + certify
CREATE OR REPLACE PROCEDURE sp_enroll_certify(p_student_id INT, p_course_id INT)
AS $$
BEGIN
    BEGIN
        WITH enroll_data AS (
            INSERT INTO enrollments (student_id, course_id)
            VALUES (p_student_id, p_course_id)
            RETURNING enrollment_id
        )
        INSERT INTO certificates (enrollment_id, serial_no)
        SELECT enrollment_id, 'CERT-' || p_student_id || '-' || p_course_id
        FROM enroll_data;

        RAISE NOTICE 'Enrollment and certification successful.';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE NOTICE 'Transaction failed: %', SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- Roles & Security

-- 1. Read-only role
CREATE ROLE readonly_user LOGIN PASSWORD 'readonly_pass';
GRANT CONNECT ON DATABASE "EdTech DB" TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON students, trainers, courses, enrollments, certificates, course_trainer TO readonly_user;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM readonly_user;

-- 2. Data entry role
CREATE ROLE data_entry_user LOGIN PASSWORD 'data_entry_pass';
GRANT CONNECT ON DATABASE "EdTech DB" TO data_entry_user;
GRANT USAGE ON SCHEMA public TO data_entry_user;
GRANT SELECT ON students, trainers, courses, enrollments, certificates, course_trainer TO data_entry_user;
GRANT INSERT ON students, enrollments TO data_entry_user;
REVOKE UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM data_entry_user;
REVOKE ALL ON certificates FROM data_entry_user;

-- Sample Queries

SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM trainers;
SELECT * FROM enrollments;
SELECT * FROM certificates;
SELECT * FROM course_trainer;
