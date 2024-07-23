/*

CREATE TABLE feed_fact (
    content_id INT,
    user_id INT,
    activity_id INT,
    activity_type VARCHAR(20),
    session_start TIMESTAMP,
    session_end TIMESTAMP
);

-- Insert sample data into feed_fact
INSERT INTO feed_fact (content_id, user_id, activity_id, activity_type, session_start, session_end) VALUES
(1, 101, 1, 'view', '2024-07-22 10:00:00', '2024-07-22 10:05:00'),
(2, 102, 2, 'comment', '2024-07-22 11:00:00', '2024-07-22 11:10:00'),
(3, 103, 3, 'reaction', '2024-07-22 12:00:00', '2024-07-22 12:03:00'),
(1, 104, 1, 'view', '2024-07-22 13:00:00', '2024-07-22 13:15:00'),
(2, 105, 2, 'comment', '2024-07-22 14:00:00', '2024-07-22 14:05:00');

-- Create the content table
CREATE TABLE content (
    date DATE,
    content_id INT,
    content_type VARCHAR(20),
    created_at TIMESTAMP,
    video_duration INT
);

-- Insert sample data into content
INSERT INTO content (date, content_id, content_type, created_at, video_duration) VALUES
('2024-07-22', 1, 'video', '2024-07-22 09:00:00', 300),
('2024-07-22', 2, 'photo', '2024-07-22 10:00:00', NULL),
('2024-07-22', 3, 'text', '2024-07-22 11:00:00', NULL),
('2024-07-22', 4, 'video', '2024-07-22 12:00:00', 600),
('2024-07-22', 5, 'photo', '2024-07-22 13:00:00', NULL);

Questions :- 

- Percentage of video view completed video watch time
- Average video watch time
- Total video watch time

*/

select 
	round(count(case when extract(epoch from a.session_end - a.session_start) >= b.video_duration then 1 else 0 end) * 100.0 / count(b.content_id), 2) as perc_video_watched_completly,
	sum(a.session_end - a.session_start) as total_watch_time, 
	avg(a.session_end - a.session_start) as averga_watch_time
from 
	feed_fact a 
join
	content b 
on 
	a.content_id=b.content_id
where 
	a.activity_type = 'view' and b.content_type = 'video' and 
	b.created_at = current_date - interval '1 day' and 
	b.date = current_date - interval '1 day'
