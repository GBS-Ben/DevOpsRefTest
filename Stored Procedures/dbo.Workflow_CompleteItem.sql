
CREATE PROC [dbo].[Workflow_CompleteItem]
@OPID AS INT =null,
@WPID AS INT=null,
@RunNumber AS INT=null,
@workflowControl AS NVARCHAR(255)=null,
@Status as VARCHAR(50) =null

AS
BEGIN
	
	BEGIN TRY

		IF @OPID IS NULL AND @workflowControl IS NOT NULL
		BEGIN

			select @OPID = opid,@WPID = wpid,@RunNumber = runnumber 
			FROM OPENJSON(@workflowControl)  
			  WITH (
				opid INT '$.opid',
				wpid INT '$.wpid',
				runnumber INT '$.runnumber'
			  )
		END

		UPDATE tblOPIDProductionProcess SET isActive = 0 WHERE OPID = @OPID and RunNumber < @RunNumber

		DECLARE @OPIDS TABLE (OPID INT)

		UPDATE gbsCore.dbo.tblopidproductionprocess 
		SET completed_On= CASE WHEN @Status = 'Success' THEN  getdate() ELSE NULL END,
			completed_Status=@Status 
		OUTPUT deleted.OPID INTO @OPIDS 
		WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1;

		IF (SELECT TOP 1 1 from @OPIDS) IS NULL
		BEGIN
			INSERT INTO gbscore.dbo.tblopidproductionprocess (OPID, RunNumber, workflowID,stepNumber,processID,WPID,isCurrentProcess,isActive,completed_On,completed_Status)
			SELECT DISTINCT @OPID,@RunNumber, workflowid, stepnumber, processid, @WPID, 1, 1,getdate(),@Status
			FROM gbsController_vwWorkflowProcess
			WHERE wpid = @wpid
		END

		IF @Status = 'Success'
		BEGIN

			EXEC gbsController_Workflow_GetNextSteps @OPID, @RunNumber ;
		
			IF (SELECT nextProcessID FROM gbsController_vwWorkflowProcess WHERE WPID = @WPID) IS NULL
			BEGIN
				UPDATE gbsCore.dbo.tblOrders_Products SET fastTrak_status = 'Completed', fastTrak_status_lastModified = GETDATE() WHERE ID = @OPID;
			END
			
			IF (SELECT nextProcessID FROM gbsController_vwWorkflowProcess WHERE WPID = @WPID) IS NOT NULL AND (SELECT fastTrak_Status FROM gbsCore.dbo.tblOrders_Products WHERE ID = @OPID) <> 'In Production'
			BEGIN
				UPDATE gbsCore.dbo.tblOrders_Products SET fastTrak_status = 'In Production', fastTrak_status_lastModified = GETDATE() WHERE ID = @OPID;
			END
		
		END

	
	END TRY
	BEGIN CATCH

		UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_Status='Fail' WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END