-- Title: 5_Store Performance by Region and Country
-- Note: Analyzes revenue and efficiency (revenue per square meter) for active stores using cohort_analysis view
SELECT 
    st.countryname,
    st.storecode,
    st.squaremeters,
    -- st.status,
    COUNT(DISTINCT ca.orderdate) AS total_order_dates,
    -- Note: Sum rounded total_net_revenue from view for store revenue
    ROUND(SUM(ca.total_net_revenue), 2) AS total_revenue,
    -- Note: Calculate revenue per square meter for store efficiency
   -- ROUND(SUM(ca.total_net_revenue) / NULLIF(st.squaremeters, 0), 2) AS revenue_per_sqm
    ROUND((SUM(ca.total_net_revenue) / NULLIF(st.squaremeters, 0))::numeric, 2) AS revenue_per_sqm
FROM cohort_analysis ca
-- Note: Join with store table to include country and store details
JOIN store st ON ca.storekey = st.storekey
-- Note: Filter for active stores to focus on current performance
-- WHERE st.status = 'Active'
-- Note: most stores have NUll status
GROUP BY st.countryname, st.storecode, st.squaremeters --, st.status
ORDER BY revenue_per_sqm DESC;
