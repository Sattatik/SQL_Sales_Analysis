WITH customer_ltv AS 
	(
	SELECT
		customerkey,
		clean_name,
		ROUND (SUM(total_net_revenue)) AS total_ltv
	FROM
		cohort_analysis
	GROUP BY 
		customerkey,
		clean_name
	), percentiles AS 
	(
		
SELECT 
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
FROM customer_ltv
	), 
	segment_values AS 
	(
SELECT
	c.*,
	CASE
		WHEN c.total_ltv < p.ltv_25th_percentile THEN '1-Low-Value '
		WHEN c.total_ltv <= p.ltv_75th_percentile THEN '2-Medium-Value'
		ELSE '3-High-Value'
	END AS ltv_category
FROM customer_ltv c,
	 percentiles p
	 )

SELECT 
	ltv_category,
	SUM (total_ltv) AS total_ltv,
	COUNT (customerkey) AS customer_count,
	ROUND(SUM (total_ltv)/ COUNT (customerkey)) AS avg_ltv
FROM segment_values
GROUP BY 
	ltv_category
ORDER BY 
	ltv_category DESC;
	
	
	WITH customer_ltv AS (
    SELECT
        customerkey,
        clean_name,
        countryfull,
        age,
        ROUND(SUM(total_net_revenue), 2) AS total_ltv,
        SUM(num_orders) AS total_orders
    FROM cohort_analysis
    GROUP BY customerkey, clean_name, countryfull, age
), percentiles AS (
    SELECT 
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
SELECT 
    ltv_category,
    countryfull,
    AVG(age) AS avg_age,
    ROUND(SUM(total_ltv), 2) AS total_ltv,
    COUNT(customerkey) AS customer_count,
    ROUND(SUM(total_ltv) / COUNT(customerkey), 2) AS avg_ltv,
    ROUND(AVG(total_orders), 2) AS avg_orders
FROM segment_values
GROUP BY ltv_category, countryfull
ORDER BY ltv_category DESC, total_ltv DESC;




