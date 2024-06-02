-- https://platform.stratascratch.com/coding/10319-monthly-percentage-difference/discussion?code_type=1

-- Using lag window function

with cte as (
    select
        to_char(created_at, 'YYYY-MM') year_month,
        sum(value) as curr_rv,
        lag(sum(value)) over() prev_rv
    from sf_transactions
    group by to_char(created_at, 'YYYY-MM')
)
select
    year_month,
    (curr_rv - prev_rv) * 100 / prev_rv as revenue_diff_pct
from cte
order by year_month;


-- Without lag and using left join

with cte as (
    select
        to_char(created_at, 'YYYY-MM') as year_month,
        sum(value) as curr_rv
    from sf_transactions
    group by to_char(created_at, 'YYYY-MM')
)
select
    c1.year_month, c1.curr_rv, c2.curr_rv, c2.year_month,
    (c1.curr_rv - c2.curr_rv) * 100 / c2.curr_rv as revenue_diff_pct
from cte c1
left join cte c2
on c1.year_month = to_char(to_date(c2.year_month, 'YYYY-MM') + interval '1 month', 'YYYY-MM')
order by c1.year_month;