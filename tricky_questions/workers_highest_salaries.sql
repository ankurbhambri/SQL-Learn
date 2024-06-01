-- https://platform.stratascratch.com/coding/10353-workers-with-the-highest-salaries?code_type=1

WITH cte AS (
    SELECT 
        w.worker_id,
        w.department,
        w.salary,
        t.worker_title,
        DENSE_RANK() OVER(PARTITION BY w.department ORDER BY w.salary DESC) AS rn
    FROM 
        worker w
    JOIN
        title t
    ON
        t.worker_ref_id = w.worker_id
)
SELECT 
    distinct worker_title AS best_paid_title
FROM 
    cte
WHERE 
    rn = 1 and salary = (select max(salary) from worker)