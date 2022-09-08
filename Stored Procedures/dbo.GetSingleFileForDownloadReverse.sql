CREATE PROCEDURE [dbo].[GetSingleFileForDownloadReverse]
AS


DECLARE @Date datetime2 = GETDATE()

UPDATE FileDownloadLog SET DownloadStartDate = @Date WHERE LogID = (
SELECT 
TOP 1 LogID 
FROM FileDownloadLog WITH (updlock, readpast)
WHERE StatusMessage = 'Pending Download'
	AND DownloadUncFile IS NOT NULL
	AND DownloadStartDate IS NULL
ORDER BY CreatedDate DESC
)


SELECT
	LogID AS HttpFileLogId,

	replace(downloadurl,'&amp;','&') AS RemoteUrl,
	REPLACE(DownloadUncFile,'\','\') AS OutputFileFullPath ---ssis filepath bullshit
FROM FileDownloadLog  WITH (NOLOCK)
WHERE DownloadStartDate = @Date
	AND DownloadUncFile IS NOT NULL