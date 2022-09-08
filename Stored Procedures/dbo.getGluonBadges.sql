CREATE PROC getGluonBadges
AS
SELECT DISTINCT op.productCode AS 'badgeCode', COUNT(op.productCode) AS 'badgeCount', op.productName
FROM tblOrders_Products op
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
INNER JOIN tblOrders o ON op.orderID = o.orderID
WHERE op.productCode LIKE 'NB%'
AND o.orderDate >= '20190101'
AND  NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppz
	WHERE optionCaption LIKE 'CC%'
	AND deleteX <> 'yes'
	AND oppz.ordersProductsID = op.ID)
GROUP BY op.ProductCode, op.productName
ORDER BY badgeCount DESC