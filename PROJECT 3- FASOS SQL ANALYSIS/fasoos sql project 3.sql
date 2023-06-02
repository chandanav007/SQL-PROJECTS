--A.roll Metrics
--B.driver and customer Experience
--C.Ingredient Optimisation
--D.Pricing and Ratings

--A)Roll Metrics
--1)How many rolls were ordered?
-- ans)14
select count(roll_id) from customer_orders;

--2)How many unique customer orders were made?

select count(distinct customer_id) from customer_orders;

--3)How many successful orders were delivered 

select driver_id, count(distinct order_id)from driver_order where cancellation not in ('Cancellation', 'Customer Cancellation')
group by driver_id;

--4)How many of each type of roll was delivered?

select roll_id,count(roll_id) 
from customer_orders where order_id in(
select order_id from
(select *, case when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order)a
where order_cancel_details='nc')
group by roll_id;

--5.How many Veg and Non Vef Rolls were ordered by each customer?
select a.*,b.roll_name from
(
select customer_id, roll_id,count(roll_id)cnt
from customer_orders
group by customer_id,roll_id)a inner join rolls b on a.roll_id=b.roll_id;

--6.What was the maximum number of rolls delivered in a single order?

select * from
(
select*,rank() over(order by cnt desc)rnk from 
(
select order_id,count(roll_id) cnt
from ( 
select * from customer_orders where order_id in (
select order_id from
(select *, case when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order)a
where order_cancel_details='nc'))b
group by order_id
)c)d where rnk= 1;

--7)For each customer,how many delivered rolls had at least 1 change and how many had no changes?


with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' 'then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included=' ' or extra_items_included='NaN'then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
temp_driver_order (order_id,driver_id,pickup_id,distance,duration,new_cancellation)as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation ','Customer Cancellation')then 0 else 1 end as new_cancellation
from driver_order
)
select customer_id,chg_no_chg,count(order_id)at_least_1_change from
(
select *,case when not_include_items= '0' and extra_items_included= '0' then 'no change' else 'change' end chg_no_chg
from temp_customer_orders where order_id in(
select order_id from temp_driver_order where new_cancellation!=0))a
group by customer_id,chg_no_chg;

--8)How many rolls were delivered that had both exclusions and extras?

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' 'then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included=' ' or extra_items_included='NaN'then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
temp_driver_order (order_id,driver_id,pickup_id,distance,duration,new_cancellation)as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation ','Customer Cancellation')then 0 else 1 end as new_cancellation
from driver_order
)
select chg_no_chg,count(chg_no_chg) from 
(select *,case when not_include_items!= '0' and extra_items_included!= '0' then 'both inc exc' else 'either 1 inc or exc' end chg_no_chg
from temp_customer_orders where order_id in(
select order_id from temp_driver_order where new_cancellation!=0))a
group by chg_no_chg;

--9)What was the total number of rolls ordered for each hour of the day?

select
hours_bucket,count(hours_bucket)from
(select*,
concat(cast(datepart(hour,order_date) as timestamp),'-', cast(datepart(hour,order_date)+1 as timestamp)) hours_bucket from customer_orders)a
group by hours_bucket;

--10)What was the number of orders for each day of the week?

select dow,count(distinct order_id)from
(select *, datename(dw,order_date) dow from customer_orders)a
group by dow;

--B)driver and Customer Experience 

--1) What was the average time in minutes it took for each driver to arrive at the fasoos HQ to pickup the order?

select driver_id,sum(diff)/count(order_id) avg_mins from
(select * from
(select *, row_number() over(partition by order_id order by diff ) rnk from 
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time)diff 
from customer_orders a inner join driver_order b on a.order_id=b.order_id
where b.pickup_time is not null)a)b where rnk=1)c
group by driver_id;

--2)Is there any relationship between the number of rolls and how long the order takes to prepare?

select order_id,count(roll_id),sum(diff)/count(roll_id) tym from
(select a.order_id,a.customer_id,a.not_include_items,a.extra_items_included,a.order_date,
b.drive_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time)diff
from customer orders a inner join driver_order on a.order_id,b.order_id
where b.pickup_time is not null)a
group by order_id;

--3) What was the average distance travelled for each customer?

select customer_id,sum(distance)/count(order_id) avg_distance from 
(select * from
(select *,row_number() over(partition by order_id order by diff ) rnk from
(
select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,
cast(trim(replace(lower(n.distance),'km',''))as decimal(4,2))distance,
b.distance,b.duration,b.cancellation,datediff(minute,a.order_dte,b.pickup_time) diff
from customer_orders a inner join driver_order b on a.order_id=b.order_id
where b.pickup_time is not null
)a)b
where rnk=1) c
group by customer_id ;


--4)What was the difference between the longest and shortes delivery times for all orders?


select max(duration)- min(duration) diff from(
select  cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else
duration end as integer) as duration from 
driver_order where duration is not null)a;

--5) What was the average speed for each driver for each delivery and do you notice any trend for these values?
 
 speed=d/t
 select a.order_id,a.driver_id,a.distance/a.duration speed,b.cnt from
 (select order-id,driver_id,cast(trim(replace(lower(distance),'km',''))as decimal(4,2))distance
 ,cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1)else
duration end as integer)as duration from diver_order where distance is not null)a inner join
(select order_id,count(roll-id)cnt from customer_orders group by order_id)b on a.order_id=b.order_id;

--6)What is the successful delivery percentage for ech driver?

sdp= total orders succesfully delivered/total orders taken

select driver_id,s/t cancelled_per from
(select driver_id,sum(can_per)s,count(driver_id)t from
(select drive_id,case when lower(cancellation)like '%cancel%' then 0 else 1 end as can_per from driver_order)a
group by driver_id)b;

