
--Revenue Trends & Pricing Impact
v---------------------------------------------

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