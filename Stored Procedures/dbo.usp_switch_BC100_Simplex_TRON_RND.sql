CREATE PROCEDURE [dbo].[usp_switch_BC100_Simplex_TRON_RND]
AS
truncate table tblSwitch_BCS_ThresholdDiff_BC100_TRON_RND_Simplex 

--Run BCD_RND now, regardless of what happened with BCS_RND. This preserves the order of BCS > BCD.
UPDATE tblSwitchControl
SET controlStatus = 1
WHERE controlName = 'IMPO_BCD_RND_100'


select * from tblSwitch_BCS_ThresholdDiff_BC100_TRON_RND_Simplex