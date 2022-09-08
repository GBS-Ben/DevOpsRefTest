CREATE PROCEDURE [dbo].[SuccessCanvasFilesForDownloadImage_iFrame_02052021]
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
SET  CanvasPdfFetchDate = GETDATE(),
	ModifiedDate = GETDATE(), 
	RetryCount = 0, 
	RetryDate = '1/1/1900'
WHERE Id = @Id

END