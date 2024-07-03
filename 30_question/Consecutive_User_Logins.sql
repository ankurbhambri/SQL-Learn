/*

-- Given is user login table for , identify dates where a user has logged in for 5 or more consecutive days.
-- Return the user id, start date, end date and no of consecutive days, sorting based on user id.
-- If a user logged in consecutively 5 or more times but not spanning 5 days then they should be excluded.

/*
-- Output:
USER_ID		START_DATE		END_DATE		CONSECUTIVE_DAYS
1			10/03/2024		14/03/2024		5
1 			25/03/2024		30/03/2024		6
3 			01/03/2024		05/03/2024		5
4			"2024-03-01"	"2024-03-04"    5
*/


-- PostgreSQL Dataset
drop table if exists user_login;
create table user_login
(
	user_id		int,
	login_date	date
);

insert into user_login values(1, to_date('01/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('02/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('03/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('04/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('06/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('10/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('11/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('12/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('13/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('14/03/2024','dd/mm/yyyy'));

insert into user_login values(1, to_date('20/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('25/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('26/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('27/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('28/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('29/03/2024','dd/mm/yyyy'));
insert into user_login values(1, to_date('30/03/2024','dd/mm/yyyy'));

insert into user_login values(2, to_date('01/03/2024','dd/mm/yyyy'));
insert into user_login values(2, to_date('02/03/2024','dd/mm/yyyy'));
insert into user_login values(2, to_date('03/03/2024','dd/mm/yyyy'));
insert into user_login values(2, to_date('04/03/2024','dd/mm/yyyy'));

insert into user_login values(3, to_date('01/03/2024','dd/mm/yyyy'));
insert into user_login values(3, to_date('02/03/2024','dd/mm/yyyy'));
insert into user_login values(3, to_date('03/03/2024','dd/mm/yyyy'));
insert into user_login values(3, to_date('04/03/2024','dd/mm/yyyy'));
insert into user_login values(3, to_date('04/03/2024','dd/mm/yyyy'));
insert into user_login values(3, to_date('04/03/2024','dd/mm/yyyy'));
insert into user_login values(3, to_date('05/03/2024','dd/mm/yyyy'));

insert into user_login values(4, to_date('01/03/2024','dd/mm/yyyy'));
insert into user_login values(4, to_date('02/03/2024','dd/mm/yyyy'));
insert into user_login values(4, to_date('03/03/2024','dd/mm/yyyy'));
insert into user_login values(4, to_date('04/03/2024','dd/mm/yyyy'));
insert into user_login values(4, to_date('04/03/2024','dd/mm/yyyy'));


*/

with cte as (
	select
		*, login_date - CAST(dense_rank() OVER (ORDER BY user_id, login_date) AS INT) AS diff
	from user_login
	group by user_id, login_date
),
cte2 as (
	select *, count(1) over(partition by diff) cnt
	from cte
)
select
	user_id, min(login_date), max(login_date), cnt
from cte2
where cnt >= 5 
group by user_id, cnt 
order by 1
