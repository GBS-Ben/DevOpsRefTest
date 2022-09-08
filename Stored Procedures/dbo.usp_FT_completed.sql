CREATE PROC [dbo].[usp_FT_completed]
--[usp_FT_completed]
@ID INT
AS

UPDATE tblOrders_Products
SET fastTrak_completed = 1
WHERE [ID] = @ID