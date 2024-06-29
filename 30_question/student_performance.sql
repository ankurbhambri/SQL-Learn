/*

drop table if exists  student_tests;
create table student_tests
(
	test_id		int,
	marks		int
);
insert into student_tests values(100, 55);
insert into student_tests values(101, 55);
insert into student_tests values(102, 60);
insert into student_tests values(103, 58);
insert into student_tests values(104, 40);
insert into student_tests values(105, 50);


Return marks that is greater than previous marks

test_id	   marks
100			55
102			60
105			50
*/

with cte as (
	select
		test_id,
		case 
			when marks > lag(marks, 1, 0) over() then marks
		end as marks
	from student_tests
)
select * from cte where marks is not null



