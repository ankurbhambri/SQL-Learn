/*

The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.

+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|1    | A          | 2341   |
|2    | A          | 341    |
|3    | A          | 15     |
|4    | A          | 15314  |
|5    | A          | 451    |
|6    | A          | 513    |
|7    | B          | 15     |
|8    | B          | 13     | 
|9    | B          | 1154   |
|10   | B          | 1345   |
|11   | B          | 1221   |
|12   | B          | 234    |
|13   | C          | 2345   |
|14   | C          | 2645   |
|15   | C          | 2645   |
|16   | C          | 2652   |
|17   | C          | 65     |
+-----+------------+--------+

Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.

+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|5    | A          | 451    |
|6    | A          | 513    |
|12   | B          | 234    |
|9    | B          | 1154   |
|14   | C          | 2645   |
+-----+------------+--------+

*/
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company ORDER BY salary DESC) AS rw,
           COUNT(1) OVER (PARTITION BY company ORDER BY salary DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS scn
    FROM salaries
),
even_odd AS (
    SELECT *
    FROM cte
    WHERE scn % 2 = 0 AND rw IN (scn / 2, (scn / 2) + 1)
    UNION ALL
    SELECT *
    FROM cte
    WHERE scn % 2 <> 0 AND rw = (scn + 1) / 2
)
SELECT id, company, salary
FROM even_odd
GROUP BY company, salary, id;
