--Data Analysis, Sortering and Filtering

--Filtering by Genre for comedy

SELECT *

FROM `fourth-blend-376817.movie_data.movies` 

WHERE Genre = "Comedy"

--Applying ORDER BY statement for sortering 
--In this case we sort by release date by descending order
--for descending order we use DESC query

SELECT *

FROM `fourth-blend-376817.movie_data.movies` 

ORDER BY Release_Date DESC

--In the same Query we sort for release date
--And filter for Genre and Revenue using WHERE and AND queries

SELECT *

FROM `fourth-blend-376817.movie_data.movies` 

WHERE Genre = "Comedy" AND Revenue > 300000

ORDER BY Release_Date DESC