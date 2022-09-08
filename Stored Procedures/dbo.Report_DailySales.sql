
CREATE PROCEDURE Report_DailySales
AS 

SELECT CONVERT(VARCHAR(6), OrderDate, 112) AS Year_Month, 
COUNT(DISTINCT Orderno)  AS Order_Count, 
LEFT(ProductCode,2) AS ProductCode,
SUM(op.productPrice* productQuantity) AS Revenue_Amount
FROM tblOrders t
INNER JOIN tblOrders_Products  op ON op.orderID = t.orderID
INNER JOIN DateDimension d ON d.DateKey = CONVERT(VARCHAR(8), t.OrderDate, 112)
WHERE orderStatus NOT IN ('Cancelled', 'Failed', 'Waiting for Payment')
--and d.DateKey IN (select datekey from DateDimension where [date] between '12/1/2019' and '2/24/2020' OR [date] between '12/1/2018' and '2/24/2019')
--and T.orderdate >= '1/1/2015'
 --AND ProductCode LIKE 'CA%'
--AND (d.DayOfYear between 32 and 90)
GROUP BY CONVERT(VARCHAR(6), OrderDate, 112),LEFT(ProductCode,2)
ORDER BY CONVERT(VARCHAR(6), OrderDate, 112) DESC;