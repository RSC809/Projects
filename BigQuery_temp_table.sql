--Using temporary tables to perform calculations

WITH trips_over_1hr AS
(
  SELECT *
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
  WHERE tripduration >= 60
)
## Count How many trips are 60 minutes long by start station name

SELECT COUNT(*) AS number_trips_over_1hr, start_station_name
FROM trips_over_1hr
GROUP BY start_station_name ORDER BY number_trips_over_1hr DESC
