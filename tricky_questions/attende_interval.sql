
/*

-- Create the EmployeeAttendance table
CREATE TABLE EmployeeAttendance (
    EmployeeID VARCHAR(10),
    Date DATE,
    Status VARCHAR(10)
);

-- Input 

INSERT INTO EmployeeAttendance (EmployeeID, Date, Status) VALUES
('A1', '2024-01-01', 'PRESENT'),
('A1', '2024-01-02', 'PRESENT'),
('A1', '2024-01-03', 'PRESENT'),
('A1', '2024-01-04', 'ABSENT'),
('A1', '2024-01-05', 'PRESENT'),
('A1', '2024-01-06', 'PRESENT'),
('A1', '2024-01-07', 'ABSENT'),
('A1', '2024-01-08', 'ABSENT'),
('A1', '2024-01-09', 'ABSENT'),
('A1', '2024-01-10', 'PRESENT'),
('A2', '2024-01-06', 'PRESENT'),
('A2', '2024-01-07', 'PRESENT'),
('A2', '2024-01-08', 'ABSENT'),
('A2', '2024-01-09', 'PRESENT'),
('A2', '2024-01-10', 'ABSENT');


-- Output

EMPLOYEE | FROM_DATE   | TO_DATE     | STATUS
--------------------------------------------
A1       | 2024-01-01  | 2024-01-03  | PRESENT
A1       | 2024-01-04  | 2024-01-04  | ABSENT
A1       | 2024-01-05  | 2024-01-06  | PRESENT
A1       | 2024-01-07  | 2024-01-09  | ABSENT
A1       | 2024-01-10  | 2024-01-10  | PRESENT
A2       | 2024-01-06  | 2024-01-07  | PRESENT
A2       | 2024-01-08  | 2024-01-08  | ABSENT
A2       | 2024-01-09  | 2024-01-09  | PRESENT
A2       | 2024-01-10  | 2024-01-10  | ABSENT

*/

with cte as (select 
	EmployeeID,
	Date,
	Status, 
 	date - CAST(ROW_NUMBER() OVER (ORDER BY date) AS INT) AS diff
from EmployeeAttendance)
select 
	EmployeeID, 
	Status, 
	diff, 
	date,
	row_number() over(partition by EmployeeID, Status order by date)
from cte
-- group by EmployeeID, Status, diff
-- order by 3 desc



-- SELECT 
--     EmployeeID,
--     STRING_AGG(Date::text, ', ') AS Dates,
--     Status
-- FROM 
--     EmployeeAttendance
-- GROUP BY 
--     EmployeeID, 
--     Status;
