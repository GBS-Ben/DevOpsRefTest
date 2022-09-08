






CREATE proc [dbo].[ProcessPreviewFileDownload]
 @JSON nvarchar(MAX),
 @destination varchar(225),
 @workflowControl varchar(255),
 @Status VARCHAR(255) OUTPUT,
 @ErrMsg NVARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		

		INSERT INTO FileDownloadLog(DownloadFileName, DownloadUNCFile, DownloadURL,StatusMessage, CreatedDate, WorkflowControl)
		VALUES (right(@destination, charindex('\', reverse(@destination) + '\') - 1), @destination, JSON_VALUE(@JSON,'$[0][0][0]'),'Pending Download', GETDATE(),@workflowControl)


	END TRY
	BEGIN CATCH

		SELECT @Status = 'Fail', @ErrMsg = ERROR_MESSAGE();
		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH

	SELECT @Status, @ErrMsg
END