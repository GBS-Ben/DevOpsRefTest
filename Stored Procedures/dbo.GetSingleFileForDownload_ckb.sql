


CREATE PROCEDURE [dbo].[GetSingleFileForDownload_ckb]
AS


DECLARE @Date datetime2 = GETDATE()

--UPDATE FileDownloadLog SET DownloadStartDate = @Date WHERE LogID = (
--SELECT 
--TOP 1 LogID 
--FROM FileDownloadLog 
--WHERE StatusMessage = 'Pending Download'
--	AND DownloadUncFile IS NOT NULL
--	AND DownloadStartDate IS NULL
--)


SELECT 
	LogID AS HttpFileLogId,
	DownloadUrl AS RemoteUrl,
	REPLACE(DownloadUncFile,'\','\') AS OutputFileFullPath ---ssis filepath bullshit
FROM FileDownloadLog WITH (NOLOCK)
WHERE --DownloadStartDate = @Date
	--AND DownloadUncFile IS NOT NULL
	 OrdersProductsId in ( 556400254) and logid = 2806724