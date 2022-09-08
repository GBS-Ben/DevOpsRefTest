CREATE PROCEDURE [dbo].[ReportProductBC]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     8/6/07
-- Purpose     Retrieves BC report for Ken, adhoc
-------------------------------------------------------------------------------------
-- Modification History
-- 09/11/18	created, jf.
-------------------------------------------------------------------------------------
;WITH cte
AS
	(SELECT x.ordersProductsID,
	SUM(x.optionPrice * x.optionQTY) AS 'SUMX'
	FROM tblOrdersProducts_productOptions x
	WHERE x.deleteX <> 'yes'
	AND x.optionPrice <> 0
	AND x.deleteX <> 'Yes'
	GROUP BY x.ordersProductsID, x.optionPrice, x.optionQTY)

SELECT DISTINCT a.orderNo, a.orderDate, 
CONVERT(VARCHAR(50), DATEPART(MM, a.orderDate)) AS 'Month', 
DATEPART(YY, a.orderDate) AS 'Year',
op.ID AS 'OPID', op.productCode, 
(op.productPrice * op.productQuantity) + SUM(c.SUMX) AS 'OPIDPrice', 1, op.productQuantity
FROM tblOrders a 
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON oppo.ordersProductsID = op.ID
LEFT JOIN cte c ON op.ID = c.ordersProductsID
WHERE op.deleteX <> 'Yes'
AND oppo.optionPrice <> 0
AND oppo.deleteX <> 'Yes'
AND a.orderStatus NOT IN ('cancelled', 'failed')
AND (SUBSTRING(op.productCode, 1, 4) = 'BCCU'
		OR SUBSTRING(op.productCode, 1, 3) = 'BCP'
		OR SUBSTRING(op.productCode, 1, 2) = 'BP'
		OR op.productCode LIKE '%KWBC%')
GROUP BY a.orderNo, a.orderTotal, a.orderDate, 
op.ID, op.productCode, op.productPrice, op.productQuantity, 
oppo.optionPrice, oppo.optionQTY

UNION

SELECT a.orderNo, a.orderDate, 
CONVERT(VARCHAR(50), DATEPART(MM, a.orderDate)) AS 'Month', 
DATEPART(YY, a.orderDate) AS 'Year', 
op.ID AS 'OPID', op.productCode, op.productPrice * op.productQuantity AS 'OPIDPrice', 1, op.productQuantity
FROM tblOrders a 
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
WHERE 
op.ID NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionPrice <> 0)
AND op.deleteX <> 'Yes'
AND a.orderStatus NOT IN ('cancelled', 'failed')
AND (SUBSTRING(op.productCode, 1, 4) = 'BCCU'
		OR SUBSTRING(op.productCode, 1, 3) = 'BCP'
		OR SUBSTRING(op.productCode, 1, 2) = 'BP'
		OR op.productCode LIKE '%KWBC%')
GROUP BY a.orderNo, a.orderTotal, a.orderDate, 
op.ID, op.productCode, op.productPrice, op.productQuantity
ORDER BY a.orderDate DESC, op.ID