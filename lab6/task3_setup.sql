-- ===========================================================================
--  In-Class Task 3: Many-to-Many JOINs  --  database setup
--  Database Systems, Laboratory Work 6 (SQL JOINs)
--
--  Usage:  createdb joinlab
--          psql -d joinlab -f setup.sql
--
--  4 students, 5 courses, 3 departments, 7 enrolments.
--  Some rows are deliberately unmatched and two grades are NULL.
-- ===========================================================================

DROP TABLE IF EXISTS enrollments, courses, students, departments;

CREATE TABLE departments (
    dept_code  char(2)     PRIMARY KEY,
    dept_name  varchar(20) NOT NULL
);

CREATE TABLE students (
    student_id char(2)     PRIMARY KEY,
    full_name  varchar(20) NOT NULL,
    program    varchar(4),
    study_year int
);

CREATE TABLE courses (
    course_id  char(2)     PRIMARY KEY,
    title      varchar(20) NOT NULL,
    credits    int,
    dept_code  char(2)     REFERENCES departments
);

-- junction table for the many-to-many relationship
CREATE TABLE enrollments (
    student_id char(2) REFERENCES students,
    course_id  char(2) REFERENCES courses,
    grade      int,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO departments VALUES
('CS', 'Computer Science'),
('MA', 'Mathematics'),
('PH', 'Physics');            -- no courses

INSERT INTO students VALUES
('S1', 'Aigerim', 'SE', 2),
('S2', 'Bolat',   'SE', 3),
('S3', 'Dana',    'CS', 2),
('S4', 'Erlan',   'CS', 4);   -- no enrolments

INSERT INTO courses VALUES
('C1', 'Databases',        6, 'CS'),
('C2', 'Algorithms',       6, 'CS'),
('C3', 'Linear Algebra',   5, 'MA'),
('C4', 'Machine Learning', 6, 'CS'),   -- nobody enrolled
('C5', 'Research Seminar', 3, NULL);   -- no department

INSERT INTO enrollments VALUES
('S1', 'C1', 90),
('S1', 'C2', 75),
('S1', 'C3', NULL),           -- enrolled, not graded yet
('S2', 'C1', 60),
('S2', 'C3', 85),
('S3', 'C1', NULL),           -- enrolled, not graded yet
('S3', 'C5', 95);
