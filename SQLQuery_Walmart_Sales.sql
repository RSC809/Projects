--Exploratory Analysis - Walmart Sales Dataset 2011-2014

-- Show the first 10 rows of the data:
SELECT TOP 10 *
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]

-- Count the number of unique Order IDs in the data:
SELECT COUNT(DISTINCT [Order_ID]) AS NumOrders
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]

-- Calculate the total sales for each year:
SELECT YEAR([Order_Date]) AS OrderYear, SUM(Sales) AS TotalSales
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY YEAR([Order_Date]) 
ORDER BY YEAR([Order_Date]);

-- Calculate the total sales for each State:
SELECT State, SUM(Sales) AS TotalSales
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY State 
ORDER BY TotalSales DESC;

-- Calculate the average profit for each category:
SELECT Category, AVG(Profit) AS AvgProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY Category
ORDER BY AvgProfit DESC;

-- Calculate the total profit for each year:
SELECT YEAR([Order_Date]) AS OrderYear, SUM(Profit) AS TotalProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY YEAR([Order_Date])
ORDER BY YEAR([Order_Date]);

-- Calculate the total profit for each state:
SELECT State, SUM(Profit) AS TotalProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY State
ORDER BY TotalProfit DESC;

-- Calculate the total sales and profit for each category and year:
SELECT YEAR([Order_Date]) AS OrderYear, Category, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY YEAR([Order_Date]), Category
ORDER BY YEAR([Order_Date]), TotalSales DESC;

-- Calculate the total sales and profit for each product and year:
SELECT YEAR([Order_Date]) AS OrderYear, [Product_Name], SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY YEAR([Order_Date]), [Product_Name]
ORDER BY YEAR([Order_Date]), TotalSales DESC;

--Calculate the average sales and profit per order:
SELECT AVG(Sales) AS AvgSalesPerOrder, AVG(Profit) AS AvgProfitPerOrder, AVG(Profit)/AVG(Sales) AS Profit_Percent
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis];

--Calculate the total sales and profit for each city:
SELECT City, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit, SUM(Profit)/SUM(Sales) AS Profit_Percent
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY City
ORDER BY TotalSales DESC;

--Calculate the total sales and profit for each customer:
SELECT [Customer_Name], SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit, SUM(Profit)/SUM(Sales) AS Profit_Percent
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
GROUP BY [Customer_Name]
ORDER BY TotalSales DESC;

--Calculate the total sales and profit for each category and year, only including categories with more than 100 orders:
--Using CTE to filter categories with more than 100 orders
WITH OrderCounts AS (
  SELECT Category, YEAR([Order_Date]) AS OrderYear, COUNT(DISTINCT [Order_ID]) AS NumOrders
  FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
  GROUP BY Category, YEAR([Order_Date])
  HAVING COUNT(DISTINCT [Order_ID]) > 100
)
SELECT WalmartSalesAnalysis.Category, WalmartSalesAnalysis.[Order_Date], SUM(WalmartSalesAnalysis.Sales) AS TotalSales, SUM(WalmartSalesAnalysis.Profit) AS TotalProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
INNER JOIN OrderCounts ON WalmartSalesAnalysis.Category = OrderCounts.Category AND YEAR(WalmartSalesAnalysis.[Order_Date]) = OrderCounts.OrderYear
GROUP BY WalmartSalesAnalysis.Category, WalmartSalesAnalysis.[Order_Date]
ORDER BY TotalSales DESC;

-- Calculate the total sales and profit for each product and year, but only include products with a profit margin greater than 40%:
-- Using CTE to Group Products and year
-- Using JOIN to retrieve columns from original table
WITH ProfitMargins AS (
  SELECT [Product_Name], YEAR([Order_Date]) AS OrderYear, SUM(Profit) / SUM(Sales) AS ProfitMargin
  FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
  GROUP BY [Product_Name], YEAR([Order_Date])
)
SELECT WalmartSalesAnalysis.[Product_Name], WalmartSalesAnalysis.[Order_Date], SUM(WalmartSalesAnalysis.Sales) AS TotalSales, SUM(WalmartSalesAnalysis.Profit) AS TotalProfit
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
INNER JOIN ProfitMargins ON WalmartSalesAnalysis.[Product_Name] = ProfitMargins.[Product_Name] AND YEAR(WalmartSalesAnalysis.[Order_Date]) = ProfitMargins.OrderYear
WHERE ProfitMargins.ProfitMargin > 0.4
GROUP BY WalmartSalesAnalysis.[Product_Name], WalmartSalesAnalysis.[Order_Date]
ORDER BY TotalSales DESC;

-- Calculate the total sales for each customer in each year, but only include customers who have placed at least 3 orders:
-- Using CTE to Group by Customer and Year
-- Using JOIN to retrieve columns from original table 
WITH OrderCounts AS (
  SELECT [Customer_Name], YEAR([Order_Date]) AS OrderYear, COUNT(DISTINCT [Order_ID]) AS NumOrders
  FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
  GROUP BY [Customer_Name], YEAR([Order_Date])
)
SELECT WalmartSalesAnalysis.[Customer_Name], YEAR(WalmartSalesAnalysis.[Order_Date]) AS OrderYear, SUM(WalmartSalesAnalysis.Sales) AS TotalSales
FROM [PortfolioProject].[dbo].[WalmartSalesAnalysis]
INNER JOIN OrderCounts ON WalmartSalesAnalysis.[Customer_Name] = OrderCounts.[Customer_Name] AND YEAR(WalmartSalesAnalysis.[Order_Date]) = OrderCounts.OrderYear
WHERE OrderCounts.NumOrders >= 3
GROUP BY WalmartSalesAnalysis.[Customer_Name], YEAR(WalmartSalesAnalysis.[Order_Date])
ORDER BY TotalSales DESC;






