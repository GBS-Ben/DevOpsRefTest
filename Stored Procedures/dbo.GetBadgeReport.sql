CREATE PROCEDURE [dbo].[GetBadgeReport]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     09/07/18	
-- Purpose    "Can you run that badge report?" ~ KH
-------------------------------------------------------------------------------
-- Modification History
--
--09/07/18		Created, jf.
-------------------------------------------------------------------------------

SELECT
a.orderNo, a.orderTotal, a.orderDate, 
CONVERT(VARCHAR(50), DATEPART(MM, a.orderDate)) AS 'Month', 
CONVERT(VARCHAR(50), DATEPART(YY, a.orderDate)) AS 'Year',
x.optionQTY, 
SUM(x.optionPrice) AS 'badgeTotal', 
x.pkid, b.productCode, x.optionCaption
FROM tblOrders a 
INNER JOIN tblOrders_Products b 	ON a.orderID = b.orderID
INNER JOIN tblOrdersProducts_productOptions x ON b.[ID] = x.ordersProductsID
WHERE x.deleteX <> 'Yes'
AND b.deleteX <> 'Yes'
AND x.optionGroupCaption = 'Frame'
AND a.orderStatus NOT IN ('failed', 'cancelled')
AND SUBSTRING(b.productCode, 1 , 2) = 'NB'
GROUP BY a.orderNo, a.orderTotal, a.orderDate, x.optionQTY, x.pkid, b.productCode, x.optionCaption
ORDER BY a.orderDate, a.orderTotal ASC