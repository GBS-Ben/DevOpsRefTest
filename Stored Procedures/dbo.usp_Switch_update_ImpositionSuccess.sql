CREATE PROC [usp_Switch_update_ImpositionSuccess] @OPID INT
AS
/*
-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			08/05/20
Purpose			Updates OPIDs as successfully imposed after Imposition step in Switch flows.
-------------------------------------------------------------------------------
Modification History

08/05/20		New
*/

UPDATE op
SET switch_create = 1,
	fastTrak_status = 'In Production',
	fastTrak_status_lastModified = GETDATE(),
	fastTrak_resubmit = 0	
FROM tblOrders_Products op
WHERE op.ID = @OPID