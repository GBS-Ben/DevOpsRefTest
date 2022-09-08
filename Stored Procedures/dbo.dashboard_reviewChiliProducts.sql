CREATE PROCEDURE "dbo"."dashboard_reviewChiliProducts"
AS
SELECT TOP 75
	op.id as id,
	dbo.fn_getOrderViewMarkdownLink(CONCAT(o.orderNo, '_', op.id), o.orderNo) AS orderNo_link,
		dbo.fn_getFileName(f.textValue) AS image,
	--dbo.fn_getFileName(b.textValue) AS image2,
	CONCAT('/api/markProductReviewed/', op.id) AS action_1
	--CONCAT('/api/markProductDeferred/', o1.ordersProductsID ) AS action_2
FROM tblOrders_products op
-- check order status
INNER JOIN tblOrders o
	ON op.orderId = o.orderID
	AND o.orderStatus NOT IN ('Delivered', 'Cancelled',	'Failed',	'In Transit',	'In Transit USPS')
-- Check for Chili flag
INNER JOIN tblOrdersproducts_productOptions op1
	ON op.id = op1.ordersProductsID
	AND op1.optionCaption = 'Chili'
	AND op1.deletex <> 'yes'
-- Check for OPC flag
INNER JOIN tblOrdersproducts_productOptions op2
	ON op.id = op2.ordersProductsID
	AND op2.optionCaption = 'OPC'
	AND op2.deletex <> 'yes'
-- get front printfile
LEFT JOIN tblOrdersProducts_productOptions f
	ON op.id = f.ordersProductsID
	AND f.optionCaption = 'File Name 2'
--LEFT JOIN tblOrdersProducts_productOptions b
	--ON op.id = b.ordersProductsID
	--AND b.optionCaption = 'Whatever the optionCaption is for chili backs if we decide to add those'
WHERE op.processType = 'fastrak'
AND op.isValidated = 0
AND op.deletex <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) <> 'PN'
ORDER BY o.orderDate ASC