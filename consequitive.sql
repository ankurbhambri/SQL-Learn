-- Using a CTE to calculate the most and least expensive products in each category
WITH cte AS (
    SELECT
        name, 
        category, 
        model, 
        price,
        -- Retrieve the model name of the most expensive product within each category
        FIRST_VALUE(model) OVER (PARTITION BY category ORDER BY price DESC) AS expensive_product_name,
        -- Retrieve the model name of the least expensive product within each category
        LAST_VALUE(model) OVER (PARTITION BY category ORDER BY price DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_expensive_product_name
    FROM products
)
-- Select the category, model, price, most expensive product, and least expensive product from the CTE
SELECT 
    category, 
    model, 
    price, 
    expensive_product_name, 
    least_expensive_product_name 
FROM cte;

-- Query to find users who have logged in consecutively 3 or more times
SELECT DISTINCT repeated_names
FROM (
    SELECT *,
           -- Check if the current user_name is the same as the next two user_name values
           CASE 
               WHEN user_name = LEAD(user_name) OVER (ORDER BY login_id)
                    AND user_name = LEAD(user_name, 2) OVER (ORDER BY login_id)
               THEN user_name 
               ELSE NULL 
           END AS repeated_names
    FROM login_details
) AS x
-- Filter out rows where repeated_names is not null
WHERE x.repeated_names IS NOT NULL;




select 
	'2024/05/01'::Date,
	'2024/05/01'::Date - Interval '90 days',
	
	'2024/05/01'::Date - Interval '91 days',
	'2024/05/01'::Date - Interval '180 days',
	
	'2024/05/01'::Date - Interval '181 days',
	'2024/05/01'::Date - Interval '270 days',
	
	'2024/05/01'::Date - Interval '271 days',
	'2024/05/01'::Date - Interval '365 days'


