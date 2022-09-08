







CREATE PROCEDURE [dbo].[Maintenance_LoadFilesToDownload]
AS

SET NOCOUNT ON;

BEGIN
	
	DECLARE @UncBasePath VARCHAR(100); 
	EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

	CREATE TABLE #tmpFileDownload  (OrdersProductsId INT, DownloadUrl varchar(500),DownloadFileName varchar(500), DownloadUNCFile varchar(500), StatusMessage varchar(255))

	--ADD New File Oppos to the download Queue
	 INSERT #tmpFileDownload (OrdersProductsId, DownloadUrl,DownloadFileName, DownloadUNCFile, StatusMessage)
	 SELECT oppo.OrdersProductsId, 
		 replace(replace(textValue,'&#x2B;','+'),'&#x27;',char(39)) AS DownloadUrl,  --special characters fail
		(SELECT TOP 1 textValue
			FROM tblOrdersProducts_ProductOptions dfn
			WHERE dfn.ordersProductsID = oppo.ordersProductsID
				AND LEFT(dfn.optionCaption,LEN(oppo.optionCaption)) =  oppo.optionCaption
				AND dfn.optionCaption LIKE '% File Name'
				AND dfn.deletex <> 'yes'
		)AS DownloadFileName,
		(SELECT TOP 1 textValue
			FROM tblOrdersProducts_ProductOptions dfn
			WHERE dfn.ordersProductsID = oppo.ordersProductsID
				AND LEFT(dfn.optionCaption,LEN(oppo.optionCaption)) =  oppo.optionCaption
				AND dfn.optionCaption LIKE '% UNC File'
				AND dfn.textValue NOT LIKE 'http%'
				AND dfn.deletex <> 'yes'
		) AS DownloadUncFile,
		'Pending Download' AS StatusMessage --select *
	 FROM tblOrdersProducts_ProductOptions oppo
	 INNER JOIN tblProductOptions op ON op.optionCaption = oppo.optionCaption
	 LEFT JOIN FileDownloadLog fdl ON fdl.DownloadUrl =  replace(replace(oppo.textValue,'&#x2B;','+'),'&#x27;',char(39))  --special characters would have been fixed
		AND fdl.ordersProductsId = oppo.ordersProductsID 
	 WHERE fdl.logId IS NULL
		AND op.isFileOppo = 1
		AND oppo.textValue LIKE 'http%' --this prevents crap from entering the log and jamming the queue
		AND oppo.optionCaption NOT LIKE '%Preview%'  --These are png previews, not print files
		AND oppo.created_on >  '2021-02-06 14:05:50'
		--AND ordersProductsID = 556061005
		AND deletex <> 'yes'
		AND oppo.ordersProductsID IS NOT NULL
		AND oppo.optionCaption IN (
			'CanvasHiResBack',
			'CanvasHiResEnvelope',
			'CanvasHiResFront',
			'CanvasHiResInside',
			'CanvasHiResPostcard',
			'CanvasHiResEnvelopeFront',
			'CanvasHiResEnvelopeBack',
			'Mailer List URL'
			)


	--Load missing UNC File attributes
	INSERT #tmpFileDownload (OrdersProductsId, DownloadUNCFile,DownloadFileName,DownloadUrl , StatusMessage)
	SELECT oppo.OrdersProductsId, 
		 textValue AS DownloadUncFile,
		REPLACE(oppo.textValue,@UncBasePath, '')     AS DownloadFileName,
		(SELECT TOP 1 textValue
			FROM tblOrdersProducts_ProductOptions dfn
			WHERE dfn.ordersProductsID = oppo.ordersProductsID
				AND dfn.optionCaption = REPLACE(oppo.optionCaption,' UNC File', '')
				AND dfn.deletex <> 'yes'
		) AS DownloadURL,
		'Pending Download' AS StatusMessage
				FROM  tblOrdersProducts_ProductOptions oppo
				INNER JOIN tblProductOptions op ON op.optionCaption = oppo.optionCaption
				LEFT join filedownloadlog f ON f.DownloadUNCFile = oppo.textValue
				WHERE oppo.optionCaption IN ('CanvasHiResEnvelopeFront UNC File',
											 'CanvasHiResPostcard UNC File',
											 'Mailer List URL UNC File',
											 'CanvasHiResBack UNC File',
											 'CanvasHiResFront UNC File',
											 'CanvasHiResInside UNC File',
											 'CanvasHiResEnvelopeBack UNC File')
					AND TEXTvalue not like 'http:%'
					AND f.logId IS NULL
					AND oppo.created_on > '2/7/2021'
					AND deletex <> 'Yes'
					AND oppo.ordersProductsID IS NOT NULL
					AND op.isFileOppo = 1

	INSERT FileDownloadLog (OrdersProductsId, DownloadUNCFile,DownloadFileName,DownloadUrl , StatusMessage)
	SELECT distinct OrdersProductsId, DownloadUNCFile,DownloadFileName,DownloadUrl , StatusMessage
	FROM #tmpFileDownload
	WHERE NULLIF(DownloadFileName,'') IS NOT NULL 
	  AND NULLIF(DownloadUncFile,'') IS NOT NULL




END