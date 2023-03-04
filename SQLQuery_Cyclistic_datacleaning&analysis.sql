--Cyclistic, Bike Sharing Company, Data Cleaning & Exploratory Analysis

--1ST STEP – JOIN ALL THE MONTHLY DATA

--Before cleaning the data we perform an UNION of all the available data on Cyclistic. 
--To make the job easier and less prone to mistakes. 
--To join multiple tables in the same query, you can use the UNION ALL keyword to specify the join conditions between the tables. 
--The join conditions specify which columns in the tables should be used to match the rows in the tables.
CREATE TABLE `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all` AS
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id,
start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202301` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202212` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202211` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202210` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202209` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202208` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
 
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202207` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202206` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202205` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202204` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202203` UNION ALL
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_202202`;

--2ND STEP – CHECK FOR DUPLICATES

--By running this query, you will get a table with all the columns, and COUNT(*). Each row corresponds to a unique combination of values, and the COUNT(*) column shows the number of occurrences of that combination.
--If the value in the COUNT(*) column is greater than 1, then there are duplicate rows in the table. You can then take appropriate action to remove the duplicates, such as deleting them or merging them into a single row.
--Note that in this example, all columns are included in the grouping, which means that the query will only identify exact duplicates, where all columns have the same values. If you want to identify duplicates based on specific columns, you can modify the GROUP BY clause accordingly. For this specific case there aren’t any duplicates
SELECT *, COUNT(*)
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
HAVING COUNT(*) > 1;

--3RD STEP – CHECK FOR MISSPELLS IN COLUMNS WITH STRING AND NULL VALUES

--We can check for misspells using GROUP BY and COUNT functions to look at all the string columns. Also, use to identify extra spaces and characters. To group by and count the frequency of string values in a specific column, you can use the following SQL queries to check all the string format columns:
SELECT rideable_type, COUNT(*) AS frequency
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY rideable_type;
--There aren’t any misspells nor cells with extra characters.
SELECT start_station_name, COUNT(*) AS frequency
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY start_station_name ;
--There aren’t any misspells nor cells with extra characters. But 843525 cells are null out of 5,754,248 SELECT start_station_id, COUNT(*) AS frequency
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY start_station_id;
--There aren’t any misspells nor cells with extra characters. But 843525 cells are null out of 5,754,248 --With no Start Station ID nor a Start Station Name, we can’t find the missing values.

SELECT end_station_name, COUNT(*) AS frequency
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY end_station_name;
--There aren’t any misspells nor cells with extra characters. But 902655 cells are null out of 5,754,248
SELECT end_station_id, COUNT(*) AS frequency
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY end_station_id;
--There aren’t any misspells nor cells with extra characters. But 902655 cells are null out of 5,754,248
--With no End Station ID nor End Station Name, We can’t find the missing values.
SELECT member_casual, COUNT(*) AS frequency
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
GROUP BY member_casual;
--There aren’t any misspells nor cells with extra characters. For the member_causal column, casual riders 2343520 and members 3410728

--4TH STEP – WE CHECK MISSPELL IN RIDE IDs

--To check if any strings are misspell for the specified columns, you can use the following SQL query:
SELECT
ride_id
FROM
`fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`
WHERE
LENGTH(ride_id) < 15 OR LENGTH(ride_id)>16

--5TH STEP – WE CREATE NEW COLUMNS FOR THE ANALYSIS.

--This SQL statement is creating a new table called cyclistic_trips_all_V2 in the cyclistic_trips dataset of the fourth-blend- 376817 project. The data for this table is derived from an existing table called cyclistic_trips_all, which is also in the same dataset.
--The new table has four additional columns as compared to the original table, created using the SELECT statement:
--trip_station_names: This column is created using the CONCAT function to concatenate the values in the start_station_name and end_station_name columns. The resulting string is separated by a hyphen (-).
--ride_length: This column is created using the TIMESTAMP_DIFF functions. It calculates the time difference between the started_at and ended_at columns in minutes, and then formats the result as a interger
--day_of_week: This column is created using the EXTRACT function to extract the day of the week from the started_at column. The DAYOFWEEK format code is used to specify that the day of the week should be returned as a number between 1 and 7, where Monday is 1 and Sunday is 7.
--The * in the SELECT statement indicates that all the columns from the original cyclistic_trips_all table should also be included in the new table.
--Overall, this SQL statement is creating a new table with additional columns that provide more insights into the cyclistic_trips_all data. The new columns can be used to analyze the data and gain insights that were not possible with the original table.
CREATE TABLE `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all_V2` AS SELECT
*,
CONCAT(start_station_name, ' - ', end_station_name) AS trip_station_names, TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length, EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all`;

--6TH STEP – WE CREATE A NEW TABLE BUT WITHOUT NULL VALUES FOR START STATION AND END STATION.

--The SQL query you provided is creating a new table called cyclistic_trips_all_V3 in the cyclistic_trips dataset of the fourth- blend-376817 project. The data for this new table is derived from an existing table called cyclistic_trips_all_V2, which is also in the same dataset.
--The SELECT statement is selecting all columns from the cyclistic_trips_all_V2 table without modifying them. The WHERE clause is filtering out any rows where the start_station_name, start_station_id, end_station_name, and end_station_id columns are all NULL. This means that the resulting table will only contain rows where all four of these columns have a non- NULL value.
CREATE TABLE `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all_clean` AS SELECT *
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all_V2`
WHERE start_station_name IS NOT NULL
AND start_station_id IS NOT NULL AND end_station_name IS NOT NULL AND end_station_id IS NOT NULL;
By doing this means 4,437,516 are left out of a total of 5,754,248

--7TH STEP – CHECK FOR OUT OF RANGE VALUES IN RIDE LENGTH.

--The query is selecting the count of all rows in the cyclistic_trips_all_clean table where the ride_length is less than zero.
--The COUNT(*) function is an aggregate function that counts the number of rows in the table that meet the specified condition in the WHERE clause. In this case, the condition is that the ride_length is less than zero, which would indicate that there is an error in the data, as it is not possible for a ride to have a negative duration.
SELECT COUNT(*)
FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all_clean`
WHERE ride_length < 0
--We find that 53 rows have values below zero. This query will delete all the rows where ride_length is less than zero from the cyclistic_trips_all_clean table.
DELETE FROM `fourth-blend-376817.cyclistic_trips.cyclistic_trips_all_clean` WHERE ride_length < 0;
