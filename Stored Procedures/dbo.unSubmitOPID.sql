CREATE PROCEDURE "dbo"."unSubmitOPID" 
@OPID INT
AS
-- do the opposite action of what usp_resubmitOPID updates in tblOrders_products
UPDATE tblOrders_Products
SET fastTrak_resubmit = 0, 
	 switch_create = 1, 
	 fastTrak_status = 'In House', 
	 fastTrak_status_lastModified = GETDATE()
WHERE [ID] = @OPID