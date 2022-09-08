





CREATE PROC [dbo].[Workflow_ApparelLogoQRExists]
@OPID AS INT,
@WPID AS INT,
@RunNumber AS INT
AS
BEGIN
	
	BEGIN TRY
	
	DECLARE @isExists INT
	DECLARE @LogoURL varchar(255)
	DECLARE @LogoQR varchar(255)

	SET @LogoURL = (SELECT textValue FROM tblOrdersProducts_ProductOptions  WHERE ordersProductsID = @OPID and deletex <> 'yes' and optionCaption = 'EMB Logo');
	SET @LogoQR = (SELECT textValue FROM tblOrdersProducts_ProductOptions  WHERE ordersProductsID = @OPID and deletex <> 'yes' and optionCaption = 'EMB Logo QR');

	EXECUTE master.[sys].[xp_fileexist] @LogoQR,@isExists OUTPUT
	
	IF @isExists = 1   
		BEGIN
			UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_On = getdate(),completed_Status='Success' WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1

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
	ELSE
		BEGIN
			DECLARE @workflowControl varchar(255)
			SET @workflowControl = dbo.GetWorkflowControl(@OPID,@WPID,@RunNumber)
			
			EXEC gbsCore.dbo.Queue_QR @LogoURL,@LogoQR,@workflowControl
		END
	END TRY
	BEGIN CATCH

		UPDATE gbsCore.dbo.tblopidproductionprocess SET completed_Status='Fail' WHERE OPID = @OPID and WPID = @WPID AND RunNumber = @RunNumber and isActive = 1
		INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) VALUES (@orderNo, 'Prod Workflow', getdate(), cast(@OPID as varchar(15)) + ' - ' + @workflowName + ' ' + ISNULL(@intranetTab,@processName) + ' was completed.', 'product',@OPID)

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
		
END