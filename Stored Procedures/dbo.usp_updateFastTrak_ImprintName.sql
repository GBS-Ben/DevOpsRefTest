CREATE PROC usp_updateFastTrak_ImprintName
AS
UPDATE tblOrders_Products
SET fastTrak_imprintName = b.textValue
FROM tblOrders_Products a JOIN tblOrdersProducts_productOptions b
ON a.[ID] = b.ordersProductsID
JOIN tblOrders o
ON a.orderID = o.orderID
WHERE b.optionID = 279
AND b.deleteX <> 'yes'
AND a.fastTrak_completed = 0
AND a.fastTrak_status <> 'Completed'
AND a.fastTrak_status <> 'Pending'
AND a.fastTrak = 1
AND a.deleteX <> 'yes'
AND o.orderStatus <> 'Failed'
AND o.orderStatus <> 'Cancelled'
AND o.orderStatus NOT LIKE '%Waiting%'