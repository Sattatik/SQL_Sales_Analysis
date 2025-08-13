CREATE OR REPLACE VIEW public.cohort_analysis AS
WITH customer_revenue AS (
    SELECT 
        s.customerkey,
        s.orderdate,
        SUM(s.quantity::double precision * s.netprice * COALESCE(s.exchangerate, 1.0)) AS total_net_revenue,
        COUNT(s.orderdate) AS num_orders,
        c.countryfull,
        c.age,
        c.givenname,
        c.surname,
        s.productkey,
        s.storekey
    FROM sales s
    LEFT JOIN customer c ON s.customerkey = c.customerkey
    GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname, s.productkey, s.storekey
)
SELECT 
    customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    age,
    CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS clean_name,
    MIN(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM customer_revenue;