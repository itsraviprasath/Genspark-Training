-- Create EMPLOYEE table
CREATE TABLE TASK_EMP (
    empno INT PRIMARY KEY,
    empname VARCHAR(50),
    salary DECIMAL(10,2),
    bossno INT NULL,
    deptname VARCHAR(50) NULL,
    FOREIGN KEY (bossno) REFERENCES TASK_EMP(empno)
);

-- Create DEPARTMENT table
CREATE TABLE TASK_DEPARTMENT (
    deptname VARCHAR(50) PRIMARY KEY,
    floor INT,
    phone VARCHAR(12),
    manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES TASK_EMP(empno)
);

-- Add foreign key from EMP to DEPARTMENT
ALTER TABLE TASK_EMP
ADD CONSTRAINT fk_emp_dept
FOREIGN KEY (deptname) REFERENCES TASK_DEPARTMENT(deptname) ON DELETE SET NULL;

-- Create ITEM table
CREATE TABLE TASK_ITEM (
    itemname VARCHAR(50) PRIMARY KEY,
    itemtype VARCHAR(50),
    itemcolor VARCHAR(50)
);

-- Create SALES table
CREATE TABLE TASK_SALES (
    salesno INT PRIMARY KEY,
    salesqty INT,
    itemname VARCHAR(50) NOT NULL,
    deptname VARCHAR(50) NOT NULL,
    FOREIGN KEY (itemname) REFERENCES TASK_ITEM(itemname),
    FOREIGN KEY (deptname) REFERENCES TASK_DEPARTMENT(deptname)
);

-- Insert into DEPARTMENT
INSERT INTO TASK_DEPARTMENT (deptname, floor, phone, manager_id) VALUES
('Management', 5, '34', NULL),
('Books', 1, '81', NULL),
('Clothes', 2, '24', 4),
('Equipment', 3, '57', 3),
('Furniture', 4, '14', 3),
('Navigation', 1, '41', NULL),
('Recreation', 2, '29', 4),
('Accounting', 5, '35', NULL),
('Purchasing', 5, '36', NULL),
('Personnel', 5, '37', NULL),
('Marketing', 5, '38', NULL);

-- Update manager assignments
UPDATE TASK_DEPARTMENT SET manager_id = 1 WHERE deptname = 'Management';
UPDATE TASK_DEPARTMENT SET manager_id = 2 WHERE deptname = 'Marketing';
UPDATE TASK_DEPARTMENT SET manager_id = 5 WHERE deptname = 'Accounting';
UPDATE TASK_DEPARTMENT SET manager_id = 7 WHERE deptname = 'Purchasing';
UPDATE TASK_DEPARTMENT SET manager_id = 9 WHERE deptname = 'Personnel';
UPDATE TASK_DEPARTMENT SET manager_id = 3 WHERE deptname = 'Navigation';
UPDATE TASK_DEPARTMENT SET manager_id = 4 WHERE deptname = 'Books';

-- Insert into EMP
INSERT INTO TASK_EMP (empno, empname, salary, deptname, bossno) VALUES
(1, 'Alice', 75000, 'Management', NULL),
(2, 'Ned', 45000, 'Marketing', 1),
(3, 'Andrew', 25000, 'Marketing', 2),
(4, 'Clare', 22000, 'Marketing', 2),
(5, 'Todd', 38000, 'Accounting', 1),
(6, 'Nancy', 22000, 'Accounting', 5),
(7, 'Brier', 43000, 'Purchasing', 1),
(8, 'Sarah', 56000, 'Purchasing', 7),
(9, 'Sophile', 35000, 'Personnel', 1),
(10, 'Sanjay', 15000, 'Navigation', 3),
(11, 'Rita', 15000, 'Books', 4),
(12, 'Gigi', 16000, 'Clothes', 4),
(13, 'Maggie', 11000, 'Clothes', 4),
(14, 'Paul', 15000, 'Equipment', 3),
(15, 'James', 15000, 'Equipment', 3),
(16, 'Pat', 15000, 'Furniture', 3),
(17, 'Mark', 15000, 'Recreation', 3);

-- Insert into ITEM
INSERT INTO TASK_ITEM (itemname, itemtype, itemcolor) VALUES
('Pocket Knife-Nile', 'E', 'Brown'),
('Pocket Knife-Avon', 'E', 'Brown'),
('Compass', 'N', NULL),
('Geo positioning system', 'N', NULL),
('Elephant Polo stick', 'R', 'Bamboo'),
('Camel Saddle', 'R', 'Brown'),
('Sextant', 'N', NULL),
('Map Measure', 'N', NULL),
('Boots-snake proof', 'C', 'Green'),
('Pith Helmet', 'C', 'Khaki'),
('Hat-polar Explorer', 'C', 'White'),
('Exploring in 10 Easy Lessons', 'B', NULL),
('Hammock', 'F', 'Khaki'),
('How to win Foreign Friends', 'B', NULL),
('Map case', 'E', 'Brown'),
('Safari Chair', 'F', 'Khaki'),
('Safari cooking kit', 'F', 'Khaki'),
('Stetson', 'C', 'Black'),
('Tent - 2 person', 'F', 'Khaki'),
('Tent -8 person', 'F', 'Khaki');

-- Insert into SALES
INSERT INTO TASK_SALES (salesno, salesqty, itemname, deptname) VALUES
(101, 2, 'Boots-snake proof', 'Clothes'),
(102, 1, 'Pith Helmet', 'Clothes'),
(103, 1, 'Sextant', 'Navigation'),
(104, 3, 'Hat-polar Explorer', 'Clothes'),
(105, 5, 'Pith Helmet', 'Equipment'),
(106, 2, 'Pocket Knife-Nile', 'Clothes'),
(107, 3, 'Pocket Knife-Nile', 'Recreation'),
(108, 1, 'Compass', 'Navigation'),
(109, 2, 'Geo positioning system', 'Navigation'),
(110, 5, 'Map Measure', 'Navigation'),
(111, 1, 'Geo positioning system', 'Books'),
(112, 1, 'Sextant', 'Books'),
(113, 3, 'Pocket Knife-Nile', 'Books'),
(114, 1, 'Pocket Knife-Nile', 'Navigation'),
(115, 1, 'Pocket Knife-Nile', 'Equipment'),
(116, 1, 'Sextant', 'Clothes'),
(117, 1, 'Sextant', 'Equipment'),
(118, 1, 'Sextant', 'Recreation'),
(119, 1, 'Sextant', 'Furniture'),
(120, 1, 'Pocket Knife-Nile', 'Furniture'),
(121, 1, 'Exploring in 10 Easy Lessons', 'Books'),
(122, 1, 'How to win Foreign Friends', 'Books'),
(123, 1, 'Compass', 'Books'),
(124, 1, 'Pith Helmet', 'Books'),
(125, 1, 'Elephant Polo stick', 'Recreation'),
(126, 1, 'Camel Saddle', 'Recreation');
