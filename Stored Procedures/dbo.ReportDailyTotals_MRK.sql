CREATE PROC [dbo].[ReportDailyTotals_MRK]
AS
SELECT CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) AS orderDate,
COUNT(CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) ) AS orderCount,
ROUND(SUM(o.calcOrderTotal), 2) AS dailyTotal,

ROUND(ROUND(SUM(o.calcOrderTotal), 2)/COUNT(CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate))),2)
AS AOV

FROM tblOrders o
WHERE orderStatus NOT IN ('Failed', 'Cancelled')
AND o.orderDate >= '20041231'
AND SUBSTRING(o.orderNo, 1, 3) IN ('HOM', 'MRK')
GROUP BY CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) 
ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate))) DESC