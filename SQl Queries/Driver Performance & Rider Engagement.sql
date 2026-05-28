
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

