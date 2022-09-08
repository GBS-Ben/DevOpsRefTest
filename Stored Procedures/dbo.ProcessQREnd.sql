








CREATE PROC [dbo].[ProcessQREnd]
@QueueID bigint,
@Status VARCHAR(255),
@ErrMsg VARCHAR(255)
AS 
BEGIN 

		-- Log status
		UPDATE t SET Process_End_Date=GETDATE(),Process_Status = @Status, Process_Error = @ErrMsg
		FROM [dbo].[tbl_QR_Log] t
		WHERE QueueID = @QueueID

END