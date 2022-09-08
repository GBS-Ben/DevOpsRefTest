CREATE PROCEDURE [dbo].[Maintenance_FixNameBadgeFileOPPOs]
@orderno varchar(100) = null
AS
BEGIN

SET NOCOUNT ON;

		DECLARE @OpcBasePath VARCHAR(50);
		DECLARE @UncBasePath VARCHAR(100);  --using arc for matching in the file exists proc
		EXEC EnvironmentVariables_Get N'OPCURL',@VariableValue = @OpcBasePath OUTPUT;
		EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;


		IF OBJECT_ID('tempdb..#CandidateOpids') IS NOT NULL
			DROP TABLE #CandidateOpids;
		CREATE TABLE #CandidateOpids
			(
			rownum INT IDENTITY(1,1) PRIMARY KEY,
			[OPID] INT,
			[productCode] VARCHAR(100),
			Left2ProductCode CHAR(2)
			);
	
		IF OBJECT_ID('tempdb..#NewOPPOS') IS NOT NULL
			DROP TABLE #NewOPPOS;
		CREATE TABLE #NewOPPOS
			(
			rownum INT IDENTITY(1,1) PRIMARY KEY,
			[OPID] INT,
			[newOptionCaption] VARCHAR(2000),
			[textValue] VARCHAR(2000)
			);

		IF @orderno IS NULL 
		BEGIN
			--Load Candidate Opids
			INSERT #CandidateOpids ([OPID], [productCode], Left2ProductCode)
			SELECT DISTINCT op.[id] AS [OPID], op.[productCode] AS [productCode], LEFT(op.[productCode], 2) AS Left2ProductCode
			FROM [tblOrders_Products] op
			INNER JOIN [tblOrders] o ON o.[orderID] = op.[orderID]
				AND orderStatus NOT IN ('Failed','Cancelled')
			WHERE  o.[orderDate] BETWEEN '2021-01-05 20:00:00.000' 
				AND DATEADD(mi,-10,GETDATE()) --give the order time to arrive
				AND LEFT([productCode], 2) IN ('NB')--,'','','','','',''
				AND NOT EXISTS (SELECT TOP 1 1   --Lets ignore anything that has the new oppos.
					FROM tblOrdersProducts_ProductOptions oppo 
					WHERE oppo.ordersProductsID = op.id 
					AND oppo.optionCaption LIKE 'CanvasHiRes%'
						AND oppo.deletex <> 'yes')
				AND  
					--make sure there are oppos we can use to build the new oppos
					EXISTS (SELECT TOP 1 1 
					FROM tblOrdersProducts_ProductOptions oppo 
					WHERE oppo.ordersProductsID = op.id 
					AND (CHARINDEX('canvas',oppo.textValue) > 1
						OR CHARINDEX('rembr',oppo.textValue) > 1)
					 
					)
		END
		ELSE 
		BEGIN
			--Load Candidate Opids for a specific order number even if they have new oppos.
			INSERT #CandidateOpids ([OPID], [productCode], Left2ProductCode)
			SELECT DISTINCT op.[id] AS [OPID], op.[productCode] AS [productCode], LEFT(op.[productCode], 2) AS Left2ProductCode
			FROM [tblOrders_Products] op
			INNER JOIN [tblOrders] o ON o.[orderID] = op.[orderID]
				AND orderStatus NOT IN ('Failed','Cancelled')
			WHERE  o.[orderDate] BETWEEN '2021-03-05 20:00:00.000' AND DATEADD(mi,-10,GETDATE()) --give the order time to arrive
				AND LEFT([productCode], 2) IN ('NB')--,'','','','','',''
				AND o.[orderNo] NOT LIKE 'NCC%'   --We will convert NCC one time.  NCC is not reorderable.
					--make sure there are oppos we can use to build the new oppos
				AND	EXISTS (SELECT TOP 1 1 
					FROM tblOrdersProducts_ProductOptions oppo 
					WHERE oppo.ordersProductsID = op.id 
					AND (CHARINDEX('canvas',oppo.textValue) > 1
						OR CHARINDEX('rembr',oppo.textValue) > 1)
						)
				AND  orderno =@orderno
		END 

		IF (SELECT COUNT(*) FROM #CandidateOpids) = 0 --dont do extra work
		BEGIN
			RETURN;
		END

		--Build CanvasHiResFront
		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT DISTINCT  oppo.ordersProductsID AS [OPID], 'CanvasHiResFront' AS [newOptionCaption], 
			REPLACE(REPLACE(REPLACE(REPLACE(textValue,'canvasa','canvaslb'),'rembrandt','canvaslb'),'canvas5b','canvaslb'),'houseofmagnets','markful') AS [textValue] 
		FROM [tblOrdersProducts_ProductOptions] oppo
		INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
		INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
		WHERE oppo.[OptionCaption] IN ( 'Intranet PDF')
		--AND textValue NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND NOT EXISTS (
			SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResFront'
			);


		/*
		run the code here to deletex='yes' any old file oppos

		*/

		--Create File Names
		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT DISTINCT  oppo.Opid AS [OPID], 'CanvasHiResFront File Name' AS [newOptionCaption], 
				 [dbo].[fn_GetOppoFileName](c.[OPID],1,'pdf') AS [textValue] 
		FROM #NewOppos oppo
		INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.Opid
		INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[newOptionCaption] 
		WHERE  newOptionCaption = 'CanvasHiResFront'
	
		--Create File Names
		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT DISTINCT  oppo.Opid AS [OPID], 'CanvasHiResBack File Name' AS [newOptionCaption], 
				 [dbo].[fn_GetOppoFileName](c.[OPID],2,'pdf') AS [textValue] 
		FROM #NewOppos oppo
		INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.Opid
		INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[newOptionCaption] 
		WHERE  newOptionCaption = 'CanvasHiResBack'
	


		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT [OPID], 
			REPLACE([newOptionCaption], 'File Name','UNC File'), 
			[textValue] = @UncBasePath + [textValue]
		FROM #NewOPPOS
		WHERE [newOptionCaption] LIKE '%File Name%';

		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT [OPID], 
			REPLACE([newOptionCaption], 'File Name','Print File'), 
			[textValue] = @OpcBasePath + [textValue]
		FROM #NewOPPOS
		WHERE [newOptionCaption] LIKE '%File Name%';
	
		--Create mIssing UNC Files
		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT oppo.[ordersProductsID],
			REPLACE([OptionCaption], 'File Name','UNC File'), 
			[textValue] = @UncBasePath + [textValue]
		FROM [tblOrdersProducts_ProductOptions] oppo
		INNER JOIN #CandidateOpids o ON o.[OPID] = oppo.[ordersProductsID]
		WHERE [OptionCaption] LIKE 'CanvasHiRes%File Name'
			AND NOT EXISTS (
			SELECT TOP 1 1  
				FROM [tblOrdersProducts_ProductOptions] x 
				WHERE x.[OptionCaption] = REPLACE(oppo.[OptionCaption], 'File Name','UNC File')
					AND x.[ordersProductsID] = oppo.[ordersProductsID]
				)
				AND [textValue] LIKE '%.pdf%';

		--Create mIssing Print Files
		INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
		SELECT oppo.[ordersProductsID],
			REPLACE([OptionCaption], 'File Name','Print File'), 
			[textValue] = @OpcBasePath + [textValue]
		FROM [tblOrdersProducts_ProductOptions] oppo
		INNER JOIN #CandidateOpids o ON o.[OPID] = oppo.[ordersProductsID]
		WHERE [OptionCaption] LIKE 'CanvasHiRes%File Name'
			AND NOT EXISTS (
			SELECT TOP 1 1  
				FROM [tblOrdersProducts_ProductOptions] x 
				WHERE x.[OptionCaption] = REPLACE(oppo.[OptionCaption], 'File Name','Print File')
					AND x.[ordersProductsID] = oppo.[ordersProductsID]
				)
				AND [textValue] LIKE '%.pdf%';

---------------------------------------------------------------------------------------------------
	--REMOVE WHAT SHOULDNT BE THERE
---------------------------------------------------------------------------------------------------

		UPDATE oppo
		SET [deletex] = 'yes'   --select * 
		FROM [tblOrdersProducts_ProductOptions] oppo
		INNER JOIN tblProductOptions op ON op.optionID = oppo.optionID  
		INNER JOIN #CandidateOpids o ON o.[OPID] = oppo.[ordersProductsID]
		WHERE op.isFileOppo = 1
			AND oppo.optionCaption NOT IN (
			'CanvasPreviewBack',
			'CanvasPreviewEnvelope',
			'CanvasPreviewFront',
			'CanvasPreviewInside',
			'CanvasPreviewPostcard',
			'CanvasPreviewEnvelopeBack',
			'CanvasPreviewEnvelopeFront')

		INSERT [tblOrdersProducts_ProductOptions] ([ordersProductsID],	[optionId],	[OptionCaption],	[optionPrice],	[optionGroupCaption],
			[textValue],	[deletex],	[optionQty], [ordersProductsGUID],	[created_on],	[modified_on])
		SELECT [OPID] AS [ordersProductsID], [po].[optionId]	[optionId], [newOptionCaption] AS	[OptionCaption],	0 AS [optionPrice], g.[optionGroupCaption] AS	[optionGroupCaption], n.[textValue] AS 
			[textValue],	'0' AS [deletex],	0 AS [optionQty], op.[ordersProductsGUID],	GETDATE() AS [created_on],	GETDATE() AS  [modified_on]
		FROM #NewOppos n
		INNER JOIN [tblOrders_Products] op on n.OPID = op.ID
		INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = n.[newOptionCaption]
		LEFT JOIN [tblProductOptionGroups] g ON g.[optionGroupId] = [po].[optionGroupId]
		LEFT JOIN [tblOrdersProducts_ProductOptions] oppo ON oppo.[ordersProductsID] = n.[OPID]
			AND oppo.[OptionCaption] = [newOptionCaption]
			AND oppo.deletex <> 'yes'
		WHERE oppo.[PKID] IS NULL;


		--REMOVE File exists
		DELETE tbloppo_fileexists
		WHERE OPID IN (select Opid FROM  #CandidateOpids c) 

		--REMOVE File Downloads
		DELETE FileDownloadLog WHERE logId IN (
		SELECT f.logId
		FROM FileDownloadLog f
		INNER JOIN #CandidateOpids c ON c.OPID = f.OrdersProductsId
			) 

		--Fix Previews so job tickets work
		INSERT [tblOrdersProducts_ProductOptions] ([ordersProductsID],	[optionId],	[OptionCaption],	[optionPrice],	[optionGroupCaption],
		[textValue],	[deletex],	[optionQty], [ordersProductsGUID],	[created_on],	[modified_on])
		SELECT p.[ordersProductsID]	,p.[optionId],	cx.[OptionCaption],	0.00,	'Custom Info',	p.[textValue],	0	,0,	op.[ordersProductsGUID] ,GETDATE(), GETDATE()
		FROM [tblOrdersProducts_ProductOptions] p
		LEFT JOIN [tblOrders_Products] op on p.ordersProductsID = op.ID
		INNER JOIN (
			SELECT DISTINCT [ordersProductsID] 
			FROM [tblOrdersProducts_ProductOptions] oppo
			WHERE oppo.created_on > dateadd(hh,-8,GETDATE())
			AND EXISTS (SELECT TOP 1 1  FROM [tblOrdersProducts_ProductOptions] a WHERE [OptionCaption] LIKE 'canvasHiRes%' AND a.[ordersProductsID] = oppo.[ordersProductsID] AND [deletex] <> 'yes')
			AND NOT EXISTS (SELECT TOP 1 1  FROM [tblOrdersProducts_ProductOptions] b WHERE [OptionCaption] LIKE 'canvasPreview%' AND b.[ordersProductsID] = oppo.[ordersProductsID] AND [deletex] <> 'yes')
			AND EXISTS (SELECT TOP 1 1  FROM [tblOrdersProducts_ProductOptions] c WHERE [OptionCaption] LIKE 'Intranet%Preview%' AND c.[ordersProductsID] = oppo.[ordersProductsID] AND [deletex] <> 'yes')
			AND [deletex] <> 'yes'
		 ) x ON x.[ordersProductsID] = p.[ordersProductsID]
		CROSS APPLY(
			SELECT * 
			FROM [tblProductOptions] --where optionCaption LIKE '%Preview%'
			WHERE [OptionCaption] IN (
			'CanvasPreviewBack',
			'CanvasPreviewEnvelope',
			'CanvasPreviewFront',
			'CanvasPreviewInside',
			'CanvasPreviewPostcard',
			'CanvasPreviewEnvelopeBack',
			'CanvasPreviewEnvelopeFront')
		) cx 
		WHERE p.[OptionCaption] LIKE '%preview%'
			
			AND ([textValue] LIKE '//%' OR [textValue] LIKE 'https://%')
			AND cx.[OptionCaption]= CASE p.[OptionCaption] 
				WHEN 'Web Preview'  THEN 'CanvasPreviewFront'
				WHEN 'Intranet Preview'  THEN 'CanvasPreviewFront'
				WHEN 'Back Web Preview'  THEN 'CanvasPreviewBack'
				WHEN 'Back Intranet Preview'  THEN 'CanvasPreviewBack'
				WHEN 'Inside Intranet Preview'  THEN 'CanvasPreviewInside'
				WHEN 'Inside Web Preview'  THEN 'CanvasPreviewInside'
				WHEN 'Postcard Intranet Preview'  THEN 'CanvasPreviewPostcard' 
			END;

		UPDATE oppo
		SET [deletex] = 'yes'   --select * 
		FROM [tblOrdersProducts_ProductOptions] oppo
		INNER JOIN tblProductOptions op ON op.optionID = oppo.optionID  
		INNER JOIN #CandidateOpids o ON o.[OPID] = oppo.[ordersProductsID]
		WHERE  oppo.optionCaption  IN (
			'Back Intranet Preview',
			'Back Web Preview'
		)


		--Remove duplicate file oppos that can happen from the above awesomeness
		UPDATE oppo
		SET [deletex] = 'yes'
		FROM [tblOrdersProducts_ProductOptions] oppo
		INNER JOIN #CandidateOpids c ON c.OPID = oppo.ordersProductsID
		INNER JOIN (
			SELECT [ordersProductsID], [OptionCaption], MAX([PKID]) AS Keeper  --this is the duplicate we want to keep
			FROM [tblOrdersProducts_ProductOptions]  
			WHERE [OptionCaption] LIKE 'CanvasHiRes%'
				AND [deletex] <> 'yes' 
			GROUP BY [ordersProductsID], [OptionCaption] --same opid, same oppo
			HAVING COUNT(*) > 1
		) k ON k.Keeper <> oppo.[PKID]
			AND k.[OptionCaption] = oppo.[OptionCaption]
			AND k.[ordersProductsID] = oppo.[ordersProductsID]
		WHERE [deletex] <> 'yes';


	 INSERT tblordersproducts_productoptions(
	ordersProductsID	,optionID,	optionCaption,	optionPrice	,optionGroupCaption,	textValue,	deletex	,optionQty, ordersProductsGUID,	created_on,	modified_on)
	SELECT op.Id,759,	'CanvasHiResFront UNC File'	,0.00	,'Custom Info'	,@UncBasePath + [dbo].[fn_GetOppoFileName](op.Id, 1,'pdf'),   	0,	0, op.ordersProductsGUID,	getdate(), getdate()
		   FROM tblordersProducts_ProductOptions oppo
		   INNER JOIN tblOrders_Products op ON op.Id = oppo.ordersProductsID
		   INNER JOIN tblOrders o ON o.OrderID = op.orderID 
		   WHERE orderStatus NOT IN ('cancelled', 'delivered', 'failed')
	   
			AND optionCaption IN  (
			 'CanvasHiResFront'
			)
			AND oppo.deletex <> 'yes'
			AND NOT EXISTS (SELECT TOP 1 1 FROM tblOrdersProducts_ProductOptions o WHERE o.ordersproductsid = oppo.ordersproductsid
				and optioncaption = oppo.optioncaption + ' unc File'
					and deletex <> 'yes'
					)

	INSERT tblordersproducts_productoptions(
		ordersProductsID	,optionID,	optionCaption,	optionPrice	,optionGroupCaption,	textValue,	deletex	,optionQty, ordersProductsGUID,	created_on,	modified_on)
	SELECT  oppo.[ordersProductsID],
			770,
		'CanvasHiResFront File Name', 
		0,
		'Custom Info',
		REPLACE(textValue, @UncBasePath, ''),
		0,
		0,
		p.ordersProductsGUID,
		getdate(), 
		getdate()
	FROM tblOrdersProducts_ProductOptions oppo
	INNER JOIN tblOrders_Products p ON p.id = oppo.ordersProductsID 
	WHERE optionCaption = 'CanvasHiResFront UNC File' AND oppo.deletex <> 'yes'
	AND not exists ( --file name
		select top 1 1  from tblOrdersProducts_ProductOptions opp WHERE opp.ordersproductsId = oppo.ordersproductsId
			AND optionCaption = 'CanvasHiResFront File Name' AND deletex <> 'yes'
	)
	AND oppo.deletex <> 'yes'
	AND productCode NOT LIKE '%EV%'
				

END