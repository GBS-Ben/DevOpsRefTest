CREATE PROCEDURE [dbo].[usp_ResynchAttributeXml_022621] AS
BEGIN

	DECLARE @orderItemOffset INT = 555444333;

	DECLARE @tableXML TABLE ([OrderNo] NVARCHAR(100), [OrdersProductsId] INT, [CustomValuesXml] XML);

	IF OBJECT_ID('tempdb..#XML') IS NOT NULL
	DROP TABLE #XML;

	CREATE TABLE #XML(
		[OrderNo] [nvarchar](100) NOT NULL,
		[OrdersProductsId] [int],
		[Key] [nvarchar](MAX) NULL,
		[Value] [nvarchar](MAX) NULL,
		[createdOn] DATETIME2 DEFAULT(GETDATE())
		);

	INSERT @tableXML([OrderNo], [OrdersProductsId], [CustomValuesXml])
	SELECT o.[GBSOrderID], b.[Id] + @orderItemOffset, REPLACE([AttributesXml], '<?xml version="1.0" encoding="utf-16"?>','')
	--select *
	FROM sql01.nopcommerce.[dbo].[tblNOPOrderItem] a
	INNER JOIN sql01.nopcommerce.[dbo].[OrderItem] b
		ON a.[nopOrderItemID] = b.[Id]
	INNER JOIN sql01.nopcommerce.[dbo].[tblNOPOrder] o
		ON b.[OrderId] = o.[nopID]
	WHERE a.[ResyncAttributesXml] = 1;
	----testing
	--and b.id + @orderItemOffset = 555897058

	INSERT #XML ([OrderNo], [OrdersProductsId], [Key], [Value])
	SELECT b.[OrderNo],
	b.[OrdersProductsId],
		t.x.value('@ID', 'varchar(max)') AS [key],
		 t.x.value('(ProductAttributeValue/Value)[1]', 'varchar(max)') AS [value]
	FROM @tableXML b
	CROSS APPLY b.[CustomValuesXml].nodes('/Attributes/ProductAttribute')  T(x);

	IF OBJECT_ID('tempdb..#ResynchOppoInsert') IS NOT NULL
		DROP TABLE #ResynchOppoInsert;

	CREATE TABLE #ResynchOppoInsert
	(
		[ordersProductsID] [int] NULL,
		[optionID] [int] NULL,
		[optionCaption] [nvarchar](255) NULL,
		[optionPrice] [money] NULL,
		[optionGroupCaption] [nvarchar](50) NULL,
		[textValue] [nvarchar](4000) NULL
	);

	INSERT INTO #ResynchOppoInsert(OrdersProductsId, optionId, optionCaption, optionPrice, optionGroupCaption, textValue)
	SELECT x.[OrdersProductsId],po.optionID,  pa.[Name] AS optionCaption,0 AS OptionPrice,  '' AS optionGroupCaption
		,CASE WHEN pav.[Id] IS NOT NULL THEN pav.[Name] ELSE x.[Value] END [Value]--, 0 AS deleteX, 0 AS optionQty, GETDATE(), GETDATE()
	FROM #XML x
	INNER JOIN tblOrders_Products ppo ON ppo.[Id] = x.OrdersProductsId
	INNER JOIN sql01.nopcommerce.[dbo].Product_ProductAttribute_Mapping pm --dbo.Product_ProductAttribute_Mapping pm 
		ON x.[Key] = pm.[Id]
	INNER JOIN sql01.nopcommerce.[dbo].ProductAttribute pa --dbo.ProductAttribute pa 
		ON pa.[Id] = pm.[ProductAttributeId] 
	INNER JOIN tblProductOptions po ON CASE  WHEN optionCaption = '10 Digit Company Code' THEN 'GBSCompanyId' ELSE optionCaption END  = pa.[Name] 
	LEFT JOIN sql01.nopcommerce.[dbo].ProductAttributeValue pav
		ON x.[Key] = pav.[ProductAttributeMappingId]
			AND try_convert(INT,x.[Value]) = pav.[Id]
	LEFT JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = x.OrdersProductsId AND oppo.optionID = po.optionID AND oppo.deletex <> 'yes'
	WHERE --oppo.PKID IS NULL
		--AND 
		[Value] NOT LIKE '{"data":'
		AND po.OptionId IS NOT NULL
		AND po.optionCaption NOT IN ('Design Fee','CustomImgUrl')
	UNION
	SELECT DISTINCT x.[OrdersProductsId] , 535,'Canvas', 0, 'Web To Print Type',  'Canvas'--, 0 AS deleteX, 0 AS optionQty, CreatedOn, CreatedOn
	FROM #XML x
	INNER JOIN tblOrders_Products ppo ON ppo.[Id] = x.OrdersProductsId
	LEFT JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = x.OrdersProductsId AND oppo.optionID = 535 AND oppo.deletex <> 'yes'
	WHERE oppo.PKID IS NULL
			AND (ppo.[ProductCode] LIKE 'CA__20%' 
			OR ppo.[ProductCode] LIKE 'FB%' AND ppo.[ProductCode] NOT LIKE 'FBPM00%'
			OR (ppo.[ProductCode] LIKE 'BB__00%' AND ppo.[ProductCode] NOT LIKE 'BBPM00%' )
			OR (ppo.[ProductCode] LIKE 'TV__00%' AND ppo.[ProductCode] NOT LIKE 'TVPM00%'
			))
	UNION	 
	SELECT DISTINCT x.[OrdersProductsId] , 399,'OPC', 0, 'OPC',  'OPC'--, 0 AS deleteX, 0 AS optionQty, CreatedOn, CreatedOn
	FROM #XML x
	INNER JOIN tblOrders_Products ppo ON ppo.[Id] = x.OrdersProductsId
	LEFT JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = x.OrdersProductsId AND oppo.optionID = 399 AND oppo.deletex <> 'yes'
	WHERE oppo.PKID IS NULL
		AND (ppo.[ProductCode] LIKE 'CA__20%' 
			OR ppo.[ProductCode] LIKE 'FB%' AND ppo.[ProductCode] NOT LIKE 'FBPM00%'
			OR (ppo.[ProductCode] LIKE 'BB__00%' AND ppo.[ProductCode] NOT LIKE 'BBPM00%' )
			OR (ppo.[ProductCode] LIKE 'TV__00%' AND ppo.[ProductCode] NOT LIKE 'TVPM00%'
			))

	UPDATE oppo SET deletex = 'yes', modified_on = GETDATE()
	FROM [dbo].tblOrdersProducts_ProductOptions oppo
	INNER JOIN #ResynchOppoInsert r
		ON oppo.ordersProductsID = r.ordersProductsID
			AND oppo.optionID = r.optionID
			AND oppo.optionCaption = r.optionCaption;

	INSERT INTO [dbo].tblOrdersProducts_ProductOptions(OrdersProductsId, optionId, optionCaption, optionPrice, optionGroupCaption, textValue, deletex, optionQty, created_on, modified_on)
	SELECT ordersProductsID,optionID,optionCaption,optionPrice,optionGroupCaption,textValue,0 AS deleteX, 0 AS optionQty, GETDATE(), GETDATE()
	FROM #ResynchOppoInsert;

	--move the envelope oppos to the envelope product
	UPDATE dbo.tblOrdersProducts_productOptions
	SET ordersProductsID = b.ordersProductsID
	FROM dbo.tblOrdersProducts_productOptions a
	INNER JOIN #ResynchOppoInsert roi ON roi.ordersProductsID = a.ordersProductsID 
		AND roi.optionCaption = a.optionCaption
	INNER JOIN dbo.tblOrdersProducts_productOptions_NOP_ProductMove b
		ON a.ordersproductsID = CONVERT(INT, b.textValue)
	WHERE a.ordersProductsID <> b.ordersProductsID
	AND b.optionCaption = 'Group ID'
	AND a.optionCaption IN ('Envelope Front', 
							'Envelope Back', 
							'Envelope Color', 
							'Add Return Address', 
							'Return Address Placement',
							'CanvasHiResEnvelopeFront',
							'CanvasHiResEnvelopeBack',
							'CanvasPreviewEnvelopeBack',
							'CanvasPreviewEnvelopeFront',
							'CanvasHiResEnvelopeBack Print File',
							'CanvasHiResEnvelopeBack File Name',
							'CanvasHiResEnvelopeFront Print File',
							'CanvasHiResEnvelopeFront File Name',
							'CanvasHiResEnvelopeBack UNC File',
							'CanvasHiResEnvelopeFront UNC File'
							)  --BJS Iframe 12/21/20



	--select *
	UPDATE a 
	SET [ResyncAttributesXml] = 0
	FROM sql01.nopcommerce.[dbo].[tblNOPOrderItem] a
	WHERE a.[nopOrderItemID] IN 
		(
			SELECT DISTINCT (OrdersProductsId - @orderItemOffset) 
			FROM #ResynchOppoInsert
		);

	--Clear files from the FileDownloadLog to be downloaded again
	UPDATE f
	SET StatusMessage = 'Pending Download', 
		DownloadEndDate = NULL, 
		DownloadStartDate = NULL
	FROM FileDownloadLog f
	INNER JOIN @tableXML tx ON tx.OrdersProductsId = f.OrdersProductsId

	--Remove duplicate file oppos that can happen from the above moving oppos to envelopes
	UPDATE oppo
	SET deletex = 'yes'
	FROM tblOrdersProducts_ProductOptions oppo
	INNER JOIN (
		SELECT ordersProductsId, optionCaption, MAX(PKID) AS Keeper  --this is the duplicate we want to keep
		FROM tblOrdersProducts_ProductOptions  
		WHERE   deletex <> 'yes'  AND ordersProductsID > 2007000000    --looks at envelopes only here
		GROUP BY ordersProductsId, optionCaption --same opid, same oppo
		HAVING COUNT(*) > 1
	) k ON k.Keeper <> oppo.PKID
		AND k.optionCaption = oppo.optionCaption
		AND k.ordersProductsID = oppo.ordersProductsID
	WHERE deletex <> 'yes'

END;