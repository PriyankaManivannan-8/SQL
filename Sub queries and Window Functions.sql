-- 1. Find out those employees whose managers are working in different department (hr schema)
use hr;
select * from employees;

select e.employee_id,e.department_id,m.employee_id as manager_id,m.department_id from employees e
join employees m
on e.employee_id=m.manager_id
where e.department_id<>m.department_id;
-- using subquery:
select e1.employee_id from employees e1 where department_id <> 
(select department_id from employees e2 where e1.manager_id=e2.employee_id);
-- or
select employee_id,department_id, 
(select m.employee_id from employees m where e.manager_id = m.employee_id and e.department_id != m.department_id) manager_id,
(select m.department_id from employees m where e.manager_id = m.employee_id and e.department_id != m.department_id) M_dept_ID from employees e
having manager_id is not null;

-- 2. Identify the quiz scores that took place on  ‘2020-09-16’ (Student schema)
/*
Student: studentid, studentname and gender
exam: examid, examdate, category
score: studentid, examid and score
*/
select score from score where examid in 
(select examid from exam where examdate = ‘2020-09-16’ and category = 'Quiz');

-- 3. WAQ to select the above-average scores from a given exam_id say 5 (Student schema)
select * from student where studentid in 
(select studentid from score where score>(select avg(score)from score) and examid = 5);


-- 4. Gather employee name and salary data of employees who receive salary greater 
-- than their manager's salary. (hr schema)
use hr;
select first_name,salary from employees e1 where salary > 
(select salary from employees e2 where e1.manager_id=e2.employee_id);
                            
-- 5. Get the employee details for those who have the word 'MANAGER' in their job title. 
-- (HR schema)
select * from employees where job_id in 
(select job_id from jobs where job_title like '%MANAGER%');         

-- 6. Find the employees who are not assigned to any department (HR schema)
select employee_id,department_id from employees where department_id is null;
-- or
select * from employees where department_id not in 
(select department_id from departments) or department_id is null;

-- 7. Display the order id's which have the maximum quantity ordered greater than 20 
-- (ord_mgmt schema)
select order_id, order_date 
from order_header
where order_id in 
(select order_id from order_items group by order_id having max(ORDERED_QTY)>20);

-- 8. Display the state province of employees who get commission_pct greater than 0.25 
-- (hr schema)
use hr1;
select state_province from locations where location_id in 
(select location_id from departments where department_id in 
(select department_id from employees where commission_pct>0.25));

-- 9. Display the manager details who have more than 5 employees reporting to them (hr schema)
select * from employees where employee_id in
(select manager_id from employees group by manager_id having count(employee_id)>5);

-- 10. Collect only the duplicate employee records (hr schema)
select * 
from employees 
where email in (select email 
				from employees 
                group by email
                having count(email)>1);

-- 11. List the products with quantity in stock greater than 10 and price greater than the 
-- average price of any of the product categories (order schema)
select product_id,product_desc,product_category_id from product where quantity_in_stock>10 
and product_price > any (select avg(product_price) from product group by product_category_id);
    
-- 12. Get the employee id and email id of all the managers (HR schema)
use hr;
select employee_id,email from employees e1 where exists 
(select employee_id from employees e2 where e2.manager_id = e1.employee_id);
-- or 
select employee_id,email from employees where employee_id in
(select manager_id from employees);

-- 13. Find the employees whose difference between the salary and average salary is greater 
-- than 10,000 (HR schema)
select employee_id from employees where salary -
(select avg(salary) from employees) >10000;

-- or

with CTE as (
select employee_id, salary, (select avg(salary) from employees) as 'avg_sal',
		 salary - (select avg(salary) from employees) as 'avg_sal_diff'
from employees)
select employee_id, avg_sal, avg_sal_diff
from CTE 
where avg_sal_diff > 10000;



-- 14. Find all the department id’s, their respective average salary, the groups High, 
-- Medium and Low based on the average salary (HR schema)

select department_id, avg(salary), 
case
when avg(salary) > 9000 then 'High'
when avg(salary) between 5000 and 9000 then 'Medium'
when avg(salary) < 5000 then 'Low'
end catagory
from employees
where department_id in (select department_id from departments)
group by department_id
;
-- 15. Get the category id and average price of the product categories whose average price 
-- is greater than the average price of product id 250 (HR schema)
use product;
select product_category_id,avg(product_price) from product
group by product_category_id
having avg((product_price)>(select avg(product_price) from product where product_id = 250));
                            
-- 16. Select those departments where the average salary of job_id working in that department 
 -- is greater than the overall average salary of that respective job_id (HR schema)
use hr1;
select department_id,job_id,avg(salary) as av_sal from employees e1 
group by department_id,job_id
having avg(salary)>(select avg(salary)from employees e2 where e2.job_id=e1.job_id);

-- 17. Fetch the department average salary along with the other columns present in department 
-- table. (HR schema)

select d.*,
avg(e.salary)from departments d join employees e
on e.department_id=d.department_id
group by e.department_id;
-- or
select d.*, dept_avg_sal
from
(select department_id, avg(salary) as dept_avg_sal
from employees 
group by department_id) dt
join departments d
on dt.department_id= d.department_id;
-- or
select *,(select avg(salary) from employees e group by department_id 
having e.department_id = d.department_id) avg_sal from departments d
having avg_sal is not null;
                
-- 18. Filter out the customer ids, the number of orders made and map them to customer types
-- 	number of orders  = 1 --> 'One-time Customer'
-- 	number of orders  = 2 --> 'Repeated Customer'
-- 	number of orders  = 3 --> 'Frequent Customer'
-- 	number of orders  > 3 --> 'Loyal Customer'
select customer_id,count(distinct order_id)as order_count,
case 
when count(distinct order_id) = 1 then 'One-time Customer'
when count(distinct order_id) = 2 then 'Repeated Customer'
when count(distinct order_id) = 3 then 'Frequent Customer'
when count(distinct order_id) > 3 then 'Loyal customer'
end customer_category
from order_header group by customer_id;
-- or
WITH cte AS (
	SELECT 
		online_customer.customer_id as cus_id, 
		COUNT(*) orderCount
	FROM
		order_header
	INNER JOIN online_customer 
	on order_header.customer_id = online_customer.customer_id
	GROUP BY online_customer.customer_id
)
SELECT 
    cus_id, 
    orderCount,
    CASE orderCount
		WHEN 1 THEN 'One-time Customer'
        WHEN 2 THEN 'Repeated Customer'
        WHEN 3 THEN 'Frequent Customer'
        ELSE 'Loyal Customer'
	end customerType
FROM
    cte
ORDER BY cus_id;


-- 19. Get the total orders as well as the break up for the total shipped, in-process and 
-- cancelled order status in a single row. (order schema)
select count(order_id) as total_order,sum(order_status='Shipped') as shipped,
sum(order_status='In process') as inprogress,
sum(order_status = 'cancelled') as cancelled
from order_header;

-- or
select count(order_id) as total_orders,
sum(if(ORDER_STATUS = 'Shipped', 1, 0)) as Shipped,
sum(if(ORDER_STATUS = 'In process', 1, 0)) as In_process,
sum(if(ORDER_STATUS = 'Cancelled', 1, 0)) as Cancelled
from order_header;

-- 20. 4. Display the employee name along with their department name. Show all the employee
--  name even those without department and show all the department names even if it 
-- doesnt have an employee  (hr schema)

select concat(e.first_name,' ',e.last_name)as full_name,
d.department_name from employees e left join departments d 
on e.department_id=d.department_id
union
select concat(e.first_name,' ',e.last_name)as full_name,
department_name from employees e right join departments d
on e.department_id=d.department_id;
