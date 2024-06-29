/*
PROBLEM STATEMENT:
In the given input table, there are rows with missing JOB_ROLE values. Write a query to fill in those blank fields with appropriate values.
Assume row_id is always in sequence and job_role field is populated only for the first skill.
Provide two different solutions to the problem.


OUTPUT

"row_id"	"skills"	"job_role"	"new_job_role"
1	"SQL"	"Data Engineer"	"Data Engineer"
2	"Python"		"Data Engineer"
3	"AWS"		"Data Engineer"
4	"Snowflake"		"Data Engineer"
5	"Apache Spark"		"Data Engineer"
6	"Java"	"Web Developer"	"Web Developer"
7	"HTML"		"Web Developer"
7	"CSS"		"Web Developer"
9	"Python"	"Data Scientist"	"Data Scientist"
10	"Machine Learning"		"Data Scientist"
11	"Deep Learning"		"Data Scientist"
12	"Tableau"		"Data Scientist"

*/

with cte as(
	select 
		*,
		sum(case when job_role is null then 0 else 1 end) over(order by row_id) rn
	from job_roles
)
select 
	row_id, skills, job_role,
	first_value(job_role) over(partition by rn order by row_id) new_job_role
from cte


-- recursive way

with recursive cte as (
	select
		row_id, job_role, skills
		from job_roles where row_id=1
	union
	select 
		js.row_id, coalesce(js.job_role, cte.job_role) as job_role, js.skills
	from cte
	join job_roles js on js. row_id = cte. row_id+1
)
select * from cte;