


CREATE procEDURE [dbo].[FailCanvasFilesForDownloadImage]
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
-- 12/30/2020	Updated for iframe conversion
-- 04/21/2021	CKB, added server and channel info
-------------------------------------------------------------------------------
--Get new files 	
 
--UPDATE tblNOPProductionFiles
--SET  CanvasPdfFetchDate = '1/1/2999',
--	 ModifiedDate = GETDATE(), 
--	 RetryDate = DATEADD(mi, 10, GETDATE()),   --Add 10 minutes to the retry period
--	 RetryCount = ISNULL(RetryCount,0) + 1 --increase by 1. When we get to 5 we will stop
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
	 RetryDate = DATEADD(mi, 10, GETDATE()),   --Add 10 minutes to the retry period
	 RetryCount = ISNULL(RetryCount,0) + 1, --increase by 1. When we get to 5 we will stop
	 StatusMessage = left('File Download Failed' + @JobChannel + @ServerURL,255)
OUTPUT inserted.WorkflowControl INTO @tblWorkflowControl
WHERE LogId = @Id

INSERT INTO FileDownloadTransLog (LogId,StatusMessage) VALUES (@Id,left('File Download Failed' + @JobChannel + @ServerURL,255))

IF (SELECT workflowControl from @tblWorkflowControl) IS NOT NULL
	BEGIN
		
		SET @workflowControl = (SELECT workflowControl from @tblWorkflowControl)
		EXEC dbo.Workflow_CompleteItem @workflowControl=@workflowControl, @Status = 'Fail', @OPID=null, @WPID=null, @RunNumber=null

	END

END