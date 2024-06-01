/*
Problem: Most Modified Extensions

A database contains a list of filenames including their extensions and the dates they were last modified. For each date that a
modification was made, return the date, the extension(s) of the files that were modified the most, and the number of files modified
that date. If more than one file extension ties for the most modifications, return them as a comma-delimited list in reverse
alphabetical order. As an example, see the first row of output in the example below.
*/

select date_modified, string_agg(x.after_dot_value, ','), max(x.cn) from (
	with cte as (
	SELECT 
		date_modified, substring(file_name from position('.' in file_name) + 1) AS after_dot_value, count(*) cn
	FROM 
		files
	group by 1, 2
	order by 1
	)
	select 
		date_modified, after_dot_value, cn, 
		dense_rank() over(partition by date_modified order by cn desc) rn 
	from
		cte
) x
where x.rn = 1
group by 1	
order by 1