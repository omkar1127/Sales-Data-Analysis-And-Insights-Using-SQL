select * from dbo.sales

-- which product have highest sales volume across all branches
select top 1 branch ,round(sum(total),2) as total_sales 
from dbo.sales
group by branch
order by total_sales desc

--What are the top-selling product categories?
select top 3 [Product line] as product_category,round(sum(total),2) as total_sales 
from dbo.sales
group by [Product line]
order by total_sales desc

--Who are the top-spending customers(10)?
select top 10 [Invoice ID] as cutomer_invoice_id,round(sum(total),2) as Spending_Amount 
from dbo.sales
group by [Invoice ID]
order by Spending_Amount desc

--What is the average transaction value per customer?
with avg_transaction(total_Customer,total_sales)
as(
	select count(distinct([Invoice ID])) total_customer,round(sum(total),2) as total_sales 
	from dbo.sales
)
select round(total_sales * 1.0/total_Customer,2) as avg_per_customer
from avg_transaction

--Analyze branchwise sales trends over the three-month period.
WITH modified_date AS (
    SELECT Branch,City,CONVERT(date, Date) AS date,[Product line],ROUND(Total, 2) AS Sales_Amount
    FROM dbo.sales
),
monthly_sales AS (
    SELECT branch,MONTH(date) AS Month,SUM(Sales_Amount) AS Sales_Amount
    FROM modified_date
    GROUP BY branch,MONTH(date)
)
SELECT * 
FROM monthly_sales
ORDER BY Month;

--Analyze product_line wise sales trends over the three-month period.
WITH modified_date AS (
    SELECT Branch,City,CONVERT(date, Date) AS date,[Product line],ROUND(Total, 2) AS Sales_Amount
    FROM dbo.sales
),
monthly_sales AS (
    SELECT [Product line],MONTH(date) AS Month,SUM(Sales_Amount) AS Sales_Amount
    FROM modified_date
    GROUP BY [Product line],MONTH(date)
)
SELECT * 
FROM monthly_sales
ORDER BY Month;

--peak sales days or hours.
WITH daily_sales AS (
    SELECT
        CAST(Date AS DATE) AS Sales_Date,
        SUM(ROUND(Total, 2)) AS Sales_Amount
    FROM dbo.sales
    GROUP BY CAST(Date AS DATE)
),
ranked_sales AS (
    SELECT Sales_Date,Sales_Amount,
        ROW_NUMBER() OVER (ORDER BY Sales_Amount DESC) AS rn
    FROM daily_sales
)
SELECT Sales_Date,Sales_Amount
FROM ranked_sales
WHERE rn <= 10 -- Adjust as needed to get more or fewer peak days
ORDER BY Sales_Amount DESC;



-- Max sales day
WITH daily_sales AS (
    SELECT
        CAST(Date AS DATE) AS Sales_Date,
        SUM(ROUND(Total, 2)) AS Sales_Amount
    FROM dbo.sales
	group by CAST(Date AS DATE)
)
SELECT Sales_Date,Sales_Amount
FROM daily_sales-- Adjust as needed to get more or fewer peak days
where Sales_Amount = (select max(Sales_Amount) from daily_sales)
ORDER BY Sales_Amount DESC;

--Product categories ranked by average customer ratings.
select [Product line],round(avg(rating),1) as average_rating
from dbo.sales
group by [Product line]
order by average_rating desc;

-- Average rating per branch
SELECT Branch,round(avg(rating),1) AS average_rating
FROM dbo.sales
GROUP BY Branch
order by average_rating desc;

--Sales amounts calculated for each city
select city,round(avg(Total),2) as Sales_Amount from dbo.sales
group by city
order by Sales_Amount

--Net Profit by Branch
select Branch,round(sum([gross income]),2) as Profit 
from dbo.sales
group by Branch
order by Profit desc

--Sales Percentage by Gender
with total_sales as(
	select sum(total) as overallsalesamount 
	from dbo.sales
),
gender_sales as(
	select gender,sum(total) as genderoverallamount 
	from dbo.sales
	group by gender
),
gendersalespercentage as(
	select gender, (genderoverallamount/overallsalesamount) * 100 as sales_percentage
	from total_sales,gender_sales
)
select gender,round(sales_percentage,0) as percentage_sales 
from gendersalespercentage

--Preffered payment method by the customers
WITH totalpayments AS (
    SELECT COUNT(Payment) AS totalpaymentcount
    FROM dbo.sales
),
typeofpayment AS (
    SELECT DISTINCT(payment) AS unique_payment, COUNT(payment) AS countbypaymenttypes
    FROM dbo.sales
    GROUP BY payment
),
typeofpaymentpercentage AS (
    SELECT unique_payment AS payment_type, 
           (countbypaymenttypes / CAST((SELECT totalpaymentcount FROM totalpayments) AS FLOAT)) * 100 AS payment_percentage
    FROM typeofpayment
)
SELECT payment_type, payment_percentage 
FROM typeofpaymentpercentage;

--revenue by payment type
SELECT distinct(payment) as Payment_type,round(sum(total),2) as Revenue
FROM dbo.sales
group by payment

