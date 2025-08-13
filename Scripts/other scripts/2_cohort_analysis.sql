SELECT 
	cohort_year,
	COUNT(DISTINCT customerkey) AS total_cutomers,
	ROUND(SUM(total_net_revenue)) AS total_revenue,
	ROUND(SUM(total_net_revenue) / COUNT(DISTINCT customerkey)) AS customer_revenue 
FROM
	cohort_analysis
WHERE 
	orderdate = first_purchase_date 
GROUP BY
	cohort_year
ORDER BY 
	cohort_year;

