/*

CREATE TABLE auto_repair_data (
    client VARCHAR(2),
    auto VARCHAR(2),
    repair_date INTEGER,
    indicator VARCHAR(10),
    value VARCHAR(10)
);


INSERT INTO auto_repair_data (client, auto, repair_date, indicator, value) VALUES
('c1', 'a1', 2022, 'level', 'good'),
('c1', 'a1', 2022, 'velocity', '90'),
('c1', 'a1', 2023, 'level', 'regular'),
('c1', 'a1', 2023, 'velocity', '80'),
('c1', 'a1', 2024, 'level', 'wrong'),
('c1', 'a1', 2024, 'velocity', '70'),
('c2', 'a1', 2022, 'level', 'good'),
('c2', 'a1', 2022, 'velocity', '90'),
('c2', 'a1', 2023, 'level', 'wrong'),
('c2', 'a1', 2023, 'velocity', '50'),
('c2', 'a2', 2024, 'level', 'good'),
('c2', 'a2', 2024, 'velocity', 80);


"50"	"wrong"	1
"70"	"wrong"	1
"80"	"good"	1
"80"	"regular"	1
"90"	"good"	2

*/


select
	velocity,
	coalesce (good, 0) as good,
	coalesce (wrong, 0) as wrong,
	coalesce (regular, 0) as regular
from crosstab('select 
					b.value as velocity, a.value as level, count(1) as value
				from 
					auto_repair_data a 
				join 
					auto_repair_data b on a.client=b.client and a.auto=b.auto and a.repair_date=b.repair_date
				where 
					a.indicator=''level'' and b.indicator=''velocity''
				group by 1,2
				order by 1,2'
			, 'select distinct value from auto_repair_data where indicator=''level'' order by value')
as result(velocity varchar, good bigint, regular bigint, wrong bigint)