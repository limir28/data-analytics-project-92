--считаем общее количество клиентов
select COUNT(customer_id) as customers_count
from customers;

--отчет с продавцами у которых наибольшая выручка
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.quantity) as operations,
    sum(s.quantity * p.price) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller
order by income desc;
