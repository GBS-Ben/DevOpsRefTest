







CREATE PROC [dbo].[Process_TicTic_Finish]
@itemGUID uniqueidentifier,
@workflowControl varchar(255),
@Status VARCHAR(255),
@ErrMsg VARCHAR(255)
AS 
BEGIN 

		-- Log status
		UPDATE t SET ProcessEndDateTime=GETDATE(),ProcessStatus = @Status, ProcessError = @ErrMsg
		FROM [dbo].[tblTicTicLog] t
		WHERE itemGUID = @itemGUID

		IF (@workflowControl  IS NOT NULL)
			BEGIN
		
				EXEC dbo.Workflow_CompleteItem @workflowControl=@workflowControl, @Status = @Status, @OPID=null, @WPID=null, @RunNumber=null

			END

END