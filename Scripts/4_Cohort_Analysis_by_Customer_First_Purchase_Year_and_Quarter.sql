--Title: 4_Cohort Analysis by Customer First Purchase Year and Quarter
--Note: Analyses revenue and customer counts for cohorts based on first purchase year and quarter, including product categories
SELECT 
    ca.cohort_year,
    ca.yearquarter,
    p.categoryname,
    COUNT(DISTINCT ca.customerkey) AS total_customers,
    -- Sum rounded total_net_revenue from view for cohort revenue
    ROUND(SUM(ca.total_net_revenue), 2) AS total_revenue,
    -- Calculate average revenue per customer in cohort
    ROUND(SUM(ca.total_net_revenue) / NULLIF(COUNT(DISTINCT ca.customerkey), 0), 2) AS customer_revenue
FROM cohort_analysis ca
-- Join with product table to include category information
JOIN product p ON ca.productkey = p.productkey
-- Filter for first purchase to define cohort
WHERE ca.orderdate = ca.first_purchase_date
GROUP BY ca.cohort_year, ca.yearquarter, p.categoryname
ORDER BY ca.cohort_year, ca.yearquarter, total_revenue DESC;

