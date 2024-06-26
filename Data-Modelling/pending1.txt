/*

The interviewer shared the below sample data logs.
Given below sample data

m0	p0	start	0.712
m0	p1	start	0.841
m0	p2	start	1.523
m0	p2	end	1.966
m0	p1	start	2.856
m0	p2	start	3.347
m0	p2	end	3.567
m0	p1	start	3.800
m0	p2	start	4.618
m0	p2	end	5.497
m0	p1	start	5.961
m0	p2	start	6.324
m0	p2	end	6.673
m0	p1	end	7.233
m0	p1	end	7.533
m0	p1	end	7.933
m0	p1	end	8.333
m0	p0	end	9.933
a row m1:p1:start:2.984 means, machine m1 starts process p1 at timestamp 2.984.

Goal:

Design a table schema for this data to be used by data scientist to query metrics such as process with max average elapsed time and they can plot each process.
Design a ETL in python to load data to above data model /table.
Follow-up

How to optimize process to parse the file and load to table. Can it be done with constant memory.
There can be multiple machine m0..mN, each machine can have millions of process entries. How you will scale.

*/


/*


I am a CEO of a taxi company

1) Desing a data model for taxi
2) How do we measure success for the conpany to find KPI (Key Performance Indicator) data
3) What all the tables took like

Follow up sql questions
1) what data point you ade to measure success
2) Now do you design data model
3) About driver and custoner in same table
4 Find out people wo took taxi directly from airport any country %, 
5) Find custmer they have only taken taxi from airport means exclusive for airport.
6) I want to launch same taxi app in diffefent city like(london), so what data point we use to make it successful.
7) what data point you add to measure success
8) Few SOL to find out people wo took taxi for airport any country they i caly tent to open a newcount report)

*/