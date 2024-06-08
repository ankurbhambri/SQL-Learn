/*

Given a database of the results of an election, find the number of seats won by each party. There are some rules to going about this:
• There are many constituencies in a state and many candidates who are contesting the election from each constituency.
• Each candidate belongs to a party.
• The candidate with the maximum number of votes in a given constituency wins for that constituency.
The output should be in the following format: Party Seats_won
The ordering should be in the order of seats won in descending order.

create table candidates
(
    id      int,
    gender  varchar(1),
    age     int,
    party   varchar(20)
);

create table results
(
    constituency_id     int,
    candidate_id        int,
    votes               int
);

Output :
Party 		seats_won
Democratic 		2
Republic 		1

*/

select * from candidates;
with cte as (select constituency_id, max(votes) mv from results group by constituency_id),
cte2 as (select r.constituency_id, r.candidate_id from results r join cte c on r.constituency_id=c.constituency_id and r.votes=c.mv)
select a.party, count(a.id) from candidates a join cte2 b on a.id=b.candidate_id group by a.party order by 2 desc

-- using partition by clause

with cte as (select constituency_id, candidate_id, votes, dense_rank() over(partition by constituency_id order by votes desc) rn from results)
select b.party, count(*) from cte a join candidates b on a.candidate_id=b.id where rn = 1 group by b.party order by 2 desc


/*

As part of HackerAd's advertising system analytics, they need a list of the customers who have the most failures and successes in ad campaigns.
There should be exactly two rows that contain type, customer, campaign, total.
• type contains 'success' in the first row and 'failure' in the second. These relate to events.status.
• customer is the customers.first_name and customers.last_name, separated by a single space.
• campaign is a comma-separated list of campaigns.name that are associated with the customer, ordered ascending.
• total is the number of associated events.

Report only 2 customers, the two with the most successful and the most failing campaigns.

create table customers
(
    id          int,
    first_name, a.  varchar(50),
    last_name   varchar(50)
);
create table campaigns
(
    id          int,
    customer_id int,
    name        varchar(50)
);
create table events
(
    campaign_id int,
    status      varchar(50)
);

*/

with cte as (
	select 
		INITCAP(e.status) status, -- to make it capital
		Concat(a.first_name, ' ', a.last_name) customer,
		string_agg(distinct b.name, ', ') campaign,
		count(1) total,
		dense_rank() over(partition by e.status order by count(1) desc) rnk
	from customers a 
	join campaigns b on a.id=b.customer_id 
	join events e on e.campaign_id=b.id
	group by status, 2
)
select status, customer, campaign, total from cte where rnk=1 order by status desc


/*

As part of HackerPoll's election exit poll analytics, a team needs a list of candidates and their top 3,
vote totals and the states where they occurred.

The result should be in the following format: candidate_name, 1st_place, 2nd_ place, 3rd_place.

• Concatenate the candidate's first and last names with a space between them.

• 1st_place, 2nd_place, 3rd_place are comma-separated US state names and numbers of votes,
  in a format "%statename% (%votes%)", for example, "New York (23)".

• Results should be sorted ascending by candidate_name.
	
create table candidates_tab
(
    id          int,
    first_name  varchar(50),
    last_name   varchar(50)
);

create table results_tab
(
    candidate_id    int,
    state           varchar(50)
);

*/

with cte as (
	select
		concat(a.first_name, ' ', a.last_name) candidate_name,
		state,
		concat(state, '(', count(1), ')') state_con,
		dense_rank() over(partition by concat(a.first_name, ' ', a.last_name) order by count(1) desc) rnk
	from candidates_tab a 
	join results_tab b on a.id=b.candidate_id 
	group by 1, 2
	order by state
)
select 
	candidate_name, 
    STRING_AGG(CASE WHEN rnk = 1 THEN state_con ELSE NULL END, ', ') AS "1st_place",
    STRING_AGG(CASE WHEN rnk = 2 THEN state_con ELSE NULL END, ', ') AS "2nd_place",
    STRING_AGG(CASE WHEN rnk = 3 THEN state_con ELSE NULL END, ', ') AS "3rd_place"
from cte
group by 1


/*

Problem Statement: Position table contains the available job vacancies, 
Employee table mentions the employees who already filled some of the vacancies. 
Write an SQL query using the above 2 tables to return the output as shown below.

create table job_positions
(
	id			int,
	title 		varchar(100),
	groups 		varchar(10),
	levels		varchar(10),
	payscale	int,
	totalpost	int
);

create table job_employees
(
	id				int,
	name 			varchar(100),
	position_id 	int
);

*/

with cte as (
	select *, generate_series(1, totalpost) gs from job_positions
),
cte2 as (
	select *, row_number() over(partition by position_id order by id) gs from job_employees
)
select a.id, a.title, a.groups, a.levels, a.payscale, coalesce(name, 'Vacant') 
from cte a left join cte2 b on a.id=b.position_id and a.gs=b.gs
order by a.id
