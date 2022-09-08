





CREATE PROC [dbo].[Workflow_CompleteItemByControl]
@workflowControl AS NVARCHAR(255),
@Status as VARCHAR(50)
AS
BEGIN
	
	BEGIN TRY
		DECLARE @OPID INT, @WPID INT, @RunNumber INT;

		SELECT @OPID = opid,@WPID = wpid,@RunNumber = runnumber 
		FROM OPENJSON(@workflowControl)  
			WITH (
			opid INT '$.opid',
			wpid INT '$.wpid',
			runnumber INT '$.runnumber'
			);

		IF @Status = 'Success'
		BEGIN
			UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_On= getdate(),completed_Status=@Status WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1;
			EXEC gbsController_Workflow_GetNextSteps @OPID, @WPID, @RunNumber ;
		END
		ELSE
		BEGIN
			UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_Status=@Status WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1;
			--TODO: send email
		END
	
	END TRY
	BEGIN CATCH

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END