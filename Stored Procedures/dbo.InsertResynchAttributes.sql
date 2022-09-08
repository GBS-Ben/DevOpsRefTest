


CREATE PROCEDURE [dbo].[InsertResynchAttributes] 
@Status varchar(255) OUTPUT,
@ErrMsg nvarchar(4000) OUTPUT
AS

BEGIN
/*
-------------------------------------------------------------------------------
Author     
Created     
Purpose     NOP OPPO resync
-------------------------------------------------------------------------------
Modification History

02/26/21	CKB, added optionprice and quantity back in - commented 399/OPC to match migration, changed to upsert from mass delete/insert
04/01/21	CKB, fixed postcard pricing attributes
04/05/21	BS, fix try_convert binary truncation issue.
08/24/21	CKB, fixed opid and opidguid values
*/
	DECLARE @orderItemOffset INT;
	EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @orderItemOffset OUTPUT;

	BEGIN TRY
			--move the envelope oppos to the envelope product
			UPDATE oppos set ordersProductsID = oppo.ordersProductsID, ordersProductsGUID = oppo.ordersProductsGUID
			FROM #tblOrdersProducts_ProductOptions_Stage oppos
			INNER JOIN #tblOrdersProducts_productOptions_NOP_ProductMove_Stage m on oppos.ordersProductsGUID = m.ordersProductsGUID
			INNER JOIN tblOrdersProducts_ProductOptions oppo on m.textValue = oppo.textvalue and oppo.optionid = 514 and oppo.ordersproductsid <> oppo.textvalue	-- get based on groupid
			WHERE oppos.optionCaption IN ('Envelope Front', 
									'Envelope Back', 
									'Envelope Color', 
									'Add Return Address', 
									'Return Address Placement',
									'CanvasHiResEnvelopeFront',
									'CanvasHiResEnvelopeBack',
									'CanvasPreviewEnvelopeBack',
									'CanvasPreviewEnvelopeFront',
									'CanvasHiResEnvelopeBack Print File',
									'CanvasHiResEnvelopeBack File Name',
									'CanvasHiResEnvelopeFront Print File',
									'CanvasHiResEnvelopeFront File Name',
									'CanvasHiResEnvelopeBack UNC File',
									'CanvasHiResEnvelopeFront UNC File'
									)  --BJS Iframe 12/21/20

			-- update ordersProductsGUID for non-envelope products
			UPDATE oppos set ordersProductsGUID = op.ordersProductsGUID
			FROM #tblOrdersProducts_ProductOptions_Stage oppos
			INNER JOIN tblOrders_Products op on oppos.ordersproductsid = op.ID
			WHERE oppos.optionCaption NOT IN ('Envelope Front', 
									'Envelope Back', 
									'Envelope Color', 
									'Add Return Address', 
									'Return Address Placement',
									'CanvasHiResEnvelopeFront',
									'CanvasHiResEnvelopeBack',
									'CanvasPreviewEnvelopeBack',
									'CanvasPreviewEnvelopeFront',
									'CanvasHiResEnvelopeBack Print File',
									'CanvasHiResEnvelopeBack File Name',
									'CanvasHiResEnvelopeFront Print File',
									'CanvasHiResEnvelopeFront File Name',
									'CanvasHiResEnvelopeBack UNC File',
									'CanvasHiResEnvelopeFront UNC File'
									)  --BJS Iframe 12/21/20


			UPDATE oppo SET deletex = 'yes' , modified_on = getdate()
			FROM tblOrdersProducts_ProductOptions oppo
			INNER JOIN #tblOrdersProducts_ProductOptions_Stage roi ON (oppo.ordersProductsID = roi.ordersProductsID and oppo.optionID = roi.optionID and oppo.optionCaption = roi.optionCaption )
			WHERE oppo.deletex <> 'yes' AND oppo.textValue <> roi.textValue

			INSERT tblOrdersProducts_ProductOptions (OrdersProductsId, optionId, optionCaption, optionPrice, optionGroupCaption, textValue, deletex, optionQty, created_on, modified_on, ordersProductsGUID)
			SELECT roi.ordersProductsID, roi.optionID, roi.optionCaption, roi.optionPrice, roi.optionGroupCaption, roi.textValue, roi.deletex AS deleteX, roi.optionQty, GETDATE(), GETDATE(), roi.ordersProductsGUID
			FROM #tblOrdersProducts_ProductOptions_Stage roi
			LEFT JOIN tblOrdersProducts_ProductOptions oppo ON (oppo.ordersProductsID = roi.ordersProductsID and oppo.optionID = roi.optionID and oppo.optionCaption = roi.optionCaption and oppo.textValue = roi.textValue)  and oppo.deletex <> 'yes'
			WHERE oppo.PKID IS NULL


			--select *
			--UPDATE a 
			--SET [ResyncAttributesXml] = 0
			--FROM nopCommerce_tblNOPOrderItem a
			--WHERE a.[nopOrderItemID] IN 
			--	(
			--		SELECT DISTINCT (OrdersProductsId - @orderItemOffset) 
			--		FROM #tblOrdersProducts_ProductOptions_Stage
			--	);

			--Remove old files from the tblOPPO_FileExists to be downloaded again
			DELETE f
			FROM tblOPPO_fileExists f
			INNER JOIN #tblOrders_Products_Stage tx ON tx.ID = f.OPID

			DELETE p
			FROM [dbo].[tblPrintFileMoverLog] p
			INNER JOIN #tblOrders_Products_Stage tx ON tx.ID = p.OPID

			--Clear files from the FileDownloadLog to be downloaded again
			UPDATE f
			SET StatusMessage = 'Pending Download', 
				DownloadEndDate = NULL, 
				DownloadStartDate = NULL
			FROM FileDownloadLog f
			INNER JOIN #tblOrders_Products_Stage tx ON tx.ID = f.OrdersProductsId
			INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = tx.ID
				AND f.DownloadUrl = oppo.textValue
				AND oppo.deletex <> 'YES'

			SELECT IDENTITY(INT,1,1) as ID,s.ID AS opid,op.workflowID
			INTO #tempwork
			FROM #tblOrders_Products_Stage s	
			INNER JOIN tblOrders_Products  op on s.id = op.id
			WHERE op.workFlowID IS NOT NULL

			-- start next steps
			DECLARE @StepCount INT = 0;
			DECLARE @CurrStep INT = 1;
			DECLARE @CurrID INT;
			DECLARE @OPID INT;
			DECLARE @SQL NVARCHAR(2000);

			SET @StepCount = (SELECT count(*) FROM #tempwork);


			WHILE @CurrStep <= @StepCount  
			BEGIN
			
				SET @OPID = (SELECT OPID FROM #tempwork WHERE id = @CurrStep);
			
				IF @OPID IS NOT NULL
				BEGIN
					SET @SQL = 'EXEC gbsController_Workflow_Start @OPID=' + cast(@OPID as varchar(10)) + ',@resubmit=1';
					EXEC (@SQL);
				END

				SET @SQL ='';
				SET @OPID = 0;
				SET @CurrStep = @CurrStep+ 1;
			END



	END TRY
	BEGIN CATCH
		
		--IF @@TRANCOUNT > 0 
		--	ROLLBACK TRANSACTION;  

		SELECT @Status = 'Fail', @ErrMsg = 'InsertResynchAttributes - '  + ERROR_MESSAGE();
		RAISERROR (@ErrMsg,11,1);
	END CATCH



END
