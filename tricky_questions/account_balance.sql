/*
	Write a query to return the account no and the transaction date when the account balance reached 1000.
	Please include only those accounts whose balance currently is >= 1000
*/


with cte as (select 
	account_no,
	transaction_date,
	sum(case when debit_credit = 'credit' then transaction_amount else -transaction_amount end) over(partition by account_no order by transaction_date) balance_til_now,
	sum(case when debit_credit = 'credit' then transaction_amount else -transaction_amount end) over(partition by account_no order by transaction_date range between unbounded preceding and unbounded following) current_balance
from account_balance),
cte2 as (
	select *, (case when balance_til_now >= 1000 then 1 else 0 end) flag from cte 
)
select account_no, min(transaction_date) from cte2 where flag = 1 and current_balance >= 1000 group by account_no
