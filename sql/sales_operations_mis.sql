DROP TABLE IF EXISTS sales_operations;
CREATE TABLE sales_operations(
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    delivery_date DATE,
    customer_name VARCHAR(100),
    region VARCHAR(30),
    city VARCHAR(50),
    sales_channel VARCHAR(30),
    product_category VARCHAR(50),
    product_name VARCHAR(100),
    quantity NUMERIC(10,2),
    unit_price_inr NUMERIC(12,2),
    discount_pct NUMERIC(6,3),
    gross_sales_inr NUMERIC(14,2),
    discount_amount_inr NUMERIC(14,2),
    net_sales_inr NUMERIC(14,2),
    estimated_cost_inr NUMERIC(14,2),
    profit_inr NUMERIC(14,2),
    payment_method VARCHAR(30),
    order_status VARCHAR(30),
    sales_rep VARCHAR(20)
);

-- Import CSV using pgAdmin Import/Export or psql \copy:
select * from sales_operations;
-- 1. Check row count
SELECT COUNT(*) AS row_count FROM sales_operations;

-- 2. Preview'columns'
SELECT * FROM sales_operations LIMIT 20;

-- 3. Find duplicate order IDs
select order_id, count(*)
from sales_operations group by order_id  having count(*) > 1;

-- 4. Identify missing values
select 
	count(*) filter (where order_date is null) as missing_order_date,
	count(*) filter (where customer_name is null or btrim (customer_name)='') as missing_customers,
	count(*) filter (where quantity is null) as missing_quantity,
	count(*) filter (where discount_pct is null) as missing_discount
from sales_operations;

-- 5. Standardise text values in a cleaned table
drop table if exists sales_orders_clean;

create table sales_orders_clean as
select 
	nullif(btrim(order_id), '') as order_id,
	order_date,
	ship_date,
	delivery_date,
	initcap(lower(btrim(customer_name))) as customer_name,
	initcap(lower(btrim(region))) as region,
	case
		when lower(btrim(city)) = 'ahmedabad' then 'Ahmedabad'
		when lower(btrim(city)) = 'surat' then 'Surat'
		else initcap (lower(btrim(city)))
	end as city,
	initcap(lower(btrim(sales_channel))) as sales_channel,
	initcap(lower(btrim(product_category))) as product_category,
	initcap(lower(btrim(product_name))) as product_name,
	quantity,
	unit_price_inr,
	coalesce(discount_pct,0) as discount_pct,
	coalesce(gross_sales_inr,quantity * unit_price_inr) as gross_sales_inr,
	round(coalesce(gross_sales_inr,quantity * unit_price_inr) * coalesce (discount_pct,0),2) as discount_amount_inr,
	round(coalesce(gross_sales_inr, quantity * unit_price_inr) * (1 - coalesce(discount_pct,0))) as net_sales_inr,
	estimated_cost_inr,
	round(coalesce(gross_sales_inr, quantity * unit_price_inr) * (1 -  coalesce(discount_pct,0)) - coalesce(estimated_cost_inr,0),2) as profit_inr,
	initcap(lower(btrim(payment_method))) as payment_method,
	initcap(lower(btrim(order_status))) as order_status,
	upper(btrim(sales_rep)) as sales_rep
	from sales_operations
	where order_id is not null and btrim(order_id) <> '';

-- 6.De_duplicate safly; keep one row per order_id in a new table
drop table if exists sales_order_dedup;

create table sales_order_dedup as 
	select distinct on (order_id) *
	from sales_orders_clean
	order by order_id, order_date nulls last; 
select * from sales_order_dedup;

--7.basic validations chekcs
select count(*) as clean_roew from sales_orders_clean;
select count(*) as distinct_order_ids,count(distinct order_id) as unique_ids from sales_order_dedup;
select * from sales_orders_clean where quantity <= 0 or unit_price_inr < 0 or discount_pct > 0 or discount_pct > 1;

-- KIP's 
-- 1.Net Sales
select round(sum(net_sales_inr),2) as Net_Sales from sales_orders_Clean;

--2. Gross Profit
select round(sum(quantity * unit_price_inr),2) as Gross_Sales from sales_orders_clean;

--3.Total Orders
select distinct count(order_id) as Total_Oraders from sales_orders_clean;

--4.Total Profit
select round(sum(profit_inr),2) as Total_profit from sales_orders_clean;

--5.Avarage Order Value
select round(sum(net_sales_inr)/count(order_id),2)as Avg_Order_Value from sales_orders_clean; 

--6.Profit Margin
select
	round((sum(profit_inr) / sum(net_sales_inr) * 100):: numeric,2) as Profit_Margin
	from sales_orders_clean;

-- chart

-- 8. Monthly sales and profit trend
select date_trunc('month',order_date):: date as month,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr,
	count(distinct order_id) as orders
from sales_orders_clean
group by 1
order by 1;

--9.Region-wise performance
select region, count(distinct order_id) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr,
	round(100.0 * sum(profit_inr)/nullif(sum(net_sales_inr),0),2) as profit_margin_pct
from sales_orders_clean
group by region
order by net_sales_inr;

--10.category performance
select product_category,sum(quantity) as unit,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr
from sales_orders_clean
group by 1
order by net_sales_inr;

--11.top 10 cities by sales
select city,count(distinct order_id) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr
from sales_orders_clean
group by city
order by net_sales_inr desc limit 10;

--12.chennal performance
select sales_channel, count(distinct order_id) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr,
	round(100.0 * sum(profit_inr)/nullif(sum(net_sales_inr),0),2) as margin_pct
from sales_orders_clean
group by sales_channel
order by net_sales_inr desc;

-- 13.order status summary
select order_status, count(*) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr
from sales_orders_clean
group by order_status
order by net_sales_inr;

--14.late delivery analysis; delivery  orders only
select count(*) as delivered_orders,
	round(avg(delivery_date - order_date)) as avg_order_to_delivery_days,
	count(*) filter (where delivery_date - order_date > 7) as delivery_over_7_days
from sales_orders_clean
where lower (order_status) = 'Delivered' and delivery_date is null;

--15. Rep_wise performance
select sales_rep,count(*) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr
from sales_orders_clean
group by sales_rep
order by net_sales_inr desc;

-- 16. Discount impact 
select 
	case when discount_pct  = 0 then 'No Discount'
		 when discount_pct <= 0.5 then '0 - 5%'
		 when discount_pct <= 0.10 then '5 - 10%'
		 else 'above 10%' end as discount_band,
		 count(*) as orders,
		 round(sum(net_sales_inr),2) as net_sales_inr
from sales_orders_clean
group by 1 order by 1;

--17.payment method mix
select payment_method, count(*) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr
from sales_orders_clean
group by payment_method
order by net_sales_inr;

--18.month over month sales change
with monthly as (
	select date_trunc('month',order_date)::date as month,
	round(sum(net_sales_inr),2) as sales
	from sales_orders_clean
	group by 1
)
select month, round(sales,2) as sales,
	round(lag(sales) over (order by month),2) as previous_month_sales,
	round(100.0 * (sales - lag(sales) over(order by month)) / nullif(lag(sales) over(order by month),0),2) as mon_change_pct
	from monthly order by month;


-- 19.top customers
select customer_name, count(*) as orders,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr
from sales_orders_clean 
group by customer_name
order by net_sales_inr desc limit 10;

--20.create dashboard - ready monthly summary view
create or replace view vw_monthly_mis as
select date_trunc('month', order_date):: date as month,
	region, product_category, sales_channel,
	count(distinct order_id) as orders,
	sum(quantity) as units,
	round(sum(net_sales_inr),2) as net_sales_inr,
	round(sum(profit_inr),2) as profit_inr
from sales_orders_clean
group by 1,2,3,4;

select * from vw_monthly_mis;

select * from sales_orders_clean;


CREATE OR REPLACE VIEW vw_monthly_mis AS
SELECT DATE_TRUNC('month',order_date)::date AS month,
       region, product_category, sales_channel,
       COUNT(DISTINCT order_id) AS orders,
       SUM(quantity) AS units,
       ROUND(SUM(net_sales_inr),2) AS net_sales_inr,
       ROUND(SUM(profit_inr),2) AS profit_inr
FROM sales_orders_dedup GROUP BY 1,2,3,4;



