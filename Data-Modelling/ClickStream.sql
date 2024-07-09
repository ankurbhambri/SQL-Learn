select * from raw_clickstream_data

-- Create Date Dimension Table
CREATE TABLE Date_Dimension (
    Date_Key SERIAL PRIMARY KEY,
    Date DATE,
    Day INT,
    Month INT,
    Year INT
);

-- Create Time Dimension Table
CREATE TABLE Time_Dimension (
    Time_Key SERIAL PRIMARY KEY,
    Hour INT,
    Minute INT
);

-- Create User Dimension Table
CREATE TABLE User_Dimension (
    User_Key SERIAL PRIMARY KEY,
    User_ID VARCHAR(50),
    User_Name VARCHAR(100),
    User_Location VARCHAR(100)
);

-- Create Page Dimension Table
CREATE TABLE Page_Dimension (
    Page_Key SERIAL PRIMARY KEY,
    Page_URL VARCHAR(255),
    Page_Title VARCHAR(255)
);

-- Create Referrer Dimension Table
CREATE TABLE Referrer_Dimension (
    Referrer_Key SERIAL PRIMARY KEY,
    Referrer_URL VARCHAR(255),
    Referrer_Type VARCHAR(50)
);


-- Create Customer Session Fact Table
CREATE TABLE Customer_Session_Fact (
    Session_Key SERIAL PRIMARY KEY,
    Universal_Date_Key INT,
    Local_Date_Key INT,
    User_Key INT,
    Entry_Page_Key INT,
    Referrer_Key INT,
    Session_Duration INT,
    Pages_Visited INT,
    Orders_Placed INT,
    Units_Ordered INT,
    Order_Amount DECIMAL(10, 2),
    FOREIGN KEY (Universal_Date_Key) REFERENCES Date_Dimension(Date_Key),
    FOREIGN KEY (Local_Date_Key) REFERENCES Date_Dimension(Date_Key),
    FOREIGN KEY (User_Key) REFERENCES User_Dimension(User_Key),
    FOREIGN KEY (Entry_Page_Key) REFERENCES Page_Dimension(Page_Key),
    FOREIGN KEY (Referrer_Key) REFERENCES Referrer_Dimension(Referrer_Key)
);

-- Create Page Event Fact Table
CREATE TABLE Page_Event_Fact (
    Event_Key SERIAL PRIMARY KEY,
    Date_Key INT,
    Time_Key INT,
    User_Key INT,
    Page_Key INT,
    Referrer_Key INT,
    Event_Type VARCHAR(50),
    Order_Amount DECIMAL(10, 2),
    FOREIGN KEY (Date_Key) REFERENCES Date_Dimension(Date_Key),
    FOREIGN KEY (Time_Key) REFERENCES Time_Dimension(Time_Key),
    FOREIGN KEY (User_Key) REFERENCES User_Dimension(User_Key),
    FOREIGN KEY (Page_Key) REFERENCES Page_Dimension(Page_Key),
    FOREIGN KEY (Referrer_Key) REFERENCES Referrer_Dimension(Referrer_Key)
);

-- Create Session Aggregate Fact Table
CREATE TABLE Session_Aggregate_Fact (
    Aggregate_Key SERIAL PRIMARY KEY,
    Universal_Date_Key INT,
    Local_Date_Key INT,
    User_Key INT,
    Total_Sessions INT,
    Total_Duration INT,
    Total_Pages_Visited INT,
    Total_Orders_Placed INT,
    Total_Units_Ordered INT,
    Total_Order_Amount DECIMAL(10, 2),
    FOREIGN KEY (Universal_Date_Key) REFERENCES Date_Dimension(Date_Key),
    FOREIGN KEY (Local_Date_Key) REFERENCES Date_Dimension(Date_Key),
    FOREIGN KEY (User_Key) REFERENCES User_Dimension(User_Key)
);


-- Transform and Load Date Dimension
INSERT INTO Date_Dimension (Date, Day, Month, Year)
SELECT DISTINCT
    DATE(event_time) AS Date,
    EXTRACT(DAY FROM event_time) AS Day,
    EXTRACT(MONTH FROM event_time) AS Month,
    EXTRACT(YEAR FROM event_time) AS Year
FROM raw_clickstream_data
ON CONFLICT (Date) DO NOTHING;

-- Transform and Load Time Dimension
INSERT INTO Time_Dimension (Hour, Minute)
SELECT DISTINCT
    EXTRACT(HOUR FROM event_time) AS Hour,
    EXTRACT(MINUTE FROM event_time) AS Minute
FROM raw_clickstream_data
ON CONFLICT (Hour, Minute) DO NOTHING;

-- Transform and Load User Dimension
INSERT INTO User_Dimension (User_ID, User_Name, User_Location)
SELECT DISTINCT
    user_id, user_name, user_location
FROM raw_clickstream_data
ON CONFLICT (User_ID) DO NOTHING;

-- Transform and Load Page Dimension
INSERT INTO Page_Dimension (Page_URL, Page_Title)
SELECT DISTINCT
    page_url, page_title
FROM raw_clickstream_data
ON CONFLICT (Page_URL) DO NOTHING;

-- Transform and Load Referrer Dimension
INSERT INTO Referrer_Dimension (Referrer_URL, Referrer_Type)
SELECT DISTINCT
    referrer_url, referrer_type
FROM raw_clickstream_data
ON CONFLICT (Referrer_URL) DO NOTHING;



-- Transform and Load Customer Session Fact
INSERT INTO Customer_Session_Fact (Universal_Date_Key, Local_Date_Key, User_Key, Entry_Page_Key, Referrer_Key, Session_Duration, Pages_Visited, Orders_Placed, Units_Ordered, Order_Amount)
SELECT
    (SELECT Date_Key FROM Date_Dimension WHERE Date = DATE(MIN(event_time))) AS Universal_Date_Key,
    (SELECT Date_Key FROM Date_Dimension WHERE Date = DATE(MIN(event_time AT TIME ZONE 'UTC'))) AS Local_Date_Key,
    u.User_Key,
    (SELECT Page_Key FROM Page_Dimension WHERE Page_URL = MIN(raw.page_url)) AS Entry_Page_Key,
    r.Referrer_Key,
    EXTRACT(EPOCH FROM MAX(event_time)) - EXTRACT(EPOCH FROM MIN(event_time)) AS Session_Duration,
    COUNT(DISTINCT page_url) AS Pages_Visited,
    COUNT(CASE WHEN event_type = 'order' THEN 1 END) AS Orders_Placed,
    COUNT(CASE WHEN event_type = 'order' THEN 1 ELSE NULL END) AS Units_Ordered,
    SUM(order_amount) AS Order_Amount
FROM raw_clickstream_data raw
JOIN User_Dimension u ON raw.user_id = u.User_ID
JOIN Referrer_Dimension r ON raw.referrer_url = r.Referrer_URL
GROUP BY u.User_Key, r.Referrer_Key;


-- Transform and Load Page Event Fact
INSERT INTO Page_Event_Fact (Date_Key, Time_Key, User_Key, Page_Key, Referrer_Key, Event_Type, Order_Amount)
SELECT
    (SELECT Date_Key FROM Date_Dimension WHERE Date = DATE(event_time)) AS Date_Key,
    (SELECT Time_Key FROM Time_Dimension WHERE Hour = EXTRACT(HOUR FROM event_time) AND Minute = EXTRACT(MINUTE FROM event_time)) AS Time_Key,
    u.User_Key,
    p.Page_Key,
    r.Referrer_Key,
    raw.event_type,
    raw.order_amount
FROM raw_clickstream_data raw
JOIN User_Dimension u ON raw.user_id = u.User_ID
JOIN Page_Dimension p ON raw.page_url = p.Page_URL
JOIN Referrer_Dimension r ON raw.referrer_url = r.Referrer_URL;



-- Transform and Load Session Aggregate Fact
INSERT INTO Session_Aggregate_Fact (Universal_Date_Key, Local_Date_Key, User_Key, Total_Sessions, Total_Duration, Total_Pages_Visited, Total_Orders_Placed, Total_Units_Ordered, Total_Order_Amount)
SELECT
    (SELECT Date_Key FROM Date_Dimension WHERE Date = DATE(MIN(event_time))) AS Universal_Date_Key,
    (SELECT Date_Key FROM Date_Dimension WHERE Date = DATE(MIN(event_time AT TIME ZONE 'UTC'))) AS Local_Date_Key,
    u.User_Key,
    COUNT(DISTINCT session_id) AS Total_Sessions,
    SUM(EXTRACT(EPOCH FROM MAX(event_time)) - EXTRACT(EPOCH FROM MIN(event_time))) AS Total_Duration,
    SUM(COUNT(DISTINCT page_url)) AS Total_Pages_Visited,
    SUM(COUNT(CASE WHEN event_type = 'order' THEN 1 END)) AS Total_Orders_Placed,
    SUM(COUNT(CASE WHEN event_type = 'order' THEN 1 ELSE NULL END)) AS Total_Units_Ordered,
    SUM(SUM(order_amount)) AS Total_Order_Amount
FROM raw_clickstream_data raw
JOIN User_Dimension u ON raw.user_id = u.User_ID
GROUP BY u.User_Key;
