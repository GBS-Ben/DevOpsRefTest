

CREATE PROC [dbo].[Workflow_StartByOrderNo]
@orderNo VARCHAR(30)
AS 
BEGIN 
	BEGIN TRY
		DROP TABLE IF EXISTS #ProdForWorkflow

		SELECT Row_number() OVER (Order BY op.ID) AS RowNumber, op.ID
		INTO #prodForWorkflow
		FROM tblorders o
		INNER JOIN tblOrders_Products op 
			ON op.orderID = o.orderID 
		WHERE op.workflowID IS NOT NULL
		AND o.orderNo = @orderNo

		

		DECLARE @RowCnt INT
		DECLARE @CurrentRow INT = 1
		DECLARE @OPID INT
		DECLARE @WPID INT
		DECLARE @runnumber INT
		SELECT @RowCnt = COUNT(*) FROM #prodForWorkflow

		WHILE @CurrentRow <= @RowCnt
		BEGIN
			SELECT @OPID = ID
				FROM #prodForWorkflow
				WHERE RowNumber = @currentRow
				
			SELECT @WPID = wp.wpid,@runnumber = runnumber
				FROM [gbsController].[dbo].[vwWorkflowProcess] wp
				inner join gbsCore.dbo.tblopidproductionprocess opp ON wp.wpid = opp.wpid
				where isactive = 1 and processaction = 'gbsCore.dbo.workflow_PaymentStatus'
				and opp.opid = @OPID
			
			IF @runnumber IS NULL
			BEGIN
				EXEC gbsController_workflow_Start @OPID
			END
			ELSE
			BEGIN
				EXEC workflow_PaymentStatus @opid = @opid , @wpid = @wpid, @runnumber = @runnumber
			END
			SET @CurrentRow += 1
		END
	END TRY
	BEGIN CATCH
		
		EXEC [dbo].[usp_StoredProcedureErrorLog]
	END CATCH



END