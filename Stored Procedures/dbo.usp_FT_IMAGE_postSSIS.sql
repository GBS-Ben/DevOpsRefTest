CREATE PROC [dbo].[usp_FT_IMAGE_postSSIS]
AS

-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/26/14
-- Purpose     Maintenance code for fasTrak related products
-------------------------------------------------------------------------------
-- Modification History
-- 01/26/14		created
-- 07/16/18		removed fastTrak_producType clause in initial query, replaced with productCode clauses, jf.
-------------------------------------------------------------------------------
SET NOCOUNT ON;

BEGIN TRY
	UPDATE tblFT_Badges
	SET exportStatus = 'Export Complete',
	exportedOn = GETDATE()
	WHERE exportStatus = 'Ready for Export'

	UPDATE tblOrders_Products
	SET
	fastTrak_imageFile_exported = 1,
	fastTrak_imageFile_exportedOn = b.exportedOn,
	fastTrak_resubmit = 0,
	fastTrak_reimage = 0,
	fastTrak_status = 'Image Created',
	fastTrak_preventImposition = 0
	FROM tblOrders_Products a
	INNER JOIN tblFT_Badges b
		ON a.[ID] = b.ordersProductsID
	WHERE b.exportStatus = 'Export Complete'
	AND SUBSTRING(a.productCode, 1, 2) = 'NB'
	AND SUBSTRING(a.productCode, 3, 2) <> 'CU'
	AND a.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')


	--// Write notes
	INSERT INTO tbl_Notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
	SELECT a.orderID, b.orderNo, 
	'The following product''s image file has been created: ' + CONVERT(VARCHAR(50), b.ordersProductsID) + '.',
	GETDATE(), 'SQL', 'product', b.ordersProductsID
	FROM tblOrders a 
	INNER JOIN tblFT_Badges b
		ON a.orderNo = b.orderNo
	WHERE b.exportStatus = 'Export Complete'
	AND b.notesWritten_imageFileCreation = 0

	UPDATE tblFT_Badges
	SET notesWritten_imageFileCreation = 1
	WHERE exportStatus = 'Export Complete'
	AND notesWritten_imageFileCreation = 0

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH