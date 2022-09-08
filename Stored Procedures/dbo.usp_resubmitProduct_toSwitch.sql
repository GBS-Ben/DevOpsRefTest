
CREATE PROC [dbo].[usp_resubmitProduct_toSwitch]
@ID INT, @QTY INT
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     1/1/2014
-- Purpose     This is the primary resubmission sproc used on orderView.asp, as well as other locations.
-------------------------------------------------------------------------------
-- Modification History
--
-- 1/1/2014	   Created, jf
-- 5/11/2018	updated with new reprint choices, jf
-------------------------------------------------------------------------------
--if resubmitted qty is 0, update it to the originally ordered quantity
IF @QTY = 0
BEGIN
	SET @QTY = (SELECT productQuantity
				FROM tblOrders_Products
				WHERE @ID = [ID]
				AND productQuantity IS NOT NULL)
END

--update fastrak fields for resubmission
UPDATE tblOrders_Products
SET fastTrak_resubmit = 1, 
	 switch_create = 0, 
	 switch_createDate = NULL, 
	 fastTrak_newQTY = @QTY,
	 fastTrak_status = 'Good to Go', 
	 fastTrak_status_lastModified = GETDATE()
WHERE [ID] = @ID

--log the action
INSERT INTO tblSwitch_Submit (ordersProductsID, submitted_on)
SELECT @ID, GETDATE()


/*
What type of resubmission is this?

1.	Production Error
2.	Reprint – Ship Alone
3.	Reprint – Ship Whole Order


THREE CHOICES FOR RESUB
1.	IS THIS A PRODUCTION ERROR? i resub it, that opid stands alone, sorts to front
2.	IS THIS A REPRINT from the client (not whole order)?
1.	if it’s only a single product, then it ships by itself
2.	if it’s a couple products (e.g. out of 5, they chose to resub 2)
not common however, need to update shipsWith to recognize other resubbed opid(s)
worse case scenario, they both say “SHIP”, and we waste a little money
3.	IS THIS A REPRINT (whole order?)
1.	when it is the whole order, in the future, can we resub all opids in order.

*/