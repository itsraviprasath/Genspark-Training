-- ======================================
--         CURSOR-BASED OPERATIONS
-- ======================================

-- 1) Print titles of films longer than 120 minutes
DO $$
DECLARE 
    film_rec RECORD;
    film_cursor CURSOR FOR SELECT title, length FROM film;
BEGIN
    OPEN film_cursor;
    LOOP
        FETCH film_cursor INTO film_rec;
        EXIT WHEN NOT FOUND;
        IF film_rec.length > 120 THEN
            RAISE NOTICE 'Long Film: % (% minutes)', film_rec.title, film_rec.length;
        END IF;
    END LOOP;
    CLOSE film_cursor;
END $$;


-- 2) Count how many rentals each customer made
DO $$
DECLARE 
    customer_rec RECORD;
    rental_count INT;
    customer_cursor CURSOR FOR
        SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name FROM customer;
BEGIN
    OPEN customer_cursor;
    LOOP
        FETCH customer_cursor INTO customer_rec;
        EXIT WHEN NOT FOUND;

        SELECT COUNT(*) INTO rental_count FROM rental
        WHERE customer_id = customer_rec.customer_id;

        RAISE NOTICE 'Customer: %, Rentals: %', customer_rec.customer_name, rental_count;
    END LOOP;
    CLOSE customer_cursor;
END $$;


-- 3) Increase rental rate by $1 for films with less than 5 rentals
DO $$
DECLARE 
    film_rec RECORD;
    film_cursor CURSOR FOR
        SELECT f.film_id, f.title, f.rental_rate, COUNT(*) AS rental_count
        FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON r.inventory_id = i.inventory_id
        GROUP BY f.film_id, f.title, f.rental_rate;
BEGIN
    OPEN film_cursor;
    LOOP
        FETCH film_cursor INTO film_rec;
        EXIT WHEN NOT FOUND;

        IF film_rec.rental_count < 5 THEN
            UPDATE film
            SET rental_rate = film_rec.rental_rate + 1
            WHERE film_id = film_rec.film_id;

            RAISE NOTICE 'Updated "%": % rentals', film_rec.title, film_rec.rental_count;
        END IF;
    END LOOP;
    CLOSE film_cursor;
END $$;


-- 4) Function: Get film titles by category name
CREATE OR REPLACE FUNCTION fnGetFilmByTitle(category_name VARCHAR)
RETURNS TABLE (title VARCHAR, category_name VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE 
    film_rec RECORD;
    film_cursor CURSOR FOR
        SELECT f.title, c.name AS category_name
        FROM film f
        JOIN film_category fc ON f.film_id = fc.film_id
        JOIN category c ON fc.category_id = c.category_id
        WHERE c.name = category_name;
BEGIN
    OPEN film_cursor;
    LOOP
        FETCH film_cursor INTO film_rec;
        EXIT WHEN NOT FOUND;
        title := film_rec.title;
        category_name := film_rec.category_name;
        RETURN NEXT;
    END LOOP;
    CLOSE film_cursor;
END;
$$;



-- 5) Count distinct films available in each store
DO $$
DECLARE
    store_rec RECORD;
    store_cursor CURSOR FOR
        SELECT store_id, COUNT(DISTINCT film_id) AS film_count
        FROM inventory
        GROUP BY store_id;
BEGIN
    OPEN store_cursor;
    LOOP
        FETCH store_cursor INTO store_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Store ID: %, Distinct Films: %', store_rec.store_id, store_rec.film_count;
    END LOOP;
    CLOSE store_cursor;
END $$;


-- ======================================
--         TRIGGER-BASED OPERATIONS
-- ======================================

-- 1) Log whenever a new customer is inserted
CREATE TABLE IF NOT EXISTS customer_logs (
    audit_id SERIAL PRIMARY KEY,
    customer_id INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_customer_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO customer_logs (customer_id, message)
    VALUES (NEW.customer_id, 'Customer inserted successfully');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_new_customer
AFTER INSERT ON customer
FOR EACH ROW
EXECUTE FUNCTION log_customer_insert();


-- 2) Prevent inserting a payment with amount <= 0
CREATE OR REPLACE FUNCTION fn_prevent_zero_payment()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Payment amount must be greater than 0';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_prevent_zero_payment
BEFORE INSERT ON payment
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_zero_payment();


-- 3) Automatically update 'last_update' before changes to film
CREATE OR REPLACE FUNCTION fn_update_film_last_modified()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    NEW.last_update := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_film_last_modified
BEFORE INSERT OR UPDATE ON film
FOR EACH ROW
EXECUTE FUNCTION fn_update_film_last_modified();


-- 4) Log insert/delete operations on inventory table
CREATE TABLE IF NOT EXISTS inventory_logs (
    log_id SERIAL PRIMARY KEY,
    inventory_id INT,
    message TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_log_inventory_changes()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO inventory_logs (inventory_id, message)
        VALUES (NEW.inventory_id, 'Inserted Successfully');
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO inventory_logs (inventory_id, message)
        VALUES (OLD.inventory_id, 'Deleted Successfully');
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_inventory_changes
AFTER INSERT OR DELETE ON inventory
FOR EACH ROW
EXECUTE FUNCTION fn_log_inventory_changes();


-- 5) Prevent rentals for customers owing more than $100
CREATE OR REPLACE FUNCTION fn_check_customer_pending()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    total_amount NUMERIC;
BEGIN
    SELECT SUM(amount) INTO total_amount FROM payment
    WHERE customer_id = NEW.customer_id;

    IF total_amount < 100 THEN
        RAISE EXCEPTION 'Rental not allowed. Customer(%) owes more than $100.', NEW.customer_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_customer_pending
BEFORE INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION fn_check_customer_pending();


-- ======================================
--         TRANSACTION-BASED OPERATIONS
-- ======================================

-- 1) Insert a customer and a rental atomically
BEGIN;
WITH new_customer AS (
    INSERT INTO customer(store_id, first_name, last_name, email, address_id, activebool, create_date)
    VALUES (1, 'Transaction', 'Test', 'john.doe@example.com', 1, TRUE, NOW())
    RETURNING customer_id
)
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
SELECT NOW(), 100, customer_id, 1 FROM new_customer;
COMMIT;


-- 2) Simulate failure and rollback
DO $$
BEGIN
    BEGIN
        UPDATE film SET rental_rate = rental_rate + 1 WHERE film_id = 1;
        INSERT INTO inventory (film_id, store_id) VALUES (-1, -1);
        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Transaction failed: %', SQLERRM;
        ROLLBACK;
    END;
END $$;


-- 3) Transfer inventory from store 1 to store 2
DO $$
BEGIN
    BEGIN
        UPDATE inventory
        SET store_id = 2
        WHERE inventory_id = 123 AND store_id = 1;
        RAISE NOTICE 'Inventory transferred successfully.';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Transfer failed: %', SQLERRM;
    END;
END $$;


-- 4) Use SAVEPOINT and ROLLBACK TO SAVEPOINT
BEGIN;
    UPDATE payment SET amount = amount + 1 WHERE payment_id = 17503;
    SAVEPOINT before_second_update;
    UPDATE payment SET amount = amount + 10 WHERE payment_id = 17504;
    ROLLBACK TO SAVEPOINT before_second_update;
    UPDATE payment SET amount = amount + 5 WHERE payment_id = 17505;
COMMIT;
