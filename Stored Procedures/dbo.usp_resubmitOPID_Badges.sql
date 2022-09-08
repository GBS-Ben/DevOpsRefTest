CREATE PROC [dbo].[usp_resubmitOPID_Badges]
@ID INT
AS

--use this instead: [usp_resubmitOPID]
--leaving this here in case it used somewhere.

UPDATE tblOrders_Products
SET fastTrak_resubmit = 1,
fastTrak_reimage = 1,
fastTrak_imposed = 0,
switch_create = 0,
fastTrak_preventImposition = 1, --//prevents IMPO from running until POST IMAGE has run which changes it back to 0.
streamPrintDate = GETDATE()
WHERE [ID] = @ID