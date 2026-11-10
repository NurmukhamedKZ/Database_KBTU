SELECT count(*) FROM students s CROSS JOIN courses c;

SELECT count(*) FROM students s JOIN enrollments e ON e.student_id = s.student_id JOIN courses c ON c.course_id  = e.course_id;

SELECT count(*) FROM students LEFT JOIN enrollments ON students.student_id = enrollments.student_id;

SELECT count(*) FROM courses LEFT JOIN enrollments ON courses.course_id = enrollments.course_id;

SELECT count(*) FROM departments FULL JOIN courses ON courses.dept_code = departments.dept_code;

-- task A 3 

SELECT * FROM students, courses;

SELECT * FROM courses CROSS JOIN students;



SELECT s.full_name, c.title, e.grade from  students s LEFT JOIN enrollments e ON s.student_id = e.student_id LEFT JOIN courses c ON c.course_id = e.course_id

SELECT s.student_id, s.full_name FROM students s LEFT JOIN enrollments e ON e.student_id = s.student_id WHERE e.student_id IS NULL;

SELECT courses.title from courses LEFT JOIN enrollments ON courses.course_id = enrollments.course_id WHERE enrollments.course_id is NULL;

SELECT s.student_id, s.full_name, COUNT(e.course_id) AS courses_enrolled, COUNT(e.grade) AS courses_graded FROM students s 
LEFT JOIN enrollments e ON e.student_id = s.student_id GROUP BY s.student_id, s.full_name ORDER BY s.student_id;



SELECT d.dept_code, d.dept_name, c.course_id,c.title FROM departments d FULL JOIN courses c ON c.dept_code = d.dept_code

SELECT s.student_id, s.full_name, count(*), count(e.grade) FROM students s LEFT JOIN enrollments e ON e.student_id = s.student_id GROUP BY s.student_id, s.full_name

