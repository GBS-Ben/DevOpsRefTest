CREATE PROCEDURE [dbo].[GetSingleFileForDownloadReverse_shreck]
AS


DECLARE @Date datetime2 = GETDATE()

--UPDATE FileDownloadLog SET DownloadStartDate = @Date WHERE LogID = (
--SELECT 
--TOP 1 LogID 
--FROM FileDownloadLog
--WHERE StatusMessage = 'Pending Download'
--	AND DownloadUncFile IS NOT NULL
--	AND DownloadStartDate IS NULL
--ORDER BY CreatedDate DESC
--)


SELECT top 1
	LogID AS HttpFileLogId,

	DownloadUrl AS RemoteUrl,
	REPLACE(DownloadUncFile,'\','\') AS OutputFileFullPath ---ssis filepath bullshit
FROM FileDownloadLog  WITH (NOLOCK)
WHERE OrdersProductsId in (555780488)
--DownloadStartDate = @Date,555780488
--	AND DownloadUncFile IS NOT NULL