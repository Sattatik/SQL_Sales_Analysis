-- Customer Revenue and Purchase year
SELECT
	cohort_year,
	COUNT (DISTINCT customerkey) AS total_customers,
	SUM (total_net_revenue) As total_revenue,
	SUM(total_net_revenue) / COUNT (DISTINCT customerkey) AS customer_revenue
FROM 
	cohort_analysis
GROUP BY
	cohort_year
	
-- Monthly Sales Trend
SELECT d.yearmonth, ROUND(SUM(s.netprice)) as total_sales
FROM sales s
JOIN date d ON s.orderdate = d.date
GROUP BY d.yearmonth
ORDER BY d.yearmonth;

-- Top-Selling Products
SELECT p.productname, p.categoryname, SUM(s.quantity) as total_quantity, SUM(s.netprice) as total_sales
FROM sales s
JOIN product p ON s.productkey = p.productkey
GROUP BY p.productname, p.categoryname
ORDER BY total_sales DESC
LIMIT 10;

-- Sales by Customer Age Group
SELECT c.age, ROUND(SUM(s.netprice)) as total_sales
FROM sales s
JOIN customer c ON s.customerkey = c.customerkey
GROUP BY c.age
ORDER BY total_sales DESC;

-- High-Sales Categories
SELECT p.categoryname, Round(SUM(s.netprice)) as total_sales
FROM sales s
JOIN product p ON s.productkey = p.productkey
GROUP BY p.categoryname
ORDER BY total_sales DESC
LIMIT 5;

WITH RankedProducts AS (
  SELECT 
    p.categoryname,
    p.productname,
    Round(SUM(s.netprice)) as total_sales,
    ROW_NUMBER() OVER (PARTITION BY p.categoryname ORDER BY SUM(s.netprice) DESC) as rn
  FROM sales s
  JOIN product p ON s.productkey = p.productkey
  GROUP BY p.categoryname, p.productname
)
SELECT categoryname, productname, total_sales
FROM RankedProducts
WHERE rn <= 3 -- yop 3 products per category
ORDER BY categoryname, total_sales DESC;

-- Quantity
WITH RankedProducts AS (
  SELECT 
    p.categoryname,
    p.productname,
    SUM(s.quantity) as total_quantity,
    ROW_NUMBER() OVER (PARTITION BY p.categoryname ORDER BY SUM(s.quantity) DESC) as rn
  FROM sales s
  JOIN product p ON s.productkey = p.productkey
  GROUP BY p.categoryname, p.productname
)
SELECT categoryname, productname, total_quantity
FROM RankedProducts
WHERE rn <= 3
ORDER BY categoryname, total_quantity DESC;