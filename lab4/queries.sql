SELECT concat(first_name, last_name), department, salary FROM employees;

SELECT DISTINCT department FROM employees;

-- Task 1.3
SELECT project_name,
       budget,
       CASE
           WHEN budget > 150000 THEN 'Large'
           WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
           ELSE 'Small'
       END AS budget_category
FROM projects;


-- Task 1.4
SELECT first_name || ' ' || last_name AS full_name,
       COALESCE(email, 'No email provided') AS email
FROM employees;
