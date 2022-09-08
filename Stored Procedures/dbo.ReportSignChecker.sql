CREATE PROC [dbo].[ReportSignChecker] AS
SELECT o.orderNo, o.orderStatus, o.orderDate, op.ID AS OPID, op.productCode, op.productName, op.fasttrak_status, oppx.optionCaption, oppx.textValue AS [JSON]
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
WHERE op.fasttrak_status = 'failed'
AND SUBSTRING(op.productCode, 1, 2) = 'SN' 
AND (op.productCode NOT LIKE 'SNFA%' AND op.processType <> 'fasTrak'
		OR op.productCode LIKE 'SNFA%' AND op.processType = 'fasTrak') 
AND oppx.optionCaption = 'CanvasUserItemsJson'
AND op.deleteX <> 'yes'
AND oppx.deleteX <> 'yes'
AND o.orderstatus not in ('failed', 'cancelled')
ORDER BY op.ID DESC