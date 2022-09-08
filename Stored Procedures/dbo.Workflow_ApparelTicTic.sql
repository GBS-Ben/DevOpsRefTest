






CREATE PROC [dbo].[Workflow_ApparelTicTic]
@OPID AS INT,
@WPID AS INT,
@RunNumber AS INT
AS
BEGIN
	
	BEGIN TRY
	
		DECLARE @workflowControl varchar(255)
		SET @workflowControl = dbo.GetWorkflowControl(@OPID,@WPID,@RunNumber)
			
		EXEC gbsCore.dbo.Queue_TicTic @OPID,'AP',@workflowControl
	END TRY
	BEGIN CATCH

		UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_Status='Fail' WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1
		DECLARE @orderNo varchar(15);
		DECLARE @workflowName varchar(255);
		DECLARE @intranetTab varchar(255);
		
		SET @orderNo = (SELECT o.orderNo FROM tblOrders o INNER JOIN tblOrders_Products op on o.orderID = op.orderID and op.id = @OPID);
		SELECT @workflowName = workflowName,@intranetTab = intranetTab
		FROM gbsController_vwWorkflowProcess WHERE wpid = @wpid;

		INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) VALUES (@orderNo, 'Prod Workflow', getdate(), cast(@OPID as varchar(15)) + ' - ' + @workflowName + ' ' + ISNULL(@intranetTab,'') + ' tab failure.', 'product',@OPID)

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END