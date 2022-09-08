--sp_recompile 'usp_getFastTrackActive'

CREATE PROC [dbo].[usp_getFastTrackActive]	
AS

SELECT  a.orderNo AS 'Order #', 
a.orderDate AS 'Order Date',
REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS 'Customer',
c.customerID,
p.productCode AS 'Product Code',
p.productID, 
p.shortName AS 'Product Name',
op.productQuantity AS 'Quantity',
'N/A' AS 'Imprint Name',
p.fastTrak_productType AS 'Type',
op.fastTrak_status AS 'Status',
CASE op.fastTrak_status_LastModified
	WHEN NULL THEN op.created_on
	ELSE op.fastTrak_status_LastModified
END AS 'Status Updated',
op.[ID]
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