/*

drop table if exists mountain_huts;
create table mountain_huts 
(
	id 			integer not null unique,
	name 		varchar(40) not null unique,
	altitude 	integer not null
);
insert into mountain_huts values (1, 'Dakonat', 1900);
insert into mountain_huts values (2, 'Natisa', 2100);
insert into mountain_huts values (3, 'Gajantut', 1600);
insert into mountain_huts values (4, 'Rifat', 782);
insert into mountain_huts values (5, 'Tupur', 1370);

drop table if exists trails;
create table trails 
(
	hut1 		integer not null,
	hut2 		integer not null
);
insert into trails values (1, 3);
insert into trails values (3, 2);
insert into trails values (3, 5);
insert into trails values (4, 5);
insert into trails values (1, 5);

select * from mountain_huts;
select * from trails;


Examples:

mountain_huts:

Id Name Altitude
1 Dakonat 1900
2 Natisa 2100
3 Gajantut 1600
4 Rifat 782
5 Tupur 1370

trails:

Hut1 Hut2
1 3
3 2
3 5
4 5
1 5

Your query should return:

startpt middlept endpt
Dakonat Gajantut Tupur
Dakonat Tupur Rifat
Gajantut Tupur Rifat
Natisa Gajantut Tupur

Assume that:

     there is no trail going from a hut back to itself;
     for every two huts there is at most one direct trail connecting them;
     each hut from table trails occurs in table mountain_huts;

*/

with cte as (select
	a.hut1 src, b.name src_name, b.altitude as src_altitude, 
	a.hut2 dest 
from
	trails a
join 
	mountain_huts b on a.hut1 = b.id
),
cte2 as (
	select a.*, b.name dest_name, b.altitude as dest_altitude,
	case when  a.src_altitude > b.altitude then 1 else 0 end as flag
	from cte a join mountain_huts b on a.dest=b.id
),
cte3 as (
	select 
		case when flag = 1 then src else dest end as src,
		case when flag = 1 then src_name else dest_name end as src_name,
		case when flag = 1 then dest else src end as dest,
		case when flag = 1 then dest_name else src_name end as dest_name
	from cte2
)
select
	a.src_name startpt, a.dest_name middlept, b.dest_name endpt 
from cte3 a 
join cte3 b on a.dest=b.src
order by a.src_name
