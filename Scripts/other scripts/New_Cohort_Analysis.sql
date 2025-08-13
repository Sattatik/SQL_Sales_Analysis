--Title: Cohort Analysis by Customer First Purchase Year and Quarter
--Note: Analyzes revenue and customer counts for cohorts based on first purchase year and quarter, including product categories
SELECT 
    ca.cohort_year,
    ca.yearquarter,
    p.categoryname,
    COUNT(DISTINCT ca.customerkey) AS total_customers,
    --Note: Sum rounded total_net_revenue from view for cohort revenue
    ROUND(SUM(ca.total_net_revenue), 2) AS total_revenue,
    --Note: Calculate average revenue per customer in cohort
    ROUND(SUM(ca.total_net_revenue) / COUNT(DISTINCT ca.customerkey), 2) AS customer_revenue
FROM cohort_analysis ca
JOIN product p ON ca.productkey = p.productkey
--Note: Filter for first purchase to define cohort
WHERE ca.orderdate = ca.first_purchase_date
GROUP BY ca.cohort_year, ca.yearquarter, p.categoryname
ORDER BY ca.cohort_year, ca.yearquarter, total_revenue DESC;