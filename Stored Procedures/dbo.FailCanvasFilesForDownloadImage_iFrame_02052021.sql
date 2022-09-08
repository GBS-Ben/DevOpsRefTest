CREATE PROCEDURE [dbo].[FailCanvasFilesForDownloadImage_iFrame_02052021]
 @Id as INT
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

-------------------------------------------------------------------------------
--Get new files 	
 
UPDATE tblNOPProductionFiles
SET  CanvasPdfFetchDate = '1/1/2999',
	 ModifiedDate = GETDATE(), 
	 RetryDate = DATEADD(mi, 10, GETDATE()),   --Add 10 minutes to the retry period
	 RetryCount = ISNULL(RetryCount,0) + 1 --increase by 1. When we get to 5 we will stop
WHERE Id = @Id


END