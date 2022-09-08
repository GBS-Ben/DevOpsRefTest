


CREATE proc [dbo].[Queue_QR]
 @Url varchar(225),
 @destination varchar(225),
 @workflowControl varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO tbl_QR_Queue([url],[json],destination, Date_added,workflowControl)
		VALUES (@url, '{
    "itemsData": {
    "QR Code":{
         "barcodeData": {
                "BarcodeFormat": "QR_CODE",
                "BarcodeSubType": "Url",
                "Url": "' + REPLACE( @url ,'\','\\') + '"
            }
      }
   },
    "productDefinitions": [
        {
            "surfaces": [
                "hires/QR_Code_Template"
            ]
        }
    ],
    "userId":"default"
}',@destination, GETDATE(), @workflowControl)


	END TRY
	BEGIN CATCH
		DECLARE @err VARCHAR(255) = 'Queue_QR - ' + ERROR_MESSAGE()
		RAISERROR (@err,11,1);
		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
END