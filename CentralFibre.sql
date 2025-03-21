-- Select all our data

SELECT *
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024] -- Calculate the annual TCV (after discounts have been applied) and compare both years
 WITH yearly_tcv AS
  (SELECT YEAR,
          SUM(Post_Discount_TCV) AS total_tcv
   FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
   GROUP BY YEAR)
SELECT yearly_tcv.YEAR AS current_year,
                          yearly_tcv.total_tcv AS current_tcv,
                          LAG(yearly_tcv.total_tcv) OVER (
                                                          ORDER BY yearly_tcv.YEAR) AS previous_tcv,
                          CASE
                              WHEN LAG(yearly_tcv.total_tcv) OVER (
                                                                   ORDER BY yearly_tcv.YEAR) IS NOT NULL
                                   AND LAG(yearly_tcv.total_tcv) OVER (
                                                                       ORDER BY yearly_tcv.YEAR) != 0 THEN ((yearly_tcv.total_tcv - LAG(yearly_tcv.total_tcv) OVER (
                                                                                                                                                                    ORDER BY yearly_tcv.YEAR)) / LAG(yearly_tcv.total_tcv) OVER (
ORDER BY yearly_tcv.YEAR)) * 100
                              ELSE NULL
END AS percentage_change
FROM yearly_tcv
ORDER BY yearly_tcv.YEAR DESC;

 -- Calculate the total sales made in 2023 and 2024
 WITH yearly_sales AS
(SELECT YEAR,
        COUNT(Post_Discount_TCV) AS total_sales
 FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
 GROUP BY YEAR)
SELECT yearly_sales.YEAR AS current_year,
                            yearly_sales.total_sales AS current_sales,
                            LAG(yearly_sales.total_sales) OVER (
                                                                ORDER BY yearly_sales.YEAR) AS previous_sales,
                            CASE
                                WHEN LAG(yearly_sales.total_sales) OVER (
                                                                         ORDER BY yearly_sales.YEAR) IS NOT NULL
                                     AND LAG(yearly_sales.total_sales) OVER (
                                                                             ORDER BY yearly_sales.YEAR) != 0 THEN ((yearly_sales.total_sales - LAG(yearly_sales.total_sales) OVER (
                                                                                                                                                                                    ORDER BY yearly_sales.YEAR)) / LAG(yearly_sales.total_sales) OVER (
ORDER BY yearly_sales.YEAR)) * 100
                                ELSE NULL
END AS percentage_change
FROM yearly_sales
ORDER BY yearly_sales.YEAR DESC;

 -- Add a day of the week column

ALTER TABLE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024] ADD sale_day_of_the_week NVARCHAR(20);

 -- Populate the column with days

UPDATE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
SET sale_day_of_the_week = DATENAME(WEEKDAY, Sale_Date);

 --Add Month of Year

ALTER TABLE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024] ADD sale_month_of_year NVARCHAR(20);

 -- Populate

UPDATE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
SET sale_month_of_year = DATENAME(MONTH, Sale_Date);

 --Add Quarter

ALTER TABLE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024] ADD sale_quarter_of_year NVARCHAR(20);

 --Populate

UPDATE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
SET sale_quarter_of_year = CASE
                               WHEN MONTH(Sale_Date) IN (1,
                                                         2,
                                                         3) THEN 'Q1'
                               WHEN MONTH(Sale_Date) IN (4,
                                                         5,
                                                         6) THEN 'Q2'
                               WHEN MONTH(Sale_Date) IN (7,
                                                         8,
                                                         9) THEN 'Q3'
                               WHEN MONTH(Sale_Date) IN (10,
                                                         11,
                                                         12) THEN 'Q4'
                           END;

 --What is the most popular day of the week for sales?

SELECT YEAR,
       DATENAME(WEEKDAY, Sale_Date),
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS daily_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY YEAR,
         DATENAME(WEEKDAY, Sale_Date)
ORDER BY YEAR,
         number_of_sales DESC;

 --What's the most popular month for sales?

SELECT YEAR,
       DATENAME(MONTH, Sale_Date),
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS monthly_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY YEAR,
         DATENAME(MONTH, Sale_Date)
ORDER BY YEAR,
         number_of_sales DESC;

 --Most popular quarter?

SELECT YEAR,
       sale_quarter_of_year,
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS q_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2023
GROUP BY YEAR,
         sale_quarter_of_year
ORDER BY YEAR,
         number_of_sales DESC;

 -- Sales by product

SELECT YEAR,
       Product,
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS product_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY YEAR,
         Product
ORDER BY YEAR,
         number_of_sales DESC;

 --Sales by Account Manager

SELECT YEAR,
       Account_Manager,
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS product_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY YEAR,
         Account_Manager
ORDER BY YEAR,
         total_income DESC;

 -- Sales by Account Manager and Product

SELECT Account_Manager,
       Product,
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS product_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2023
GROUP BY YEAR,
         Account_Manager,
         Product
ORDER BY Product,
         number_of_sales DESC;

 --Sales improvement year on year by individual
 WITH yearly_sales AS
(SELECT Account_Manager,
        YEAR,
        SUM(Post_Discount_TCV) AS total_sales
 FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
 WHERE YEAR IN (2023,
                2024) -- Ensure only the relevant years are included

 GROUP BY Account_Manager,
          YEAR),
      sales_comparison AS
(SELECT y1.Account_Manager,
        y1.total_sales AS sales_year_1,
        y2.total_sales AS sales_year_2,
        (y2.total_sales - y1.total_sales) AS absolute_change,
        ((y2.total_sales - y1.total_sales) / NULLIF(y1.total_sales, 0) * 100) AS percentage_change
 FROM yearly_sales y1
 JOIN yearly_sales y2 ON y1.account_manager = y2.account_manager
 AND y1.YEAR = 2023 -- Base Year

 AND y2.YEAR = 2024 -- Comparison Year
)
SELECT Account_Manager,
       sales_year_1,
       sales_year_2,
       absolute_change,
       percentage_change
FROM sales_comparison
ORDER BY absolute_change DESC; -- Order by highest improvement

 --Sales by contract length.

SELECT YEAR,
       Contract_Length,
       COUNT(*) AS number_of_sales,
       SUM(Post_Discount_TCV) AS total_income,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS product_count_percentage
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY YEAR,
         Contract_Length
ORDER BY YEAR,
         number_of_sales DESC;

 -- Marketing budget spent

SELECT SUM(Marketing_Cost) AS total_spent,
       (SUM(Marketing_Cost) / 2000000) * 100 AS percentage_of_budget
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024;

 -- Marketing spend by activity

SELECT Marketing_Channel,
       SUM(Marketing_Cost) AS total_spent,
       (SUM(Marketing_Cost) / 2000000) * 100 AS percentage_of_budget
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY Marketing_Channel
ORDER BY total_spent DESC; -- Sorting from highest to lowest spend

 -- Add discount cost column

ALTER TABLE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024] ADD discount_cost INT;


UPDATE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
SET discount_cost = Monthly_Cost * Discount_Months;


ALTER TABLE [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
ALTER COLUMN discount_cost MONEY;

 -- Marketing Spend, plus ROMI and Avg cost of acquisition - this uses the combined activity costs and discount costs

SELECT Marketing_Channel,
       SUM(Marketing_Cost) AS total_spent,
       SUM(discount_cost) AS total_discounts,
       SUM(Marketing_Cost) + SUM(discount_cost) AS combined_spend,
       -- Marketing + Discount spend

       (SUM(Marketing_Cost) / 2000000) * 100 AS percentage_of_budget,
       COUNT(*) AS total_sales,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage_of_sales,
       SUM(Post_Discount_TCV) AS total_revenue,
       -- Total revenue after discounts

       CASE
           WHEN COUNT(*) = 0 THEN NULL
           ELSE SUM(Marketing_Cost) / COUNT(*)
       END AS cost_per_acquisition,
       CASE
           WHEN SUM(Marketing_Cost) + SUM(discount_cost) = 0 THEN NULL
           ELSE ((SUM(Post_Discount_TCV) - (SUM(Marketing_Cost) + SUM(discount_cost))) / (SUM(Marketing_Cost) + SUM(discount_cost))) * 100
       END AS romi_percentage,
       -- ROMI using combined spend

       CASE
           WHEN SUM(Marketing_Cost) + SUM(discount_cost) = 0 THEN 'N/A'
           ELSE CONCAT(ROUND((SUM(Post_Discount_TCV) / (SUM(Marketing_Cost) + SUM(discount_cost))), 2), ':1')
       END AS romi_ratio -- ROMI Ratio using combined spend
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024
GROUP BY Marketing_Channel
ORDER BY total_revenue DESC;

 -- Overall ROMI

SELECT SUM(Marketing_Cost) AS total_spent,
       SUM(discount_cost) AS total_discounts,
       SUM(Marketing_Cost) + SUM(discount_cost) AS combined_spend,
       -- Marketing + Discounts

       SUM(Post_Discount_TCV) AS total_revenue,
       -- Revenue already accounts for discounts

       ((SUM(Post_Discount_TCV) - (SUM(Marketing_Cost) + SUM(discount_cost))) / (SUM(Marketing_Cost) + SUM(discount_cost))) * 100 AS romi_percentage,
       CONCAT(ROUND(SUM(Post_Discount_TCV) / (SUM(Marketing_Cost) + SUM(discount_cost)), 2), ':1') AS romi_ratio
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE YEAR = 2024;

 -- Count discounts in 2024

SELECT COUNT(discount_cost) AS total_discounts
FROM [CentralFibre].[dbo].[CentralFibre-Broadband-Sales-2023-2024]
WHERE (YEAR = 2024)
AND (discount_cost <> 0);