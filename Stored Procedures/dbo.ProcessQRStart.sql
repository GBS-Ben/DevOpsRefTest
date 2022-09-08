






CREATE PROC [dbo].[ProcessQRStart]
@Channel INT = 1,
@QRkey BIGINT OUTPUT,
@QRurl VARCHAR(255) OUTPUT,
@QRJson varchar(8000) OUTPUT,
@QRDestination varchar(255) OUTPUT,
@Status VARCHAR(255) OUTPUT,
@ErrMsg NVARCHAR(4000) OUTPUT,
@RowCount INT OUTPUT,
@workflowControl VARCHAR(255) OUTPUT
AS 
BEGIN 

	BEGIN TRY
			SET @RowCount = 0;
			DECLARE @ID INT;

			DECLARE @tblQR TABLE (PKID bigint, QRurl varchar(255), QRjson varchar(max),QRdestination varchar(255), queueDate DATETIME, workflowcontrol varchar(255));
			DELETE top (1) [dbo].[tbl_QR_Queue]
			OUTPUT deleted.PKID ,deleted.[url] AS QRurl ,deleted.[json] AS QRjson, deleted.destination AS QRdestination, deleted.Date_Added as queueDate,deleted.workflowControl into @tblQR;

			--select * from @tblQR;

			-- Log process start
			INSERT INTO tbl_QR_Log (QueueID,[url],[json],destination,channel,date_added,Process_Start_Date,process_status, workflowControl)
				SELECT PKID, QRurl, QRjson, QRdestination, @Channel, queueDate,GETDATE(), 'Process QR Pending',workflowcontrol FROM @tblQR

			select @QRkey = PKID
			,@QRurl = QRurl
			,@QRJson = QRjson
			,@QRDestination = QRDestination
			,@RowCount = (select count(*) from @tblQR)
			,@workflowControl = workflowcontrol
			from @tblQR

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  

		SELECT @Status = 'Fail', @ErrMsg = ERROR_MESSAGE();

		-- Log status
		UPDATE t SET Process_Start_Date=GETDATE(),Process_End_Date = GETDATE(),Process_Status = @Status, Process_Error=@ErrMsg
		FROM [dbo].[tbl_QR_Log] t
		WHERE PKID = @ID

		IF @workflowControl IS NOT NULL
		BEGIN
			EXEC dbo.Workflow_CompleteItem @workflowControl=@workflowControl, @Status = 'Fail', @OPID=null, @WPID=null, @RunNumber=null
		END;

	END CATCH

	SELECT @QRKey,@QRurl,@QRjson,@QRDestination,@Status,@ErrMsg,@RowCount

END