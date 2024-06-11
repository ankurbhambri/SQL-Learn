-- https://techtfq.com/blog/learn-how-to-write-sql-queries-practice-complex-sql-queries

-- Q1. Write a SQL Query to fetch all the duplicate records in a table.
-- We can use the row_number() function.

SELECT user_id, user_name, cn 
FROM (
    SELECT *,
           COUNT(1) OVER (PARTITION BY user_name ORDER BY user_id) AS cn
    FROM USERS
) AS subquery
WHERE cn > 1;

-- Q2. Write a SQL query to fetch the second last record from the employee table.

SELECT * 
FROM (
    SELECT *,
           RANK() OVER (ORDER BY id DESC) AS rn
    FROM employees
) AS subquery
WHERE rn = 2;

-- For the second highest salary using a similar approach:

SELECT * 
FROM (
    SELECT *,
           RANK() OVER (ORDER BY salary DESC) AS rn
    FROM employees
) AS subquery
WHERE rn = 2;

-- Q3. Write a SQL query to display only the details of employees who either earn the highest salary or the lowest salary in each department from the employee table.

WITH cte AS (
  SELECT MAX(salary) AS mx, MIN(salary) AS mn, DEPT_NAME 
  FROM employee 
  GROUP BY DEPT_NAME
)
SELECT e.* 
FROM employee e 
JOIN cte ON cte.DEPT_NAME = e.DEPT_NAME 
         AND (e.salary = cte.mx OR e.salary = cte.mn) 
ORDER BY DEPT_NAME;

-- Q4. From the students table, fetch the details of students who study in the same university but in different courses.

SELECT a.*,
       ROW_NUMBER() OVER (PARTITION BY a.university ORDER BY a.student_id)
FROM students a 
JOIN students b 
ON a.student_id <> b.student_id 
   AND a.university = b.university 
   AND a.course <> b.course;

-- Q5. From the login_details table, fetch the users who logged in consecutively 3 or more times.

-- Idea: Fetch users who logged in consecutively 3 or more times by comparing the current username with the next two usernames.

SELECT DISTINCT x.name
FROM (
    SELECT login_id, login_date,
           CASE
               WHEN user_name = LEAD(user_name) OVER (ORDER BY login_id) 
                    AND user_name = LEAD(user_name, 2) OVER (ORDER BY login_id)
               THEN user_name
           END AS name
    FROM login_details
) AS x
WHERE x.name IS NOT NULL;

-- Q6. From the students table, write a SQL query to interchange adjacent student names.

SELECT name, 
       CASE 
           WHEN student_id % 2 <> 0 
           THEN LEAD(name) OVER (ORDER BY student_id) 
           ELSE LAG(name) OVER (ORDER BY student_id) 
       END AS new_student_name
FROM students;

-- Q7. From the weather table, fetch all the records when London had extremely cold temperatures for 3 consecutive days or more.

-- IDEA: Identify records with consecutive temperatures below zero.

SELECT * 
FROM (
    SELECT *, COUNT(1) OVER (PARTITION BY x.rn) AS diff 
    FROM (
        SELECT *, 
            day - CAST(ROW_NUMBER() OVER (ORDER BY day) AS INT) AS rn
        FROM weather 
        WHERE temperature < 0
    ) AS x
) AS a
WHERE a.diff >= 3;

-- Q8. From the following 3 tables (course_category, instructor_department, student_enrollment), 
-- write a SQL query to get the histogram of departments of the unique instructors
-- who have taught lectures but have never been involved in seminars or labs.

WITH cte AS (
  SELECT a.course_name, a.instructor_id 
  FROM student_enrollment a 
  JOIN (
      SELECT course_name 
      FROM course_category 
      WHERE category NOT IN ('Lab', 'Seminar')
  ) AS b
  ON a.course_name = b.course_name
)
SELECT department, COUNT(1) 
FROM instructor_department a 
JOIN cte ON cte.instructor_id = a.instructor_id
GROUP BY department;

-- Q9. Find the top 2 accounts with the maximum number of unique accounts on a monthly basis.

SELECT month, account_id, no_of_acc 
FROM (
    SELECT month, account_id, no_of_acc,
           RANK() OVER (PARTITION BY month ORDER BY no_of_acc DESC, account_id) AS rn
    FROM (
        WITH cte AS (
            SELECT DISTINCT TO_CHAR(date, 'month') AS month, account_id, customer_id 
            FROM acc_logs
        )
        SELECT month, account_id, COUNT(1) AS no_of_acc
        FROM cte
        GROUP BY month, account_id
    ) AS subquery
) AS ranked
WHERE rn IN (1, 2);

-- Q10. Finding n consecutive records where temperature is below zero.

-- 10a. Table has a primary key.

-- IDEA: Subtract row_number from id to form clusters and identify consecutive records.

WITH t1 AS (
    SELECT *, (id - ROW_NUMBER() OVER (ORDER BY id)) AS diff
    FROM weather 
    WHERE temperature < 0
), t2 AS (
    SELECT *,
           COUNT(*) OVER (PARTITION BY diff ORDER BY diff) AS cnt
    FROM t1
)
SELECT id, city, temperature, day
FROM t2
WHERE t2.cnt = 3;

-- 10b. Table does not have a primary key.

-- IDEA: Create a temporary id using row_number and apply the same logic.

CREATE OR REPLACE VIEW vw_weather AS
SELECT city, temperature 
FROM weather;

WITH w AS (
    SELECT *, ROW_NUMBER() OVER () AS id
    FROM vw_weather
), t1 AS (
    SELECT *, id - ROW_NUMBER() OVER (ORDER BY id)::NUMERIC AS diff
    FROM w
    WHERE w.temperature < 0
), t2 AS (
    SELECT *,
           COUNT(*) OVER (PARTITION BY diff ORDER BY diff) AS cnt
    FROM t1
)
SELECT city, temperature, id
FROM t2
WHERE t2.cnt = 5;

-- 10c. Query logic based on the date field.

-- IDEA: Subtract row_number from date to form clusters and identify consecutive records.

WITH t1 AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY order_date) AS rn,
           order_date - CAST(ROW_NUMBER() OVER (ORDER BY order_date) AS INT) AS diff
    FROM order_table
), t2 AS (
    SELECT *,
           COUNT(1) OVER (PARTITION BY diff) AS cnt
    FROM t1
)
SELECT order_id, order_date
FROM t2
WHERE cnt >= 3;
