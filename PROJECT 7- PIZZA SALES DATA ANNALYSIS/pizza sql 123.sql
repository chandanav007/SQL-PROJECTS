--A.KPIs

--1) What is the total revenue of the pizza?

SELECT SUM([total_price]) AS Total_Revenue
FROM [dbo].[pizza_sales];

--2)What is average order value of orders?

select * from pizza_sales;
select sum([total_price])/ COUNT(distinct [order_id])  as Average_order_value
from pizza_sales;

--3)what is the Total pizza sold?

select * from pizza_sales;

select sum(quantity) as Total_Pizza_Sold
from pizza_sales;

--4) What is the total orders of pizza?

select count(distinct order_id) as Total_order
from pizza_sales;

--5)What is the Average pizza per orders?

select cast(cast(sum(quantity) as decimal(10,2))/
cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) Average_pizza_per_orders 
from pizza_sales;

--Charts requirement
--6)What is the Daily trend for total orders?

select DATENAME(DW, order_date) as order_day, count(distinct order_id) as Total_orders
from pizza_sales
group by DATENAME(DW, order_date);

--7)What is the Hourly trend for total orders?

select * from pizza_sales;
select datepart(hour, order_time) as order_hours,
count(distinct order_id) as Total_orders
from pizza_sales
group by  datepart(hour, order_time)
order by  datepart(hour, order_time);

--8)What is % of Sales by Pizza Category?

select * from pizza_sales;
select pizza_category, sum(total_price) as Total_Sales,sum(total_price) * 100/
(select sum([total_price]) from pizza_sales where MONTH(order_date)= 1) as perc_sales
from pizza_sales
where MONTH(order_date)= 1
group by pizza_category;

--9)What is % of Sales by Pizza size?

select * from pizza_sales;

select  pizza_size, cast(sum(total_price) as decimal(10,2)) as Total_Sales,cast(sum(total_price) * 100/
(select sum([total_price]) from pizza_sales where DATEPART(Quarter, order_date)=1) as decimal(10,2)) as perc_sales
from pizza_sales
where  DATEPART(Quarter, order_date)=1
group by pizza_size
order by perc_sales desc;

--10)what is the Total pizzas sold by pizza category?

select * from pizza_sales;

select pizza_category, sum(quantity) as Total_pizzas_sold
from pizza_sales
group by  pizza_category;

--11)Top 5 best sellers by total Pizzas sold?

select * from pizza_sales

select top 5 pizza_name,sum(quantity) as total_Pizzas_old
from pizza_sales
Group by pizza_name
order by sum(quantity) desc;

--12)Bottom 5 sellers by total Pizzas sold?

select top 5 pizza_name,sum(quantity) as total_Pizzas_old
from pizza_sales
where month(order_date)= 8
Group by pizza_name
order by sum(quantity) asc;

-




