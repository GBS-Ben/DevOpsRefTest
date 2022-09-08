CREATE PROC [dbo].[usp_tabStatus_update]
AS

BEGIN TRY

		DECLARE @tblOrders TABLE (OrderId int)

		--get the records to update
		INSERT @tblOrders (orderID)
		SELECT OrderId
		FROM  tblOrders
		WHERE tabStatus = 'Failed'
			AND orderStatus NOT IN ('Cancelled', 'Failed')


		UPDATE o
		SET tabStatus = 'Valid'
		FROM @tblOrders t
		INNER JOIN tblOrders o ON o.OrderId = t.OrderId

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH