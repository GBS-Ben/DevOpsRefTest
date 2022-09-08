CREATE PROC usp_SwitchControl_check
AS
DECLARE @controlStatus BIT = 0
SET @controlStatus = (SELECT controlStatus
					  FROM tblSwitchControl
					  WHERE controlName = 'IMPO_Badge')
IF @controlStatus = 1
	BEGIN
		UPDATE tblSwitchControl
		SET controlStatus = 0
		WHERE controlName = 'IMPO_Badge'
		AND controlStatus = 1

		EXEC usp_FT_impose
	END