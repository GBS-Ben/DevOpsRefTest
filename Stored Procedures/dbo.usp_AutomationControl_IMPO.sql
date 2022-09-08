CREATE PROC [dbo].[usp_AutomationControl_IMPO]
@controlName VARCHAR(20) = 'NotecardImposition'
AS
UPDATE tblSwitchControl
SET controlStatus = 1
WHERE controlName = @controlName