# CSE1301 Databases — Midterm Exam Preparation Tasks

**Course:** CSE1301 Databases **Term:** Fall 2026 **Topics Covered:** Weeks 1-7

> Расшифровано с 49 фото слайдов (2026-10-20). Ответы, видимые на слайдах, даны в блоках «Answers».
> Пометка ⚠️ — фрагмент не попал в кадр.

---

## SECTION A: Introduction to Databases (Week 1)

### Task 1: Fill in the Blanks

1. A ________ is a collection of interrelated data and a set of programs to access that data.
2. The three levels of data abstraction are: ________, ________, and ________.
3. ________ is a language used to specify the database schema, while ________ is used to express database queries and updates.
4. The component of a DBMS that is responsible for storage and retrieval of data is called the ________.
5. Data ________ means that different users can have different views of the same data.

### Task 2: Match the Terms

Match each term with its correct definition:

| Term | Definition |
|---|---|
| A. Data Redundancy | 1. The property that ensures database remains in a consistent state |
| B. Data Integrity | 2. Duplication of data in multiple places |
| C. Data Isolation | 3. Protection of data from unauthorized access |
| D. Data Security | 4. Difficulty in accessing data due to scattered storage |

⚠️ Остальная часть таблицы и ответы не попали в кадр.

---

## SECTION B (Week 2) — Tasks 3–5

⚠️ На фото этого раздела нет.

---

## SECTION C: DDL & DML Foundations (Week 3)

### Task 6: Complete the CREATE TABLE Statement

```sql
CREATE TABLE courses (
    course_id ______ PRIMARY KEY,
    course_name VARCHAR(100) ______,
    credits ______ CHECK (______),
    department_id INTEGER ______ departments(dept_id)
);
```

Fill in the blanks to:
- Make course_id auto-incrementing
- Ensure course_name cannot be NULL
- Credits must be between 1 and 6
- Reference the departments table

**Answers:** SERIAL, NOT NULL, INTEGER, credits BETWEEN 1 AND 6, REFERENCES

### Task 7: Write the DML Statements

Given the table:

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    stock INTEGER DEFAULT 0
);
```

Complete the following statements:

1. Insert a new product "Laptop" with price 999.99 and stock 50:
```sql
INSERT INTO products (__________)
VALUES (__________);
```

2. Update the price of all products to increase by 10%:
```sql
UPDATE products
SET price = __________;
```

3. Delete all products where stock is 0:
```sql
DELETE FROM products
WHERE __________;
```

⚠️ Ответы не попали в кадр.

---

## SECTION D: SELECT, Filtering & Ordering (Week 4)

### Task 8: Complete the SELECT Queries

Given tables:
```
employees(emp_id, emp_name, department, salary, hire_date)
```

1. Select all employees from 'IT' department earning more than 50000:
```sql
SELECT * FROM employees
WHERE ______ AND ______;
```

2. Select employee names and salaries, ordered by salary (highest first):
```sql
SELECT emp_name, salary
FROM employees
ORDER BY ______;
```

3. Select the first 5 highest-paid employees:
```sql
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC
______;
```

4. Select employees whose names start with 'A':
```sql
SELECT * FROM employees
WHERE emp_name ______ '______';
```

**Answers:**
1. department = 'IT', salary > 50000
2. salary DESC
3. LIMIT 5
4. LIKE, A%

### Task 9: Fix the Query

The following queries contain errors. Find and fix them:

1. **Error Query:**
```sql
SELECT emp_name salary FROM employees WHERE department = IT;
```
**Corrected:**
```sql
SELECT ______, ______ FROM employees WHERE department = ______;
```

2. **Error Query:**
```sql
SELECT * FROM employees ORDER BY salary LIMIT 10 DESC;
```

⚠️ Продолжение Task 9 (исправление п.2, другие пункты, ответы) не попало в кадр.

---

## SECTION E (Week 5) — Operators & Functions

⚠️ Заголовок раздела не попал в кадр.

### Task 10: Logical Operators (truth tables)

⚠️ Условие и таблица AND/OR видны частично; строки восстановлены по ответам.

AND/OR table:

| a | b | a AND b | a OR b |
|---|---|---|---|
| TRUE | TRUE | ______ | ______ |
| TRUE | FALSE | ______ | ______ |
| TRUE | NULL | ______ | ______ |
| FALSE | FALSE | ______ | ______ |
| FALSE | NULL | ______ | ______ |
| NULL | NULL | ______ | ______ |

NOT table:

| a | NOT a |
|---|---|
| TRUE | ______ |
| FALSE | ______ |
| NULL | ______ |

**Answers:** AND/OR table: TRUE/TRUE, FALSE/TRUE, NULL/TRUE, FALSE/FALSE, FALSE/NULL, NULL/NULL
NOT table: FALSE, TRUE, NULL

### Task 11: Comparison Operators

Write the correct comparison operator or predicate:

1. Check if salary is between 50000 and 100000 (inclusive):
```sql
SELECT * FROM employees WHERE salary ______ 50000 ______ 100000;
```

2. The above query is equivalent to:
```sql
SELECT * FROM employees WHERE salary ______ 50000 AND salary ______ 100000;
```

3. Check if a value is NOT between 10 and 20:
```sql
SELECT * FROM products WHERE price ______ 10 AND 20;
```
This is equivalent to: `price ______ 10 OR price ______ 20`

4. Check if email is NULL:
```sql
SELECT * FROM users WHERE email ______;
```

5. Check if email is NOT NULL:
```sql
SELECT * FROM users WHERE email ______;
```

⚠️ Ответы не попали в кадр.

### Task 12: Mathematical Operators

What is the result of each expression?

| Expression | Result |
|---|---|
| `2 + 3` | ______ |
| `2 - 3` | ______ |
| `2 * 3` | ______ |
| `5 / 2` (integer division) | ______ |
| `5 % 2` (modulo) | ______ |
| `2.0 ^ 3.0` (exponentiation) | ______ |
| `\|/ 25.0` (square root) | ______ |
| `@ -5.0` (absolute value) | ______ |

**Answers:** 5, -1, 6, 2, 1, 8, 5, 5

### Task 13: Mathematical Functions

Complete the queries using appropriate mathematical functions:

1. Get absolute value of -17.4:
```sql
SELECT ______(-17.4);  -- Result: 17.4
```
2. Round 42.4 to nearest integer:
```sql
SELECT ______(42.4);  -- Result: 42
```
3. Round 42.4382 to 2 decimal places:
```sql
SELECT ______(42.4382, ______);  -- Result: 42.44
```
4. Get the smallest integer >= -42.8 (ceiling):
```sql
SELECT ______(-42.8);  -- Result: -42
```
5. Get the largest integer <= -42.8 (floor):
```sql
SELECT ______(-42.8);  -- Result: -43
```
6. Truncate 42.8 toward zero:
```sql
SELECT ______(42.8);  -- Result: 42
```
7. Calculate square root of 2.0:
```sql
SELECT ______(2.0);  -- Result: 1.4142...
```
8. Calculate cube root of 27.0:
```sql
SELECT ______(27.0);  -- Result: 3
```
9. Get remainder of 9 divided by 4:
```sql
SELECT ______(9, 4);  -- Result: 1
```
10. Raise 9 to the power of 3:
```sql
SELECT ______(9.0, 3.0);  -- Result: 729
```

**Answers:** 1) abs 2) round 3) round, 2 4) ceil or ceiling 5) floor 6) trunc 7) sqrt 8) cbrt 9) mod 10) power

### Task 14: String Functions and Operators

Complete the queries:

1. Concatenate 'Post' and 'greSQL' using operator:
```sql
SELECT 'Post' ______ 'greSQL';  -- Result: PostgreSQL
```
2. Get number of characters in 'jose':
```sql
SELECT ______('jose');  -- Result: 4
```
3. Convert 'TOM' to lowercase:
```sql
SELECT ______('TOM');  -- Result: tom
```
4. Convert 'tom' to uppercase:
```sql
SELECT ______('tom');  -- Result: TOM
```
5. Extract substring 'hom' from 'Thomas' (starting at position 2, length 3):
```sql
SELECT ______('Thomas' FROM 2 FOR 3);  -- Result: hom
```
6. Find position of 'om' in 'Thomas':
```sql
SELECT ______('om' IN 'Thomas');  -- Result: 3
```
7. Remove 'xyz' from both ends of 'yxTomxx':
```sql
SELECT ______(both 'xyz' FROM 'yxTomxx');  -- Result: Tom
```
8. Replace substring in 'Txxxxas' - place 'hom' from position 2 for 4 characters:
```sql
SELECT ______('Txxxxas' PLACING 'hom' FROM 2 FOR 4);  -- Result: Thomas
```

**Answers:** 1) || 2) char_length or character_length 3) lower 4) upper 5) substring 6) position 7) trim 8) overlay

### Task 15: LIKE Pattern Matching

Determine if each LIKE expression returns TRUE or FALSE:

| Expression | Result |
|---|---|
| `'abc' LIKE 'abc'` | ______ |
| `'abc' LIKE 'a%'` | ______ |
| `'abc' LIKE '_b_'` | ______ |
| `'abc' LIKE 'c'` | ______ |
| `'abc' LIKE '%b%'` | ______ |
| `'abc' LIKE 'a_'` | ______ |
| `'abc' LIKE '%c'` | ______ |

Write LIKE patterns for the following:

1. Find all employees whose name starts with 'A':
```sql
WHERE emp_name LIKE '______';
```
2. Find all employees whose name ends with 'son':
```sql
WHERE emp_name LIKE '______';
```
3. Find all employees whose name contains 'an':
```sql
WHERE emp_name LIKE '______';
```
4. Find all employees whose name has exactly 5 characters:
```sql
WHERE emp_name LIKE '______';
```
5. Find all employees whose name starts with 'J' and has exactly 4 characters:
```sql
WHERE emp_name LIKE '______';
```

**Answers:** Table: TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE
Patterns: 1) A% 2) %son 3) %an% 4) _____ (5 underscores) 5) J___

### Task 16: CASE Expression

Complete the CASE expressions:

1. Categorize employees by salary:
```sql
SELECT emp_name, salary,
    CASE
        ______ salary < 30000 ______ 'Low'
        ______ salary < 70000 ______ 'Medium'
        ______ 'High'
    ______ AS salary_category
FROM employees;
```

2. Simple CASE form - convert numeric grade to letter:
```sql
SELECT student, -- ⚠️ начало запроса видно частично
    CASE grade
        ______ 5 ______ 'Excellent'
        ______ 4 ______ 'Good'
        ______ 3 ______ 'Satisfactory'
        ______ 'Fail'
    ______ AS letter_grade
FROM students;
```

**Answers:**
1. WHEN, THEN, WHEN, THEN, ELSE, END
2. WHEN, THEN, WHEN, THEN, WHEN, THEN, ELSE, END

### Task 17: COALESCE and NULLIF

1. Return description if not null, otherwise short_description, otherwise '(none)':
```sql
SELECT ______(description, short_description, '(none)') FROM products;
```
2. Return NULL if value equals '(none)', otherwise return the value:
```sql
SELECT ______(value, '(none)') FROM data;
```
3. Display employee's phone, or 'No phone' if NULL:
```sql
SELECT emp_name, ______(phone, 'No phone') AS contact
FROM employees;
```
4. Avoid division by zero (return NULL instead of error):
```sql
SELECT total / ______(count, 0) FROM stats;
```

**Answers:** 1) COALESCE 2) NULLIF 3) COALESCE 4) NULLIF

### Task 18: GREATEST and LEAST

1. Find the largest value among three columns:
```sql
SELECT ______(score1, score2, score3) AS max_score FROM exams;
```
2. Find the smallest value:
```sql
SELECT ______(price1, price2, price3) AS min_price FROM products;
```
3. Ensure a value is at least 0 (no negative values):
```sql
SELECT ______(balance, 0) AS non_negative_balance FROM accounts;
```
4. Cap a value at maximum 100:
```sql
SELECT ______(score, 100) AS capped_score FROM results;
```

**Answers:** 1) GREATEST 2) LEAST 3) GREATEST 4) LEAST

### Task 19: Data Type Formatting Functions

Match the function to convert:

1. Convert timestamp to string in format 'HH12:MI:SS':
```sql
SELECT ______(current_timestamp, 'HH12:MI:SS');
```
2. Convert string '05 Dec 2000' to date:
```sql
SELECT ______(______, '______ ______ ______');
```
3. Convert integer 125 to string:
```sql
SELECT ______(125, '999');
```
4. Convert string '12,454.8-' to numeric:
```sql
SELECT ______(______, '99G999D9S');
```

**Answers:** 1) to_char (⚠️ строка не в кадре) 2) to_date, '05 Dec 2000', 'DD Mon YYYY' 3) to_char 4) to_number, '12,454.8-'

### Task 20: What's the Output?

Predict the result of each query:

1. `SELECT abs(-17.4);` → ______
2. `SELECT round(42.4382, 2);` → ______
3. `SELECT ceil(-42.8);` → ______
4. `SELECT floor(-42.8);` → ______
5. `SELECT 'Hello' || ' ' || 'World';` → ______
6. `SELECT position('om' IN 'Thomas');` → ______
7. `SELECT substring('Thomas' FROM 2 FOR 3);` → ______
8. `SELECT COALESCE(NULL, NULL, 'default');` → ______
9. `SELECT NULLIF(5, 5);` → ______
10. `SELECT GREATEST(3, 7, 2, 9, 1);` → ______

**Answers:** 1) 17.4 2) 42.44 3) -42 4) -43 5) Hello World 6) 3 7) hom 8) default 9) NULL 10) 9

---

## SECTION F: Constraints (Week 6)

> Нумерация задач в документе здесь начинается заново с 13.

### Task 13: Identify Constraint Types

For each constraint, write its type (PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK, DEFAULT):

1. `emp_id SERIAL PRIMARY KEY` - ______
2. `email VARCHAR(100) UNIQUE` - ______
3. `salary DECIMAL(10,2) CHECK (salary > 0)` - ______
4. `status VARCHAR(20) DEFAULT 'active'` - ______
5. `department_id INTEGER REFERENCES departments(dept_id)` - ______
6. `emp_name VARCHAR(100) NOT NULL` - ______

⚠️ Ответы не попали в кадр.

### Task 14: Add Constraints

Write ALTER TABLE statements to add the following constraints:

1. Add a UNIQUE constraint on email column in employees table:
```sql
ALTER TABLE employees
ADD CONSTRAINT ______ UNIQUE (______);
```
2. Add a CHECK constraint to ensure age is between 18 and 65:
```sql
ALTER TABLE employees
ADD CONSTRAINT ______ CHECK (______);
```
3. Add a foreign key constraint:
```sql
ALTER TABLE orders
ADD CONSTRAINT ______
FOREIGN KEY (______) REFERENCES ______(______);
```

**Answers:**
1. uk_email, email
2. chk_age, age BETWEEN 18 AND 65
3. fk_customer, customer_id, customers, customer_id

### Task 15: Constraint Violations

For each INSERT statement, identify which constraint would be violated:

Given:
```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INTEGER CHECK (age >= 18),
    department_id INTEGER REFERENCES departments(dept_id)
);
```

1. `INSERT INTO students (email, age) VALUES (NULL, 20);` Violates: ______
2. `INSERT INTO students (email, age) VALUES ('test@email.com', 16);` Violates: ______
3. `INSERT INTO students (email, age, department_id) VALUES ('test@email.com', 20, 999);` (Assuming dept_id 999 doesn't exist) Violates: ______

⚠️ В п.3 значения обрезаны краем слайда, «20, 999» восстановлено по контексту.

**Answers:** 1) NOT NULL 2) CHECK 3) FOREIGN KEY

---

## SECTION G: Set Operations, NULL, Aggregates, Subqueries (Week 7)

### Task 16: Set Operations

Given tables:
```
students_2024(student_id, name)
students_2025(student_id, name)
```

1. Get all students from both years (no duplicates):
```sql
SELECT * FROM students_2024
______
SELECT * FROM students_2025;
```
2. Get students who are in both years:
```sql
SELECT * FROM students_2024
______
SELECT * FROM students_2025;
```
3. Get students from 2024 who are NOT in 2025:
```sql
SELECT * FROM students_2024
______
SELECT * FROM students_2025;
```

**Answers:** 1) UNION 2) INTERSECT 3) EXCEPT

### Task 17: NULL Values

1. Select employees with no manager:
```sql
SELECT * FROM employees WHERE manager_id ______;
```
2. Replace NULL salary with 0:
```sql
SELECT emp_name, ______(salary, 0) AS salary FROM employees;
```
3. Check if any of three values is NULL:
```sql
SELECT * FROM data WHERE col1 IS NULL ______ col2 IS NULL ______ col3 IS NULL;
```

**Answers:** 1) IS NULL 2) COALESCE 3) OR, OR

### Task 18: Aggregate Functions

Complete the queries:
```sql
-- Sample table: sales(sale_id, product_id, quantity, price, sale_date)
```

1. Count total number of sales:
```sql
SELECT ______(______) FROM sales;
```
2. Find the average price:
```sql
SELECT ______(price) FROM sales;
```
3. Find minimum and maximum quantity:
```sql
SELECT ______(quantity), ______(quantity) FROM sales;
```
4. Calculate total revenue (quantity * price):
```sql
SELECT ______(quantity * price) AS total_revenue FROM sales;
```
5. Count distinct products sold:
```sql
SELECT COUNT(______ product_id) FROM sales;
```

**Answers:** 1) COUNT, * 2) AVG 3) MIN, MAX 4) SUM 5) DISTINCT

### Task 19: GROUP BY and HAVING

Complete the queries:

1. Count employees per department:
```sql
SELECT department, ______(______) AS emp_count
FROM employees
______ department;
```
2. Find departments with more than 5 employees:
```sql
SELECT department, COUNT(*) AS emp_count
FROM employees
GROUP BY department
______ ______(______) > 5;
```
3. Find the average salary per department for departments where avg salary > 50000:
```sql
SELECT department, ______(salary) AS avg_salary
FROM employees
GROUP BY ______
HAVING ______ > 50000;
```

⚠️ Ответы не попали в кадр.

### Task 20: Nested Subqueries

Complete the queries:

1. Find employees earning more than the average salary:
```sql
SELECT * FROM employees
WHERE salary > (______);
```
2. Find employees in departments located in 'Almaty':
```sql
SELECT * FROM employees
WHERE department_id ______ (
    SELECT dept_id FROM departments WHERE location = 'Almaty'
);
```
3. Find the employee with the highest salary:
```sql
SELECT * FROM employees
WHERE salary = (
    SELECT ______(______) FROM employees
);
```
4. Find employees who have made at least one sale:
```sql
SELECT * FROM employees e
WHERE ______ (
    SELECT 1 FROM sales s WHERE s.emp_id = e.emp_id
);
```

⚠️ Ответы не попали в кадр.

---

## SECTION H: Mixed Practice Problems

### Task 21: Write Complete Queries

Given the schema:
```
departments(dept_id, dept_name, location)
employees(emp_id, emp_name, salary, hire_date, dept_id)
projects(project_id, project_name, budget, dept_id)
```

Write SQL queries for:

1. **List all employees with their department names, ordered by salary (descending):**
```sql
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
______ departments d ______ e.dept_id = d.dept_id
ORDER BY ______;
```
2. **Find the total budget allocated to each department:**
```sql
SELECT d.dept_name, ______(p.budget) AS total_budget
FROM departments d
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY ______;
```
3. **Find departments with no employees:**
```sql
SELECT * FROM departments
WHERE dept_id ______ (
    SELECT ______ dept_id FROM employees
);
```

⚠️ Ответы не попали в кадр.

### Task 22: Error Analysis

Find and explain the error in each query:

1. `SELECT department, AVG(salary) FROM employees;`
   Error: ______ Fix: ______
2. `SELECT * FROM employees WHERE salary = NULL;`
   Error: ______ Fix: ______
3. `SELECT department, COUNT(*) FROM employees GROUP BY department HAVING salary > 50000;`
   Error: ______ Fix: ______

**Answers:**
1. Missing GROUP BY clause / Add GROUP BY department
2. Cannot use = with NULL / Use IS NULL
3. HAVING must use aggregate function / Use HAVING AVG(salary) > 50000 or move to WHERE clause before GROUP BY

---

## SECTION I: True/False Questions

Mark each statement as True (T) or False (F):

1. [ ] A primary key can contain NULL values.
2. [ ] UNION ALL removes duplicate rows from the result.
3. [ ] The WHERE clause is evaluated before GROUP BY.
4. [ ] A foreign key must reference a primary key or unique key.
5. [ ] DELETE without WHERE clause deletes all rows in the table.
6. [ ] HAVING can be used without GROUP BY.
7. [ ] COUNT(*) counts NULL values, but COUNT(column) does not.
8. [ ] TRUNCATE is faster than DELETE for removing all rows.

**Answers (обрезано):** 1-F 2-F (UNION removes duplicates, UNION ALL keeps them) 3-T 4-T 5-T 6-F (generally requires … ⚠️ дальше не в кадре)

---

## Замечания к ответам (проверено на PostgreSQL 18)

1. **Section I, п.6 «HAVING can be used without GROUP BY».** На слайде ответ F, но запрос
   `SELECT COUNT(*) FROM employees HAVING COUNT(*) > 1;` выполняется без ошибки: вся таблица считается одной группой.
   Строго говоря, верно T. У преподавателя «generally requires», то есть «обычно». Лучше уточнить, какой ответ он ждёт.

2. **Task 21, п.3 (`dept_id NOT IN (SELECT DISTINCT dept_id FROM employees)`).** Если хотя бы у одного сотрудника
   `dept_id` равен NULL, `NOT IN` вернёт 0 строк, даже когда пустые отделы есть. Надёжный вариант:
   ```sql
   SELECT * FROM departments d
   WHERE NOT EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id);
   ```

3. **Task 19 (форматирование), п.3.** `to_char(125, '999')` возвращает `' 125'` с пробелом впереди: это место под знак числа.
