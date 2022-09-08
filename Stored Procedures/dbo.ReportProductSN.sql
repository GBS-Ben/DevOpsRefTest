CREATE PROCEDURE [dbo].[ReportProductSN]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     8/6/07
-- Purpose     Retrieves SN report for Ken, adhoc
-------------------------------------------------------------------------------------
-- Modification History
-- 09/11/18	created, jf.
-- 01/16/19	update, jf.
-------------------------------------------------------------------------------------
TRUNCATE TABLE ReportSalesByProduct_Signs

;WITH cte
AS
	(SELECT x.ordersProductsID,
	SUM(x.optionPrice * x.optionQTY) AS 'SUMX'
	FROM tblOrdersProducts_productOptions x
	WHERE x.deleteX <> 'yes'
	AND x.optionPrice <> 0
	AND x.deleteX <> 'Yes'
	GROUP BY x.ordersProductsID, x.optionPrice, x.optionQTY)



INSERT INTO ReportSalesByProduct_Signs (orderNo, orderDate, [Month],[Year], productCode, productQuantity, option_2Grommets, 
option_2GrommetsTotal, option_4Grommets, option_4GrommetsTotal, option_AluminumReflectiveUpgrade, option_AluminumReflectiveUpgradeTotal,
option_AluminumUpgrade, option_AluminumUpgradeTotal, option_PVCUpgrade, option_PVCUpgradeTotal, opidTotal, oppoTotal, opid_oppo_combinedTotal,
OrderTotal, OPID)
SELECT DISTINCT a.orderNo, a.orderDate, 
CONVERT(VARCHAR(50), DATEPART(MM, a.orderDate)) AS 'Month', 
DATEPART(YY, a.orderDate) AS 'Year',
op.productCode, op.productQuantity,
0 AS option_2Grommets,
0 AS option_2GrommetsTotal,
0 AS option_4Grommets,
0 AS option_4GrommetsTotal,
0 AS option_AluminumReflectiveUpgrade,
0 AS option_AluminumReflectiveUpgradeTotal,
0 AS option_AluminumUpgrade,
0 AS option_AluminumUpgradeTotal,
0 AS option_PVCUpgrade,
0 AS option_PVCUpgradeTotal,
(op.productPrice * op.productQuantity) AS opidTotal,
0 AS oppoTotal,
(op.productPrice * op.productQuantity) + SUM(c.SUMX) AS 'opid_oppo_combinedTotal',
a.orderTotal AS 'OrderTotal',
op.ID AS 'OPID'
FROM tblOrders a 
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON oppo.ordersProductsID = op.ID
LEFT JOIN cte c ON op.ID = c.ordersProductsID
WHERE op.deleteX <> 'Yes'
AND oppo.optionPrice <> 0
AND oppo.deleteX <> 'Yes'
AND a.orderStatus NOT IN ('cancelled', 'failed')
AND SUBSTRING(op.productCode, 1, 2) = 'SN'
AND SUBSTRING(op.productCode, 3, 3) <> 'ENV'
GROUP BY a.orderNo, a.orderTotal, a.orderDate, 
op.ID, op.productCode, op.productPrice, op.productQuantity, 
oppo.optionPrice, oppo.optionQTY

UNION

SELECT DISTINCT a.orderNo, a.orderDate, 
CONVERT(VARCHAR(50), DATEPART(MM, a.orderDate)) AS 'Month', 
DATEPART(YY, a.orderDate) AS 'Year',
op.productCode, op.productQuantity,
0 AS option_2Grommets,
0 AS option_2GrommetsTotal,
0 AS option_4Grommets,
0 AS option_4GrommetsTotal,
0 AS option_AluminumReflectiveUpgrade,
0 AS option_AluminumReflectiveUpgradeTotal,
0 AS option_AluminumUpgrade,
0 AS option_AluminumUpgradeTotal,
0 AS option_PVCUpgrade,
0 AS option_PVCUpgradeTotal,
(op.productPrice * op.productQuantity) AS opidTotal,
0 AS oppoTotal,
(op.productPrice * op.productQuantity) AS 'opid_oppo_combinedTotal',
a.orderTotal AS 'OrderTotal',
op.ID AS 'OPID'
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
AND SUBSTRING(op.productCode, 1, 2) = 'SN'
AND SUBSTRING(op.productCode, 3, 3) <> 'ENV'
GROUP BY a.orderNo, a.orderTotal, a.orderDate, 
op.ID, op.productCode, op.productPrice, op.productQuantity
ORDER BY a.orderDate DESC, op.ID


TRUNCATE TABLE tempJF_SN_Addons
INSERT INTO tempJF_SN_Addons (ordersProductsID, optionCaption, optionPrice, optionQty)
SELECT ordersProductsID, optionCaption, optionPrice, optionQty
FROM tblOrdersProducts_productOptions
WHERE optionGroupCaption = 'Add Ons'
AND deleteX <> 'yes'
AND ordersProductsID IN
		(SELECT ID
		FROM tblORders_Products op
		WHERE  SUBSTRING(op.productCode, 1, 2) = 'SN'
		AND SUBSTRING(op.productCode, 3, 3) <> 'ENV')

UPDATE a
SET option_2Grommets = b.optionQTY,
	option_2GrommetsTotal = b.optionPrice * b.optionQTY
FROM ReportSalesByProduct_Signs a
INNER JOIN tempJF_SN_Addons b ON a.OPID = b.ordersProductsID
WHERE b.optionCaption = 'Add 2 Grommets'

UPDATE a
SET option_4Grommets = b.optionQTY,
	option_4GrommetsTotal = b.optionPrice * b.optionQTY
FROM ReportSalesByProduct_Signs a
INNER JOIN tempJF_SN_Addons b ON a.OPID = b.ordersProductsID
WHERE b.optionCaption = 'Add 4 Grommets'

UPDATE a
SET option_AluminumReflectiveUpgrade = b.optionQTY,
	option_AluminumReflectiveUpgradeTotal = b.optionPrice * b.optionQTY
FROM ReportSalesByProduct_Signs a
INNER JOIN tempJF_SN_Addons b ON a.OPID = b.ordersProductsID
WHERE b.optionCaption = 'Aluminum Reflective Upgrade'

UPDATE a
SET option_AluminumUpgrade = b.optionQTY,
	option_AluminumUpgradeTotal = b.optionPrice * b.optionQTY
FROM ReportSalesByProduct_Signs a
INNER JOIN tempJF_SN_Addons b ON a.OPID = b.ordersProductsID
WHERE b.optionCaption = 'Aluminum Upgrade'

UPDATE a
SET option_PVCUpgrade = b.optionQTY,
	option_PVCUpgradeTotal = b.optionPrice * b.optionQTY
FROM ReportSalesByProduct_Signs a
INNER JOIN tempJF_SN_Addons b ON a.OPID = b.ordersProductsID
WHERE b.optionCaption = 'PVC Upgrade'

UPDATE ReportSalesByProduct_Signs
SET oppoTotal = option_2GrommetsTotal + option_4GrommetsTotal + option_AluminumReflectiveUpgradeTotal + option_AluminumUpgradeTotal + option_PVCUpgradeTotal

SELECT * FROM ReportSalesByProduct_Signs

/*
SELECT * FROM tempJF_SN_Addons

(orderNo, orderDate, [Month],[Year], productCode, productQuantity, option_2Grommets, 
option_2GrommetsTotal, option_4Grommets, option_4GrommetsTotal, option_AluminumReflectiveUpgrade, option_AluminumReflectiveUpgradeTotal,
option_AluminumUpgrade, option_AluminumUpgradeTotal, option_PVCUpgrade, option_PVCUpgradeTotal, opidTotal, oppoTotal, opid_oppo_combinedTotal,
OrderTotal, OPID)
*/