CREATE PROC [dbo].[usp_FT_getActive]	
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/26/15
-- Purpose     Not used.
-------------------------------------------------------------------------------
-- Modification History
--
-- 8/26/16		Added fasTrak related code to include First Class products (FC); JF.
-------------------------------------------------------------------------------
SELECT DISTINCT a.orderNo AS 'Order #', 
a.orderDate AS 'Order Date',
REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS 'Customer',
c.customerID,
p.productCode AS 'Product Code',
p.productID, 
CASE
	WHEN p.shortName IS NOT NULL THEN p.shortName
	WHEN p.shortName IS NULL THEN SUBSTRING(p.productName, 1, CHARINDEX( '(', p.productName) -1)
END AS 'Product Name',
op.productQuantity AS 'Quantity',
op.fastTrak_imprintName AS 'Imprint Name',
p.fastTrak_productType AS 'Type',
op.fastTrak_status AS 'Status',
CASE op.fastTrak_status_LastModified
	WHEN NULL THEN op.created_on
	ELSE op.fastTrak_status_LastModified
END AS 'Status Updated',
op.[ID]
FROM
tblOrders a 
JOIN tblOrders_Products op 
	ON a.orderID = op.orderID
JOIN tblCustomers c 
	ON a.customerID = c.customerID
JOIN tblProducts p 
	ON op.productID = p.productID
WHERE op.processType = 'fasTrak'
AND op.deleteX <> 'Yes'
AND a.orderStatus <> 'Failed'
AND a.orderStatus <> 'Cancelled'
AND a.orderStatus NOT LIKE '%Waiting%'
AND a.orderStatus NOT LIKE '%transit%'
AND a.orderStatus <> 'Delivered'
AND a.orderStatus NOT LIKE '%Waiting%'
AND (p.fastTrak_productType = 'Name Badge' 
	OR p.fastTrak_productType = 'QuickCard' 
	OR p.fastTrak_productType = 'CACX'
	OR p.fastTrak_productType = 'Pen'
	OR p.fastTrak_productType = 'FC')
AND (op.fastTrak_status <> 'Completed' AND op.fastTrak_status <> 'Pending'
	OR op.fastTrak_status IS NULL)
AND op.fastTrak_completed = 0
AND (op.fastTrak_imprintName NOT LIKE '%Spreadsheet%' 
	AND op.fastTrak_imprintName NOT LIKE '%email%'
	OR op.fastTrak_imprintName IS NULL)
--AND p.fastTrak_productType = 'FC'