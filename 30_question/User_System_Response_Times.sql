/*

You have been provided with two tables: conversation_messages and interviews.

Write a query to compute the average time it takes for each user to respond to the previous system message. The message type is described in the message_type field where it could be either user or system indicating who sent the message.

Example:

Input:

conversation_messages table

Column	Type
id	int
created_at	timestamp
updated_at	timestamp
text	text
message_type	varchar(255)
interview_id	int
interviews table

Column	Type
id	int
created_at	datetime
updated_at	datetime
user_id	int
Example Output:

user_id	response_times
1	60.00
2	120.00

https://www.interviewquery.com/questions/user-system-response-times?utm_source=youtube&utm_medium=social

*/

with cte as (
	select
	*,
	case when lag(interview_id)	over() = interview_id and lag(message_type) over() = 'system' then lag(created_at) over() end as start_created_at
	from
		conversation_messages
),
cte2 as (
	select
		cast(sum(extract(epoch from created_at - start_created_at)) / count(1) as int) avg_t,
		interview_id 
	from
		cte
	where
		start_created_at is not null
	group by interview_id
)
select 
	a.user_id user_id, avg_t response_times
from interviews a 
join cte2 b 
on a.id=b.interview_id



