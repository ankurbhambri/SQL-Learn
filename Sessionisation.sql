with cte as (
	SELECT
		user_id,
		mytimestamp as ogtimestamp,
		case when EXTRACT(EPOCH FROM mytimestamp) - LAG(
			EXTRACT(EPOCH FROM mytimestamp)
		) OVER (PARTITION BY user_id ORDER BY mytimestamp) >= 30 * 60 then 1 else 0 end AS time_interval
	-- , row_number() over(PARTITION BY user_id ORDER BY mytimestamp) rn
	FROM user_timestamps
	ORDER BY 1, 2
)
select 
	user_id, ogtimestamp, time_interval, user_id || '_' || time_interval,
	sum(time_interval) over(PARTITION BY user_id, ogtimestamp) global_session_id,
	sum(time_interval) over(PARTITION BY user_id ORDER BY ogtimestamp) user_session_id
from cte
