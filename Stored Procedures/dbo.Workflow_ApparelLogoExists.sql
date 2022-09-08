





CREATE PROC [dbo].[Workflow_ApparelLogoExists]
@OPID AS INT,
@WPID AS INT,
@RunNumber AS INT
AS
BEGIN
	
	BEGIN TRY
	
	DECLARE @isExists INT
	DECLARE @LogoURL varchar(255)

	SET @LogoURL = (SELECT textValue FROM tblOrdersProducts_ProductOptions  WHERE ordersProductsID = @OPID and deletex <> 'yes' and optionCaption = 'EMB Logo');

	EXECUTE master.[sys].[xp_fileexist] @LogoURL,@isExists OUTPUT
	
	IF @isExists = 1   
		BEGIN

			UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_On = getdate() WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1

			DECLARE @orderNo varchar(15);
			DECLARE @workflowName varchar(255);
			DECLARE @intranetTab varchar(255);
			DECLARE @processName varchar(255);

			SET @orderNo = (SELECT o.orderNo FROM tblOrders o INNER JOIN tblOrders_Products op on o.orderID = op.orderID and op.id = @OPID);
			SELECT @workflowName = workflowName,@intranetTab = intranetTab,@processName = processName
			FROM gbsController_vwWorkflowProcess WHERE wpid = @wpid;

			INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) VALUES (@orderNo, 'Prod Workflow', getdate(), cast(@OPID as varchar(15)) + ' - ' + @workflowName + ' ' + ISNULL(@intranetTab,@processName) + ' was completed.', 'product',@OPID)

			EXEC gbsController_Workflow_GetNextSteps @OPID, @RunNumber ;
		END
	
	END TRY
	BEGIN CATCH

		UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_Status='Fail' WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1
		INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) VALUES (@orderNo, 'Prod Workflow', getdate(), cast(@OPID as varchar(15)) + ' - ' + @workflowName + ' ' + ISNULL(@intranetTab,@processName) + ' was completed.', 'product',@OPID)

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END