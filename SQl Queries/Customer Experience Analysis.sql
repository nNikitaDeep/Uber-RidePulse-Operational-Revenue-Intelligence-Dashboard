
--Customer Experience Analysis
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
HAVING COUNT(*) > 10  
ORDER BY avg_rating ASC;

