CREATE PROCEDURE "dbo"."dashboard_getFasTrakActive"
AS

SELECT
	op.[ID],
	a.orderNo AS [OrderNo],
	dbo.fn_getOrderViewMarkdownLink(a.orderNo, a.orderNo) AS orderNo_link,
	a.orderDate AS [Order Date],
	REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS [Customer],
	c.customerID,
	p.productCode AS [Product Code],
	p.productID, 
	p.shortName AS [Product Name],
	op.productQuantity AS [Quantity],
	p.fastTrak_productType AS [productType],
	op.fastTrak_status AS [Status],
CASE op.fastTrak_status_LastModified
	WHEN NULL THEN op.created_on
	ELSE op.fastTrak_status_LastModified
END AS [Status Updated]
FROM
tblOrders a 
INNER JOIN tblOrders_Products op 
	ON a.orderID = op.orderID
INNER JOIN tblCustomers c 
	ON a.customerID = c.customerID
INNER JOIN tblProducts p 
	ON op.productID = p.productID
WHERE op.fastTrak = 1
AND op.deleteX <> 'Yes'
AND a.orderStatus NOT IN ('Failed', 'Cancelled')
AND op.fastTrak_status <> 'Delivered'
AND op.fastTrak_status NOT LIKE '%Transit%'
AND op.fastTrak_status NOT LIKE '%DOCK%'
AND op.fastTrak_completed = 0
ORDER BY a.orderDate DESC