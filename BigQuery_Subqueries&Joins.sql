--Data Analysis, New York City Share Bike company

--In order to analyze trip duration, routes and number of trips we create a couple of columns:
--'route', by concadenating columns start station and end station name. We use CONCAT query.
--"num_trips" by counting the all the rows. We use COUNT statement
-- and "duration" by converting tripduration into an integer and calculating the average. We use CAST for converting,
-- AVG to calculate average and ROUND to round the decimals to the nearest tenth
-- Addionally we use GROUP BY and ORDER BY to sort the data
-- And LIMIT to see only to top values

SELECT 
  usertype,
  CONCAT(start_station_name, " ", end_station_name) AS route,
  COUNT(*) AS num_trips,
  ROUND(AVG(CAST(tripduration AS int64)/60), 2) AS duration

FROM `bigquery-public-data.new_york.citibike_trips`

GROUP BY start_station_name, end_station_name, usertype

ORDER BY num_trips DESC

LIMIT 10

--Nested Query to calculate average number of bike
--We use a nested query in SELECT statement to create a new column with the average number of bikes

SELECT station_id,num_bikes_available,
(
  SELECT
    AVG(num_bikes_available)

  FROM `bigquery-public-data.new_york.citibike_stations`
) AS avg_num_bikes_available

FROM `bigquery-public-data.new_york.citibike_stations`

--Nested Query to calculate number of rides by station

SELECT 
  station_id, 
  name, 
  number_of_rides AS number_of_rides_starting_at_station

FROM
(
  SELECT 
    CAST(start_station_id AS STRING) AS start_station_id, 
    COUNT(*) AS number_of_rides
  FROM `bigquery-public-data.new_york.citibike_trips`
  GROUP BY start_station_id
) AS station_num_trips

INNER JOIN `bigquery-public-data.new_york.citibike_stations`
  ON station_id = start_station_id

ORDER BY number_of_rides DESC

--Alternative to calculate number of rides by station USING GROUP BY

SELECT start_station_id, name, COUNT(*) AS number_of_rides

FROM `bigquery-public-data.new_york.citibike_trips`
INNER JOIN `bigquery-public-data.new_york.citibike_stations`
  ON SAFE_CAST(station_id AS INT64) = start_station_id

GROUP BY start_station_id, name

ORDER BY number_of_rides DESC