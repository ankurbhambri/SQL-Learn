with cte as (select
	name, category, model, price,
	-- row_number() over(partition by category order by price desc) as rnk,
	first_value(model) over(partition by category order by price desc) as "expensive_product_name",
	last_value(model) over(partition by category order by price desc range between unbounded preceding and unbounded following) as "least_expensive_product_name"
	-- sum(price) over(partition by name, category order by price),
	-- sum(price) over(partition by name, category order by price range between unbounded preceding and unbounded following)
from products)
select category, model, price, expensive_product_name, least_expensive_product_name from cte 
-- where rnk = 1


select distinct repeated_names
from (
select *,
case when user_name = lead(user_name) over(order by login_id)
and  user_name = lead(user_name,2) over(order by login_id)
then user_name else null end as repeated_names
from login_details) x
where x.repeated_names is not null;