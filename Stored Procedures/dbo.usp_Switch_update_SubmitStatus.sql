CREATE PROC [dbo].[usp_Switch_update_SubmitStatus]
@OPID INT = 0
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/02/18
-- Purpose     Switch sproc that runs via switch to update OPID level fields based on pUnit sibling being split.
--					  This runs after a successful imposition of BCs and reverts any pUnit sibling that was split and incorrectly 
--					  marked as switch_create=1. Despite one half of the OPID being successfully submitted on the OPID level,
--					  the other half (or more) of the OPID, if on the pUnit level is marked as split=1 and submitted_to_switch=0,
--                   hasn't been imposed yet, so we don't want to block the top-level OPID from future impositions. This sproc
--                   helps prevent that issue.
-------------------------------------------------------------------------------
-- Modification History
--07/02/18	created, jf.
-------------------------------------------------------------------------------
UPDATE tblOrders_Products
SET switch_create = 0
WHERE switch_create = 1
AND ID = @OPID
AND ID IN
    (SELECT OPID
    FROM tblSwitch_pUnit_TRON
    WHERE split = 1
    AND submitted_to_switch = 0)