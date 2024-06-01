/*
The relationship between the LIFT and LIFT_PASSENGERS table is such that multiple passengers can attempt to enter the same lift, 
but the total weight of the passengers in a lift cannot exceed the lifts' capacity.

Your task is to write a SQL query that produces a comma-separated list of passengers,
who can be accommodated in each lift without exceeding the lift's capacity. 

The passengers in the list should be ordered by their weight in increasing order.
You can assume that the weights of the passengers are unique within each lift.

https://medium.com/@singhsalujamandeep222/sql-interview-problem-by-capgemini-3d7133255c23

*/

with cte as (
	select
		a.*, b.CAPACITY_KG,
		sum(WEIGHT_KG) over(partition by a.LIFT_ID order by a.WEIGHT_KG) weight_till_persons
	from
		LIFT_PASSENGERS a 
	join LIFT b
	on a.lift_id=b.id
)
select 
	LIFT_ID, STRING_AGG(PASSENGER_NAME, ',')
from cte
where CAPACITY_KG > weight_till_persons
group by LIFT_ID
