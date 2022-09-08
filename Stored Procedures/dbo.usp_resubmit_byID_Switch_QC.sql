CREATE PROC [dbo].[usp_resubmit_byID_Switch_QC]
@ID INT
AS

--use this instead: [usp_resubmitOPID]
--leaving this here in case it is referenced somewhere.

UPDATE tblOrders_Products
SET switch_create = 0, switch_createDate = null 
WHERE [ID] = @ID