CREATE PROC [dbo].[usp_AutomationControl_NotecardImposition]
@controlName VARCHAR(20) = 'ReversetheReverse',
@printerID INT = 1
AS
UPDATE tblSwitchControl
SET controlStatus = 1,
	   printerID = @printerID
WHERE controlName = @controlName