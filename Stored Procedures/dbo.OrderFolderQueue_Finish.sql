CREATE PROC [dbo].[OrderFolderQueue_Finish]
@folderGUID uniqueidentifier,
@Status VARCHAR(255),
@ErrMsg VARCHAR(255)
AS 
BEGIN 

		-- Log status
		UPDATE t SET ProcessEndDateTime=GETDATE(),ProcessStatus = @Status, ProcessError = @ErrMsg
		FROM [dbo].[tblOrderFolderLog] t
		WHERE folderGUID = @folderGUID

END