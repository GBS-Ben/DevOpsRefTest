CREATE VIEW [dbo].[vwCoreCompanyStats]
AS

---------------Ordered_Products------------------------
--DROP TABLE IF EXISTS #temp_Core
SELECT op.GbsCompanyID
,MAX(o.orderDate) AS LastOrderDate
,MIN(o.orderDate) AS FirstOrderDate
,COUNT(DISTINCT op.orderID) AS OrderCount
,SUM((op.productPrice + op.productQuantity) + oppo.oppoPrice) LifeTimeValue
,SUM((op.productPrice + op.productQuantity) + oppo.oppoPrice)/COUNT(DISTINCT op.orderID) AverageOrderValue
--INTO #temp_Core
FROM tblOrders_Products op
INNER JOIN tblOrders o
ON o.orderID = op.orderID
INNER JOIN (SELECT op.ID,
			SUM(CASE WHEN oppox.optionID = 617 AND oppox.textValue like 'Yes%' and oppox.optionQTY < 100 THEN 5.00 
				WHEN oppox.optionID = 529 THEN oppox.optionPrice * oppox.textValue
				ELSE oppox.optionPrice + oppox.optionQty END) AS oppoPrice
			FROM tblOrdersProducts_ProductOptions oppox 
			INNER JOIN tblOrders_Products op 
				ON op.ID = oppox.ordersProductsID 
			WHERE op.deletex <> 'yes' 
				AND oppox.deletex <> 'yes'
			GROUP BY op.ID) oppo ON oppo.ID = op.ID
WHERE o.orderStatus NOT IN ('Cancelled', 'Failed') AND op.gbsCompanyID IS NOT NULL 
GROUP BY op.GbsCompanyID