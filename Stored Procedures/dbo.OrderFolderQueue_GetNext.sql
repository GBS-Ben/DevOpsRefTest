CREATE PROC [dbo].[OrderFolderQueue_GetNext]
@Channel INT = 1,
@folderGUID UNIQUEIDENTIFIER OUTPUT,
@orderId INT OUTPUT,
@OrderNo NVARCHAR(50) OUTPUT, 
@ordersProductsId INT OUTPUT,
@optionJSON VARCHAR(8000) OUTPUT,
@status VARCHAR(255) OUTPUT,
@errMsg NVARCHAR(4000) OUTPUT
AS 
BEGIN 

	BEGIN TRY

			DECLARE @ID int;
			DECLARE @tblOrder TABLE (ID int,folderGUID uniqueidentifier, orderId int,orderNo nvarchar(50), ordersProductsId int, optionJSON varchar(8000));

			DELETE top (1) [dbo].[tblOrderFolderQueue]
			OUTPUT deleted.ID,deleted.folderGUID,deleted.OrderId,deleted.OrderNo,deleted.ordersProductsId,deleted.optionJSON into @tblOrder;

			--select * from @tblOrder;

			SELECT @folderGUID = folderGUID, @orderId = orderId,@ID = id,@orderNo =orderNo, @ordersProductsId = ordersProductsId, @optionJSON = optionJSON FROM @tblOrder;


			IF @ID IS NOT NULL
			BEGIN
				-- Log process start
				INSERT INTO [tblOrderFolderLog] (ID, folderGUID, orderId, orderNo, ordersProductsId, optionJSON, processChannel ,processBeginDateTime)
				SELECT ID, folderGUID, orderId, orderNo, ordersProductsId, optionJSON, @Channel,GETDATE()	FROM @tblOrder

			END
		

	END TRY
	BEGIN CATCH
		
		SELECT @status = 'Fail', @errMsg = ERROR_MESSAGE();

		-- Log error status
		UPDATE t SET processEndDateTime=GETDATE(),processStatus = @status, processError=@errMsg
		FROM [dbo].[tblOrderFolderLog] t
		WHERE id = @Id

	END CATCH


	SELECT @folderGUID as folderGUID, @orderId as orderId, @orderNo as orderNo, @ordersProductsID as ordersProductsId, @optionJSON as optionJSON, @status as processStatus, @errMsg as errMsg
END