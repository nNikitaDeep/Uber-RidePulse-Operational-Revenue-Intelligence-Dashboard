
-- Trip Cancellation Analysis--


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
