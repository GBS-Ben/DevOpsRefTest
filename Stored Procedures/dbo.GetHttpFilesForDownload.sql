CREATE PROCEDURE [dbo].[GetHttpFilesForDownload]
AS
SET NOCOUNT ON;
BEGIN

--Move new files to the file log for processing
INSERT httpfilelog (RemoteFilePath,FileStatus, RemoteFileSource )
SELECT o.BuyerCustomizedInfoCustomizedURL, 'New', 'AMAZON'    --HttpFileLogId, RemoteFilePath, [Order-Item-Id], RemoteFileSource, LocalFilePath, CreateDateTime
FROM tblAMZ_orderImporter o 
LEFT JOIN httpfilelog h ON o.BuyerCustomizedInfoCustomizedURL = RemoteFilePath
WHERE NULLIF(o.BuyerCustomizedInfoCustomizedURL,'') IS NOT NULL
 AND h.RemoteFilePath IS NULL

--Get new files 	
SELECT HttpFileLogId, RemoteFilePath, [Order-Item-Id], RemoteFileSource, LocalFilePath, CreateDateTime
FROM httpfilelog h
INNER JOIN tblAMZ_orderImporter o ON o.BuyerCustomizedInfoCustomizedURL = RemoteFilePath
WHERE FileStatus = 'New'


END