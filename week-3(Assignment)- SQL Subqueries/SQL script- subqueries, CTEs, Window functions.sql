/* ============================================================================
   PROJECT: Superstore Sales Data Analysis
   DESCRIPTION: End-to-end SQL analysis including data normalization, 
                Subqueries, CTEs, Window Functions, and Business Insights.
   DIALECT: MySQL
============================================================================ */

/* ----------------------------------------------------------------------------
   STEP 1: DATABASE NORMALIZATION (CREATING TABLES)
---------------------------------------------------------------------------- */

-- 1A. Create Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255),
    segment VARCHAR(100)
);

-- 1B. Create Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(500)
);

-- 1C. Create Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(100),
    customer_id VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


/* ----------------------------------------------------------------------------
   STEP 2: POPULATING TABLES (INSERT & SELECT DISTINCT)
---------------------------------------------------------------------------- */

-- 2A. Insert unique customers (Skipping the CSV header row)
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT 
    `Customer ID`, 
    `Customer Name`, 
    Segment
FROM superstore_raw
WHERE `Customer ID` != 'Customer ID';

-- 2B. Insert unique products (Using GROUP BY/MAX to prevent duplicate ID errors)
INSERT INTO products (product_id, category, sub_category, product_name)
SELECT 
    `Product ID`, 
    MAX(Category), 
    MAX(`Sub-Category`), 
    MAX(`Product Name`)
FROM superstore_raw
WHERE `Product ID` != 'Product ID'
GROUP BY `Product ID`;

-- 2C. Insert unique orders (Parsing strings to proper DATE formats)
INSERT INTO orders (order_id, order_date, ship_date, ship_mode, customer_id, country, city, state, postal_code, region)
SELECT DISTINCT 
    `Order ID`, 
    STR_TO_DATE(`Order Date`, '%m/%d/%Y'), 
    STR_TO_DATE(`Ship Date`, '%m/%d/%Y'), 
    `Ship Mode`, 
    `Customer ID`,
    Country,
    City,
    State,
    `Postal Code`,
    Region
FROM superstore_raw
WHERE `Order ID` != 'Order ID';


/* ----------------------------------------------------------------------------
   STEP 3: FILTERING WITH SUBQUERIES
---------------------------------------------------------------------------- */

-- 3A. Subquery: Find all individual purchases that have above-average sales
SELECT 
    `Order ID`, 
    `Customer Name`, 
    `Product Name`, 
    Sales
FROM superstore_raw
WHERE Sales > (
    SELECT AVG(Sales) FROM superstore_raw WHERE Sales != 'Sales'
)
ORDER BY Sales DESC;

-- 3B. Subquery: Find the single most expensive purchase per customer
-- Note: Using an INNER JOIN approach to prevent query timeout on large datasets
SELECT 
    s1.`Customer ID`, 
    s1.`Customer Name`, 
    s1.`Order ID`, 
    s1.Sales
FROM superstore_raw s1
INNER JOIN (
    SELECT `Customer ID`, MAX(Sales) AS MaxSales
    FROM superstore_raw
    WHERE `Customer ID` != 'Customer ID'
    GROUP BY `Customer ID`
) s2 
  ON s1.`Customer ID` = s2.`Customer ID` 
 AND s1.Sales = s2.MaxSales
ORDER BY s1.`Customer Name`;


/* ----------------------------------------------------------------------------
   STEP 4: AGGREGATIONS WITH CTEs (Common Table Expressions)
---------------------------------------------------------------------------- */

-- 4A. CTE: Compute total sales aggregation per customer
WITH CustomerTotalSales AS (
    SELECT 
        `Customer ID`,
        `Customer Name`,
        SUM(Sales) AS Total_Sales
    FROM superstore_raw
    WHERE `Customer ID` != 'Customer ID'
    GROUP BY `Customer ID`, `Customer Name`
)
SELECT * FROM CustomerTotalSales ORDER BY Total_Sales DESC;


/* ----------------------------------------------------------------------------
   STEP 5: ANALYSIS WITH WINDOW FUNCTIONS (ROW_NUMBER & RANK)
---------------------------------------------------------------------------- */

-- 5A. Window Function: Rank every purchase dynamically for each customer
SELECT 
    `Customer ID`,
    `Customer Name`,
    `Order ID`,
    Sales,
    RANK() OVER(PARTITION BY `Customer ID` ORDER BY Sales DESC) AS Purchase_Rank,
    ROW_NUMBER() OVER(PARTITION BY `Customer ID` ORDER BY Sales DESC) AS Purchase_Row
FROM superstore_raw
WHERE `Customer ID` != 'Customer ID';


/* ----------------------------------------------------------------------------
   STEP 6: COMBINING JOIN + CTE + WINDOW FUNCTIONS
---------------------------------------------------------------------------- */

-- 6A. Final Architecture: Link clean dimension tables to aggregated metric ranks
WITH CustomerSales AS (
    SELECT 
        `Customer ID` AS customer_id,
        SUM(Sales) AS total_sales
    FROM superstore_raw
    WHERE `Customer ID` != 'Customer ID' 
    GROUP BY `Customer ID`
)
SELECT 
    c.customer_id, 
    c.customer_name, 
    c.segment,
    cs.total_sales,
    RANK() OVER (ORDER BY cs.total_sales DESC) AS sales_rank
FROM customers c
JOIN CustomerSales cs 
  ON c.customer_id = cs.customer_id
ORDER BY sales_rank;


/* ----------------------------------------------------------------------------
   STEP 7: SOLVING BUSINESS QUERIES
---------------------------------------------------------------------------- */

-- 7A. Business Query: Top 10 Customers (Highest Lifetime Value)
WITH CustomerSales AS (
    SELECT `Customer ID`, `Customer Name`, SUM(Sales) AS Total_Sales
    FROM superstore_raw 
    WHERE `Customer ID` != 'Customer ID' 
    GROUP BY `Customer ID`, `Customer Name`
)
SELECT * FROM CustomerSales ORDER BY Total_Sales DESC LIMIT 10;

-- 7B. Business Query: Bottom 10 Customers (Lowest Lifetime Value)
WITH CustomerSales AS (
    SELECT `Customer ID`, `Customer Name`, SUM(Sales) AS Total_Sales
    FROM superstore_raw 
    WHERE `Customer ID` != 'Customer ID' 
    GROUP BY `Customer ID`, `Customer Name`
)
SELECT * FROM CustomerSales ORDER BY Total_Sales ASC LIMIT 10;

-- 7C. Business Query: Single-Order Customers (Churn Risk / One-time buyers)
SELECT 
    `Customer ID`, 
    `Customer Name`, 
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(Sales) AS Total_Lifetime_Value
FROM superstore_raw
WHERE `Customer ID` != 'Customer ID'
GROUP BY `Customer ID`, `Customer Name`
HAVING COUNT(DISTINCT `Order ID`) = 1
ORDER BY Total_Lifetime_Value DESC;

-- 7D. Business Query: Top 10 Absolute Highest Transactions vs Company Average
WITH GlobalAverage AS (
    SELECT AVG(Sales) AS Avg_Sale 
    FROM superstore_raw 
    WHERE Sales != 'Sales' 
)
SELECT 
    r.`Order ID`, 
    r.`Customer Name`, 
    r.`Product Name`, 
    r.Sales,
    (SELECT Avg_Sale FROM GlobalAverage) AS Company_Average
FROM superstore_raw r
CROSS JOIN GlobalAverage g
WHERE r.Sales > g.Avg_Sale
ORDER BY r.Sales DESC 
LIMIT 10;