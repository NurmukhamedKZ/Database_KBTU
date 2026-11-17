-- Laboratory Work 8: SQL Indexes

-- Part 1: Database Setup
DROP VIEW IF EXISTS index_documentation;
DROP TABLE IF EXISTS projects, employees, departments CASCADE;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10, 2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12, 2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


-- Part 2: Creating Basic Indexes

-- Exercise 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
-- Answer: 2 indexes — employees_pkey (created automatically by PRIMARY KEY)
-- and emp_salary_idx (created by us).

-- Exercise 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;
-- Answer: PostgreSQL does NOT index foreign key columns automatically.
-- An index on the FK speeds up JOINs with the parent table, filtering by dept_id,
-- and ON DELETE/UPDATE checks on departments (otherwise each delete of a
-- department would require a full scan of employees).

-- Exercise 2.3
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Answer: departments_pkey, emp_dept_idx, emp_salary_idx, employees_pkey, projects_pkey.
-- Created automatically: departments_pkey, employees_pkey, projects_pkey (from PRIMARY KEY).


-- Part 3: Multicolumn Indexes

-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- Answer: Mostly no. A B-tree on (dept_id, salary) is sorted by dept_id first,
-- salary only within each dept_id. A filter on salary alone cannot use the
-- leftmost column, so the planner would have to scan the whole index
-- (only rarely cheaper than a Seq Scan). For salary-only filters use emp_salary_idx.

-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- Answer: The order of conditions in WHERE does not matter (the planner
-- reorders them), but the order of columns in the index does. An index is
-- most efficient when the leading column is compared by equality and the
-- range condition is on the following column: (dept_id, salary) fits
-- "dept_id = 102 AND salary > 50000" better than (salary, dept_id),
-- because with salary first the range covers many entries and dept_id
-- can only be checked as a filter inside that range.


-- Part 4: Unique Indexes

-- Exercise 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- This should fail with a unique violation error
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- Answer:
-- ERROR:  duplicate key value violates unique constraint "emp_email_unique_idx"
-- DETAIL:  Key (email)=(john.smith@company.com) already exists.

-- Exercise 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
-- Answer: Yes. PostgreSQL automatically created the unique index
-- employees_phone_key:
-- CREATE UNIQUE INDEX employees_phone_key ON public.employees USING btree (phone)
-- Type: B-tree (UNIQUE).


-- Part 5: Indexes and Sorting

-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
-- Answer: The index stores the rows already sorted by salary descending,
-- so PostgreSQL can read the index in order and skip the separate Sort step.
-- Especially useful with ORDER BY ... LIMIT N (top-N queries).
-- (A plain B-tree can also be read backwards; DESC matters most for
-- mixed-order multicolumn sorts like ORDER BY a ASC, b DESC.)

-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- Part 6: Indexes on Expressions

-- Exercise 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- Answer: Without it PostgreSQL does a Seq Scan: reads every row, computes
-- LOWER(emp_name) for each and compares. An ordinary index on emp_name
-- does not help, because the query compares LOWER(emp_name), not emp_name.

-- Exercise 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- Part 7: Managing Indexes

-- Exercise 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;
-- Answer: Every index slows down INSERT/UPDATE/DELETE (it must be updated too),
-- takes disk space and memory, and adds work for VACUUM. An index should be
-- dropped when it is unused (idx_scan = 0 in pg_stat_user_indexes),
-- duplicates another index, or was replaced by a better one.

-- Exercise 7.3
REINDEX INDEX employees_salary_index;


-- Part 8: Practical Scenarios

-- Exercise 8.1
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
-- JOIN: emp_dept_idx (already created); ORDER BY: emp_salary_desc_idx (already created)

SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Exercise 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
-- Answer: A partial index contains only the rows matching its WHERE, so it is
-- smaller, faster to scan, fits in memory better, and is cheaper to maintain
-- (rows outside the condition don't touch it on INSERT/UPDATE).
-- It is used only by queries whose condition implies the index predicate.

-- Exercise 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
-- Answer: "Seq Scan on employees ... Filter: (salary > 52000)".
-- The table has only 5 rows (1 page), so reading it sequentially is cheaper
-- than going through an index — the planner chooses by estimated cost.
-- Indexes pay off on large tables with selective conditions. To see the index
-- used on this small table: SET enable_seqscan = off; and repeat EXPLAIN.
SET enable_seqscan = off;
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
RESET enable_seqscan;


-- Part 9: Index Types Comparison

-- Exercise 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';
-- Answer: HASH supports only equality (=). Use it for columns searched only
-- by exact match, with long values (e.g. long strings/URLs, hash index stores
-- a 4-byte hash, so it can be smaller). For ranges (<, >, BETWEEN), ORDER BY,
-- LIKE 'abc%', UNIQUE or multicolumn indexes you need B-tree, which is why
-- B-tree is usually the default choice.

-- Exercise 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';  -- both can be used
SELECT * FROM projects WHERE proj_name > 'Database';          -- only B-tree


-- Part 10: Cleanup and Best Practices

-- Exercise 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Answer: The hash indexes are the largest (dept_name_hash_idx, proj_name_hash_idx
-- ~32 kB vs 16 kB for each B-tree). A hash index is created with pre-allocated
-- buckets (meta page + bitmap + several bucket pages) even for a few rows, while
-- a tiny B-tree is just a meta page + one leaf page. On large tables B-tree
-- size grows with the indexed values instead.

-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;  -- duplicate of proj_name_btree_idx
-- Also redundant: emp_salary_desc_idx duplicates employees_salary_index
-- (a B-tree can be scanned backwards for ORDER BY salary DESC).

-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;


-- Summary Questions
-- 1. B-tree.
-- 2. Columns often used in WHERE; foreign key / JOIN columns;
--    columns used in ORDER BY (and columns that must be UNIQUE).
-- 3. Small tables (Seq Scan is cheaper anyway); columns with low selectivity
--    (e.g. boolean/gender) or tables with very frequent writes and rare reads.
-- 4. Indexes are updated automatically together with the table: INSERT adds
--    entries, DELETE marks them dead (removed by VACUUM), UPDATE adds a new
--    entry (unless it is a HOT update). This makes writes slower, and indexes
--    can bloat over time (fixed by REINDEX).
-- 5. EXPLAIN (plan) or EXPLAIN ANALYZE (plan + real execution) — look for
--    "Index Scan" / "Index Only Scan" / "Bitmap Index Scan" vs "Seq Scan".
--    Usage statistics: pg_stat_user_indexes (idx_scan).


-- Additional Challenges (Optional)

-- 1. Employees hired in a specific month
-- (cast to timestamp: DATE_TRUNC on a date goes through timestamptz,
--  which is not IMMUTABLE and cannot be used in an index)
CREATE INDEX emp_hire_month_idx ON employees(DATE_TRUNC('month', hire_date::timestamp));
SELECT emp_name, hire_date FROM employees
WHERE DATE_TRUNC('month', hire_date::timestamp) = '2020-01-01';

-- 2. Composite unique index on dept_id and email
CREATE UNIQUE INDEX emp_dept_email_unique_idx ON employees(dept_id, email);

-- 3. EXPLAIN ANALYZE with and without index (on a bigger table)
CREATE TABLE big_employees AS
SELECT g AS emp_id, 'Emp ' || g AS emp_name, (random() * 100000)::INT AS salary
FROM generate_series(1, 100000) g;
ANALYZE big_employees;

EXPLAIN ANALYZE SELECT * FROM big_employees WHERE salary = 50000;  -- Seq Scan
CREATE INDEX big_emp_salary_idx ON big_employees(salary);
EXPLAIN ANALYZE SELECT * FROM big_employees WHERE salary = 50000;  -- Bitmap/Index Scan, much faster
DROP TABLE big_employees;

-- 4. Covering index (Index Only Scan without touching the table)
CREATE INDEX emp_dept_covering_idx ON employees(dept_id) INCLUDE (emp_name, salary);
VACUUM employees;  -- update visibility map so Index Only Scan is possible
SET enable_seqscan = off;
EXPLAIN SELECT emp_name, salary FROM employees WHERE dept_id = 101;
RESET enable_seqscan;


-- Reflection
-- Indexes are worth creating for columns that are frequently filtered, joined
-- or sorted on, especially in large tables and with selective conditions.
-- They are not free: each index slows down writes and takes space, and on
-- small tables the planner ignores them. So index what queries actually need,
-- verify with EXPLAIN / EXPLAIN ANALYZE, and drop unused or duplicate indexes.
