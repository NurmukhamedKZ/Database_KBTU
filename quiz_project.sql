INSERT INTO projects (project_name, budget, start_date, end_date)
VALUES ('Mobile App', 400000 * 1.25, CURRENT_DATE, CURRENT_DATE + 90)
RETURNING project_id, budget, start_date, end_date;



UPDATE team_members
SET status = 'Unassigned'
WHERE project_id IS NULL
RETURNING full_name, status;



UPDATE projects
SET completion_pct = CASE
    WHEN total_tasks = 0 THEN 0
    ELSE ROUND(done_tasks * 100.0 / total_tasks, 1)
END;


UPDATE projects
SET end_date = end_date + 30
WHERE budget > 500000
  AND (SELECT COUNT(*) FROM team_members t WHERE t.project_id = projects.project_id) > 2
RETURNING project_name, end_date;



DELETE FROM team_members
WHERE project_id IN (SELECT project_id FROM projects WHERE end_date < '2026-01-01')
RETURNING *;