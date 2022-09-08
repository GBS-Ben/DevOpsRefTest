



CREATE PROCEDURE [dbo].[SuccessCanvasFilesForDownloadImage]
 @Id as INT,
 @JobChannel as varchar(255) = '',
 @ServerURL as varchar(255) = ''
AS
SET NOCOUNT ON;
BEGIN

-------------------------------------------------------------------------------
-- Author      Bobby Shreck
-- Created     12/03/2018
-- Purpose     SSIS calls this when a failure is encountered.
-------------------------------------------------------------------------------
-- Modification History
--
-- 12/03/2018 	New
-- 12/30/2019	Iframe Conversion
-- 04/21/2021	CKB, added server and channel info
-------------------------------------------------------------------------------
--Get new files 	
 
--UPDATE tblNOPProductionFiles
--SET  CanvasPdfFetchDate = GETDATE(),
--	ModifiedDate = GETDATE(), 
--	RetryCount = 0, 
--	RetryDate = '1/1/1900'
--WHERE Id = @Id
DECLARE @tblWorkflowControl TABLE (workflowControl nvarchar(255))
DECLARE @workflowControl nvarchar(255)

SET @JobChannel = isnull(@JobChannel,'')
SET @ServerURL = isnull(@ServerURL,'')

IF @JobChannel <> '' SET @JobChannel = ' - Channel: ' + @JobChannel
IF @ServerURL <> '' SET @ServerURL = ' - Server: ' + @ServerURL

UPDATE FileDownloadLog
SET  DownloadEndDate = GETDATE(),
	 ModifiedDate = GETDATE(), 
	 RetryDate = '1/1/1900',
	 RetryCount = 0,
	 StatusMessage = left('Success - File Downloaded' + @JobChannel + @ServerURL,255)
OUTPUT inserted.WorkflowControl INTO @tblWorkflowControl
WHERE LogId = @Id

INSERT INTO FileDownloadTransLog (LogId,StatusMessage) VALUES (@Id,left('Success - File Downloaded' + @JobChannel + @ServerURL,255))


IF (SELECT workflowControl from @tblWorkflowControl) IS NOT NULL
	BEGIN
		
		SET @workflowControl = (SELECT workflowControl from @tblWorkflowControl)
		EXEC dbo.Workflow_CompleteItem @workflowControl=@workflowControl, @Status = 'Success', @OPID=null, @WPID=null, @RunNumber=null

	END

END