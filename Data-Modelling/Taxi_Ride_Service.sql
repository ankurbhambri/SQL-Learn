/*

Taxi Company would like to design a data model to capture all critical data elements.

Questions -

Track rides done by driver and their Performance

How many rides are happening to a common/famous destinations each day( Airports , Parks , Museums etc)

How many trips are cancelled per day.

How many rides and the average price during the peak hour per day.

what data point you do to measure success the - DAU, MAU, WAU

About driver and custoner in same table

Find out people wo took taxi directly from airport any country %, 

Find custmer they have only taken taxi from airport means exclusive for airport.

I want to launch same taxi app in diffefent city like(london), so what data point we use to make it successful.

*/

Dim_Date
- date_id
- date
- day
- week
- month
- quarter
- year


Dim_user
- user_id
- user_name
- user_email
- user_phone
- user_address

Dim_vehicle
- vehicle_id
- vehicle_type
- vehicle_number
- vehicle_model
- vehicle_color

Dim_Driver
- driver_id
- user_id
- vehicle_id
- driver_license
- driver_rating
- driver_status (active, inactive)

Dim_Location
- Location_id, 
- Location_name
- Latitude
- Longitude
- Landmark Type ( Airport, park, museum)
- Landmark Name
- Landmark City
- State
- country

Fact_payment
- paymet_id
- ride_id
- payment_type (cash, card)
- payment_amount
- payment_date (date_id)
- payment_status (completed, pending)
- taxes
- discount
- total_amount
- payment_gateway
- base_rate
- surge_rate
- tip_amount

Fact_trips
- trip_id
- user_id
- driver_id
- pick_up_Location_id
- drop_Location_id
- payment_id
- trip_starttimestamp (date_id)
- trip_endtimestamp (date_id)
- trip_status (completed, cancelled, progress)
- driver_rating
- customer_rating


-- 1) Track rides done by driver and their Performance

SELECT driver_id, COUNT(distinct driver_id) as total_rides, AVG(driver_rating) as avg_rating from Fact_rides group by driver_id

-- 2) How many rides are happening to a common/famous destinations each day( Airports , Parks , Museums etc)

with cte as (
    select b.Location_name, count(1) trip_counts from Fact_trips a join Dim_Location b on a.pick_up_Location_id = b.Location_id 
    where b.Landmark_Type in ('Airport', 'Museum', 'Park')
    group by b.Location_name
),
cte2 as (
    select b.Location_name, dense_rank() over(order by  trip_counts desc) rnk from cte
)
select b.Location_name from cte2 where rnk <= 2

-- 3) How many trips are cancelled per day.

select count(1) from Fact_trips where trip_status = 'cancelled' group by trip_starttimestamp

-- 4) How many rides and the average price during the peak hour per day.

with cte as (
    select 
        EXTRACT(HOUR from trip_starttimestamp) hour, EXTRACT(day from trip_starttimestamp) day, 
        count(1) trip_count, avg(tip_amount), avg_trip_amount as trip_count 
    from Fact_trips a 
    join Fact_payment b on a.payment_id=b.payment_id 
    group by 1, 2
),
cte2 as (
    select *, dense_rank() over(order by trip_count desc) rnk from cte 
)
select * from cte2 where rnk <= 2


-- What data points do you add to measure success (DAU, MAU, WAU)
    -- Daily Active Users (DAU): Number of unique users using the app per day.
    -- Weekly Active Users (WAU): Number of unique users using the app per week.
    -- Monthly Active Users (MAU): Number of unique users using the app per month.
    -- Ride Completion Rate: Percentage of completed rides out of total requested rides.
    -- Customer Satisfaction: Average rating given by users.
    -- Driver Retention Rate: Percentage of drivers continuing to use the platform over a period.

-- About driver and customer in the same table

    -- This is generally not recommended as drivers and customers have distinct attributes and roles. Keeping them in separate tables ensures better normalization and easier data management.

-- Find out percentage of people who took taxi directly from any airport in any country

SELECT 
    user_id, 
    COUNT(trip_id) AS airport_trips,
    COUNT(trip_id) * 100.0 / (SELECT COUNT(*) FROM Fact_Trips) AS percentage_from_airport
FROM Fact_Trips a 
JOIN Dim_Location b ON a.pick_up_location_id = b.location_id 
WHERE b.landmark_type = 'Airport'
GROUP BY user_id;

-- Find customers who have only taken taxis from airports (exclusive for airports)

SELECT 
    user_id 
FROM Fact_Trips a 
JOIN Dim_Location b ON a.pick_up_location_id = b.location_id 
WHERE b.landmark_type = 'Airport'
GROUP BY user_id
HAVING COUNT(DISTINCT a.trip_id) = (
    SELECT COUNT(*) 
    FROM Fact_Trips c 
    WHERE c.user_id = a.user_id
);


-- Data Points for Launching in a New City (e.g., London)
--     Market Demand: Population density, tourist influx, business hubs.
--     Competitor Analysis: Existing transportation options, pricing strategies.
--     Regulations: Local laws, licensing requirements.
--     User Demographics: Preferences, income levels, frequent destinations.
--     Traffic and Transportation: Public transport availability, traffic patterns.
--     Pricing Strategy: Dynamic pricing, competitive rates.
--     Operational Logistics: Fleet size, driver recruitment.
--     Technology Integration: Localization of app features, payment systems.
--     Marketing Strategy: Targeted campaigns, partnerships.
--     Customer Feedback: Continuous improvement based on user reviews and performance metrics.
