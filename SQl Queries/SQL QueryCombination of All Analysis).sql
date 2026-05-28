Use ola


---------------------------------------------
--Key Factors Influencing Trip Cancellations--
----------------------------------------------

-- What is the overall cancellation rate? 
SELECT 
   COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
        / COUNT(*)  AS cancellation_rate
FROM trips;


--Who cancels more — riders or drivers? 
SELECT 
    cancellations.cancelled_by, 
    COUNT(*) as cancellation_number
FROM dbo.cancellations  
Group By cancellations.cancelled_by 


--Do cancellations vary by time or location? 
SELECT 
    DATEPART(HOUR, requested_at) AS hour,
    COUNT(*) AS total_trips,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_trips,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
        / COUNT(*) AS cancellation_rate
FROM trips
GROUP BY DATEPART(HOUR, requested_at)
ORDER BY hour;


--Are long-distance trips more likely to be cancelled?
SELECT 
    CASE 
        WHEN distance_km < 5 THEN 'Short (0-5 km)'
        WHEN distance_km BETWEEN 5 AND 10 THEN 'Medium (5-10 km)'
        ELSE 'Long (10+ km)'
    END AS distance_category,
    
    COUNT(*) AS total_trips,
    
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_trips,
    
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
        / COUNT(*) AS cancellation_rate

FROM trips
GROUP BY 
    CASE 
        WHEN distance_km < 5 THEN 'Short (0-5 km)'
        WHEN distance_km BETWEEN 5 AND 10 THEN 'Medium (5-10 km)'
        ELSE 'Long (10+ km)'
    END
ORDER BY cancellation_rate DESC;

--Does waiting time impact cancellations?
SELECT 
    CASE 
        WHEN DATEDIFF(MINUTE, requested_at, started_at) < 5 THEN '0-5 mins'
        WHEN DATEDIFF(MINUTE, requested_at, started_at) BETWEEN 5 AND 10 THEN '5-10 mins'
        WHEN DATEDIFF(MINUTE, requested_at, started_at) BETWEEN 10 AND 15 THEN '10-15 mins'
        ELSE '15+ mins'
    END AS waiting_time_bucket,

    COUNT(*) AS total_trips,

    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_trips,

    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
        / COUNT(*) AS cancellation_rate

FROM dbo.trips
WHERE requested_at IS NOT NULL 
  AND started_at IS NOT NULL

GROUP BY 
    CASE 
        WHEN DATEDIFF(MINUTE, requested_at, started_at) < 5 THEN '0-5 mins'
        WHEN DATEDIFF(MINUTE, requested_at, started_at) BETWEEN 5 AND 10 THEN '5-10 mins'
        WHEN DATEDIFF(MINUTE, requested_at, started_at) BETWEEN 10 AND 15 THEN '10-15 mins'
        ELSE '15+ mins'
    END

ORDER BY cancellation_rate DESC;



-----------------------------------------------
--Patterns in Ride Demand--
-----------------------------------------------

--When is peak ride demand (hour/day)? 
SELECT 
 CASE 
    WHEN DATEPART(HOUR, requested_at) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN DATEPART(HOUR, requested_at) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN DATEPART(HOUR, requested_at) BETWEEN 17 AND 21 THEN 'Evening'
    ELSE 'Night'
END,
count(trip_id) as total_trip,
   COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
        / COUNT(*) AS cancellation_rate
 FROM trips
 GROUP BY  CASE 
    WHEN DATEPART(HOUR, requested_at) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN DATEPART(HOUR, requested_at) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN DATEPART(HOUR, requested_at) BETWEEN 17 AND 21 THEN 'Evening'
    ELSE 'Night'
END
 ORDER BY total_trip desc


 SELECT 
 DATENAME(WEEKDAY, requested_at) as days,
count(trip_id) as total_trip,
   COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
        / COUNT(*) AS cancellation_rate
 FROM trips
 GROUP BY  DATENAME(WEEKDAY, requested_at)
 ORDER BY total_trip desc

 
--Is there a supply-demand mismatch? 
SELECT 
    pickup_location_id,
    COUNT(*) AS total_requests,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 
    / COUNT(*) AS cancellation_rate
FROM trips
GROUP BY pickup_location_id
ORDER BY cancellation_rate DESC;


--Which locations have highest demand? 
SELECT 
    COUNT(t.trip_id) AS total_rides,
    t.pickup_location_id, 
    l.zone_name
FROM dbo.trips AS t
INNER JOIN dbo.locations AS l
    ON t.pickup_location_id = l.location_id
GROUP BY 
    t.pickup_location_id,
    l.zone_name
ORDER BY total_rides DESC;

--What are the most frequent routes? 
select * from locations
select * from trips


SELECT 
    pickup_location_id,
    dropoff_location_id,
    COUNT(*) AS trip_count
FROM trips
GROUP BY 
    pickup_location_id,
    dropoff_location_id
ORDER BY trip_count DESC;

--Most Frequent Trip Distance Bucket
SELECT 
    CASE 
        WHEN distance_km < 5 THEN 'Short'
        WHEN distance_km BETWEEN 5 AND 15 THEN 'Medium'
        ELSE 'Long'
    END AS trip_type,
    COUNT(*) AS total_trips
FROM trips
GROUP BY 
    CASE 
        WHEN distance_km < 5 THEN 'Short'
        WHEN distance_km BETWEEN 5 AND 15 THEN 'Medium'
        ELSE 'Long'
    END
ORDER BY total_trips DESC;


--Most Frequent trip by hour
SELECT 
    DATEPART(HOUR, requested_at) AS hour,
    COUNT(*) AS total_trips
FROM trips
GROUP BY DATEPART(HOUR, requested_at)
ORDER BY total_trips DESC;





------------------------------------------------
--Driver Performance & Rider Engagement--
------------------------------------------------

--Which drivers complete the most trips?
SELECT 
    driver_id,
    COUNT(CASE WHEN trips.status = 'Completed' then 1 END) AS Completed_trips
  
FROM dbo.trips
Group by driver_id
Order by Completed_trips desc


--Is driver rating linked to completion rate?
SELECT 
    t.driver_id,
    COUNT(*) AS total_trips,
    COUNT(CASE WHEN t.status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS completion_rate,
    AVG(r.rating) AS avg_rating
FROM dbo.trips AS t
LEFT JOIN dbo.reviews AS r 
    ON t.trip_id = r.trip_id
GROUP BY t.driver_id
ORDER BY completion_rate DESC;



--Who are the most active riders? 
SELECT rider_id,
      count(*) as Total_trips
FROM trips 
GROUP BY rider_id
ORDER BY Total_trips DESC



---------------------------------------------
--Revenue Trends & Pricing Impact--
----------------------------------------------


--What is total and average revenue per trip?
select sum(total_fare) as Total_revenue, Avg(total_fare) as Avg_revenue from trips
where status = 'completed'


--How does revenue vary over time? 
SELECT 
    DATEPART(HOUR, requested_at) AS hour,
    SUM(total_fare) AS total_revenue,
    COUNT(*) AS total_trips,
    AVG(total_fare) AS avg_fare
FROM trips
WHERE status = 'Completed'   -- 🔥 only completed generate revenue
GROUP BY DATEPART(HOUR, requested_at)
ORDER BY hour;



--Are longer trips more profitable? 

SELECT 
    CASE 
        WHEN distance_km < 5 THEN 'Short'
        WHEN distance_km BETWEEN 5 AND 15 THEN 'Medium'
        ELSE 'Long'
    END AS trip_type,
    AVG(total_fare / NULLIF(distance_km, 0)) AS revenue_per_km
FROM trips
WHERE status = 'Completed'
GROUP BY 
    CASE 
        WHEN distance_km < 5 THEN 'Short'
        WHEN distance_km BETWEEN 5 AND 15 THEN 'Medium'
        ELSE 'Long'
    END
ORDER BY revenue_per_km DESC;

-------------------------------------------
--Customer Experience--
-------------------------------------------

--What is the average rating? 
SELECT AVG(rating) as Average_rating from reviews


---Do completed trips have better ratings? 
SELECT t.status, Avg(r.rating) as Avg_rating, Count(r.rating) as number_of_rating
from trips as t
Left Join reviews as r
ON t.trip_id = r.trip_id
Group by t.status


--Are certain drivers linked to poor ratings?
SELECT 
    t.driver_id,
    COUNT(*) AS total_trips,
    AVG(r.rating) AS avg_rating
FROM trips t
JOIN reviews r
    ON t.trip_id = r.trip_id
GROUP BY t.driver_id
HAVING COUNT(*) > 10   -- filter noise
ORDER BY avg_rating ASC;

-----------------------------------------------
--Cohort Analysis--
-----------------------------------------------

-- Firts Time Rider V/s Repeat Riders

WITH rider_trips AS (
    SELECT 
        rider_id,
        COUNT(*) AS total_trips
    FROM trips
    GROUP BY rider_id
)

SELECT 
    COUNT(CASE WHEN total_trips = 1 THEN 1 END) AS first_time_riders,
    COUNT(CASE WHEN total_trips > 1 THEN 1 END) AS repeat_riders
FROM rider_trips;


-- Rider retention after first trip?

WITH cohort AS (
    SELECT 
        rider_id,
        FORMAT(MIN(requested_at), 'yyyy-MM') AS cohort_month
    FROM trips
    GROUP BY rider_id
),
activity AS (
    SELECT 
        t.rider_id,
        FORMAT(t.requested_at, 'yyyy-MM') AS activity_month
    FROM trips t
)

SELECT 
    c.cohort_month,
    a.activity_month,
    COUNT(DISTINCT c.rider_id) AS active_users
FROM cohort c
JOIN activity a
    ON c.rider_id = a.rider_id
GROUP BY c.cohort_month, a.activity_month
ORDER BY c.cohort_month, a.activity_month;


--Lost Revenue--
SELECT 
    ROUND(SUM(total_fare), 2) AS total_revenue_lost
FROM trips
WHERE status = 'cancelled';


-- Average Lost Revenue--
SELECT 
    ROUND(AVG(total_fare), 2) AS avg_cancelled_fare
FROM trips
WHERE status = 'cancelled';





--Who is causing bigger business loss? By revenue perspective--

SELECT 
    cancelled_by,
    COUNT(*) AS total_cancelled_rides,
    ROUND(SUM(t.total_fare), 2) AS revenue_lost,
    ROUND(AVG(t.total_fare), 2) AS avg_fare_lost
FROM trips t
JOIN cancellations c 
    ON t.trip_id = c.trip_id
WHERE t.status = 'cancelled'
GROUP BY cancelled_by
ORDER BY revenue_lost DESC;


--Identify zones where drivers wait but bookings don’t convert--
SELECT 
    l.zone_name,
    COUNT(DISTINCT driver_id) AS active_drivers,
    COUNT(t.trip_id) AS total_requests,
    ROUND(
        COUNT(t.trip_id) * 1.0 / COUNT(DISTINCT t.driver_id), 
        3
    ) AS requests_per_driver
FROM trips as t
Left Join locations as l
ON t.pickup_location_id = l.location_id
GROUP BY  l.zone_name
ORDER BY requests_per_driver ASC;


--Zone-Level Revenue Leakage--
SELECT 
    l.zone_name,
    COUNT(*) AS cancelled_trips,
    ROUND(SUM(t.total_fare), 2) AS revenue_lost
FROM trips as t
Left Join locations as l
ON t.pickup_location_id = l.location_id
WHERE status = 'cancelled'
GROUP BY l.zone_name
ORDER BY revenue_lost DESC;



--Cancellation Reasons--
SELECT 
    reason,
    COUNT(*) AS total_cancellations
FROM cancellations
GROUP BY reason
ORDER BY total_cancellations DESC;