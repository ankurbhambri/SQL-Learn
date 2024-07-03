/*
create table covid_cases
(
	cases_reported	int,
	dates			date	
);
insert into covid_cases values(20124,'2020-01-10');
insert into covid_cases values(40133,'2020-01-15');
insert into covid_cases values(65005,'2020-01-20');
insert into covid_cases values(30005,'2020-02-08');
insert into covid_cases values(35015,'2020-02-19');
insert into covid_cases values(15015,'2020-03-03');
insert into covid_cases values(35035,'2020-03-10');
insert into covid_cases values(49099,'2020-03-14');
insert into covid_cases values(84045,'2020-03-20');
insert into covid_cases values(100106,'2020-03-31');
insert into covid_cases values(17015,'2020-04-04');
insert into covid_cases values(36035,'2020-04-11');
insert into covid_cases values(50099,'2020-04-13');
insert into covid_cases values(87045,'2020-04-22');
insert into covid_cases values(101101,'2020-04-30');
insert into covid_cases values(40015,'2020-05-01');
insert into covid_cases values(54035,'2020-05-09');
insert into covid_cases values(71099,'2020-05-14');
insert into covid_cases values(82045,'2020-05-21');
insert into covid_cases values(90103,'2020-05-25');
insert into covid_cases values(99103,'2020-05-31');
insert into covid_cases values(11015,'2020-06-03');
insert into covid_cases values(28035,'2020-06-10');
insert into covid_cases values(38099,'2020-06-14');
insert into covid_cases values(45045,'2020-06-20');
insert into covid_cases values(36033,'2020-07-09');
insert into covid_cases values(40011,'2020-07-23');	
insert into covid_cases values(25001,'2020-08-12');
insert into covid_cases values(29990,'2020-08-26');	
insert into covid_cases values(20112,'2020-09-04');	
insert into covid_cases values(43991,'2020-09-18');	
insert into covid_cases values(51002,'2020-09-29');	
insert into covid_cases values(26587,'2020-10-25');	
insert into covid_cases values(11000,'2020-11-07');	
insert into covid_cases values(35002,'2020-11-16');	
insert into covid_cases values(56010,'2020-11-28');	
insert into covid_cases values(15099,'2020-12-02');	
insert into covid_cases values(38042,'2020-12-11');	
insert into covid_cases values(73030,'2020-12-26');

PROBLEM STATEMENT: Given table contains reported covid cases in 2020.
Calculate the percentage increase in covid cases each month versus cumulative cases as of the prior month.
Return the month number, and the percentage increase rounded to one decimal. Order the result by the month.

*/


-- 3	283300
-- 1	125262
-- 4	291295
-- 9	115105
-- 6	122194
-- 10	26587
-- 8	54991
-- 7	76044
-- 2	65020
-- 11	102012
-- 12	126171
-- 5	436400

-- with cte as (
-- 	select
-- 		extract(month from dates) as "month",
-- 		sum(cases_reported) as "month_wise"
-- 	from covid_cases
-- 	group by 1
-- )
-- select sum(month_wise) over(partition by month)  from cte


with cte as (
	select
		distinct extract(month from dates) as "month",
		sum(cases_reported) over(partition by extract(month from dates)) as "month_wise",
		sum(cases_reported) over() as total_sum
	from covid_cases
	order by 1
)
select
	month
	, case when month > 1 then (Round((month_wise * 100.0) / lag(month_wise) over(order by month), 1))::varchar else '-' end "month_wise_percentage"
	, lag(month_wise) over(order by month)
from cte
order by 1