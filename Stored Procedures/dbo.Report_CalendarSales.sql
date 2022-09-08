CREATE PROCEDURE [dbo].[Report_CalendarSales] AS
SELECT 
CONVERT(VARCHAR(50), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY, o.orderDate)) AS orderdate, d.weekdayname,
CONVERT(DEC(8,2), SUM(op.productQuantity * op.productPrice)) AS [CA Total],
COUNT(DISTINCT(o.orderID)) AS transactions --, op.productname, op.productcode, o.orderid
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN dateDimension d ON DATEPART(dd, o.orderDate) = d.[day]
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND (op.productCode LIKE 'CA__00%' OR op.productCode LIKE 'CA__20%')
AND op.productCode NOT LIKE 'CAIN%'
AND o.orderDate BETWEEN '20190601' AND GETDATE()
AND DATEPART(mm, o.orderDate) = d.[month]
AND DATEPART(yyyy, o.orderDate) = d.[year]
GROUP BY CONVERT(VARCHAR(50), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY, o.orderDate)), d.weekdayname-- , op.productname, op.productcode, o.orderid
ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR(50), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY, o.orderDate)) ) DESC