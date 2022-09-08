CREATE PROCEDURE [dbo].[usp_ResynchAttributeXml] AS
BEGIN
/*
-------------------------------------------------------------------------------
Author     
Created     
Purpose     NOP OPPO resync
-------------------------------------------------------------------------------
Modification History

02/26/21	CKB, added optionprice and quantity back in - commented 399/OPC to match migration, changed to upsert from mass delete/insert
04/01/21	CKB, fixed postcard pricing attributes
04/05/21	BS, fix try_convert binary truncation issue.
*/
	DECLARE @orderItemOffset INT;-- = 555444333;
	EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @orderItemOffset OUTPUT;

	IF OBJECT_ID('tempdb..#tableXML') IS NOT NULL
	DROP TABLE #tableXML;
	
	create table #tableXML  ([OrderNo] NVARCHAR(100), [OrdersProductsId] INT, [CustomValuesXml] XML);

	IF OBJECT_ID('tempdb..#XML') IS NOT NULL
	DROP TABLE #XML;

	CREATE TABLE #XML(
		[OrderNo] [nvarchar](100) NOT NULL,
		[OrdersProductsId] [int],
		[Key] [nvarchar](MAX) NULL,
		[Value] [nvarchar](MAX) NULL,
		[createdOn] DATETIME2 DEFAULT(GETDATE())
		);

	INSERT #tableXML([OrderNo], [OrdersProductsId], [CustomValuesXml])
	SELECT o.[GBSOrderID], b.[Id] + @orderItemOffset, REPLACE([AttributesXml], '<?xml version="1.0" encoding="utf-16"?>','')
	--select *
	FROM nopCommerce_tblNOPOrderItem a
	INNER JOIN nopCommerce_OrderItem b
		ON a.[nopOrderItemID] = b.[Id]
	INNER JOIN nopCommerce_tblNOPOrder o
		ON b.[OrderId] = o.[nopID]
	WHERE a.[ResyncAttributesXml] = 1;
	----testing
	--and b.id + @orderItemOffset = 555897058

	INSERT #XML ([OrderNo], [OrdersProductsId], [Key], [Value])
	SELECT b.[OrderNo],
	b.[OrdersProductsId],
		t.x.value('@ID', 'varchar(max)') AS [key],
		 t.x.value('(ProductAttributeValue/Value)[1]', 'varchar(max)') AS [value]
	FROM #tableXML b
	CROSS APPLY b.[CustomValuesXml].nodes('/Attributes/ProductAttribute')  T(x);

	IF OBJECT_ID('tempdb..#ResynchOppoInsert') IS NOT NULL
		DROP TABLE #ResynchOppoInsert;

	CREATE TABLE #ResynchOppoInsert
	(
		[ordersProductsID] [int] NULL,
		[optionID] [int] NULL,
		[optionCaption] [nvarchar](500) NULL,
		[optionPrice] [money] NULL,
		[optionGroupCaption] [nvarchar](255) NULL,
		[textValue] [nvarchar](max) NULL,
		[optionQty] int
	);

	INSERT INTO #ResynchOppoInsert(OrdersProductsId, optionId, optionCaption, optionPrice, optionGroupCaption, textValue,optionQty)
	SELECT x.[OrdersProductsId],po.optionID,  pa.[Name] AS optionCaption,ISNULL(pav.priceadjustment,0) AS optionPrice,  '' AS optionGroupCaption
		,CASE WHEN pav.[Id] IS NOT NULL THEN pav.[Name] ELSE x.[Value] END [Value]
		,CASE WHEN ISNULL(pav.priceadjustment,0) = 0 THEN 0 
			 WHEN pa.[name] IN (
								'Express Production', 
								'Custom Artwork',  --These are a per order charge
								'Change Fee',
								'Custom Art Fee',
								'Design Fee',
								'Setup Charges',
								'Electronic Proof',
								'Receive an Electronic Proof',
								'Photo and Logo x 3',
								'Photo and Logo x 5',
								'Photo and Logo x 4'
					) THEN 1 
				WHEN ppo.productcode like 'bp%' or ppo.productcode like 'GNNC%' or ppo.productCode like 'FANC%' then ppo.productQuantity * 100 
				ELSE ppo.productQuantity 
		 END AS optionQty
	FROM #XML x
	INNER JOIN tblOrders_Products ppo ON ppo.[Id] = x.OrdersProductsId
	INNER JOIN nopcommerce_Product_ProductAttribute_Mapping pm --dbo.Product_ProductAttribute_Mapping pm 
		ON x.[Key] = pm.[Id]
	INNER JOIN nopcommerce_ProductAttribute pa --dbo.ProductAttribute pa 
		ON pa.[Id] = pm.[ProductAttributeId] 
	INNER JOIN tblProductOptions po ON CASE  WHEN optionCaption = '10 Digit Company Code' THEN 'GBSCompanyId' ELSE optionCaption END  = pa.[Name] 
	LEFT JOIN nopcommerce_ProductAttributeValue pav
		ON x.[Key] = pav.[ProductAttributeMappingId]
			AND try_convert(int,try_convert(nvarchar(500),x.[Value])) = pav.[Id]
	LEFT JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = x.OrdersProductsId AND oppo.optionID = po.optionID AND oppo.deletex <> 'yes'
	WHERE --oppo.PKID IS NULL
		--AND 
		[Value] NOT LIKE '{"data":'
		AND po.OptionId IS NOT NULL
		AND po.optionCaption NOT IN ('Design Fee','CustomImgUrl','Magnetic Postcard')
	UNION
	SELECT DISTINCT x.[OrdersProductsId] , 535,'Canvas', 0, 'Web To Print Type',  'Canvas',-- 0 AS deleteX, 
	0 AS optionQty--, CreatedOn, CreatedOn
	FROM #XML x
	INNER JOIN tblOrders_Products ppo ON ppo.[Id] = x.OrdersProductsId
	LEFT JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = x.OrdersProductsId AND oppo.optionID = 535 AND oppo.deletex <> 'yes'
	WHERE oppo.PKID IS NULL
			AND (ppo.[ProductCode] LIKE 'CA__20%' 
			OR ppo.[ProductCode] LIKE 'FB%' AND ppo.[ProductCode] NOT LIKE 'FBPM00%'
			OR (ppo.[ProductCode] LIKE 'BB__00%' AND ppo.[ProductCode] NOT LIKE 'BBPM00%' )
			OR (ppo.[ProductCode] LIKE 'TV__00%' AND ppo.[ProductCode] NOT LIKE 'TVPM00%'
			))
	-- removing this to match usp_getmigrationOPPOs
	--UNION	 
	--SELECT DISTINCT x.[OrdersProductsId] , 399,'OPC', 0, 'OPC',  'OPC'--, 0 AS deleteX
	--, 0 AS optionQty--, CreatedOn, CreatedOn
	--FROM #XML x
	--INNER JOIN tblOrders_Products ppo ON ppo.[Id] = x.OrdersProductsId
	--LEFT JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = x.OrdersProductsId AND oppo.optionID = 399 AND oppo.deletex <> 'yes'
	--WHERE oppo.PKID IS NULL
	--	AND (ppo.[ProductCode] LIKE 'CA__20%' 
	--		OR ppo.[ProductCode] LIKE 'FB%' AND ppo.[ProductCode] NOT LIKE 'FBPM00%'
	--		OR (ppo.[ProductCode] LIKE 'BB__00%' AND ppo.[ProductCode] NOT LIKE 'BBPM00%' )
	--		OR (ppo.[ProductCode] LIKE 'TV__00%' AND ppo.[ProductCode] NOT LIKE 'TVPM00%'
	--		))

	--UPDATE oppo SET deletex = 'yes', modified_on = GETDATE()
	--FROM [dbo].tblOrdersProducts_ProductOptions oppo
	--INNER JOIN #ResynchOppoInsert r
	--	ON oppo.ordersProductsID = r.ordersProductsID
	--		AND oppo.optionID = r.optionID
	--		AND oppo.optionCaption = r.optionCaption;

	--INSERT INTO [dbo].tblOrdersProducts_ProductOptions(OrdersProductsId, optionId, optionCaption, optionPrice, optionGroupCaption, textValue, deletex, optionQty, created_on, modified_on)
	--SELECT ordersProductsID,optionID,optionCaption,optionPrice,optionGroupCaption,textValue,0 AS deleteX, optionQty, GETDATE(), GETDATE()
	--FROM #ResynchOppoInsert;

update #ResynchOppoInsert
set optionPrice = ISNULL(pav.priceadjustment,0.00)
FROM #XML x
INNER JOIN tblOrders_Products ppo ON ppo.id = x.OrdersProductsId
INNER JOIN nopcommerce_Product_ProductAttribute_Mapping pm --sql01.nopCommerce.dbo.Product_ProductAttribute_Mapping pm 
	ON x.[Key] = pm.id
INNER JOIN nopcommerce_ProductAttribute pa --sql01.nopCommerce.dbo.ProductAttribute pa 
	ON pa.id = pm.ProductAttributeId 
left join nopcommerce_ProductAttributeValue pav
	on x.[Key] = pav.ProductAttributeMappingId
		and try_convert(int,x.[Value]) = pav.Id
INNER JOIN tblProductOptions po ON CASE  WHEN optionCaption = '10 Digit Company Code' THEN 'GBSCompanyId' ELSE optionCaption END  = pa.[Name] 
INNER JOIN #ResynchOppoInsert oppo ON oppo.ordersProductsID = x.OrdersProductsId 
WHERE [Value] NOT LIKE '{"data":%'
	AND po.OptionId IS NOT NULL
	and po.optionCaption in ('Magnetic Postcard')
	and oppo.optionCaption = 'Postcard quantity'

	--move the envelope oppos to the envelope product
UPDATE roi 
	SET ordersProductsID = b.ordersProductsID
	FROM #ResynchOppoInsert roi
	INNER JOIN dbo.tblOrdersProducts_productOptions_NOP_ProductMove b
		ON roi.ordersproductsID = CONVERT(INT, b.textValue)
	WHERE b.ordersProductsID <> b.textValue
	AND b.optionCaption = 'Group ID'
	AND roi.optionCaption IN ('Envelope Front', 
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


	----Remove duplicate file oppos that can happen from the above moving oppos to envelopes
	--UPDATE oppo
	--SET deletex = 'yes'
	--FROM tblOrdersProducts_ProductOptions oppo
	--INNER JOIN (
	--	SELECT ordersProductsId, optionCaption, MAX(PKID) AS Keeper  --this is the duplicate we want to keep
	--	FROM tblOrdersProducts_ProductOptions  
	--	WHERE   deletex <> 'yes'  AND ordersProductsID > 2007000000    --looks at envelopes only here
	--	GROUP BY ordersProductsId, optionCaption --same opid, same oppo
	--	HAVING COUNT(*) > 1
	--) k ON k.Keeper <> oppo.PKID
	--	AND k.optionCaption = oppo.optionCaption
	--	AND k.ordersProductsID = oppo.ordersProductsID
	--WHERE deletex <> 'yes'


	UPDATE oppo SET deletex = 'yes' , modified_on = getdate()
	FROM tblOrdersProducts_ProductOptions oppo
	INNER JOIN #ResynchOppoInsert roi ON (oppo.ordersProductsID = roi.ordersProductsID and oppo.optionID = roi.optionID and oppo.optionCaption = roi.optionCaption )
	WHERE oppo.deletex <> 'yes' AND oppo.textValue <> roi.textValue

	INSERT tblOrdersProducts_ProductOptions (OrdersProductsId, optionId, optionCaption, optionPrice, optionGroupCaption, textValue, deletex, optionQty, created_on, modified_on)
	SELECT roi.ordersProductsID, roi.optionID, roi.optionCaption, roi.optionPrice, roi.optionGroupCaption, roi.textValue, 0 AS deleteX, roi.optionQty, GETDATE(), GETDATE()
	FROM #ResynchOppoInsert roi
	LEFT JOIN tblOrdersProducts_ProductOptions oppo ON (oppo.ordersProductsID = roi.ordersProductsID and oppo.optionID = roi.optionID and oppo.optionCaption = roi.optionCaption and oppo.textValue = roi.textValue)
	WHERE oppo.PKID IS NULL


	--select *
	UPDATE a 
	SET [ResyncAttributesXml] = 0
	FROM nopCommerce_tblNOPOrderItem a
	WHERE a.[nopOrderItemID] IN 
		(
			SELECT DISTINCT (OrdersProductsId - @orderItemOffset) 
			FROM #ResynchOppoInsert
		);

	--Remove old files from the tblOPPO_FileExists to be downloaded again
	DELETE f
	FROM tblOPPO_fileExists f
	INNER JOIN #tableXML tx ON tx.OrdersProductsId = f.OPID


	--Clear files from the FileDownloadLog to be downloaded again
	UPDATE f
	SET StatusMessage = 'Pending Download', 
		DownloadEndDate = NULL, 
		DownloadStartDate = NULL
	FROM FileDownloadLog f
	INNER JOIN #tableXML tx ON tx.OrdersProductsId = f.OrdersProductsId
	INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = tx.OrdersProductsId
		AND f.DownloadUrl = oppo.textValue
		AND deletex <> 'YES'
END;