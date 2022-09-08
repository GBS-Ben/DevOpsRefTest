CREATE PROC [dbo].[usp_FT_getCompleted]	
AS
SELECT DISTINCT TOP 1000 a.orderNo AS 'Order #', 
a.orderDate AS 'Order Date',
REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS 'Customer',
c.customerID,
p.productCode AS 'Product Code',
p.productID, 
p.shortName AS 'Product Name',
op.productQuantity AS 'Quantity',
op.fastTrak_imprintName AS 'Imprint Name',
p.fastTrak_productType AS 'Type',
op.fastTrak_status AS 'Status',
op.fastTrak_status_LastModified AS 'Status Updated',
op.[ID]
FROM
tblOrders a INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblProducts p ON op.productID = p.productID
WHERE op.fastTrak = 1
AND op.deleteX <> 'Yes'
AND a.orderStatus <> 'Failed'
AND a.orderStatus <> 'Cancelled'
AND a.orderStatus NOT LIKE '%Waiting%'
AND p.fastTrak_productType = 'Name Badge'
AND op.fastTrak_completed = 1
AND a.cartVersion = 1
AND DATEDIFF(dd, op.fastTrak_status_LastModified, GETDATE()) <= 7
AND DATEDIFF(mm, a.orderDate, GETDATE()) <= 6

UNION

SELECT DISTINCT TOP 1000 a.orderNo AS 'Order #', 
a.orderDate AS 'Order Date',
a.billing_FirstName AS 'Customer',
c.customerID,
p.productCode AS 'Product Code',
p.productID, 
p.shortName AS 'Product Name',
op.productQuantity AS 'Quantity',
op.fastTrak_imprintName AS 'Imprint Name',
p.fastTrak_productType AS 'Type',
op.fastTrak_status AS 'Status',
op.fastTrak_status_LastModified AS 'Status Updated',
op.[ID]
FROM
tblOrders a INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblProducts p ON op.productID = p.productID
WHERE op.fastTrak = 1
AND op.deleteX <> 'Yes'
AND a.orderStatus <> 'Failed'
AND a.orderStatus <> 'Cancelled'
AND a.orderStatus NOT LIKE '%Waiting%'
AND p.fastTrak_productType = 'Name Badge'
AND op.fastTrak_completed = 1
AND a.cartVersion = 2
AND a.billing_FirstName <> ''
AND DATEDIFF(dd, op.fastTrak_status_LastModified, GETDATE()) <= 7
AND DATEDIFF(mm, a.orderDate, GETDATE()) <= 6

UNION

SELECT DISTINCT TOP 1000 a.orderNo AS 'Order #', 
a.orderDate AS 'Order Date',
REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS 'Customer',
c.customerID,
p.productCode AS 'Product Code',
p.productID, 
p.shortName AS 'Product Name',
op.productQuantity AS 'Quantity',
op.fastTrak_imprintName AS 'Imprint Name',
p.fastTrak_productType AS 'Type',
op.fastTrak_status AS 'Status',
op.fastTrak_status_LastModified AS 'Status Updated',
op.[ID]
FROM
tblOrders a INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblProducts p ON op.productID = p.productID
WHERE op.fastTrak = 1
AND op.deleteX <> 'Yes'
AND a.orderStatus <> 'Failed'
AND a.orderStatus <> 'Cancelled'
AND a.orderStatus NOT LIKE '%Waiting%'
AND p.fastTrak_productType = 'Name Badge'
AND op.fastTrak_completed = 1
AND a.cartVersion = 2
AND a.billing_FirstName = ''
AND DATEDIFF(dd, op.fastTrak_status_LastModified, GETDATE()) <= 7
AND DATEDIFF(mm, a.orderDate, GETDATE()) <= 6

ORDER BY a.orderDate DESC