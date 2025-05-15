
-- TRANSACTIONS

-- 1) Transaction without SAVEPOINT
-- If any statement fails, the entire transaction is rolled back.

BEGIN;
-- Successful operations
UPDATE customer SET first_name = 'John' WHERE customer_id = 1;
UPDATE customer SET last_name = 'Doe' WHERE customer_id = 2;

-- Failing operation
UPDATE customer SET email = 'fail@example.com' WHERE customer_id = -1;

-- Since the last update fails, the following rollback undoes all previous updates.
ROLLBACK;

-- 2) READ COMMITTED isolation (default) — prevents dirty reads

-- Transaction A (not committed)
BEGIN;
UPDATE customer SET first_name = 'Alice' WHERE customer_id = 1;

-- Transaction B (concurrently)
-- Will NOT see Alice's updated name until committed
SELECT first_name FROM customer WHERE customer_id = 1;

ROLLBACK;


-- 3) Concurrent updates on the same row are serialized using row-level locks

-- Transaction 1
BEGIN;
UPDATE customer SET last_name = 'Brown' WHERE customer_id = 1;

-- Transaction 2 (waits for Transaction 1 to finish)
-- When T1 commits, T2 proceeds
-- UPDATE customer SET last_name = 'White' WHERE customer_id = 1;

COMMIT;


-- 4) ROLLBACK TO SAVEPOINT - only reverts changes after the savepoint

BEGIN;
UPDATE customer SET first_name = 'Sam' WHERE customer_id = 1;

SAVEPOINT sp1;
UPDATE customer SET last_name = 'Broken' WHERE customer_id = -1; -- error
ROLLBACK TO SAVEPOINT sp1;

INSERT INTO customer (store_id, first_name, last_name, email, address_id, activebool, active)
VALUES (1, 'Test', 'User', 'test@example.com', 1, TRUE, 1);

COMMIT;


-- 5) Phantom reads are prevented by SERIALIZABLE isolation level

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Ensures that a query re-run in the same transaction sees same result set

BEGIN;
SELECT * FROM customer WHERE last_name LIKE 'S%';
-- If another transaction inserts a row matching 'S%', this one will fail at commit
COMMIT;


-- 6) PostgreSQL does NOT support dirty reads

-- READ UNCOMMITTED is not available in PostgreSQL
-- Use READ COMMITTED or higher


-- 7) Autocommit mode (default): each statement is automatically committed

UPDATE customer SET first_name = 'Autocommit' WHERE customer_id = 1;

-- No explicit COMMIT needed


-- 8) Uncommitted changes are not visible from other sessions

-- Session 1
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
-- No COMMIT

-- Session 2
SELECT balance FROM accounts WHERE id = 1; -- sees old committed value

ROLLBACK;


-- Transaction block using DO + EXCEPTION handling

DO $$
BEGIN
    BEGIN
        UPDATE payment SET amount = amount + 10 WHERE payment_id = 17504;
        UPDATE payment SET amount = amount - 10 WHERE payment_id = 17506;
        RAISE NOTICE 'Transaction Successful';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Transaction Failed: %', SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;


-- Stored Procedure for amount transfer with error handling

CREATE OR REPLACE PROCEDURE sp_amount_transfer(
    sender_id INT,
    receiver_id INT,
    pamount INT
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE payment SET amount = amount - pamount WHERE payment_id = sender_id;
        UPDATE payment SET amount = amount + pamount WHERE payment_id = receiver_id;
        RAISE NOTICE 'Transaction succeeded.';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Transaction failed: %', SQLERRM;
    END;
END;
$$;

-- Execute procedure
CALL sp_amount_transfer(17504, 17506, 100);


-- Autocommit examples
UPDATE customer SET first_name = 'Smith' WHERE customer_id = 1;  -- success
UPDATE customer SET last_name = 'FailTest' WHERE customer_id = -1;  -- fails, partial effect

-- Manual transaction
BEGIN;
UPDATE customer SET first_name = 'Smith' WHERE customer_id = 1;
UPDATE customer SET last_name = 'FailTest' WHERE customer_id = -1;
ROLLBACK;

-- Using SAVEPOINT
BEGIN;
UPDATE customer SET first_name = 'Smith' WHERE customer_id = 1;

SAVEPOINT update_lastname;
UPDATE customer SET last_name = 'FailTest' WHERE customer_id = -1;
ROLLBACK TO update_lastname;

COMMIT;


-- Isolation Level: READ COMMITTED (Default)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Session 1
BEGIN;
UPDATE payment SET amount = amount - 50 WHERE payment_id = 17504;

-- Session 2
SELECT * FROM payment WHERE payment_id = 17504;

ROLLBACK;

-- Isolation Level: REPEATABLE READ

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Transaction 1
BEGIN;
SELECT amount FROM payment WHERE payment_id = 17504;

-- Transaction 2 (parallel)
BEGIN;
UPDATE payment SET amount = amount + 50 WHERE payment_id = 17504;
COMMIT;

-- Back to Transaction 1: still sees old value
COMMIT;