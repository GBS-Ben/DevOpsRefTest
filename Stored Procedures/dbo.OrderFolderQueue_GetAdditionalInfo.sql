CREATE PROC [dbo].[OrderFolderQueue_GetAdditionalInfo]
@folderGUID varchar(255) ,
@optionJSON varchar(8000),
@status VARCHAR(255) OUTPUT,
@errMsg NVARCHAR(4000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SELECT optioncaption + ':  ' + textvalue as 'AdditionalInfo'
		FROM OPENJSON(@optionJSON)
			WITH (
				[optioncaption] [varchar](255),
				[textvalue] [nvarchar](400));
	END TRY
	BEGIN CATCH
		
		SELECT @status = 'Fail', @errMsg = ERROR_MESSAGE();

		-- Log error status
		UPDATE t SET processEndDateTime=GETDATE(),processStatus = @status, processError=@errMsg
		FROM [dbo].[tblOrderFolderLog] t
		WHERE FolderGUID = @folderGUID

	END CATCH
END