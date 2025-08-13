--Title: 3_Customer Retention and Churn Analysis by Cohort Year and Quarter
--Note: Calculates churn (no purchases in last 6 months) and retention rates, including revenue impact
WITH customer_last_purchase AS (
    SELECT
        customerkey,
        clean_name,
        orderdate,
    	yearquarter,
        ROW_NUMBER() OVER (PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,-- Identify last purchase per customer using ROW_NUMBER
        first_purchase_date,
        cohort_year,
        total_net_revenue
    FROM cohort_analysis
), churned_customers AS (
    SELECT -- Define churn as no purchases in last 6 months from max sales date
        customerkey,
        clean_name,
        orderdate AS last_purchase_date,
        -- yearquarter,
        CASE 
            WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' 
            THEN 'Churned'
            ELSE 'Active'
        END AS customer_status,
        cohort_year,
        total_net_revenue
    FROM customer_last_purchase
    WHERE rn = 1   -- Ensure customers have enough history to be considered for churn
        AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)
SELECT -- Summarize customer counts and revenue by cohort year and status
    cohort_year,
  --  yearquarter,
    customer_status,
    COUNT(customerkey) AS num_customers,
  	SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year) AS total_customers,
    ROUND(COUNT(customerkey) * 1.0 / NULLIF(SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year ), 0), 2) AS status_pct, --,yearquarter
    ROUND(SUM(total_net_revenue), 2) AS total_revenue,
    Round(SUM(total_net_revenue / (2025 - cohort_year)),2) AS adjusted_revenue
FROM churned_customers
GROUP BY cohort_year, customer_status -- yearquarter,
ORDER BY cohort_year, customer_status; -- yearquarter,
