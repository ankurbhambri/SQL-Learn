/*
    Median (odd set of numbers) = ((n+1)/2)th term

    Median (even set of numbers) = ((n/2)th term + ((n/2)+1)th term)/2

    The median is also known as the 50th percentile


*/

-- Using Window Function


-- This is more accurate one in fraction


SELECT 
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY column_name) AS median
FROM
  table_name;


-- One more way to calculate median is by using the following query:

SELECT
	percentile_disc(0.5) WITHIN GROUP (
	ORDER BY temperature)
FROM city_data;

-- Because the query used percentile_disc(), the result is a value that exists in the dataset.


-- Calculating Multiple Percentiles


SELECT
	device_id,
	percentile_cont(0.25) WITHIN GROUP(
ORDER BY
	humidity) AS percentile_25,
	percentile_cont(0.50) WITHIN GROUP(
ORDER BY
	humidity) AS percentile_50,
	percentile_cont(0.75) WITHIN GROUP(
ORDER BY
	humidity) AS percentile_75,
	percentile_cont(0.95) WITHIN GROUP(
ORDER BY
	humidity) AS percentile_95
FROM
	conditions
GROUP BY
	device_id; 


-- Calculating a Series of Percentiles

SELECT
	city,
	percentile,
	percentile_cont(p) WITHIN GROUP (
ORDER BY
	temperature)
FROM
	city_data,
	generate_series(0.01, 1, 0.01) AS percentile
GROUP BY
	city, percentile;


-- Without Window Function

WITH get_median AS (
  SELECT
    y, row_number() OVER(ORDER BY y ASC) AS rn_asc, 
    COUNT(*) OVER() AS ct
  FROM dataset
)
SELECT
  AVG(y) AS median
FROM
  get_median
WHERE
  rn_asc BETWEEN ct/2.0 AND ct / 2.0 + 1;
