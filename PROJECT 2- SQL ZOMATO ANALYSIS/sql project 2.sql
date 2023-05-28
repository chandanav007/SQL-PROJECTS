--1) What is the total amount each customer spent on zomato?

select a.userid,
sum(b.price) total_amt_spent from sales a inner join product b on a.product_id= b.product_id
group by a.userid


--2) How many days has each customer visited zomato?

Select userid, count(distinct created_date)distinct_days from sales group by userid;

--3) What was the first product purchased by each customer?
select * from
(select *, rank() over(partition by userid order by created_date) rnk from sales)a where rnk=1

--4)What is the most purchased item on the menu and how many times was it purchased by all customers?

select userid,count(product_id) cnt from sales where product_id = 
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid

--5)Which item was the most popular for each customer?

select * from
(select *,rank() over(partition by userid order by cnt desc)rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk = 1

--6) Which item was purchased first by the customer after they became a member?
select * from
(select c.*,rank() over(partition by userid order by created_date)rnk from
(select a.userid,a.created_date, a.product_id,b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date) c)d where rnk=1;

--7) Which item was purchased just before the customer became a member?

select * from
(select c.*,rank() over(partition by userid order by created_date desc)rnk from
(select a.userid,a.created_date, a.product_id,b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c)d where rnk=1;

--8)What is the total orders and amount spent for each member before they became a member?

select userid,count(created_date)order_purchased,sum(price) total_amt_spent from
(select c.*,d.price from 
(select a.userid,a.created_date, a.product_id,b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
group by userid;

--9)If buying each product generates points for eg 5rs= 2 zomato point and each product has different purchasing points for eg for p1 5rs=1 zomato point
-- calculate points collected by each columns and for which product most points have been given till now.


select userid,sum(total_points)*2.5 total_money_earned from
(select e.*,amt/points total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid,c.product_id,sum(price) amt from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by userid;

select * from
(select *,rank()over(order by total_point_earned desc)rnk from
(select product_id,sum(total_points) total_point_earned from
(select e.*,amt/points total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid,c.product_id,sum(price) amt from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by product_id)f)g where rnk=1;


--10) In the first one year after a customer joins the gold program(including their join date)irrespective of what the customer has purchased they ear 5 zomato points for every 10rs spentwho earned more more 1 or 3 and what was their points earnings in their first year?

1 zp=2rs
0.5 zp=1rs

select c.*,d.price*0.5 total_points_earned from 
(select a.userid, a.created_date,a.product_id,b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date>gold_signup_date and created_date<=DATEADD(year, 1, gold_signup_date))c
inner join product d on c.product_id=d.product_id;

--11) rnk all the transaction of customers

select *,rank() over(partition by userid order by created_date)rnk from sales;

--12) rank all the transactions for each member whenever they are a zomato gold member for every non gold member transaction mark as na 

select c.*,rank() over(partition by userid order by created_date desc) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a left join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)c;
