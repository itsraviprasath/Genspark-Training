CREATE DATABASE my_test_db;

CREATE USER test_user WITH PASSWORD 'test_password';

CREATE TABLE confidential_data (
    id SERIAL PRIMARY KEY,
    info TEXT
);

INSERT INTO confidential_data (info) VALUES ('Top Secret');

GRANT CONNECT ON DATABASE my_test_db TO test_user;

GRANT USAGE ON SCHEMA public TO test_user;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO test_user;

REVOKE SELECT ON confidential_data FROM test_user;