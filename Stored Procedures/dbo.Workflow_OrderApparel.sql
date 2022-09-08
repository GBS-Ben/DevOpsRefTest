


CREATE PROC [dbo].[Workflow_OrderApparel]
@OPID AS INT,
@WPID AS INT,
@RunNumber AS INT
AS
BEGIN
	
	BEGIN TRY

		IF (SELECT Completed_On FROM gbsCore.dbo.tblopidproductionprocess WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1) IS NOT NULL 
		BEGIN
			EXEC gbsController_Workflow_ProcessEnd @OPID, @WPID, @RunNumber ;
		END
	
	END TRY
	BEGIN CATCH

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END