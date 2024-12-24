select  * from amazon_sales;
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE amazon_sales1
ADD timeofday VARCHAR(50);
UPDATE amazon_sales
SET timeofday = 
    CASE 
        WHEN TIME(Time) BETWEEN '00:00:01' AND '10:59:59' THEN 'Morning'
        WHEN TIME(Time) BETWEEN '11:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END;
    
alter table amazon_sales
add dayname varchar(30);

UPDATE amazon_sales
SET Date = STR_TO_DATE(Date, '%d-%m-%Y')
WHERE STR_TO_DATE(Date, '%d-%m-%Y') IS NOT NULL;

UPDATE amazon_sales
SET dayname = DAYNAME(Date);

alter table amazon_sales
add monthname varchar(30);

UPDATE amazon_sales
SET monthname = MONTHNAME(Date);

-- 1.What is the count of distinct cities in the dataset?

select count(distinct city) as no_of_cities 
from amazon_sales;

-- 2. For each branch, what is the corresponding city?

select distinct(branch), city 
from amazon_sales;

-- 3. What is the count of distinct product lines in the dataset?

select count(distinct product_line) as No_of_productlines 
from amazon_sales;

-- 4.Which payment method occurs most frequently?

select payment, count(*) as No_of_payments
from amazon_sales
group by payment
order by No_of_payments desc
limit 1 ;

-- 5.Which product line has the highest sales?

select Product_line, sum(Total) as Total_sales
from amazon_sales
group by Product_line
order by Total_sales desc
limit 1 ;

-- 6. How much revenue is generated each month?

select monthname, sum(cogs) as Revenue 
from amazon_sales
group by monthname;

-- 7.In which month did the cost of goods sold reach its peak? 

select monthname, sum(cogs) as Total_cogs
from amazon_sales
group by monthname
order by Total_cogs desc
limit 1;

-- 8.Which product line generated the highest revenue? 

select product_line, sum(cogs) as Revenue 
from amazon_sales
group by product_line
order by Revenue desc
limit 1;

-- 9.In which city was the highest revenue recorded? 

select city, sum(cogs) as Revenue 
from amazon_sales
group by city
order by Revenue desc
limit 1;

-- 10.Which product line incurred the highest Value Added Tax? 

select product_line, sum(Vat) as Total_vat
from amazon_sales
group by product_line
order by Total_vat desc
limit 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 

with cte1 as(
select product_line, avg(Total) as avg_sales
from amazon_sales
group by Product_line)
select amazon_sales.*, avg_sales,
case 
 when Total > avg_sales then "Good"
 else "Bad"
 end as Sales_performance
 from amazon_sales inner join cte1
 on amazon_sales.Product_line = cte1.Product_line;
 
 -- 12.Identify the branch that exceeded the average number of products sold.
 
with cte1 as(
 select branch, sum(quantity) as total_quantity
 from amazon_sales
 group by branch)
 select *  from cte1
 where total_quantity > (select avg(total_quantity) from cte1);
 
 -- 13. Which product line is most frequently associated with each gender? 
 
 with cte1 as(
 select Gender, product_line, count(*) as frequency,
 dense_rank() over(partition by Gender order by count(*) desc) as rn
 from amazon_sales
 group by Gender, product_line)
select Gender, product_line, frequency
from cte1
where rn = 1;



-- 14.Calculate the average rating for each product line. 

select product_line, Round(avg(rating),3) as avg_rating
from amazon_sales
group by product_line;

-- 15.Count the sales occurrences for each time of day on every weekday.

select dayname, timeofday, count(*) no_of_sales
from amazon_sales
group by dayname, timeofday
order by dayname, FIELD(timeofday, 'Morning', 'Afternoon', 'Evening');

-- 16.Identify the customer type contributing the highest revenue. 

select customer_type, Round(sum(cogs), 2) as total_revenue 
from amazon_sales
group by Customer_type
order by total_revenue desc
limit 1;

-- 17.Determine the city with the highest VAT percentage. 

with cte1 as (
select city, sum(unit_price * quantity) as Product_cost, sum(vat) as tax
from amazon_sales
group by city),
cte2 as(
select city, ((tax/Product_cost)*100) as tax_percentage,
dense_rank() over(order by (tax/Product_cost)*100 desc) as rn 
from cte1)
select  city, tax_percentage
from cte2
where rn = 1;

-- 18. Identify the customer type with the highest VAT payments. 

select customer_type, sum(vat) as total_vat 
from amazon_sales
group by customer_type
order by total_vat desc
limit 1;

-- 19. What is the count of distinct customer types in the dataset? 

select count(distinct customer_type) as No_of_customers_types
from amazon_sales;


-- 20. What is the count of distinct payment methods in the dataset?

select count(distinct payment) as No_of_payment_methods
from amazon_sales;


-- 21. Which customer type occurs most frequently?

select customer_type, count(*) as frequency
from amazon_sales
group by customer_type
order by frequency desc
limit 1;
 
-- 22.Identify the customer type with the highest purchase frequency. 
 
select customer_type, sum(total) as Total_purchase
from amazon_sales
group by customer_type
order by Total_purchase desc
limit 1;

-- 23.Determine the predominant gender among customers.

select gender, count(*) as no_of_customers
from amazon_sales
group by gender
order by no_of_customers desc
limit 1;
 
 -- 24.Examine the distribution of genders within each branch.
 
 select branch, gender, count(*) as no_of_customers
 from amazon_sales
 group by branch, gender
 order by branch, gender;
 
-- 25. Identify the time of day when customers provide the most ratings.

select timeofday, count(rating) as no_of_rating
from amazon_sales
group by timeofday
order by no_of_rating desc
limit 1;

-- 26. Determine the time of day with the highest customer ratings for each branch.

select branch, timeofday, no_of_rating
from(
select branch, timeofday, count(rating) as no_of_rating,
dense_rank() over(partition by branch order by count(rating) desc) as rn
from amazon_sales
group by branch, timeofday
) x1
where rn = 1;

-- 27. Identify the day of the week with the highest average ratings.

select dayname, round(avg(rating),3) as avg_rating
from amazon_sales
group by dayname
order by avg_rating desc
limit 1;

-- 28.Determine the day of the week with the highest average ratings for each branch.

select branch, dayname, avg_rating
from
(select branch, dayname, round(avg(rating),3) as avg_rating,
dense_rank() over(partition by branch order by round(avg(rating),3) desc) as rn
from amazon_sales
group by branch, dayname) x1
where rn = 1;
    



