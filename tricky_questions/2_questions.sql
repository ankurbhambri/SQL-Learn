/* 
The relationship between the LIFT and LIFT_PASSENGERS table is such that multiple passengers can attempt to enter the same lift, 
but the total weight of the passengers in a lift cannot exceed the lifts' capacity.

Your task is to write a SQL query that produces a comma-separated list of passengers,
who can be accommodated in each lift without exceeding the lift's capacity. 

The passengers in the list should be ordered by their weight in increasing order.
You can assume that the weights of the passengers are unique within each lift.
*/

with cte as (select 
	a.*,
	b.capacity_kg,
	sum(weight_kg) over(partition by lift_id order by weight_kg) sm
from lift_passengers a 
	join lift b on a.lift_id=b.id
order by lift_id, weight_kg
)
select lift_id, string_agg(passenger_name, ', ') from cte where sm <= capacity_kg group by lift_id


--  Total runs score in each over in T20 match format

select x.tc, sum(runs) from (SELECT *, ntile(20) over(order by balls) tc FROM match_score) x group by x.tc order by 1
