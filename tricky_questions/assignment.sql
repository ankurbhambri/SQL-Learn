select 
	Concat(first_value(games) over(order by cn), ' - ', first_value(cn) over(order by cn)) as Lowest_Countries,
	Concat(first_value(games) over(order by cn), ' - ', first_value(cn) over(order by cn desc)) as Highest_Countries
from 
	(with cte as (select games, noc from athlete_events group by games, noc order by games) 
	select games, count(noc) cn from cte group by games order by 2 desc)
limit 1

with cte as (
	select count(distinct games) tc from athlete_events),
	cte2 as (
		select b.region, a.games from athlete_events a join noc_regions b on a.noc=b.noc group by b.region, a.games
	),
	cte3 as (
		select region, count(games) cn from cte2 group by region
	)
select a.region, b.tc from cte3 a join cte b on a.cn=b.tc order by a.region


with cte as (select count(distinct games) cn from athlete_events where season='Summer'),
cte2 as (select sport, count(distinct games) cn from athlete_events where season = 'Summer'  group by sport order by 2 desc)
select cte2.sport, cte2.cn, cte.cn from cte2, cte where cte.cn=cte2.cn



with cte as (select distinct games, sport from athlete_events),
cte2 as (select sport, count(1) cn from cte group by sport)
select cte2.*, cte.games from cte2, cte where cte2.cn=1 and cte.sport=cte.sport order by cte.sport



select games, count(distinct sport) from athlete_events group by games order by 2 desc, games



with cte as (select *, rank() over(order by age desc) from athlete_events where sex='M' and medal='Gold' and age is not null order by age desc)
select * from cte where rank=1 order by name desc


select round(
	(count(case when sex='M' then 1 end)*1.0 / count(case when sex='F' then 1 end)*1.0), 2)
from athlete_events

with cte as (select count(case when medal in ('Gold', 'Silver', 'Bronze') then 1 end) cn, name from athlete_events group by name order by 1 desc),
cte2 as (select distinct a.name, a.team, dense_rank() over(order by b.cn desc) rank, b.cn
from athlete_events a join cte b on a.name=b.name order by b.cn desc)
select * from cte2 
	where rank <= 5



with cte as (select count(case when medal in ('Gold', 'Silver', 'Bronze') then 1 end) cn, name from athlete_events group by name order by 1 desc),
cte2 as (select distinct a.name, a.team, dense_rank() over(order by b.cn desc) rank, b.cn
from athlete_events a join cte b on a.name=b.name order by b.cn desc)
select * from cte2 
	where rank <= 5


with cte as (select noc, count(case when medal in ('Gold', 'Silver', 'Bronze') then 1 end) cn from athlete_events group by noc order by 2 desc),
cte2 as (select *, dense_rank() over(order by cn desc) rn from cte)
select * from cte2 where rn <= 5


with cte as (select
	distinct games,
	noc,
	count(case when medal = 'Gold' then 1 end) as Gold,
	count(case when medal = 'Silver' then 1 end) as Silver,
	count(case when medal = 'Bronze' then 1 end) as Bronze
from athlete_events 
group by noc, games
order by games, noc),
cte2 as (
	select games, max(Gold) gl, max(Silver) sl, max(Bronze) br from cte group by games
)
select cte.games, concat(noc, ' - ', gl), concat(noc, ' - ', sl), concat(noc, ' - ', br) from cte2, cte 
where cte2.games=cte.games and cte2.gl=cte.Gold or cte2.sl=cte.Silver or cte2.br=cte.Bronze order  by games asc

	select * from noc_regions



select 
	distinct athlete_events.noc,	
	noc_regions.region,
	count(case when medal = 'Silver' then 1 end) as Silver,
	count(case when medal = 'Bronze' then 1 end) as Bronze  
from athlete_events, noc_regions where athlete_events.noc=noc_regions.noc and medal <> 'Gold'
group by noc



select distinct team, games, count(1) over(partition by games) from athlete_events 
	where noc = 'IND' and sport='Hockey' and medal is not null order by 3 desc
	


-- problem 16, 17

with cte as (select 
	games,
	region,
	count(case when medal = 'Gold' then 1 end) as gold,
	count(case when medal = 'Silver' then 1 end) as silver,
	count(case when medal = 'Bronze' then 1 end) as bronze,
	count(1) as tc
from athlete_view
group by games, region),
cte2 as (
	select distinct games, max(gold) gold, max(silver) silver, max(bronze) bronze, max(tc) tc from cte group by games
),
cte3 as (select a.games, a.region, a.gold from cte a, cte2 b where a.games=b.games and a.gold=b.gold),
cte4 as (select a.games, a.region, a.silver from cte a, cte2 b where a.games=b.games and a.silver=b.silver),
cte5 as (select a.games, a.region, a.bronze from cte a, cte2 b where a.games=b.games and a.bronze=b.bronze),
cte6 as (select a.games, a.region, a.tc from cte a, cte2 b where a.games=b.games and a.tc=b.tc)
select
	a.games, 
	concat(a.region, ' - ', a.gold), 
	concat(b.region, ' - ', b.silver), 
	concat(c.region, ' - ', c.bronze),
	concat(d.region, ' - ', d.tc) 
from cte3 a 
join cte4 b on a.games=b.games
join cte5 c on a.games=c.games  
join cte6 d on d.games=c.games
order by a.games



