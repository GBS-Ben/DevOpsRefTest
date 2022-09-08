







CREATE PROC [dbo].[TicTicQueue_Finish]
@itemGUID uniqueidentifier,
@Status VARCHAR(255),
@ErrMsg VARCHAR(255)
AS 
BEGIN 

		-- Log status
		UPDATE t SET ProcessEndDateTime=GETDATE(),ProcessStatus = @Status, ProcessError = @ErrMsg
		FROM [dbo].[tblTicTicLog] t
		WHERE itemGUID = @itemGUID

END
GO
