-- 1. Book titles
SELECT title AS Book_Name 
FROM titles;

-- 2. Titles by publisher 1389
SELECT title 
FROM titles 
WHERE pub_id = 1389;

-- 3. Books priced between 10 and 15
SELECT * 
FROM titles 
WHERE price BETWEEN 10 AND 15;

-- 4. Books with no price
SELECT * 
FROM titles 
WHERE price IS NULL;

-- 5. Titles starting with 'The'
SELECT title 
FROM titles 
WHERE title LIKE 'The%';

-- 6. Titles without 'v'
SELECT title 
FROM titles 
WHERE title NOT LIKE '%v%';

-- 7. Books sorted by royalty
SELECT * 
FROM titles 
ORDER BY royalty;

-- 8. Sort by publisher (desc), type (asc), price (desc)
SELECT * 
FROM titles
ORDER BY pub_id DESC, type ASC, price DESC;

-- 9. Average price per type
SELECT type, AVG(price) AS Avg_Price 
FROM titles
GROUP BY type;

-- 10. Unique types
SELECT DISTINCT type 
FROM titles;

-- 11. Top 2 costliest books
SELECT TOP 2 title, price 
FROM titles 
ORDER BY price DESC;

-- 12. Business books with price < 20 and advance > 7000
SELECT title 
FROM titles 
WHERE type = 'business' AND price < 20 AND advance > 7000;

-- 13. Publishers with >2 books priced 15–25 and 'It' in title
SELECT pub_id, COUNT(*) AS book_count 
FROM titles
WHERE price BETWEEN 15 AND 25 AND title LIKE '%It%'
GROUP BY pub_id
HAVING COUNT(*) > 2
ORDER BY book_count;

-- 14. Authors from CA
SELECT au_fname, au_lname 
FROM authors 
WHERE state = 'CA';

-- 15. Count of authors by state
SELECT state, COUNT(*) AS Count_Of_Author 
FROM authors 
GROUP BY state;
