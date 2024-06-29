-- Write a query to filter the dates column to showcase only those days where day_indicator character for that day of the week is 1.

with cte as (
	select 
		product_id,
		dates,
		day_indicator,
		substring(day_indicator, extract('isodow' from dates)::int, 1)::int flag
	from 
		product_schedule
)
select 
	product_id, day_indicator, dates
from cte
where flag = 1
