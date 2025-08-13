DROP VIEW cohort_analysis;

-- New view with extended infromation such as stores inf and client 

CREATE OR REPLACE VIEW public.cohort_analysis
AS WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            d.datekey,
            d.year,
            d.yearquarter,
            d.month,
            sum(s.quantity::double precision * s.netprice * COALESCE(s.exchangerate, 1.0::double precision)) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname,
            s.productkey,
            s.storekey
           FROM sales s
             LEFT JOIN customer c ON s.customerkey = c.customerkey
             JOIN date d ON s.orderdate = d.date
          GROUP BY s.customerkey, s.orderdate, d.datekey, d.year, d.yearquarter, d.month, c.countryfull, c.age, c.givenname, c.surname, s.productkey, s.storekey
        )
 SELECT customerkey,
    orderdate,
    productkey,
    datekey,
    storekey,
    year,
    yearquarter,
    month,
    round(total_net_revenue::numeric, 2) AS total_net_revenue,
    num_orders,
    countryfull,
    age,
    concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS clean_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue;