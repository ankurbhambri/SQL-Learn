/*
Output - 
"A1"	"2024-01-01"	"2024-01-03"	"PRESENT"
"A1"	"2024-01-04"	"2024-01-04"	"ABSENT"
"A1"	"2024-01-05"	"2024-01-06"	"PRESENT"
"A1"	"2024-01-07"	"2024-01-09"	"ABSENT"
"A1"	"2024-01-10"	"2024-01-10"	"PRESENT"
"A2"	"2024-01-06"	"2024-01-07"	"PRESENT"
"A2"	"2024-01-08"	"2024-01-08"	"ABSENT"
"A2"	"2024-01-09"	"2024-01-09"	"PRESENT"
"A2"	"2024-01-10"	"2024-01-10"	"ABSENT"
*/

with cte as (
	select 
		*,
		ROW_NUMBER() OVER () id
	from emp_attendance
),
cte2 as (
	select 
		*,
		id - ROW_NUMBER() OVER (partition by status ORDER BY id) AS diff 
	from cte
)
select
	employee, min(dates) from_date, max(dates) to_date, status 
from cte2 
group by 
	employee, diff, status
order by 
	1, 2, 3