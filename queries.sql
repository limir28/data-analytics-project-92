--считаем общее количество клиентов
select COUNT(customer_id) as customers_count
from customers;

--отчет с продавцами у которых наибольшая выручка
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.quantity) as operations,
    floor(sum(s.quantity * p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller
order by income desc limit 10;

--отчет с продавцами, чья выручка ниже средней выручки всех продавцов
WITH individual_income AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        FLOOR(AVG(s.quantity * p.price)) AS average_income
    FROM employees AS e
    INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    GROUP BY e.employee_id, seller
),

overall_avg AS (
    SELECT FLOOR(AVG(average_income)) AS overall_avg_income
    FROM individual_income
)

SELECT
    ii.seller,
    ii.average_income
FROM individual_income AS ii,
    overall_avg AS oa
WHERE ii.average_income < oa.overall_avg_income
ORDER BY ii.average_income ASC;


--отчет с данными по выручке по каждому продавцу и дню недели
--функция TRIM для удаления пробелов из строки day_of_week, полученной с помощью функции TO_CHAR
with days as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        to_char(s.sale_date, 'Day') as day_of_week,
        floor(sum(s.quantity * p.price)) as income
    from employees as e
    inner join sales as s on e.employee_id = s.sales_person_id
    inner join products as p on s.product_id = p.product_id
    group by seller, to_char(s.sale_date, 'Day')
)

select
    d.seller,
    d.income,
    trim(d.day_of_week) as day_of_week
from days as d
order by
    case
        when trim(d.day_of_week) = 'Monday' then 1
        when trim(d.day_of_week) = 'Tuesday' then 2
        when trim(d.day_of_week) = 'Wednesday' then 3
        when trim(d.day_of_week) = 'Thursday' then 4
        when trim(d.day_of_week) = 'Friday' then 5
        when trim(d.day_of_week) = 'Saturday' then 6
        when trim(d.day_of_week) = 'Sunday' then 7
    end,
    d.seller;



--отчет с возрастными группами покупателей
with cat as (
    select
        case
            when c.age between 16 and 25 then '16-25'
            when c.age between 26 and 40 then '26-40'
            else '40+'
        end as age_category,
        count(c.customer_id) as age_count
    from customers as c
    group by age_category
)

select
    cat.age_category,
    cat.age_count
from cat
order by
    case
        when cat.age_category = '16-25' then 1
        when cat.age_category = '26-40' then 2
        else 3
    end;


--отчет с количеством покупателей и выручкой по месяцам
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
INNER JOIN customers AS c ON s.customer_id = c.customer_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY selling_month;


--отчет с покупателями первая покупка которых пришлась на время проведения специальных акций
/* Находим первую дату, когда товар стоил 0 */
    /* Находим первую покупку каждого клиента во 2 подзапросе */
WITH FIRSTDATE AS (
    SELECT
        S.CUSTOMER_ID,
        MIN(S.SALE_DATE) AS FIRST_ZERO_DATE
    FROM SALES AS S
    INNER JOIN PRODUCTS AS P ON S.PRODUCT_ID = P.PRODUCT_ID
    WHERE P.PRICE = 0
    GROUP BY 1
),

CUSTOMERFIRSTPURCHASE AS (
    SELECT
        C.CUSTOMER_ID,
        CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS CUSTOMER,
        MIN(S.SALE_DATE) AS FIRST_PURCHASE_DATE,
        CONCAT(E.FIRST_NAME, ' ', E.LAST_NAME) AS SELLER
    FROM EMPLOYEES AS E
    INNER JOIN SALES AS S ON E.EMPLOYEE_ID = S.SALES_PERSON_ID
    INNER JOIN CUSTOMERS AS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
    GROUP BY C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, E.FIRST_NAME, E.LAST_NAME
)

SELECT
    CFP.CUSTOMER,
    CFP.FIRST_PURCHASE_DATE AS SALE_DATE,
    CFP.SELLER
FROM CUSTOMERFIRSTPURCHASE AS CFP
INNER JOIN FIRSTDATE AS FD
    ON
        CFP.FIRST_PURCHASE_DATE = FD.FIRST_ZERO_DATE
        AND CFP.CUSTOMER_ID = FD.CUSTOMER_ID
ORDER BY CFP.CUSTOMER_ID;





