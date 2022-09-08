CREATE PROC [dbo].[usp_inArt_getActive_Sort]	
@order_by VARCHAR(255),
@ASCDESC VARCHAR(10)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     02/3/17
-- Purpose     Used to present sorted data to
--					http://intranet/gbs/admin/orders_inArt.asp
--					This is the primary sproc used for fasTrak presentation.

-- Sample Use	EXEC [usp_inArt_getActive_Sort] 'Order #', 'DESC'

-------------------------------------------------------------------------------
-- Modification History
--9/13/2017		BJS	Added Try Catch
-------------------------------------------------------------------------------
SET NOCOUNT ON;
BEGIN TRY

	SELECT a.orderNo AS 'Order #', 
	a.orderDate AS 'Order Date',
	REPLACE((c.firstName + ' ' + c.surName), '  ', ' ') AS 'Customer',
	c.customerID,
	p.productCode AS 'Product Code',
	p.productID, 
	--SUBSTRING(p.productName, 1, CHARINDEX( '(', p.productName) -1) AS 'Product Name',
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
	FROM
	tblOrders a 
	JOIN tblOrders_Products op 
		ON a.orderID = op.orderID
	JOIN tblCustomers c 
		ON a.customerID = c.customerID
	JOIN tblProducts p 
		ON op.productID = p.productID
	WHERE op.fastTrak_status LIKE '%art%'
		AND op.deleteX <> 'Yes'

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
END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH