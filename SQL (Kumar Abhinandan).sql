create database Analytics

select * from md

delete from md
where [order id] is null

--Case 1: Find out how good West is as compared to East w.r.t. no of products being sold
declare @w1 float
declare @e1 float
set @w1 = (select count(*)  as TPS_in_west from md where (region='West'))
set @e1 = (select count(*)  as TPS_in_east from md where (region='East'))
select round((@w1/@e1),2) as TPS_W_Vs_E

--Case 2: Find out Retention Rate
declare @v1 float
declare @v2 float

set @v1 = (select count([customer id]) from (select [customer id] from md group by [customer id]  having count([order id])>1)as TCRC)
set @v2 = (select count(distinct([customer id])) from md)
select round((@v1/@v2),2)as retention_rate

--Case 3: Write the Query for showing Top 10 Customers as per State sales wise


SELECT Top_10_Customer_state,State,[Customer Name],total_sales
from (select distinct [state],[customer name],sum(sales) as total_sales,
Dense_rank() over(partition by[state] order by Sum(SALES) desc)as Top_10_Customer_state
from md Group by State,[Customer Name])as top_10_customers
where top_10_customers.Top_10_Customer_state<=10

--Case 4: How many customers have not placed the order in last 2 months?


 --- Recent Order Date   
declare @recent_order_date datetime
set @recent_order_date = (select max([order date]) from md)

--- Order Daate 2 Months Before

declare @2_month_before datetime
set @2_month_before = (select dateadd(month,-2,max([order date])) from md)

---Finding Number of customer who ordered in last 2 months

declare @cust_ordered_in_2_months int
set @cust_ordered_in_2_months = (select count(distinct[customer id])as cust_ordered_in_2_months 
from md where [Order Date] between ('2017-10-29 00:00:00') and ('2017-12-29 00:00:00.000'))
select @cust_ordered_in_2_months as no_cust_not_ordered_in_last_2_months

--- Finding Total Number Of Distinct Customers

declare @total_customer int
set @total_customer = (select count(distinct[customer id]) as total_customer from md)
select @total_customer as total_customer

---Customer who do not placed any order in lat two months

select @total_customer - @cust_ordered_in_2_months as no_cust_not_ordered_in_last_2_months


---Case 5: Find all customers who are living in the same city?

---Method 1 :-

select distinct[customer name ],[customer id],[city]
from md where city in (select city from md as city_name 
group by city having count(distinct[customer id])>=1)
order by city

---Method 2:-

select distinct[customer name ],[customer id],[city],sum(sales)
over(partition by[city],[customer id]) as ms from md order by city

