--Revenue Leakage & Operational Loss Analysis--
-----------------------------------------------

-- Lost Revenue--
SELECT 
    ROUND(SUM(total_fare), 2) AS total_revenue_lost
FROM trips
WHERE status = 'cancelled';


-- Average Lost Revenue--
SELECT 
    ROUND(AVG(total_fare), 2) AS avg_cancelled_fare
FROM trips
WHERE status = 'cancelled';


-- Who is causing bigger business loss? By revenue perspective--

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


-- Identify zones where drivers wait but bookings don’t convert--
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


-- Zone-Level Revenue Leakage--
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


-- Cancellation Reasons--
SELECT 
    reason,
    COUNT(*) AS total_cancellations
FROM cancellations
GROUP BY reason
ORDER BY total_cancellations DESC;