-- 1. Display the top 3 most frequently rented movies in descending order.
-- Get the movie name and times rented (sakila schema)
use sakila;
with movies(title,times_rented,rank_rental) as (select title,count(rental_id) as times_rented,
rank()over(order by count(rental_id) desc) as rank_rental from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by title
order by count(rental_id) desc)
select * from movies where rank_rental<=3;

-- or

select * from (select title,count(rental_id) as times_rented,
rank()over(order by count(rental_id) desc) as rank_rental from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by title) m
where m.rank_rental <4;

-- 2. Find the total payment received every year and display the same for the respective 
-- records ( for all the payment id's) (sakila schema)

select payment_id,year(payment_date),
sum(amount) over(partition by year(payment_date)) as yr_pay
from payment;


-- 3. Find the overall payment received so far and the amount received for a month of a year, 
-- find the proportion and sort the result based on the highest proportion coming first. 
-- Display the calculated results for all the payment id's (sakila schema)
select payment_id, amount,
		concat(month(payment_date), '-',year(payment_date)),
        sum(amount) over() as overall_amt_recd,
        sum(amount) over(partition by concat(month(payment_date), '-',year(payment_date))) 
        as amt_recd_month,
        round(sum(amount) 
        over(partition by concat(month(payment_date), '-',year(payment_date))) /
        sum(amount) over(),2)
        as prop
from payment
order by prop desc;

-- 4. For department id 80 and commission percentage more than 30% collect the below details:
-- employee id's of each department, their name, department id and the number of employees 
-- in each department (hr schema)
use hr1;
select employee_id,first_name,department_id,count(employee_id) over(partition by department_id)
from employees
where department_id = 80 and commission_pct >0.30;

-- 5. Show the employee id's , employee name, manager id, salary, average salary
-- of employees reporting under each manager and the difference between them (hr schema)
use hr;
select EMPLOYEE_ID, concat(first_name, ' ', last_name) as name, manager_id, salary,
		avg(salary)over(partition by manager_id) as mgr_avg_sal, 
        salary - avg(salary)over(partition by manager_id) as diff
from employees;

-- 6. Get the order date, order id, product id, product quantity and Quantity ordered 
-- in a single day for each record (order schema)
select oh.order_id,oh.order_date,oi.product_id,oi.ordered_qty,
sum(ORDERED_QTY)over(partition by ORDER_DATE) Ouantity_ordered 
from order_header oh
join order_items oi on oh.order_id = oi.order_id;

-- or
select 
	oh.ORDER_DATE,
	oh.ORDER_ID,
    ot.PRODUCT_ID, 
    ot.ORDERED_QTY,
    sum(ot.ORDERED_QTY) over(order by oh.ORDER_DATE range current row ) test
from order_header oh
join order_items ot
on oh.ORDER_ID = ot.ORDER_ID;


-- 7. Divide the employees into 10 groups with highest paid employees coming first.
-- For each employee fetch the emp id, department id salary and the group they belong to (hr schema)
use hr1;
select employee_id,department_id,salary,
ntile(10)over(order by salary desc) as bucket_no
from employees;

-- 8. create a view to get all the product details of cheapest product in each product category
 use product;
DROP VIEW IF EXISTS cheap_prod;
create view cheap_prod as
select * from product p1 where PRODUCT_PRICE =
(select min(PRODUCT_PRICE) from product p2
group by product_category_id
having p1.product_category_id = p2.product_category_id);
select * from cheap_prod;
-- or
CREATE VIEW cheap_prod AS 
select * 
from product 
where (PROD_CAT_ID, product_price) in (select PROD_CAT_ID, min(product_price) 
									from product 
									group by PROD_CAT_ID);
                                    
select * from cheap_prod;

-- 9. create a view high_end_product with product_id, product_desc, product_price,
-- product_category_id, product_category_description having product price 
-- greater than the minimum price of the category 2055 
use product;

DROP VIEW IF EXISTS high_end_product;
create view high_end_product as
select p.product_id, p.product_desc, p.product_price,p.product_category_id,
pc.product_category_description
from product p
join product_category pc on p.product_category_id=pc.product_category_id
where p.PRODUCT_PRICE >
(select min(PRODUCT_PRICE) from product
group by product_category_id
having product_category_id = 2055); 
select * from high_end_product;

-- 10. Make a copy of the product table with name prod_copy and Update the product price of 
-- categories with description containing promotion-medium with 10% increase in price
CREATE TABLE IF NOT EXISTS prod_copy 
SELECT * FROM product;
SET SQL_SAFE_UPDATES = 0;
UPDATE prod_copy 
SET product_price = product_price * 1.1 
WHERE PROD_CAT_ID IN 
(SELECT PROD_CAT_ID FROM product_category WHERE PROD_CAT_DESC like '%promotion-medium%');
select * from prod_copy;