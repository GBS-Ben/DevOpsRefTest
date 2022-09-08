CREATE PROC [dbo].[usp_resubmit_byID_plusQTY_Switch_QC]
@ID INT, @QTY INT
AS

--should be able to use this instead: [usp_resubmitOPID]
--leaving this here in case it is used elsewhere.

IF @QTY = 0
BEGIN
	SET @QTY = (SELECT productQuantity
				FROM tblOrders_Products
				WHERE @ID = [ID]
				AND productQuantity IS NOT NULL)
END

IF @QTY IS NULL
BEGIN
	SET @QTY = (SELECT productQuantity
				FROM tblOrders_Products
				WHERE @ID = [ID]
				AND productQuantity IS NOT NULL)
END

UPDATE tblOrders_Products
SET switch_create = 0, switch_createDate = null, fastTrak_newQTY = @QTY
WHERE [ID] = @ID

INSERT INTO tblSwitch_Submit (ordersProductsID, submitted_on)
SELECT @ID, GETDATE()