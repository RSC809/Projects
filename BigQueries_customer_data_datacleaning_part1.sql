--Data Cleaning without updating Table

--Looking at customer ids

SELECT customer_id 

FROM `fourth-blend-376817.customer_data.customer_address` 

--Accounting for duplicates. 
--To avoid duplicates we use DISTINT quwry at the SELECT statement

SELECT DISTINCT customer_id

FROM `fourth-blend-376817.customer_data.customer_address` 

--Checking for misspells when the LENGTH in the string values has fixed length
--We use the LENGTH query at WHERE to filter for are condition

SELECT LENGTH(country) AS letters_country, country

FROM `fourth-blend-376817.customer_data.customer_address` 

WHERE LENGTH(country)>2

--Use SUBSTR to account for Misspell without UPDATING the table
--NOTE: most usefull when we can't update table
--the Substring query, SUBSTR, is use in the WHERE statement

SELECT DISTINCT customer_id

FROM `fourth-blend-376817.customer_data.customer_address` 

WHERE SUBSTR(country, 1, 2) = 'US'

--Checking for extra apces when the LENGTH in the string values has fixed length 
--A field with extra spaces
--To find it we can also use LENGTH() statement

SELECT state

FROM `fourth-blend-376817.customer_data.customer_address` 

WHERE LENGTH(state) > 2

--Use TRIM to account for extra space without UPDATING the table

SELECT DISTINCT customer_id, state

FROM `fourth-blend-376817.customer_data.customer_address` 

WHERE TRIM(state) = 'OH'
