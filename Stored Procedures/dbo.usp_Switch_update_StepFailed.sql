CREATE PROC [dbo].[usp_Switch_update_StepFailed] @OPID INT
AS
/*
-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			08/05/20
Purpose			Updates OPIDs as failed after failed step in Switch flows. 
				Reset switch_create back to 0 so that it can get picked up again.
-------------------------------------------------------------------------------
Modification History

08/05/20		New
*/

UPDATE op
SET switch_create = 0,
	fastTrak_status = 'Failed',
	fastTrak_status_lastModified = GETDATE()	
FROM tblOrders_Products op
WHERE op.ID = @OPID