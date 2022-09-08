CREATE PROCEDURE [dbo].[usp_Switch_BC_Simplex_BC100_TRON]
AS
truncate table tblSwitch_BCS_ThresholdDiff_BC100_TRON 

--Run BCD100 now, regardless of what happened with BCS. This preserves the order of BCS > BCD.
UPDATE tblSwitchControl
SET controlStatus = 1
WHERE controlName = 'IMPO_BCD_100'

select * from tblSwitch_BCS_ThresholdDiff_BC100_TRON