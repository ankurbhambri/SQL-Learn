-- By default, the frame clause is set to 'RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'.
-- It will access/copy the final column value from the start to the end of that column with 'RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING'.
-- If you use 'ROWS' instead of 'RANGE' and end with 'CURRENT ROW' like this - 'ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW' - it will consider only the current row.

SELECT *,
    first_value(model) OVER (PARTITION BY category ORDER BY price) AS first_model,
    last_value(model) OVER (PARTITION BY category ORDER BY price RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_model_range,
    last_value(model) OVER (PARTITION BY category ORDER BY price ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS last_model_rows
FROM products;

-- If you want to consider two rows before the current row and two rows after the current row:

SELECT *,
    first_value(model) OVER (PARTITION BY category ORDER BY price) AS first_model,
    last_value(model) OVER (PARTITION BY category ORDER BY price RANGE BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS last_model_range
FROM products;

-- Another way of writing window function values:

SELECT *,
    first_value(model) OVER w AS most_expensive,
    last_value(model) OVER w AS least_expensive
FROM products
WINDOW w AS (PARTITION BY category ORDER BY price RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);

-- NTH_VALUE based on our position:

SELECT *,
    first_value(model) OVER w AS most_expensive,
    last_value(model) OVER w AS least_expensive,
    nth_value(model, 2) OVER w AS second_most_expensive
FROM products
WINDOW w AS (PARTITION BY category ORDER BY price DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);

-- NTILE creates equal buckets of given values in order. If the values are more or equal, it tries to manage the buckets with more than the specified values:

SELECT *,
    ntile(5) OVER (ORDER BY price DESC) AS buckets
FROM products
WHERE category = 'Mobile';

-- PERCENT_RANK gives the percentage ranking of data in the table. The max value will have the highest percentage:

SELECT *,
    percent_rank() OVER (ORDER BY price) AS percent_rank,
    round(percent_rank() OVER (ORDER BY price)::numeric * 100, 2) AS percent_rank_rounded
FROM products
WHERE category = 'Mobile';
