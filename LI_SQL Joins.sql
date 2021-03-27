use hr;
-- 1. Create a worker table with attributes id, name, email, phone, salary, manager_id and 
-- department_id the email id and phone number must not contain null values and must be unique,
--  salary must be greater than 1000
-- set id column as the primary key.
create table LIday1(
id int primary key,
name_n varchar(32),
email_id varchar(64) not null,
phone varchar(12) not null,
salary float,
manager_id int,
dept_id int,
constraint email unique(email_id),
constraint id unique(phone),
constraint salary_check check (salary>1000)
);
-- constraint pk primary key(column_name)

-- 2. Delete the salary check constraint from the worker table
-- if we give a name for constraint, follow this:
alter table LIday1
drop salary_check;

-- If we didn't give constraint name, #show create table <table_name>;
# run and right click the response and 'copy row unquoted' and select the auto created constraint name
# basically the back end creates a constraint name even if we didn't give
show create table LIday1;

-- 3. Update the product price with an decrease in 5% for product id's 205. 
-- (use aug20_bridge schema)
use aug20_bridge;
select * from products;
set SQL_safe_updates = 0;
update products 
set product_price = product_price * 0.95
where product_id = 205;

-- 4. display the country_id and country names of the following 
-- countries: Austria, Brazil and Chad (use Sakila schema)
use sakila;
select country_id,country from country
where country in ('Austria','Brazil','Chad');

-- 5. Get the product id and description of product whose length is greater than 10 and 
-- also height is less than 500 (use product schema)
use aug20_bridge;
select * from products;
select product_id,product_desc from products
where product_length >10 and height < 500;

-- 6. Find the products whose category id is the range of 2060 to 2070 and whose total stock 
-- is more than 23. (use product schema)
select * from products;
select product_desc,product_id,product_category_id from products
where (product_category_id between 2060 and 2070) and quantity_in_stock > 23;

-- 7. For all the products weight, return the smallest integer not less than the weight 
-- 	value (use product schema)
select product_id,weight,ceil(weight)
from products;

-- 8. Get only the first 7 characters from the product description (use product schema)
select substring(product_desc,1,7)
from products;
-- or
select left (product_desc,7) from products;

--  9. Fetch the last but one letter of the product description, name the column as 
-- lastbutone_substr (use product schema)
select product_desc,substring(product_desc,-2,1)as last_but_one from product;

-- 10. Get the id, description and price  of products which contain 'TV' in their description 
-- (use product schema)
select product_id,product_desc,product_price from products
where product_desc like '%tv%';

-- 11. Get the employees full name, the first letter in first_name must be in lower case. 
-- (use hr schema)
use hr;
select * from employees;
select substring(first_name,1,1) from employees;
select first_name,
concat(replace(first_name,substring(first_name,1,1),lower(substring(first_name,1,1))),' ',
last_name) as full_name
from employees;

-- 12. Get the position of letter 'S' (first occurence) in the product desc 
-- (instring gives the position of the string, it gives only the first occurence) 
-- (use product schema)
use aug20_bridge;
select position('s' in product_desc) as position_of_s from products;
-- or
select product_desc, instr(product_desc, 'S') as s_position
from products;

-- 13. For the given string '  Great Lakes ', Check how Ltrim, Rtrim and trim works

select '  Great Lakes ',ltrim('  Great Lakes '),rtrim('  Great Lakes '),trim('  Great Lakes ');

-- 14. Remove the dollar symbol from $400
select trim(leading '$' from '$400');

-- 15. Remove the # present in the end of the string '#Great_Lakes#'
select trim(trailing '#' from '#Great_Lakes#');

-- 16. Remove the symbol '*' from the string '**Great_Lakes**'
select trim('*' from '**Great_Lakes**');

-- 17. Create sales table with the below column details,
-- i) order_id - 101, 102, 103, 104, 105 --> Primary key
-- ii) order_date - yesterday's date
-- iii) expected_delivery_date - 7 days from order date (use product schema)
create table sales(
order_id int primary key,
order_date date,
expected_delivery_date date
);
insert into sales(order_id) values(101),(102),(103),(104),(105);
update sales set order_date = subdate(curdate(),1);
update sales set expected_delivery_date = date_add(order_date, interval 7 day);

-- Method 2:
create table sales1 (
order_id int primary key,
order_date date,	
expected_delivery_date date
);

insert into sales1
values(101, subdate(curdate(), 1), adddate(order_date, 7)), 
(102, subdate(curdate(), 1), adddate(order_date, 7)),
 (103, subdate(curdate(), 1), adddate(order_date, 7)),
 (104, subdate(curdate(), 1), adddate(order_date, 7)), 
 (105, subdate(curdate(), 1), adddate(order_date, 7));

select * 
from sales1;

--  18. Find the customers who have taken rentals for more than a week (use Sakila schema)
use sakila;
select * from rental;
select distinct customer_id from rental 
where datediff(return_date,rental_date) > 7;

-- 19. Find rental id, rental date and day as rental_date_day in which the customers rented 
-- the inventory (use Sakila schema)
select rental_id,concat(rental_date,' ',dayname(rental_date))as rental_date_day from rental;

-- 20. Get the film id and title of the film in upper case (use Sakila schema)
select film_id,ucase(title) from film;

-- 21. Delivery cost for the goods is 10% of the total weight. Calculate the same. 
-- Note: If a product does not have weight detail, the delivery cost is 0.1$ 
-- (use product schema)
use aug20_bridge;
select * from products;
select product_id,product_desc,weight,
case when weight is null then 0.1
else (0.1*weight) 
end as delivery_cost 
from products;
-- or 
select weight,(ifnull(weight,1)*0.1) as delivery_cost from products;

--  22. Find the full name of actors whose last name ends with YD. Sort the records based on 
-- the full name in descending order (use Sakila schema)
use sakila;
select concat(first_name,' ',last_name) as full_name from actor
where last_name like '%yd'
order by full_name desc;

-- 23. Find the highest amount for rental id's (use Sakila schema)
use sakila;
select * from payment;

select amount from payment
order by amount desc
limit 0,1;
-- or
select max(amount) as amt from payment;

-- 24. Find top three highest amount for rentals (use Sakila schema)
select distinct amount from payment
order by amount desc
limit 0,3;

-- 25. Find the fifth highest amount for rentals (use Sakila schema)
select distinct amount from payment
order by amount desc
limit 4,1;

-- 26. Find out the id's of actor who have performed in more than 40 films (use Sakila schema)
select actor_id,count(film_id) from film_actor
group by actor_id
having count(film_id)>40;

-- 27.  For every product category find the total quantity in stock (use product schema)
use aug20_bridge;
select * from products;

select product_category_id,sum(quantity_in_stock) from products
group by product_category_id;

-- 28. Find the max price, min price and the difference between the maximum and minimum price 
-- for a category  (use product schema)
select product_category_id,max(product_price),min(product_price),
(max(product_price)-min(product_price)) as diff_price from products
group by product_category_id;

-- 29. List last names of actors and the number of actors who have last name that are shared by at least two actors (use Sakila schema)
use sakila;
select last_name, count(last_name) from actor
group by last_name
having count(last_name)>1 ;

-- 30. How many copies of the film 'DADDY PITTSBURGH' exist in the inventory system? (use Sakila schema)
select * from film;
select * from inventory;

select f.title,count(i.inventory_id) as inv_count
from film f join inventory i
on f.film_id=i.film_id
where f.title = 'DADDY PITTSBURGH'
group by f.film_id;

-- 31. List the total paid by each customer. List the customers alphabetically by last name 
-- (use Sakila schema)
select * from customer;
select * from payment;
select c.customer_id,concat(c.first_name,' ',c.last_name)as full_name,sum(p.amount) from customer c
join payment p on c.customer_id = p.customer_id
group by c.customer_id
order by c.last_name;

-- 32.  The titles of movies starting with the letters K and Q whose language is English. 
-- (use Sakila schema)
select * from film;
select * from language;

select f.title from film f
join language l on f.language_id=l.language_id
where l.name='English' and (f.title like 'k%' or f.title like 'q%');


-- 33. Display the 3 most frequently rented movies in descending order.
-- Get the movie name and times rented (use Sakila schema)
select * from film;
select * from rental;
select title,count(rental_id)as times_rented from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by title
order by times_rented desc;

-- 34. Find out how much business, each store has brought in. Along with store id get the city,
--  country too(use sakila schema)
 select s.store_id as store ,concat(c.city,' ',cc.country) as location,sum(p.amount) as sales_amt
 from payment p 
 join rental r on p.rental_id = r.rental_id
 join inventory i on r.inventory_id = i.inventory_id
 join store s on i.store_id = s.store_id
 join address a on s.address_id=a.address_id
 join city c on a.city_id=c.city_id
 join country cc on c.country_id = cc.country_id
 group by s.store_id;

-- 35. Get the employee's and manager's id and department id's for employees whose manager is 
-- working in a different department. (use hr schema)
use hr;

select e.employee_id,e.department_id,m.employee_id,m.department_id from employees e
join employees m
on e.employee_id=m.manager_id
where e.department_id<>m.department_id;

-- 
-- Constriant names
SHOW CREATE TABLE employees;

SHOW KEYS FROM employees WHERE Key_name = 'PRIMARY';

select *
from information_schema.key_column_usage
where table_name='order_items';


select *
from information_schema.table_constraints
where table_name='order_items';





