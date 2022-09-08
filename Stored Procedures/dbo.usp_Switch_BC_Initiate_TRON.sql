CREATE PROCEDURE [dbo].[usp_Switch_BC_Initiate_TRON]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     09/12/18
-- Purpose     Business Card Flow initiated by a SQL Server Job uses this flag
-------------------------------------------------------------------------------
-- Modification History
--
--09/12/18	    Created, jf.
-------------------------------------------------------------------------------

UPDATE tblSwitchControl
SET controlStatus = 1
WHERE controlName = 'IMPO_BCS'