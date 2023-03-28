--Data Cleaning 

--Looking at product price by descending order, using ORDER BY and DESC queries
--The data isn't return in descending order because it isnt formated as a value

SELECT purchase_price 

FROM `fourth-blend-376817.customer_data.customer_purchase`

ORDER BY product_price DESC

--To change the purchase price format we use CAST query 
--NOTE: The format of a column can be check at the table schema

SELECT CAST(purchase_price AS FLOAT64) AS new_purchase_price

FROM `fourth-blend-376817.customer_data.customer_purchase`

ORDER BY new_purchase_price DESC;

--Looking at price and date
--Filtered for december
--The date has a format that include timestamp

SELECT date, purchase_price 

FROM `fourth-blend-376817.customer_data.customer_purchase`

WHERE date BETWEEN '2020-12-01' AND '2020-12-31'

--To change the date format to exclude timestamp we can use the CAST query

SELECT CAST(date AS DATE) AS only_date, purchase_price

FROM `fourth-blend-376817.customer_data.customer_purchase`

WHERE date BETWEEN '2020-12-01' AND '2020-12-31';

--To Joing two strings into one column we use CONCAT() query
--NOTE: in this case, useful to identify which color codes are the most pupular

SELECT CONCAT(product_code, product_color) AS new_product_code,

FROM `fourth-blend-376817.customer_data.customer_purchase`

WHERE product = 'couch'

--Filling out blanks
--COALESCE can be use as an alternative to filling out blanks.
--COALESCE use values in other columns to execute
--By checking the value of the indicating column and retrieving a value
--from a second column

SELECT COALESCE(product, product_code) AS product_info

FROM `fourth-blend-376817.customer_data.customer_purchase`

-- Change misspell with CASE statement

SELECT customer_id CASE
                      WHEN first_name = 'Tnoy' THEN 'Tony
                      ELSE first_name
                      END AS cleaned_name

FROM `fourth-blend-376817.customer_data.customer_name`


