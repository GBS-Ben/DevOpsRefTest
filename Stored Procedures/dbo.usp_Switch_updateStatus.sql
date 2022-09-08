CREATE PROC [dbo].[usp_Switch_updateStatus]
@ordersProductsID INT = 0,
@new_Order_Status VARCHAR(50) = ' ',
@new_FT_Status VARCHAR(50) = ' '
AS
SET NOCOUNT ON;

	BEGIN TRY
		
		IF @new_Order_Status <> ' '
			BEGIN
				UPDATE o
				SET orderStatus = @new_Order_Status
				FROM dbo.tblOrders o 
				INNER JOIN tblOrders_Products op 
					ON op.orderID = o.orderID
				WHERE op.[id] = @ordersProductsID

			END

		IF @new_FT_Status <> ' '
			BEGIN
				UPDATE tblOrders_Products
				SET fastTrak_status = @new_FT_Status, 
				fastTrak_status_lastModified = GETDATE()
				WHERE [ID] = @ordersProductsID
			END

	END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH