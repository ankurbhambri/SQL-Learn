/*

PROBLEM STATEMENT: In the given input table, there are hotel ratings which are either too high or too low compared to the standard ratings the hotel receives each year. Write a query to identify and exclude these outlier records as shown in expected output below.
Your output should follow the same order of records as shown.

CREATE TABLE hotel_ratings (
    hotel VARCHAR(50),
    year INTEGER,
    rating DECIMAL(2,1)
);


INSERT INTO hotel_ratings (hotel, year, rating) VALUES
('Radisson Blu', 2020, 4.8),
('Radisson Blu', 2021, 3.5),
('Radisson Blu', 2022, 3.2),
('Radisson Blu', 2023, 3.4),
('InterContinental', 2020, 4.2),
('InterContinental', 2021, 4.5),
('InterContinental', 2022, 1.5),
('InterContinental', 2023, 3.8);

*/


select 
	hotel, min(rating), max(rating), round(avg(rating), 2) average,
	percentile_cont(0.1) within group(order by rating) "P10",
	percentile_cont(0.5) within group(order by rating) "P50",
	percentile_cont(0.75) within group(order by rating) "P75", 
	percentile_cont(0.9) within group(order by rating) "P90",
	percentile_cont(0.99) within group(order by rating) "P99"
from hotel_ratings 
group by hotel


-- Now, we can remove values based on the difference between the rating and the average value abs(rating - average), 
-- and then rank them. If this difference is higher than others, rank it as 1 and remove it.
-- Or we can remove values greater than average value by 1 or 2 whatever logic we want to add.
