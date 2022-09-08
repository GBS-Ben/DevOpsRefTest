CREATE PROC [dbo].[usp_FT_OPC_IMAGE_postSSIS]
AS
SET NOCOUNT ON;

BEGIN TRY

	UPDATE tblW2PMerge
	SET exportStatus = 'Export Complete',
	exportedOn = getDate()
	WHERE exportStatus = 'Ready for Export'

	UPDATE tblOrders_Products
	SET
	fastTrak_imageFile_exported = 1,
	fastTrak_imageFile_exportedOn = b.exportedOn,
	fastTrak_resubmit = 0,
	fastTrak_reimage = 0,
	fastTrak_status = 'In Production'
	FROM tblOrders_Products a
	INNER JOIN tblW2PMerge b
		ON a.[ID] = b.ordersProductsID
	WHERE b.exportStatus = 'Export Complete'
	AND a.fastTrak_productType = 'OPC'

	--// Write notes

	INSERT INTO tbl_Notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
	SELECT a.orderID, b.orderNo, 
	'The following product''s image file has been created: ' + CONVERT(VARCHAR(50), b.ordersProductsID) + '.',
	GETDATE(), 'SQL', 'product', b.ordersProductsID
	FROM tblOrders a INNER JOIN tblW2PMerge b
	ON a.orderNo = b.orderNo
	WHERE b.exportStatus = 'Export Complete'

	--// Wipe and refresh data to account for possible data changes on the Intranet
	DELETE FROM tblW2PMerge

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH
	/*
	Turn it around

	SELECT * FROM tblOrders_Products
	WHERE fastTrak_productType = 'OPC'

	UPDATE tblOrders_Products
	SET fastTrak_imageFile_exported = 0,
	fastTrak_resubmit = 0,
	fastTrak_completed =0
	WHERE fastTrak_productType = 'OPC'

	*/