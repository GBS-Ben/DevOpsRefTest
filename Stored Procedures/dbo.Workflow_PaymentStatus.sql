





CREATE PROC [dbo].[Workflow_PaymentStatus]
@OPID AS INT,
@WPID AS INT,
@RunNumber AS INT
AS
BEGIN
	
	BEGIN TRY

		DECLARE @tblOPID TABLE (OPID int);
		DECLARE @orderNo varchar(15);
		DECLARE @workflowName varchar(255);
		DECLARE @intranetTab varchar(255);
		DECLARE @processName varchar(255);

		SET @orderNo = (SELECT o.orderNo FROM tblOrders o INNER JOIN tblOrders_Products op on o.orderID = op.orderID and op.id = @OPID);
		SELECT @workflowName = workflowName,@intranetTab = intranetTab,@processName = processName
		FROM gbsController_vwWorkflowProcess WHERE wpid = @wpid;
		
		EXEC dbo.usp_PaymentStatus @orderNo

		UPDATE opp SET Completed_on = getdate(), completed_Status = 'Success'
		FROM tblopidproductionprocess opp
		INNER JOIN tblOrders_Products op ON opp.OPID = op.ID
		INNER JOIN tblOrders o on op.orderID = o.orderID
		WHERE opp.OPID = @OPID and opp.WPID = @WPID AND opp.RunNumber = @RunNumber AND opp.isActive = 1
		  AND o.displayPaymentStatus IN ('Good', 'Credit Due')

		INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) VALUES (@orderNo, 'Prod Workflow', getdate(), cast(@OPID as varchar(15)) + ' - ' + @workflowName + ' ' + ISNULL(@intranetTab,@processName) + ' was completed.', 'product',@OPID)
		
		IF @@ROWCOUNT > 0 
		BEGIN
			EXEC gbsController_Workflow_GetNextSteps @OPID, @RunNumber ;
		END
	
	END TRY
	BEGIN CATCH

		UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_Status='Fail' WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1
		INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) VALUES (@orderNo, 'Prod Workflow', getdate(), cast(@OPID as varchar(15)) + ' - ' + @workflowName + ' ' + ISNULL(@intranetTab,@processName) + ' failure.', 'product',@OPID)

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END