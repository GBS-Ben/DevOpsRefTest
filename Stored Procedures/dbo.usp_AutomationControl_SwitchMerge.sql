CREATE PROC usp_AutomationControl_SwitchMerge
AS
UPDATE tblSwitchControl
SET controlStatus = 1
WHERE controlName = 'SwitchMerge'