
CREATE PROC usp_OPC_reset
AS
UPDATE tblOrders_Products
SET fastTrak_completed = 0,
fastTrak_imageFile_exported = 0,
fastTrak_resubmit = 1
WHERE fastTrak_productType = 'OPC'