-- RANK - WIll give rank based on the value but skips the suplicate value rank
-- DENSE_RANK - This will give rank in continous manner instead skipping
-- ROW_Number - Gives row number

/*

"row_number"	"rnk"	"dense_rnk"
1				  1			1
2				  1			1
3				  1			1
4				  4			2
5				  4			2
6				  4			2

*/

select *,
	row_number() over(partition by dept order by salary desc) as row_number,
	rank() over(partition by dept order by salary desc) as rnk,
	dense_rank() over(partition by dept order by salary desc) as dense_rnk
from employees;

-- lag - To match/check current value with the previous record (first row will be null)
-- lead - To match/check current value with the next record (first row will be null)

select *,
	lag(salary) over(partition by dept order by id),
	lead(salary) over(partition by dept order by id)
from employees


-- Example

select *,
	lag(salary) over(partition by dept order by id),
	case when salary > lag(salary) over(partition by dept order by id) then 'Higher than previous employee'
	when salary = lag(salary) over(partition by dept order by id) then 'Same as previous employee' 
	else 'Less than previous employee' end
from employees;



-- Wthout LAG or LEAD

with cte as (select row_number() over() id, amount from orders)
select a.id, a.amount - b.amount as rv  from cte a left join cte b on a.id =  b.id + 1 -- for previous add
union all
select a.id, a.amount - b.amount  from cte a left join cte b on a.id =  b.id - 1 -- for next subract



-- Example

with cte as (select 
	brand, 
	year, 
	amount,
	case when amount < lead(amount, 1, amount + 1) over(partition by brand order by year) -- amount + 1 is to make sure that next value is not null
	then 1 else 0
	end as flag
from brands
)
select
	brand, year, amount, flag
from cte
where brand not in (select brand from cte where flag= 0)
