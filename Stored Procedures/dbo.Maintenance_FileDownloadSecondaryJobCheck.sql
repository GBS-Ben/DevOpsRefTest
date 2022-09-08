CREATE PROCEDURE Maintenance_FileDownloadSecondaryJobCheck		


AS
BEGIN



IF ( SELECT COUNT(*) FROM tblNOPProductionFiles WHERE CanvasPdfFetchDate IS NULL) > 50			
	BEGIN
		--When we are over 50 items to download images for, we enable the second job to move through the images much faster 
		EXECUTE msdb..sp_update_job @job_name = 'OPC - Web2Print File Creator Reverse', @enabled = 1 --Enable
	END
ELSE
	BEGIN 
		EXECUTE msdb..sp_update_job @job_name = 'OPC - Web2Print File Creator Reverse', @enabled = 0 --Disable
	END


END