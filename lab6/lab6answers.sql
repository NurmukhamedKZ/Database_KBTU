-- Laboratory Work 6: SQL JOINs (PostgreSQL)

-- ============================================================
-- Part 1: Database Setup
-- ============================================================
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

-- ============================================================
-- Part 2: CROSS JOIN
-- ============================================================

-- 2.1
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- Ответ: 5 × 4 = 20 строк.

-- 2.2 a) Через запятую
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- 2.2 b) INNER JOIN ON TRUE
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

-- 2.3 Матрица доступности: все сотрудники × все проекты (5 × 5 = 25 строк)
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p
ORDER BY e.emp_name, p.project_name;

-- ============================================================
-- Part 3: INNER JOIN
-- ============================================================

-- 3.1
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Ответ: 4 строки. У Tom Brown dept_id = NULL, а NULL = 101 даёт UNKNOWN,
-- поэтому пары для него нет, и INNER JOIN его отбрасывает.

-- 3.2
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- Ответ: с USING колонка dept_id в SELECT * выводится один раз (слитая),
-- а с ON их две: e.dept_id и d.dept_id.

-- 3.3
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- Результат тот же, что в 3.2: общая колонка только dept_id.

-- 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;
-- 6 строк: у IT два проекта и два сотрудника (2×2=4), плюс по одной строке у HR и Finance.

-- ============================================================
-- Part 4: LEFT JOIN
-- ============================================================

-- 4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Ответ: Tom Brown остаётся в результате, но emp_dept, dept_dept и dept_name = NULL.

-- 4.2
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- 4.3 Сотрудники без отдела
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- Результат: Tom Brown.

-- 4.4 Число сотрудников в каждом отделе (включая 0)
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
-- IT 2, HR 1, Finance 1, Marketing 0. COUNT(e.emp_id), а не COUNT(*),
-- иначе Marketing получил бы 1 за NULL-строку.

-- ============================================================
-- Part 5: RIGHT JOIN
-- ============================================================

-- 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 5.2 То же через LEFT JOIN (таблицы меняются местами)
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- 5.3 Отделы без сотрудников
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
-- Результат: Marketing, Building D.

-- ============================================================
-- Part 6: FULL JOIN
-- ============================================================

-- 6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Ответ: NULL слева (emp_name, emp_dept) у отдела Marketing — в нём нет сотрудников.
-- NULL справа (dept_dept, dept_name) у Tom Brown — у него нет отдела.

-- 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;
-- Marketing без проекта (project_name = NULL), AI Research без отдела (dept_name = NULL).

-- 6.3 «Осиротевшие» записи
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
-- Результат: Tom Brown (Employee without department), Marketing (Department without employees).

-- ============================================================
-- Part 7: ON vs WHERE
-- ============================================================

-- 7.1 Фильтр в ON
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
-- 5 строк: все сотрудники; dept_name заполнен только у John Smith и Mike Johnson (IT).

-- 7.2 Фильтр в WHERE
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- 2 строки: John Smith, Mike Johnson.
-- Ответ: в Query 1 условие участвует в сопоставлении, поэтому LEFT JOIN сохраняет
-- всех сотрудников, у несовпавших просто NULL в колонках отдела. В Query 2 WHERE
-- работает после соединения и выбрасывает строки, где location <> 'Building A'
-- или location IS NULL. LEFT JOIN фактически превращается в INNER JOIN.

-- 7.3 То же с INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Ответ: разницы нет, оба запроса возвращают 2 строки. INNER JOIN оставляет только
-- строки, где выполнено всё условие, а ON и WHERE для него логически равносильны:
-- нет «дополняющих» NULL-строк, которые ON мог бы сохранить.

-- ============================================================
-- Part 8: Complex JOIN Scenarios
-- ============================================================

-- 8.1 Все отделы + сотрудники (если есть) + проекты (если есть)
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

-- 8.2 Self Join
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
-- У всех менеджер Mike Johnson, у самого Mike Johnson manager = NULL.

-- 8.3 Отделы со средней зарплатой > 50000
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
-- IT 52500, HR 60000, Finance 65000.

-- ============================================================
-- Lab Questions
-- ============================================================
-- 1. INNER JOIN возвращает только строки, у которых есть пара в обеих таблицах.
--    LEFT JOIN возвращает все строки левой таблицы; если пары нет, колонки правой
--    таблицы заполняются NULL.
--
-- 2. Когда нужны все комбинации: матрица «сотрудник × проект», сетка
--    «товар × размер × цвет», календарь «дата × сотрудник» для расписания,
--    генерация тестовых данных.
--
-- 3. Во внешнем JOIN условие в ON решает только, какие строки считаются совпавшими,
--    а несовпавшие строки сохраняемой таблицы всё равно выводятся с NULL.
--    WHERE применяется после соединения и удаляет строки целиком, в том числе эти
--    NULL-строки. У INNER JOIN несовпавших строк нет вообще, поэтому фильтр в ON
--    и фильтр в WHERE дают одинаковый результат.
--
-- 4. 5 × 10 = 50.
--
-- 5. NATURAL JOIN соединяет по всем колонкам с одинаковыми именами в обеих таблицах,
--    условие — равенство по каждой такой колонке (как USING со всеми общими колонками).
--    Если общих колонок нет, получается CROSS JOIN.
--
-- 6. Риски NATURAL JOIN:
--    - если в таблицу добавят колонку с совпадающим именем (например, name,
--      created_at, updated_at), условие соединения молча изменится и запрос
--      начнёт возвращать другие данные;
--    - совпадение по имени не означает совпадения по смыслу;
--    - из запроса не видно, по каким колонкам идёт соединение;
--    - если общих колонок нет, получится CROSS JOIN, и строк станет очень много.
--
-- 7. SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
--    (порядок колонок в SELECT * будет B, A; при необходимости колонки перечисляют явно)
--
-- 8. FULL OUTER JOIN нужен, когда важны несовпавшие строки с обеих сторон:
--    сверка/синхронизация двух источников данных, поиск «сирот» в обеих таблицах
--    (как в 6.3), объединение двух отчётов по общему ключу, где у каждой стороны
--    могут быть свои ключи.

-- ============================================================
-- Additional Challenges (Optional)
-- ============================================================

-- 1. Имитация FULL OUTER JOIN через UNION LEFT и RIGHT JOIN
--    (UNION убирает дубликаты совпавших строк; emp_id/dept_id в выборке
--     нужны, чтобы не склеить разные строки с одинаковыми именами)
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 2. Сотрудники из отделов, у которых больше одного проекта
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(*) > 1
) p ON p.dept_id = d.dept_id;
-- Результат: John Smith и Mike Johnson (IT: Website Redesign, Cloud Migration).

-- 3. Иерархия: сотрудник → менеджер → менеджер менеджера (рекурсивно, любая глубина)
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

-- 3 (вариант только на self-join, три уровня)
SELECT e.emp_name  AS employee,
       m1.emp_name AS manager,
       m2.emp_name AS managers_manager
FROM employees e
LEFT JOIN employees m1 ON e.manager_id = m1.emp_id
LEFT JOIN employees m2 ON m1.manager_id = m2.emp_id;

-- 4. Пары сотрудников из одного отдела
--    (e1.emp_id < e2.emp_id убирает пару с самим собой и зеркальные дубли)
SELECT d.dept_name, e1.emp_name AS employee_1, e2.emp_name AS employee_2
FROM employees e1
INNER JOIN employees e2
    ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
INNER JOIN departments d ON d.dept_id = e1.dept_id;
-- Результат: IT — John Smith, Mike Johnson.
