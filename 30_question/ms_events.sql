/*

CREATE TABLE DeviceEvents (
    EventName VARCHAR(50),
    DateTime TIMESTAMP,
    DeviceId VARCHAR(50),
    JobId VARCHAR(50),
    BytesFromCdn INT,
    BytesFromPeers INT,
    IsBackGround BOOLEAN,
    PackageId VARCHAR(50),
    NumPeers INT,
    ErrorCode VARCHAR(50)
);

INSERT INTO DeviceEvents (EventName, DateTime, DeviceId, JobId, BytesFromCdn, BytesFromPeers, IsBackGround, PackageId, NumPeers, ErrorCode) VALUES
('DownloadStarted', '2024-05-15 00:00:00', 'D1', 'J1', 0, NULL, NULL, 'P1', 1, NULL),
('DownloadInProgress', '2024-05-15 01:00:00', 'D1', 'J1', 0, NULL, NULL, 'P1', 1, 'E1'),
('DownloadFailureTransient', '2024-05-15 02:00:00', 'D1', 'J1', 0, 100, NULL, 'P1', 1, 'E3'),
('DownloadCompleted', '2024-05-16 03:00:00', 'D1', 'J1', 500, 200, TRUE, 'P1', 1, NULL),
('DownloadStarted', '2024-05-15 02:00:00', 'D1', 'J2', 100, NULL, FALSE, 'P2', 2, NULL),
('DownloadCanceled', '2024-05-15 02:00:00', 'D1', 'J2', 100, 50, FALSE, 'P2', 2, 'E2'),
('DownloadStarted', '2024-05-15 00:00:00', 'D2', 'J1', 0, NULL, NULL, 'P1', 3, NULL),
('DownloadInProgress', '2024-05-15 01:00:00', 'D2', 'J1', 0, NULL, NULL, 'P1', 3, NULL),
('DownloadStarted', '2024-05-15 00:00:00', 'D3', 'J1', 0, NULL, NULL, 'P1', 1, NULL),
('DownloadInProgress', '2024-05-15 01:00:00', 'D3', 'J1', 0, NULL, NULL, 'P1', 1, NULL);


-- Output
 
Can you write a query which gives

* per device per job TotalBytesFromCdn,
* last value of - IsBackGround,
* last value of - PackageId , last value of - ErrorCode
* Per device - Max value of NumPeers

DeviceId	JobId	PackageId	ErrorCode	BytesFromCdn	BytesFromPeers	IsBackGround	NumPeers
D1			 J1			P1			E3			500				300				true			2
D1			 J2			P2			E2			200				50				false			2
D2			 J1			P1																		3
D3			 J1			P1																		1

*/

WITH cte AS (
    SELECT
        DeviceId,
        JobId,
        PackageId,
		MAX(ErrorCode) AS ErrorCode,
        SUM(COALESCE(BytesFromCdn, 0)) AS BytesFromCdn,
        SUM(COALESCE(BytesFromPeers, 0)) AS BytesFromPeers,
		BOOL_OR(IsBackGround) as IsBackGround
    FROM
        DeviceEvents
    GROUP BY DeviceId, JobId, PackageId
),
cte2 AS (
    SELECT DeviceId, MAX(NumPeers) AS NumPeers 
    FROM DeviceEvents 
    GROUP BY DeviceId
)
SELECT a.*, b.NumPeers
FROM cte a 
JOIN cte2 b ON a.DeviceId = b.DeviceId
ORDER BY a.DeviceId, a.JobId, a.PackageId;



