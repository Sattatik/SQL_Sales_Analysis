DROP VIEW cohort_analysis;
--Title: Cohort Analysis VIEW for Customer Revenue by First Purchase Year
--Note: Aggregates sales data to calculate customer revenue and first purchase date for cohort analysis
CREATE OR REPLACE VIEW public.cohort_analysis AS
WITH customer_revenue AS (
    SELECT 
        s.customerkey,
        s.orderdate,
        d.datekey,
        d.year,
        d.yearquarter,
        d.month,
        SUM(s.quantity::double precision * s.netprice * COALESCE(s.exchangerate, 1.0)) AS total_net_revenue,
        --Note: Cast quantity to DOUBLE PRECISION for accurate multiplication with netprice and exchangerate
		--Note: COALESCE handles potential null exchangerate values in the dataset
        COUNT(s.orderkey) AS num_orders,
        c.countryfull,
        c.age,
        c.givenname,
        c.surname,
        s.productkey,
        s.storekey
    FROM sales s
    LEFT JOIN customer c ON s.customerkey = c.customerkey
	--Note: Join with date table to enable time-based analysis (year, quarter, month)
    JOIN date d ON s.orderdate = d.date
    GROUP BY s.customerkey, s.orderdate, d.datekey, d.year, d.yearquarter, d.month, 
             c.countryfull, c.age, c.givenname, c.surname, s.productkey, s.storekey
)
SELECT 
    customerkey,
    orderdate,
    productkey,
    datekey,
    storekey,
    year,
    yearquarter,
    month,
	--Note: Round total_net_revenue to 2 decimal places for business-readable output
  	ROUND(total_net_revenue::numeric, 2) AS total_net_revenue,
    num_orders,
    countryfull,
    age,
    CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS clean_name,
	--Note: Window function to calculate first purchase date for cohort analysis
    MIN(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM customer_revenue;