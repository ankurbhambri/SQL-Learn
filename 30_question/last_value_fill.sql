/*

DROP TABLE IF EXISTS FOOTER;
CREATE TABLE FOOTER 
(
	id 			INT PRIMARY KEY,
	car 		VARCHAR(20), 
	length 		INT, 
	width 		INT, 
	height 		INT
);

INSERT INTO FOOTER VALUES (1, 'Hyundai Tucson', 15, 6, NULL);
INSERT INTO FOOTER VALUES (2, NULL, NULL, NULL, 20);
INSERT INTO FOOTER VALUES (3, NULL, 12, 8, 15);
INSERT INTO FOOTER VALUES (4, 'Toyota Rav4', NULL, 15, NULL);
INSERT INTO FOOTER VALUES (5, 'Kia Sportage', NULL, NULL, 18); 

SELECT * FROM FOOTER;

*/

-- Solution 1

select *
from (select car from footer where car is not null order by id desc limit 1) car
cross join (select length from footer where length is not null order by id desc limit 1) length
cross join (select width from footer where width is not null order by id desc limit 1) width
cross join (select height from footer where height is not null order by id desc limit 1) height;


-- Solution 2

with cte as (
    SELECT 
        array_agg(car) FILTER (WHERE car IS NOT NULL) car,
            array_agg(length) FILTER (WHERE length IS NOT NULL) len, 

        array_agg(width) FILTER (WHERE width IS NOT NULL) width, 
        array_agg(height) FILTER (WHERE height IS NOT NULL) height
    FROM FOOTER
)
SELECT
	array_length(car, 1),
    car[array_length(car, 1)] AS car,
	len[array_length(len, 1)] AS length,
    width[array_length(width, 1)] AS width,
    height[array_length(height, 1)] AS height
FROM cte;