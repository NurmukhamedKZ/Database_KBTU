DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
  (10, 'Central Park', 'Almaty',   4),
  (20, 'Riverside',    'Almaty',   3),
  (30, 'Expo Gate',    'Astana',   5),
  (40, 'Old Town',     'Shymkent', 2),
  (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
  (101, 'City Cruiser', 10,  4.50),
  (102, 'City Cruiser', 10,  4.50),
  (103, 'Mountain X',   20,  7.00),
  (104, 'Mountain X',   30,  7.00),
  (105, 'Road Sprint',  30,  9.25),
  (106, 'Folding Mini', 40,  3.75),
  (107, 'Cargo Hauler', 20, 12.00),
  (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
  (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
  (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
  (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
  (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
  (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
  (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
  ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
  ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
  ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
  ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
  ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
  ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
  ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
  ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
  ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
  (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
  (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
  (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
  (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
  (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
  (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
  (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
  (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
  (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
  (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
  (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
  (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
  (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes)    AS bikes,
       (SELECT COUNT(*) FROM members) AS members,
       (SELECT COUNT(*) FROM rentals) AS rentals;

CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT) RETURNS INT AS $$
DECLARE
    v_start DATE;
    v_end   DATE;
    v_days  INT;
BEGIN
    SELECT start_date, end_date INTO v_start, v_end
    FROM rentals WHERE rental_id = p_rental_id;
    v_days := v_end - v_start;
    RETURN v_days;
END; $$ LANGUAGE plpgsql;

SELECT rental_days(2);

SELECT rental_days(11);

SELECT rental_days(19);

SELECT rental_days(999);

CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT) RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM rentals WHERE member_id = p_member_id;
    RETURN v_count;
END; $$ LANGUAGE plpgsql;

SELECT member_rental_count(1);

SELECT member_rental_count(5);

SELECT member_rental_count(6);

SELECT member_rental_count(99);

CREATE OR REPLACE FUNCTION station_city(p_station_id INT) RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR(40);
BEGIN
    SELECT city INTO v_city
    FROM stations WHERE station_id = p_station_id;
    RETURN v_city;
END; $$ LANGUAGE plpgsql;

SELECT station_city(30);

SELECT station_city(77);

SELECT r.rental_id,
       r.member_id,
       rental_days(r.rental_id) AS days
FROM rentals r
WHERE rental_days(r.rental_id) > 4
ORDER BY days DESC, r.rental_id;

CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100.0), 2);
END; $$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15);

CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE)
AS $$
BEGIN
    SELECT COUNT(*), COALESCE(SUM(fee), 0), MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals WHERE member_id = p_member_id;
END; $$ LANGUAGE plpgsql;

SELECT member_stats(3);

SELECT * FROM member_stats(3);

SELECT * FROM member_stats(6);

CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC) AS $$
BEGIN
    p_fee := p_fee + 5.00;
END; $$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee) AS fee_plus_late FROM rentals WHERE rental_id = 1;

CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC)
AS $$
BEGIN
    SELECT SUM(p_fees[i]), ROUND(AVG(p_fees[i]), 2), MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) g(i);
END; $$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);

SELECT * FROM fee_summary(VARIADIC ARRAY[]::NUMERIC[]);

SELECT * FROM fee_summary();

CREATE OR REPLACE FUNCTION total_fees(p_member_id INT) RETURNS NUMERIC AS $$
BEGIN
    RETURN (SELECT COALESCE(SUM(fee), 0)
            FROM rentals WHERE member_id = p_member_id);
END; $$ LANGUAGE plpgsql;

SELECT total_fees(1);

SELECT total_fees(6);

CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (SELECT COALESCE(SUM(fee), 0)
            FROM rentals
            WHERE member_id = p_member_id AND start_date >= p_from_date);
END; $$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');

SELECT total_fees(1, DATE '2025-01-01');

\df total_fees

CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01')
RETURNS NUMERIC AS $$
BEGIN
    RETURN (SELECT COALESCE(SUM(fee), 0)
            FROM rentals
            WHERE member_id = p_member_id AND start_date >= p_from_date);
END; $$ LANGUAGE plpgsql;

SELECT total_fees(1);

DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1);

CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR) RETURNS NUMERIC AS $$
BEGIN
    RETURN (SELECT COALESCE(SUM(r.fee), 0)
            FROM members m
            LEFT JOIN rentals r ON r.member_id = m.member_id
            WHERE m.full_name = p_member_name);
END; $$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova');

SELECT total_fees(1);

CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (found_id INT, found_model VARCHAR, found_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR, b.daily_rate
    FROM bikes b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');

SELECT * FROM find_bikes('%Mini');

SELECT find_bikes('%road%');

CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (rental_id INT, bike_model VARCHAR, station_name VARCHAR,
               duration_days INT, fee NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id,
           b.model::VARCHAR,
           s.station_name::VARCHAR,
           (r.end_date - r.start_date)::INT,
           r.fee
    FROM rentals r
    JOIN bikes b ON b.bike_id = r.bike_id
    JOIN stations s ON s.station_id = b.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END; $$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

CREATE OR REPLACE FUNCTION bike_list_bad(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;

SELECT * FROM bike_list_bad(10);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (b_id INT, b_model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model
                 FROM bikes b WHERE b.station_id = p_station_id
                 ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

DROP FUNCTION bike_list(INT);
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model
                 FROM bikes b WHERE b.station_id = p_station_id
                 ORDER BY b.bike_id;
END; $$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

CREATE OR REPLACE FUNCTION station_board_bad(p_city VARCHAR)
RETURNS TABLE (s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name::VARCHAR,
           COUNT(b.bike_id),
           (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity;
END; $$ LANGUAGE plpgsql;

SELECT * FROM station_board_bad('Almaty');

CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name::VARCHAR,
           COUNT(b.bike_id)::INT,
           (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END; $$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');

SELECT * FROM station_board('Astana');

SELECT * FROM station_board('Shymkent');

DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report $$;

DO $$
<<outer_block>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT SUM(fee) INTO fee_total FROM rentals;
    RAISE NOTICE 'outer before subblock: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total
        FROM rentals WHERE start_date >= DATE '2025-01-01';
        RAISE NOTICE 'subblock fee_total:    %', fee_total;
        RAISE NOTICE 'outer from subblock:   %', outer_block.fee_total;
    END;

    RAISE NOTICE 'outer after subblock:  %', fee_total;
END outer_block $$;

DO $$
DECLARE
    v_shared NUMERIC;
BEGIN
    DECLARE
        v_unused NUMERIC;
    BEGIN
        v_shared := 10;
        RAISE NOTICE 'first subblock sees %', v_shared;
    END;
    DECLARE
        v_unused2 NUMERIC;
    BEGIN
        RAISE NOTICE 'second subblock sees %', v_shared;
    END;
END $$;

CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC)
AS $$
BEGIN
    SELECT COALESCE(SUM(fee) FILTER (WHERE start_date <  p_from_date), 0),
           COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date), 0)
    INTO before_total, after_total
    FROM rentals;
END; $$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');

CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC)
AS $$
BEGIN
    SELECT COUNT(b.bike_id)::INT,
           CASE WHEN s.capacity = 0 THEN NULL
                ELSE ROUND(100.0 * COUNT(b.bike_id) / s.capacity, 1)
           END
    INTO bikes_parked, capacity_pct
    FROM stations s LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.station_id, s.capacity;
END; $$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l;

CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (member_name VARCHAR, rental_cnt INT, total_spent NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name::VARCHAR,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee), 0) DESC, m.member_id
    LIMIT p_limit;
END; $$ LANGUAGE plpgsql;

SELECT * FROM top_members();

SELECT * FROM top_members(6);

CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (member_name VARCHAR, bike_model VARCHAR, days INT,
               amount NUMERIC, status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name::VARCHAR,
           b.model::VARCHAR,
           (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
           ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date)
                 * b.daily_rate, 2),
           CASE WHEN r.end_date IS NULL THEN 'OPEN'::VARCHAR
                ELSE 'CLOSED'::VARCHAR END
    FROM rentals r
    JOIN members m ON m.member_id = r.member_id
    JOIN bikes b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id;
END; $$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);

SELECT * FROM rental_invoice(19);

CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    OUT member_cnt INT,
    OUT rental_cnt INT,
    OUT total_revenue NUMERIC)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    INTO member_cnt, rental_cnt, total_revenue
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.city = p_city;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE,
    OUT member_cnt INT,
    OUT rental_cnt INT,
    OUT total_revenue NUMERIC)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    INTO member_cnt, rental_cnt, total_revenue
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
                       AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END; $$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');

SELECT * FROM city_report('Almaty', DATE '2025-01-01');

CREATE OR REPLACE FUNCTION busiest_station(
    p_from_date DATE DEFAULT DATE '2024-01-01')
RETURNS TABLE (station_id INT, station_name VARCHAR, total_days INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_id,
           s.station_name::VARCHAR,
           SUM(r.end_date - r.start_date)::INT AS total_days
    FROM stations s
    JOIN bikes b ON b.station_id = s.station_id
    JOIN rentals r ON r.bike_id = b.bike_id
    WHERE r.start_date >= p_from_date AND r.end_date IS NOT NULL
    GROUP BY s.station_id, s.station_name
    ORDER BY total_days DESC, s.station_id
    LIMIT 1;
END; $$ LANGUAGE plpgsql;

SELECT * FROM busiest_station();

DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT m.full_name, COUNT(r.rental_id) AS cnt,
               COALESCE(SUM(r.fee), 0) AS total
        FROM members m
        LEFT JOIN rentals r ON r.member_id = m.member_id
        GROUP BY m.member_id, m.full_name
        ORDER BY m.member_id
    LOOP
        RAISE NOTICE '%: % rentals, % spent', rec.full_name, rec.cnt, rec.total;
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION rental_days_strict(p_rental_id INT) RETURNS INT AS $$
DECLARE
    v_start DATE;
    v_end   DATE;
BEGIN
    SELECT start_date, end_date INTO v_start, v_end
    FROM rentals WHERE rental_id = p_rental_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'rental % does not exist', p_rental_id;
    END IF;
    RETURN v_end - v_start;
END; $$ LANGUAGE plpgsql;

SELECT rental_days_strict(2);

SELECT rental_days_strict(999);

CREATE OR REPLACE FUNCTION fee_report(p_id INT) RETURNS NUMERIC AS $$
BEGIN RETURN (SELECT COALESCE(SUM(fee),0) FROM rentals WHERE member_id = p_id); END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION fee_report(p_name VARCHAR) RETURNS NUMERIC AS $$
BEGIN RETURN (SELECT COALESCE(SUM(r.fee),0) FROM members m
              LEFT JOIN rentals r ON r.member_id = m.member_id
              WHERE m.full_name = p_name); END;
$$ LANGUAGE plpgsql;
SELECT fee_report(1);

SELECT fee_report('Aisha Nurlanova');

CREATE OR REPLACE FUNCTION fee_report(p_name TEXT) RETURNS NUMERIC AS $$
BEGIN RETURN -1; END;
$$ LANGUAGE plpgsql;
SELECT fee_report('Aisha Nurlanova');

SELECT fee_report('Aisha Nurlanova'::VARCHAR);

CREATE OR REPLACE PROCEDURE close_rental(
    p_rental_id INT,
    p_end_date DATE DEFAULT CURRENT_DATE)
AS $$
DECLARE
    v_daily NUMERIC(8,2);
    v_start DATE;
BEGIN
    SELECT r.start_date, b.daily_rate INTO v_start, v_daily
    FROM rentals r JOIN bikes b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id AND r.end_date IS NULL;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'rental % is not open', p_rental_id;
    END IF;
    UPDATE rentals
       SET end_date = p_end_date,
           fee = ROUND((p_end_date - v_start) * v_daily, 2)
     WHERE rental_id = p_rental_id;
    RAISE NOTICE 'rental % closed, fee %', p_rental_id,
                 ROUND((p_end_date - v_start) * v_daily, 2);
END; $$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(19);

CALL close_rental(19, DATE '2025-10-20');

SELECT * FROM rental_invoice(19);
