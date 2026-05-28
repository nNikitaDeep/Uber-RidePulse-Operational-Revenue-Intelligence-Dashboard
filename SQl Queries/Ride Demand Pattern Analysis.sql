-----Ride Demand Pattern Analysis-------

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