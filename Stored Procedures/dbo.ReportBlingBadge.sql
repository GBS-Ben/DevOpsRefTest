CREATE PROC [dbo].[ReportBlingBadge]
AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     8/6/07
Purpose     Retrieves Badge "Bling" report for Ken, adhoc
-------------------------------------------------------------------------------------
Modification History

08/06/07	created, jf.
01/03/18	updated, jf.
-------------------------------------------------------------------------------------
*/

SELECT
a.orderNo, a.orderTotal, a.orderDate, 
DATEPART(MM, a.orderDate) AS 'Month', 
DATEPART(YY, a.orderDate) AS 'Year',
x.optionQTY, 
SUM(x.optionPrice * b.productQuantity) as 'blingTotal', 
x.pkid, b.productCode, x.optionCaption,
SUM(b.productQuantity * b.productPrice) as 'productTotal',
SUBSTRING(productCode, 5, 1) AS 'shape'
FROM tblOrders a 
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
INNER JOIN tblOrdersProducts_productOptions x ON b.[ID] = x.ordersProductsID
WHERE 
x.deleteX <> 'Yes'
AND b.deleteX <> 'Yes'
AND x.optionGroupCaption = 'Frame'
AND a.orderStatus NOT IN ('cancelled', 'failed', 'migz')
AND SUBSTRING(b.productCode, 1, 2) = 'NB'
GROUP BY a.orderNo, a.orderTotal, a.orderDate, x.optionQTY, x.pkid, b.productCode, x.optionCaption
ORDER BY a.orderDate, a.orderTotal