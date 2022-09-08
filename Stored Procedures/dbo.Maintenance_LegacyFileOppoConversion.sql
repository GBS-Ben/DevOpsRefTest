CREATE PROCEDURE [dbo].[Maintenance_LegacyFileOppoConversion]
AS
SET NOCOUNT ON;

BEGIN
	/*
		Candidate Opids - Orders that were not cancelled and were placed after iframe Conversion Release on FEB 5 2021 8 pm
	*/
	DECLARE @OrderOffset INT; 
	DECLARE @OpcBasePath VARCHAR(50);
	DECLARE @UncBasePath VARCHAR(100);
	EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;
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

	--Load Candidate Opids
	INSERT #CandidateOpids ([OPID], [productCode], Left2ProductCode)
	SELECT op.[id] AS [OPID], op.[productCode] AS [productCode], LEFT(op.[productCode], 2) AS Left2ProductCode
	FROM [tblOrders_Products] op
	INNER JOIN [tblOrders] o ON o.[orderID] = op.[orderID]
		AND orderStatus NOT IN ('Failed','Cancelled','Delivered')
	WHERE  o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND DATEADD(mi,-5,GETDATE()) --give the order time to arrive
		AND LEFT([productCode], 2) IN ('BP','SN','NP','EV','CM','NB', 'FB', 'BB','CA','NC','PN', 'FA','GN')--,'','','','','',''
		AND o.[orderNo] NOT LIKE 'NCC%'   --We will convert NCC one time.  NCC is not reorderable.
		AND NOT EXISTS (SELECT TOP 1 1   --Lets ignore anything that has the new oppos.
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.ordersProductsID = op.id 
			AND oppo.optionCaption LIKE 'CanvasHiRes%'
				AND oppo.deletex <> 'yes')
		AND (
			--make sure there are oppos we can use to build the new oppos
			EXISTS (SELECT TOP 1 1  FROM tblNOPProductionFiles pf WHERE pf.nopOrderItemID = op.Id)
			OR 
			EXISTS (SELECT TOP 1 1   --Lets ignore anything that has the new oppos.
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.ordersProductsID = op.id 
			AND CHARINDEX('canvas',oppo.textValue) > 1 
				AND oppo.deletex <> 'yes')
			) 

		

	IF (SELECT COUNT(*) FROM #CandidateOpids) = 0 --dont do extra work
	BEGIN
		RETURN;
	END

	--Build CanvasHiResFront
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResFront' AS [newOptionCaption], [CanvasURL] AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'front' 
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResFront'
		);

	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResFront File Name' AS [newOptionCaption], REPLACE(REPLACE([FileName],'/InProduction/General/', ''),'?file=','') AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE ISNULL([Surface],'front') = 'front'
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResFront File Name'
		);

	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResBack' AS [newOptionCaption], [CanvasURL] AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'back' 
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResBack'
		);

	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResBack File Name' AS [newOptionCaption], REPLACE(REPLACE([FileName],'/InProduction/General/', ''),'?file=','') AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'back' 
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResBack File Name'
		);

	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResInside' AS [newOptionCaption], [CanvasURL] AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'inside' 
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResInside'
		);


	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResInside File Name' AS [newOptionCaption], REPLACE(REPLACE([FileName],'/InProduction/General/', ''),'?file=','') AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'inside' 
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResInside File Name'
		);

	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResInside' AS [newOptionCaption], [CanvasURL] AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'greeting' 
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResInside'
		);

	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResInside File Name' AS [newOptionCaption], REPLACE(REPLACE([FileName],'/InProduction/General/', ''),'?file=','') AS [textValue] 
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders] O ON o.[orderNo] = f.[gbsOrderID]
	INNER JOIN #CandidateOpids c ON c.[OPID] = f.[nopOrderItemID]
	WHERE [Surface] = 'greeting' 
		AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND [nopOrderItemID] <> @OrderOffset
		AND o.[orderDate] BETWEEN '2021-02-05 20:00:00.000' AND GETDATE()
		AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = f.[nopOrderItemID] AND [newOptionCaption] = 'CanvasHiResInside File Name'
		);

	--Add missing File Names
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT oppo.[ordersProductsID], 
	'CanvasHiResFront File Name' AS [newOptionCaption],   
	REPLACE(REPLACE([textValue],'/InProduction/General/', ''),'?file=','') AS [textValue]
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	WHERE oppo.[OptionCaption] = 'intranet pdf'
	AND [textValue] NOT LIKE 'http%'
	AND [textValue] LIKE '%pdf'
	AND NOT EXISTS (
		--Make sure we arent adding the new attributes again
		SELECT TOP 1 1 
		FROM [tblOrdersProducts_ProductOptions] ne 
		WHERE ne.[ordersProductsID] = oppo.[ordersProductsID]
			AND ne.[OptionCaption] = 'CanvasHiResFront'
			)
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResFront File Name'
		);

	--Build CanvasHiResFront
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResFront' AS [newOptionCaption], [CanvasURL] AS [textValue] 
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	INNER JOIN [tblNOPProductionFiles] f ON f.[nopOrderItemID] = oppo.[ordersProductsID] AND [Surface] = 'front' 
	WHERE oppo.[OptionCaption] = 'intranet pdf'
	AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResFront'
		);

	--Build CanvasHiResFront if it wasnt in the production files table and isnt in the #NewOppo table
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  oppo.[ordersProductsID] AS [OPID], 'CanvasHiResFront' AS [newOptionCaption], 
			CASE WHEN [textValue] LIKE 'HTTP%' THEN [textValue]
			ELSE 'https:' + [textValue]
		
			END AS [textValue] 
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	--INNER JOIN tblNopProductionFiles f ON f.NopOrderItemId = oppo.OrdersProductsId and surface = 'front'
	WHERE oppo.[OptionCaption] = 'Web PDF'
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResFront'
		);	


	--Add missing File Names
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT oppo.[ordersProductsID], 
	'CanvasHiResBack File Name' AS [newOptionCaption],   
	REPLACE(REPLACE([textValue],'/InProduction/General/', ''),'?file=','') AS [textValue]
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	WHERE oppo.[OptionCaption] = 'back intranet pdf'
	AND [textValue] NOT LIKE 'http%'
	AND [textValue] LIKE '%pdf'
	AND NOT EXISTS (
		--Make sure we arent adding the new attributes again
		SELECT TOP 1 1 
		FROM [tblOrdersProducts_ProductOptions] ne 
		WHERE ne.[ordersProductsID] = oppo.[ordersProductsID]
			AND ne.[OptionCaption] = 'CanvasHiResBack'
			)
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResBack File Name'
		);


	--Build CanvasHiResFront
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  [nopOrderItemID] AS [OPID], 'CanvasHiResBack' AS [newOptionCaption], [CanvasURL] AS [textValue] 
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	INNER JOIN [tblNOPProductionFiles] f ON f.[nopOrderItemID] = oppo.[ordersProductsID] AND [Surface] = 'back'
	WHERE oppo.[OptionCaption] = 'back intranet pdf'
	AND [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResBack'
		);



	--Build CanvasHiResBack if it wasnt in the production files table and isnt in the #NewOppo table
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  oppo.[ordersProductsID] AS [OPID], 'CanvasHiResBack' AS [newOptionCaption], 
			CASE WHEN [textValue] LIKE 'HTTP%' THEN [textValue]
			ELSE 'https:' + [textValue]
			END AS [textValue] 
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	--INNER JOIN tblNopProductionFiles f ON f.NopOrderItemId = oppo.OrdersProductsId and surface = 'front'
	WHERE oppo.[OptionCaption] = 'Back Web PDF'
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResBack'
		);	

	----------------------------------------------------------------------------------

	--Postcards

	----------------------------------------------------------------------------------
	
	--Build CanvasHiResBack if it wasnt in the production files table and isnt in the #NewOppo table
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  oppo.[ordersProductsID] AS [OPID], 'CanvasHiResPostcard' AS [newOptionCaption], 
			CASE WHEN [textValue] LIKE 'HTTP%' THEN [textValue]
			ELSE 'https:' + [textValue]
			END AS [textValue]   --select *
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	--INNER JOIN tblNopProductionFiles f ON f.NopOrderItemId = oppo.OrdersProductsId and surface = 'front'
	WHERE oppo.[OptionCaption] = 'Postcard Intranet PDF'
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResPostcard'
		);	

	--Create file names
	INSERT #NewOppos( [OPID],[newOptionCaption], [textValue])
	SELECT DISTINCT  oppo.[ordersProductsID] AS [OPID], 'CanvasHiResPostcard File Name' AS [newOptionCaption], 
			 [dbo].[fn_GetOppoFileName](c.[OPID],1,'pdf') AS [textValue] 
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids c ON c.[OPID] = oppo.[ordersProductsID]
	INNER JOIN [tblProductOptions] [po] ON [po].[OptionCaption] = oppo.[OptionCaption] 
	WHERE oppo.[OptionCaption] = 'Postcard Intranet PDF'
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM #NewOppos WHERE [OPID] = oppo.[ordersProductsID] AND [newOptionCaption] = 'CanvasHiResPostcard File Name'
		)	
	AND NOT EXISTS (
		SELECT TOP 1 1 FROM [tblOrdersProducts_ProductOptions] x WHERE x.[ordersProductsID] = oppo.[ordersProductsID] AND x.[OptionCaption] = 'CanvasHiResPostcard File Name'
		);	

	/*
	run the code here to deletex='yes' any old file oppos

	*/
	

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

	--TO DO:
	--1.	Replace Canvasa with canvasb
	--2.	Can we test the url to make sure it is valid?



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
	WHERE oppo.[PKID] IS NULL;

	--Fix Previews so job tickets work
	INSERT [tblOrdersProducts_ProductOptions] ([ordersProductsID],	[optionId],	[OptionCaption],	[optionPrice],	[optionGroupCaption],
	[textValue],	[deletex],	[optionQty], [ordersProductsGUID],	[created_on],	[modified_on])
	SELECT p.[ordersProductsID]	,p.[optionId],	cx.[OptionCaption],	0.00,	'Custom Info',	p.[textValue],	0	,0, op.[ordersProductsGUID],	GETDATE(), GETDATE()
	FROM [tblOrdersProducts_ProductOptions] p
	INNER JOIN [tblOrders_Products] op on p.ordersProductsID = op.ID
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
		AND p.[deletex] <> 'yes'
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

---------------------------------------------------------------------------------------------------
--REMOVE WHAT SHOULDNT BE THERE
---------------------------------------------------------------------------------------------------

	UPDATE oppo
	SET [deletex] = 'yes'
	FROM [tblOrdersProducts_ProductOptions] oppo
	INNER JOIN #CandidateOpids o ON o.[OPID] = oppo.[ordersProductsID]
	WHERE [optionId] IN (
					678,--	19	Print File Back
					679,--	19	Print File Front
					680,--	19	Print File Middle 1
					708,--	19	Back Canvas Url
					709,--	19	Front Canvas Url
					710,--	19	Inside Canvas Url
					711,--	19	Back File Name
					712,--	19	Front File Name
					713,--	19	Inside File Name
					714,--	19	Back Print File
					715,--	19	Front Print File
					716,--	19	Inside Print File
					717,--	19	Back Web Canvas Url
					718,--	19	Front Web Canvas Url
					719,--	19	Inside Web Canvas Url
					720,--	19	Back Web File Name
					721,--	19	Front Web File Name
					722,--	19	Inside Web File Name
					723,--	19	Back Web Print File
					724,--	19	Front Web Print File
					725,--	19	Inside Web Print File
					728,--	19	Postcard File Name
					729,--	19	Postcard Canvas Url
					730,--	19	Postcard Print File
					731,--	19	Postcard Web Canvas Url
					732,--	19	Postcard Web File Name
					733,--	19	Postcard Web Print File
					--538,--	Intranet Preview
					539,--	Intranet PDF
					--543,--	Back Web Preview
					544,--	Back Web PDF
					--545,--	Back Intranet Preview
					546,--	Back Intranet PDF
					320,--	File Name 1
					336--	File Name 2
					--536,--	Web Preview
					--537--	Web PDF
			);


	--		Remove IntranetPDF where it isnt needed
UPDATE oppo	
SET deletex  = 'yes'
FROM tblOrdersProducts_ProductOptions oppo
WHERE optionCaption = 'Intranet PDF'
	AND deletex <> 'YES'
	AND EXISTS (SELECT top 1 1  
					FROM tblOrdersProducts_ProductOptions x
					WHERE optionCaption LIKE 'CanvasHiRes%'
						AND x.ordersProductsID = oppo.ordersProductsID 
						AND deletex <> 'YES' 
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

	--More Random Fixing: Fronts don't  always end up in OPPO.  Rebuild them here.
	INSERT [tblOrdersProducts_ProductOptions] (
	[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty], [ordersProductsGUID],[created_on]	,[modified_on]
	)
	SELECT f.[nopOrderItemID],  757,'CanvasHiResFront',0.00,	'Custom Info',[CanvasURL],0,0,op.ordersProductsGUID,GETDATE(), GETDATE()
	FROM [tblNOPProductionFiles] f 
	INNER JOIN [tblOrders_Products] op on f.nopOrderItemID = op.ID
	WHERE   [filename] NOT LIKE '%-%-%-%-%.pdf' --these are bs files and shoulnt be included
		AND f.CreateDate > dateadd(hh,-8,GETDATE())
		AND [Surface] IS NULL
		AND f.[ProductType] = ''
	AND NOT EXISTS (SELECT TOP 1 1 FROM [tblOrdersProducts_ProductOptions] WHERE  f.[nopOrderItemID] = [ordersProductsID]
													AND [OptionCaption] = 'CanvasHiResFront'
													AND [deletex] <> 'yes'
													);

END;