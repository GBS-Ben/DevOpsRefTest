




CREATE proc [dbo].[Queue_TicTic]
 @OPID varchar(225),
 @TicTicType varchar(10),
 @workflowControl varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO tblTicTicQueue(itemGUID,orderId,orderNo,ordersProductsId,ticticType,workflowControl)
		SELECT newid(),o.orderId,o.orderNo,op.id,@TicTicType,@workflowControl
		FROM tblOrders_Products op
		INNER JOIN tblOrders o on op.orderId = o.orderId
		WHERE op.id = @OPID

	END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
END