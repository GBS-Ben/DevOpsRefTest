CREATE PROC [dbo].[usp_completed_fastTrack]
--[usp_FT_completed]
@ID INT
AS

UPDATE tblOrders_Products
SET fastTrak_resubmit = 1
WHERE [ID] = @ID