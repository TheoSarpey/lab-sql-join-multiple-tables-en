-- ============================================================
-- LAB: SQL JOINS ON MULTIPLE TABLES
-- Database: sqlite-sakila.db
-- ============================================================
-- All queries below are written for SQLite / DB Browser for SQLite.
-- ============================================================


-- ============================================================
-- CHALLENGE 1
-- Display each store's STORE ID, CITY, and COUNTRY.
-- ============================================================

SELECT
    s.store_id AS "STORE ID",
    ci.city AS "CITY",
    co.country AS "COUNTRY"
FROM store AS s
JOIN address AS a
    ON s.address_id = a.address_id
JOIN city AS ci
    ON a.city_id = ci.city_id
JOIN country AS co
    ON ci.country_id = co.country_id
ORDER BY
    s.store_id;


-- ============================================================
-- CHALLENGE 2
-- Display how much business, in dollars, each store brought in.
--
-- Payments are linked to staff, and each staff member belongs
-- to a store. COALESCE protects against a store having no
-- recorded payments.
-- ============================================================

SELECT
    s.store_id AS "STORE ID",
    ROUND(COALESCE(SUM(p.amount), 0), 2) AS "TOTAL BUSINESS ($)"
FROM store AS s
LEFT JOIN staff AS st
    ON s.store_id = st.store_id
LEFT JOIN payment AS p
    ON st.staff_id = p.staff_id
GROUP BY
    s.store_id
ORDER BY
    s.store_id;


-- ============================================================
-- CHALLENGE 3
-- What is the average running time of films by category?
--
-- The result is ordered from the longest average running time
-- to the shortest.
-- ============================================================

SELECT
    c.name AS "CATEGORY",
    ROUND(AVG(f.length), 2) AS "AVERAGE RUNNING TIME (MINUTES)"
FROM category AS c
JOIN film_category AS fc
    ON c.category_id = fc.category_id
JOIN film AS f
    ON fc.film_id = f.film_id
GROUP BY
    c.category_id,
    c.name
ORDER BY
    AVG(f.length) DESC;


-- ============================================================
-- CHALLENGE 4
-- Which film categories are longest?
--
-- This query ranks categories by their average film running
-- time, with the longest category appearing first.
-- ============================================================

SELECT
    c.name AS "CATEGORY",
    ROUND(AVG(f.length), 2) AS "AVERAGE RUNNING TIME (MINUTES)"
FROM category AS c
JOIN film_category AS fc
    ON c.category_id = fc.category_id
JOIN film AS f
    ON fc.film_id = f.film_id
GROUP BY
    c.category_id,
    c.name
ORDER BY
    AVG(f.length) DESC;


-- ============================================================
-- CHALLENGE 5
-- Display the most frequently rented movies in descending order.
--
-- A film can have multiple inventory copies, so the query joins
-- film -> inventory -> rental and counts rental transactions.
-- ============================================================

SELECT
    f.title AS "FILM",
    COUNT(r.rental_id) AS "RENTAL COUNT"
FROM film AS f
JOIN inventory AS i
    ON f.film_id = i.film_id
JOIN rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id,
    f.title
ORDER BY
    COUNT(r.rental_id) DESC,
    f.title;


-- ============================================================
-- CHALLENGE 6
-- List the top five genres in gross revenue in descending order.
--
-- Revenue is calculated from payment.amount and connected to
-- film categories through:
-- category -> film_category -> film/inventory -> rental -> payment
-- ============================================================

SELECT
    c.name AS "GENRE",
    ROUND(SUM(p.amount), 2) AS "GROSS REVENUE ($)"
FROM category AS c
JOIN film_category AS fc
    ON c.category_id = fc.category_id
JOIN inventory AS i
    ON fc.film_id = i.film_id
JOIN rental AS r
    ON i.inventory_id = r.inventory_id
JOIN payment AS p
    ON r.rental_id = p.rental_id
GROUP BY
    c.category_id,
    c.name
ORDER BY
    SUM(p.amount) DESC
LIMIT 5;


-- ============================================================
-- CHALLENGE 7
-- Is "Academy Dinosaur" available for rent from Store 1?
--
-- An inventory copy is considered available when:
--   1. It belongs to Store 1.
--   2. It is a copy of "Academy Dinosaur".
--   3. It does not currently have an unreturned rental.
--
-- The query returns YES or NO.
-- ============================================================

SELECT
    CASE
        WHEN COUNT(i.inventory_id) > 0 THEN 'YES'
        ELSE 'NO'
    END AS "AVAILABLE AT STORE 1"
FROM film AS f
JOIN inventory AS i
    ON f.film_id = i.film_id
LEFT JOIN rental AS r
    ON i.inventory_id = r.inventory_id
    AND r.return_date IS NULL
WHERE
    f.title = 'Academy Dinosaur'
    AND i.store_id = 1
    AND r.rental_id IS NULL;


-- ============================================================
-- END OF LAB
-- ============================================================
