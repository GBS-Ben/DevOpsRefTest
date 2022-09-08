CREATE PROCEDURE FileDownload_Reset
	@opid int = NULL
	AS 
	BEGIN

		UPDATE f
		SET StatusMessage = 'Pending Download',
			DownloadStartDate = NULL, 
			DownloadEndDate = NULL
		FROM FileDownloadLog f 
		WHERE ordersProductsId = @opid

	END