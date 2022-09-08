






CREATE PROC [dbo].[TicTicQueue_GetNext]
@Channel INT = 1,
@itemGUID UNIQUEIDENTIFIER OUTPUT,
@orderId INT OUTPUT,
@OrderNo NVARCHAR(50) OUTPUT, 
@ordersProductsId INT OUTPUT,
@ticticType VARCHAR(10) OUTPUT,
@status VARCHAR(255) OUTPUT,
@errMsg NVARCHAR(4000) OUTPUT
AS 
BEGIN 

	BEGIN TRY

			DECLARE @ID int;
			DECLARE @tblTicTic TABLE (ID int,itemGUID uniqueidentifier, orderId int,orderNo nvarchar(50), ordersProductsId int, ticticType varchar(10));

			DELETE top (1) [dbo].[tblTicTicQueue]
			OUTPUT deleted.ID,deleted.itemGUID,deleted.OrderId,deleted.OrderNo,deleted.ordersProductsId,deleted.ticticType into @tblTicTic;

			--select * from @tblOrder;

			SELECT @itemGUID = itemGUID, @orderId = orderId,@ID = id,@orderNo =orderNo, @ordersProductsId = ordersProductsId, @ticticType = ticticType FROM @tblTicTic;


			IF @ID IS NOT NULL
			BEGIN
				-- Log process start
				INSERT INTO [tblTicTicLog] (ID, itemGUID, orderId, orderNo, ordersProductsId, ticticType, processChannel ,processBeginDateTime)
				SELECT ID, itemGUID, orderId, orderNo, ordersProductsId, ticticType, @Channel,GETDATE()	FROM @tblTicTic

			END
		

	END TRY
	BEGIN CATCH
		
		SELECT @status = 'Fail', @errMsg = ERROR_MESSAGE();

		-- Log error status
		UPDATE t SET processEndDateTime=GETDATE(),processStatus = @status, processError=@errMsg
		FROM [dbo].[tblTicTicLog] t
		WHERE id = @Id

	END CATCH


	SELECT @itemGUID as itemGUID, @orderId as orderId, @orderNo as orderNo, @ordersProductsID as ordersProductsId, @ticticType as ticticType, @status as processStatus, @errMsg as errMsg
END
GO
