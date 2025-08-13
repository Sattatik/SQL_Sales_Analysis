--Title: 1_Customer Segmentation by Lifetime Value (LTV)
--Note: Segments customers into low, medium, and high-value based on LTV percentiles
WITH customer_ltv AS (
    SELECT
        customerkey,
        clean_name,
        countryfull,
        CASE -- Aggregates total revenue and orders by customer, with age grouped for analysis
            WHEN age < 25 THEN 'Under 25'
            WHEN age BETWEEN 25 AND 40 THEN '25-40'
            WHEN age BETWEEN 41 AND 60 THEN '41-60'
            ELSE 'Over 60'
        END AS age_group,
        ROUND(SUM(total_net_revenue), 2) AS total_ltv,
        SUM(num_orders) AS total_orders
    FROM cohort_analysis
    GROUP BY customerkey, clean_name, countryfull, age
), percentiles AS (
    SELECT  -- Uses PERCENTILE_CONT to dynamically calculate LTV thresholds
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
    FROM customer_ltv
), segment_values AS (
    SELECT
        c.*,
        CASE
            WHEN c.total_ltv < p.ltv_25th_percentile THEN '1-Low-Value'
            WHEN c.total_ltv <= p.ltv_75th_percentile THEN '2-Medium-Value'
            ELSE '3-High-Value'
        END AS ltv_category
    FROM customer_ltv c, percentiles p
)
SELECT  --Summarizes LTV and order metrics by segment and region for business insights
    ltv_category,
    countryfull,
    age_group,
    COUNT(customerkey) AS customer_count,
    ROUND(SUM(total_ltv), 2) AS total_ltv,
    ROUND(SUM(total_ltv) / COUNT(customerkey), 2) AS avg_ltv,
    ROUND(AVG(total_orders), 2) AS avg_orders
FROM segment_values
GROUP BY ltv_category, countryfull, age_group
ORDER BY ltv_category DESC, total_ltv DESC;