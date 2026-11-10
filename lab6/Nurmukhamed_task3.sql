-- In-Class Task 3: Many-to-Many JOINs

-- Step 0
DROP TABLE IF EXISTS enrollments, courses, students, departments;

CREATE TABLE departments (
    dept_code char(2)     PRIMARY KEY,
    dept_name varchar(20) NOT NULL);

CREATE TABLE students (
    student_id char(2)     PRIMARY KEY,
    full_name  varchar(20) NOT NULL,
    program    varchar(4),
    study_year int);

CREATE TABLE courses (
    course_id char(2)     PRIMARY KEY,
    title     varchar(20) NOT NULL,
    credits   int,
    dept_code char(2)     REFERENCES departments);

CREATE TABLE enrollments (
    student_id char(2) REFERENCES students,
    course_id  char(2) REFERENCES courses,
    grade      int,
    PRIMARY KEY (student_id, course_id));

INSERT INTO departments VALUES
('CS', 'Computer Science'),
('MA', 'Mathematics'),
('PH', 'Physics');

INSERT INTO students VALUES
('S1', 'Aigerim', 'SE', 2),
('S2', 'Bolat',   'SE', 3),
('S3', 'Dana',    'CS', 2),
('S4', 'Erlan',   'CS', 4);

INSERT INTO courses VALUES
('C1', 'Databases',        6, 'CS'),
('C2', 'Algorithms',       6, 'CS'),
('C3', 'Linear Algebra',   5, 'MA'),
('C4', 'Machine Learning', 6, 'CS'),
('C5', 'Research Seminar', 3, NULL);

INSERT INTO enrollments VALUES
('S1','C1',90),  ('S1','C2',75),
('S1','C3',NULL),('S2','C1',60),
('S2','C3',85),  ('S3','C1',NULL),
('S3','C5',95);

-- Part A

-- A1 a) predicted: 20 (4 × 5), actual: 20
SELECT *
FROM students s CROSS JOIN courses c;

-- A1 b) predicted: 7 (каждая запись enrollments находит студента и курс), actual: 7
SELECT *
FROM students s
JOIN enrollments e ON e.student_id = s.student_id
JOIN courses c     ON c.course_id  = e.course_id;

-- A1 c) predicted: 8 (7 записей + Erlan без курсов), actual: 8
SELECT *
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id;

-- A1 d) predicted: 8 (7 записей + Machine Learning без студентов), actual: 8
SELECT *
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.course_id;

-- A1 e) predicted: 6 (4 курса с отделом + Physics без курсов + Research Seminar без отдела), actual: 6
SELECT *
FROM departments d
FULL JOIN courses c ON c.dept_code = d.dept_code;

-- A2
-- Удивил d): кажется, что LEFT JOIN от courses вернёт 5 строк (по числу курсов),
-- а получается 8. LEFT JOIN гарантирует только, что каждая левая строка появится
-- хотя бы раз. Курс с несколькими студентами повторяется (Databases — 3 раза),
-- курс без студентов даёт одну строку с NULL.

-- A3
SELECT *
FROM students s, courses c;

SELECT *
FROM students s INNER JOIN courses c ON TRUE;

-- Part B

-- B1
SELECT s.full_name, c.title, e.grade
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
LEFT JOIN courses c     ON c.course_id  = e.course_id
ORDER BY s.full_name, c.title;

-- B2
SELECT s.student_id, s.full_name
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
WHERE e.student_id IS NULL;

-- B3
SELECT c.course_id, c.title
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.course_id
WHERE e.course_id IS NULL;

-- B4
SELECT s.full_name,
       COUNT(e.course_id) AS enrolled,
       COUNT(e.grade)     AS graded
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
GROUP BY s.student_id, s.full_name
ORDER BY s.full_name;

-- Part C

-- C1
SELECT d.dept_code, d.dept_name, c.course_id, c.title
FROM departments d
FULL JOIN courses c ON c.dept_code = d.dept_code;
-- Physics | NULL — у отдела Physics нет ни одного курса.
-- NULL | Research Seminar — курс не привязан ни к одному отделу (dept_code = NULL).

-- C2
SELECT s.full_name,
       COUNT(*)       AS enrolled,
       COUNT(e.grade) AS graded
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
GROUP BY s.student_id, s.full_name
ORDER BY s.full_name;
-- У Erlan enrolled становится 1 вместо 0. COUNT(*) считает строки, а LEFT JOIN
-- создаёт для Erlan одну строку с NULL в колонках enrollments. COUNT(e.course_id)
-- пропускает NULL и правильно даёт 0.

-- C3
SELECT c.title, s1.full_name AS student_1, s2.full_name AS student_2
FROM enrollments e1
JOIN enrollments e2 ON e2.course_id = e1.course_id
                   AND e1.student_id < e2.student_id
JOIN students s1 ON s1.student_id = e1.student_id
JOIN students s2 ON s2.student_id = e2.student_id
JOIN courses c   ON c.course_id   = e1.course_id
ORDER BY c.title, student_1, student_2;
