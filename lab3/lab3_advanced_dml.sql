-- Part A: Database and Table Setup
CREATE DATABASE advanced_lab;
\c advanced_lab

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    department VARCHAR(50),
    salary     INTEGER,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(50),
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);

-- Part B: Advanced INSERT Operations
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (100, 'Alice', 'Ivanova', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Bob', 'Petrov', 'HR', DEFAULT, '2021-03-15', DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('IT', 200000, 1),
       ('HR', 80000, 2),
       ('Sales', 150000, NULL);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Carol', 'Sidorova', 'Sales', 50000 * 1.1, CURRENT_DATE);

CREATE TEMP TABLE temp_employees (LIKE employees);
INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Dan', 'Smirnov', 'IT', 90000, '2018-06-01', 'Active'),
       ('Eve', 'Kim', 'IT', 65000, '2019-09-10', 'Active'),
       ('Frank', 'Lee', 'Sales', 45000, '2023-05-20', 'Active'),
       ('Grace', 'Nur', 'Sales', 70000, '2017-01-12', 'Inactive'),
       ('Hank', 'Omar', 'HR', 30000, '2023-07-01', 'Terminated'),
       ('Ivy', 'Bek', NULL, 35000, '2023-08-01', 'Active');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES ('Portal', 1, '2022-01-01', '2022-12-31', 60000),
       ('Hiring', 2, '2023-02-01', '2023-09-30', 20000),
       ('Campaign', 3, '2023-03-01', '2024-03-01', 90000);

-- Part C: Complex UPDATE Operations
UPDATE employees SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';

UPDATE departments d
SET budget = (SELECT AVG(e.salary) * 1.2
              FROM employees e
              WHERE e.department = d.dept_name)
WHERE EXISTS (SELECT 1 FROM employees e WHERE e.department = d.dept_name);

UPDATE employees
SET salary = salary * 1.15, status = 'Promoted'
WHERE department = 'Sales';

-- Part D: Advanced DELETE Operations
DELETE FROM employees WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (SELECT DISTINCT department FROM employees WHERE department IS NOT NULL);

DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

-- Part E: Operations with NULL Values
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Jack', 'Null', NULL, NULL, '2022-02-02');

UPDATE employees SET department = 'Unassigned' WHERE department IS NULL;

DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

-- Part F: RETURNING Clause Operations
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Kate', 'Wong', 'IT', 60000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees e
SET salary = e.salary + 5000
FROM employees old
WHERE old.emp_id = e.emp_id AND e.department = 'IT'
RETURNING e.emp_id, old.salary AS old_salary, e.salary AS new_salary;

DELETE FROM employees WHERE hire_date < '2020-01-01' RETURNING *;

-- Part G: Advanced DML Patterns
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Kate', 'Wong', 'IT', 60000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Kate' AND last_name = 'Wong'
);

UPDATE employees e
SET salary = CASE
    WHEN (SELECT d.budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN salary * 1.10
    ELSE salary * 1.05
END;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bulk1', 'A', 'IT', 50000, CURRENT_DATE),
       ('Bulk2', 'B', 'IT', 51000, CURRENT_DATE),
       ('Bulk3', 'C', 'IT', 52000, CURRENT_DATE),
       ('Bulk4', 'D', 'IT', 53000, CURRENT_DATE),
       ('Bulk5', 'E', 'IT', 54000, CURRENT_DATE);

UPDATE employees SET salary = salary * 1.10 WHERE last_name IN ('A', 'B', 'C', 'D', 'E');

CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);
INSERT INTO employee_archive SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';

UPDATE projects p
SET end_date = end_date + 30
WHERE budget > 50000
  AND (SELECT COUNT(*)
       FROM employees e
       JOIN departments d ON d.dept_name = e.department
       WHERE d.dept_id = p.dept_id) > 3;
