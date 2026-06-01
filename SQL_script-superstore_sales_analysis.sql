/*=========================================================
  PROJECT: Superstore Sales Analysis using SQL
  OBJECTIVE:
  1. Explore dataset
  2. Apply filters
  3. Perform aggregations
  4. Analyze trends
  5. Identify top-performing customers/products
  6. Check data quality
=========================================================*/


/*=========================================================
  SECTION 1: DATA EXPLORATION
=========================================================*/

-- View table structure
DESCRIBE superstore_sales;

-- Preview first 10 rows
SELECT *
FROM superstore_sales
LIMIT 10;

-- Count total records
SELECT COUNT(*) AS Total_Rows
FROM superstore_sales;


/*=========================================================
  SECTION 2: DATA FILTERING
=========================================================*/

-- Sales from West Region
SELECT *
FROM superstore_sales
WHERE Region = 'West';

-- Technology category sales
SELECT *
FROM superstore_sales
WHERE Category = 'Technology';

-- Orders with sales greater than 1000
SELECT *
FROM superstore_sales
WHERE Sales > 1000;

-- Combined filter
SELECT *
FROM superstore_sales
WHERE Region = 'West'
  AND Category = 'Technology'
  AND Sales > 500;


/*=========================================================
  SECTION 3: AGGREGATIONS
=========================================================*/

-- Total sales by region
SELECT
    Region,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Total quantity sold by category
SELECT
    Category,
    SUM(Quantity) AS Total_Quantity
FROM superstore_sales
GROUP BY Category
ORDER BY Total_Quantity DESC;

-- Average sales by category
SELECT
    Category,
    ROUND(AVG(Sales),2) AS Average_Sales
FROM superstore_sales
GROUP BY Category
ORDER BY Average_Sales DESC;

-- Total profit by category
SELECT
    Category,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore_sales
GROUP BY Category
ORDER BY Total_Profit DESC;


/*=========================================================
  SECTION 4: TOP PRODUCTS & CATEGORIES
=========================================================*/

-- Top 10 products by sales
SELECT
    `Product Name`,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY `Product Name`
ORDER BY Total_Sales DESC
LIMIT 10;

-- Top categories by sales
SELECT
    Category,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Top 10 profitable products
SELECT
    `Product Name`,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore_sales
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;


/*=========================================================
  SECTION 5: BUSINESS USE CASES
=========================================================*/

-- Top 10 customers by sales
SELECT
    `Customer Name`,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;

-- Top states by revenue
SELECT
    State,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore_sales
GROUP BY State
ORDER BY Total_Sales DESC
LIMIT 10;


/*=========================================================
  MONTHLY SALES TREND
  (Order Date stored as TEXT)
=========================================================*/

SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Month,
    ROUND(SUM(Sales),2) AS Monthly_Sales
FROM superstore_sales
GROUP BY
    YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y')),
    MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))
ORDER BY Year, Month;


/*=========================================================
  SECTION 6: DUPLICATE RECORD CHECK
=========================================================*/

SELECT
    `Order ID`,
    `Product ID`,
    `Customer ID`,
    COUNT(*) AS Duplicate_Count
FROM superstore_sales
GROUP BY
    `Order ID`,
    `Product ID`,
    `Customer ID`
HAVING COUNT(*) > 1;


/*=========================================================
  SECTION 7: DATA QUALITY CHECKS
=========================================================*/

-- Check total rows
SELECT COUNT(*) AS Total_Rows
FROM superstore_sales;

-- Check missing values
SELECT
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN `Customer ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_ID,
    SUM(CASE WHEN `Order ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Order_ID
FROM superstore_sales;

-- Check duplicate Row IDs
SELECT
    COUNT(*) - COUNT(DISTINCT `Row ID`) AS Duplicate_RowIDs
FROM superstore_sales;


/*=========================================================
  SECTION 8: SALES SUMMARY
=========================================================*/

SELECT
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(AVG(Sales),2) AS Average_Sales,
    ROUND(MAX(Sales),2) AS Highest_Sale,
    ROUND(MIN(Sales),2) AS Lowest_Sale
FROM superstore_sales;


/*=========================================================
  END OF PROJECT
=========================================================*/