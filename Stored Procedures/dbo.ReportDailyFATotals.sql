CREATE PROC [dbo].[ReportDailyFATotals]
AS
SELECT CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) AS orderDate,
COUNT(op.ID) AS FA_OPIDs,
ROUND(SUM(op.productQuantity * op.productPrice), 2) AS dailyTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE orderStatus NOT IN ('Failed', 'Cancelled')
AND o.orderDate >= '20041231'
AND op.deleteX <> 'yes'
AND op.productCode LIKE '%FA%'
AND SUBSTRING(o.orderNo, 1, 3) IN ('HOM', 'NCC', 'ADH', 'ATM', 'MRK')
GROUP BY CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate)) 
ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR(255), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(255), DATEPART(YYYY, o.orderDate))) DESC