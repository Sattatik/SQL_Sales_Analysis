WITH cutomer_last_purchase AS
	(
	SELECT
		customerkey,
		clean_name,
		orderdate,
		ROW_NUMBER () OVER (PARTITION BY customerkey ORDER BY orderdate DESC ) AS rn,
		first_purchase_date ,
		cohort_year
	FROM 
		cohort_analysis	
		), churned_customers AS
	(
SELECT 	
	customerkey,
	clean_name,
--	first_purchase_date,
	orderdate AS cutomer_last_purchase,
	CASE 
		WHEN orderdate < (SELECT Max (orderdate) FROM sales)- INTERVAL '6 months' 
		THEN 'Churd'
		ELSE 'Active'
	END AS customer_status,
			cohort_year
FROM
	cutomer_last_purchase
WHERE rn = 1
	AND first_purchase_date < (SELECT Max(orderdate) FROM sales)- INTERVAL '6 months'
	)

	SELECT
		cohort_year,
		customer_status,
		COUNT(customerkey) AS num_customers,
		SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_cutomers,
		Round(COUNT(customerkey) /SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year),2) AS status_pct
	FROM 
		churned_customers
	GROUP BY cohort_year, customer_status

