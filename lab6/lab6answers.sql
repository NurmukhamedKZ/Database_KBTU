-- Laboratory Work 6: SQL JOINs

-- Part 1: Database Setup
DROP TABLE IF EXISTS projects, employees, departments;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- Part 2: CROSS JOIN

-- 2.1
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- 5 × 4 = 20 строк.

-- 2.2 a
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- 2.2 b
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

-- 2.3
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p
ORDER BY e.emp_name, p.project_name;

-- Part 3: INNER JOIN

-- 3.1
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 4 строки. У Tom Brown dept_id = NULL, сравнение с NULL не даёт совпадения.

-- 3.2
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- С USING колонка dept_id выводится один раз, с ON — две (e.dept_id и d.dept_id).

-- 3.3
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

-- 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

-- Part 4: LEFT JOIN

-- 4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown есть в результате, но emp_dept, dept_dept и dept_name = NULL.

-- 4.2
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- 4.3
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- 4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- Part 5: RIGHT JOIN

-- 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 5.2
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- 5.3
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- Part 6: FULL JOIN

-- 6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- NULL слева — у Marketing (нет сотрудников), NULL справа — у Tom Brown (нет отдела).

-- 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- 6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

-- Part 7: ON vs WHERE

-- 7.1
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- 7.2
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Query 1 возвращает всех 5 сотрудников, dept_name заполнен только у IT.
-- Query 2 возвращает 2 строки: WHERE выполняется после соединения и отбрасывает
-- строки с другим location или NULL, поэтому LEFT JOIN становится INNER JOIN.

-- 7.3
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Разницы нет: INNER JOIN не сохраняет несовпавшие строки, поэтому фильтр
-- в ON и в WHERE даёт одинаковый результат.

-- Part 8: Complex JOIN Scenarios

-- 8.1
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- 8.2
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- 8.3
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- Lab Questions
-- 1. INNER JOIN возвращает только строки с парой в обеих таблицах. LEFT JOIN
--    возвращает все строки левой таблицы, а где пары нет, правые колонки = NULL.
-- 2. Когда нужны все комбинации: матрица «сотрудник × проект», «товар × размер × цвет»,
--    расписание «дата × сотрудник», генерация тестовых данных.
-- 3. Во внешнем JOIN условие в ON определяет только совпадения, а несовпавшие строки
--    всё равно выводятся с NULL. WHERE применяется после соединения и удаляет эти строки.
--    У INNER JOIN несовпавших строк нет, поэтому результат одинаковый.
-- 4. 5 × 10 = 50.
-- 5. По всем колонкам с одинаковыми именами в обеих таблицах (равенство по каждой).
--    Если общих колонок нет, получается CROSS JOIN.
-- 6. При добавлении колонки с тем же именем (name, created_at) условие соединения
--    молча меняется; совпадение имён не означает совпадения смысла; из запроса
--    не видно, по каким колонкам идёт соединение; без общих колонок — CROSS JOIN.
-- 7. SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
-- 8. Когда нужны несовпавшие строки с обеих сторон: сверка двух источников данных,
--    поиск «сирот» в обеих таблицах, объединение двух отчётов по общему ключу.

-- Additional Challenges

-- 1
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 2
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(*) > 1
) p ON p.dept_id = d.dept_id;

-- 3
WITH RECURSIVE org AS (
    SELECT emp_id, emp_name, manager_id, 1 AS level,
           emp_name::TEXT AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id, o.level + 1,
           o.path || ' -> ' || e.emp_name
    FROM employees e
    INNER JOIN org o ON e.manager_id = o.emp_id
)
SELECT level, emp_name, path
FROM org
ORDER BY path;

SELECT e.emp_name  AS employee,
       m1.emp_name AS manager,
       m2.emp_name AS managers_manager
FROM employees e
LEFT JOIN employees m1 ON e.manager_id = m1.emp_id
LEFT JOIN employees m2 ON m1.manager_id = m2.emp_id;

-- 4
SELECT d.dept_name, e1.emp_name AS employee_1, e2.emp_name AS employee_2
FROM employees e1
INNER JOIN employees e2
    ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
INNER JOIN departments d ON d.dept_id = e1.dept_id;
