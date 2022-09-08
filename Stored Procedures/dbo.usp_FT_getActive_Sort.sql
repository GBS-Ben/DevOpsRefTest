CREATE PROC [dbo].[usp_FT_getActive_Sort]	
@order_by VARCHAR(255),
@ASCDESC VARCHAR(10)
AS
/*
-------------------------------------------------------------------------------
Author				Jeremy Fifer
Created			01/26/15
Purpose			Used to present sorted data to
						http://intranet/gbs/admin/orders_fasTrak.asp
						This is the primary sproc used for fasTrak presentation.

Sample Use		EXEC usp_FT_getActive_Sort 'Order #', 'DESC'
-------------------------------------------------------------------------------
Modification History

08/26/16		Added fasTrak related code to include First Class products (FC), jf.
08/09/17		Added JU/EX/BU to FT code, jf.
07/16/18		Pulled code from WHERE clause: AND op.fastTrak_completed = 0; AND p.fastTrak_productType IN 
					('Name Badge', 'QuickCard', 'QM', 'CM', 'CACX', 'Pen', 'FC', 'NC', 'JU', 'EX', 'BU'); 
					AND (op.fastTrak_imprintName NOT LIKE '%Spreadsheet%' , jf
-------------------------------------------------------------------------------
*/

SELECT a.orderNo AS 'Order #', 
a.orderDate AS 'Order Date',
REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS 'Customer',
c.customerID,
p.productCode AS 'Product Code',
p.productID, 
REPLACE(SUBSTRING(p.productName, 1, CHARINDEX( '(', p.productName)), '(', '') AS 'Product Name',
op.productQuantity AS 'Quantity',
op.fastTrak_imprintName AS 'Imprint Name',
p.fastTrak_productType AS 'Type',
op.fastTrak_status AS 'Status',
CASE op.fastTrak_status_LastModified
	WHEN NULL THEN op.created_on
	ELSE op.fastTrak_status_LastModified
END AS 'Status Updated',
op.[ID],
a.orderID
FROM tblOrders a 
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblProducts p ON op.productID = p.productID
WHERE op.processType = 'fasTrak'
AND op.deleteX <> 'Yes'
AND op.fastTrak_completed = 0
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'Delivered', 'MIGZ', 'In Transit', 'In Transit USPS', 'Waiting For Payment', 
						 'Waiting On Customer', 'Waiting For New Art', 'GTG-Waiting For Payment')
AND (op.fastTrak_status NOT IN ('Completed', 'Pending')
	OR op.fastTrak_status IS NULL)
AND (op.fastTrak_imprintName NOT LIKE '%Spreadsheet%' AND op.fastTrak_imprintName NOT LIKE '%email%'
	OR op.fastTrak_imprintName IS NULL)
ORDER BY
     CASE @ASCDESC
          WHEN 'ASC' THEN
               CASE @order_by
                    WHEN 'Order #' THEN a.orderNo
					WHEN 'Order Date' THEN CONVERT(VARCHAR(50), a.orderDate)
                    WHEN 'Customer' THEN REPLACE((c.firstName + ' ' + c.surName), '  ', ' ')
                    WHEN 'customerID' THEN CONVERT(VARCHAR(50), c.customerID)
                    WHEN 'Product Code' THEN p.productCode
                    WHEN 'Product ID' THEN CONVERT(VARCHAR(50), p.productID)
					WHEN 'Product Name' THEN SUBSTRING(p.productName, 1, CHARINDEX( '(', p.productName) -1)
					WHEN 'Quantity' THEN CONVERT(VARCHAR(50), op.productQuantity)
					WHEN 'Imprint Name' THEN op.fastTrak_imprintName
					WHEN 'Type' THEN p.fastTrak_productType
					WHEN 'Status' THEN op.fastTrak_status
					WHEN 'ID' THEN CONVERT(VARCHAR(50), op.[ID])
					WHEN 'orderID' THEN CONVERT(VARCHAR(50), a.orderID)
                    ELSE a.orderNo
               END
		  ELSE '1'
     END ASC,
     CASE @ASCDESC
          WHEN 'DESC' THEN
               CASE @order_by
                    WHEN 'Order #' THEN a.orderNo
					WHEN 'Order Date' THEN CONVERT(VARCHAR(50), a.orderDate)
                    WHEN 'Customer' THEN REPLACE((c.firstName + ' ' + c.surName), '  ', ' ')
                    WHEN 'customerID' THEN CONVERT(VARCHAR(50), c.customerID)
                    WHEN 'Product Code' THEN p.productCode
                    WHEN 'Product ID' THEN CONVERT(VARCHAR(50), p.productID)
					WHEN 'Product Name' THEN SUBSTRING(p.productName, 1, CHARINDEX( '(', p.productName) -1)
					WHEN 'Quantity' THEN CONVERT(VARCHAR(50), op.productQuantity)
					WHEN 'Imprint Name' THEN op.fastTrak_imprintName
					WHEN 'Type' THEN p.fastTrak_productType
					WHEN 'Status' THEN op.fastTrak_status
					WHEN 'orderID' THEN CONVERT(VARCHAR(50), a.orderID)
                    ELSE a.orderNo
               END
		  ELSE '1'
     END DESC