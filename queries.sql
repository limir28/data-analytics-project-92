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

--отчет с продавцами, чья выручка ниже средней выручки всех продавцов
WITH individual_income AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        AVG(s.quantity * p.price) AS average_income
    FROM employees AS e
    INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    GROUP BY e.employee_id, seller
),
overall_avg AS (
    SELECT AVG(average_income) AS overall_avg_income
    FROM individual_income
)
SELECT
    ii.seller,
    ii.average_income
FROM individual_income AS ii,
    overall_avg AS oa
WHERE ii.average_income < oa.overall_avg_income
ORDER BY ii.average_income ASC;

