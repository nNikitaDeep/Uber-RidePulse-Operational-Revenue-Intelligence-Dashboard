
--Rider Cohort & Retention Analysis--
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
