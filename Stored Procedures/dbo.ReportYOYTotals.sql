CREATE PROC [dbo].[ReportYOYTotals]
AS
SELECT DATENAME(WEEKDAY, o.orderDate) + ', ' +CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) AS orderDate,
COUNT(CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) ) AS orderCount,
ROUND(SUM(o.calcOrderTotal), 2) AS dailyTotal
FROM tblOrders o
WHERE orderStatus NOT IN ('Failed', 'Cancelled')
AND o.orderDate BETWEEN '20201201' AND GETDATE()
AND SUBSTRING(o.orderNo, 1, 3) IN ('HOM', 'NCC', 'ADH', 'ATM', 'MRK')
GROUP BY DATENAME(WEEKDAY, o.orderDate) + ', ' +CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate))

UNION

SELECT DATENAME(WEEKDAY, o.orderDate) + ', ' +CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) AS orderDate,
COUNT(CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) ) AS orderCount,
ROUND(SUM(o.calcOrderTotal), 2) AS dailyTotal
FROM tblOrders o
WHERE orderStatus NOT IN ('Failed', 'Cancelled')
AND o.orderDate BETWEEN '20191203' AND GETDATE()-364
AND SUBSTRING(o.orderNo, 1, 3) IN ('HOM', 'NCC', 'ADH', 'ATM', 'MRK')
GROUP BY DATENAME(WEEKDAY, o.orderDate) + ', ' +CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate))