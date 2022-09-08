/*
Script Purpose: CONVERTS OLD File OPPOS to NEW FILE Oppos
*/
    

CREATE PROCEDURE [dbo].[Maintenance_ClassicOpposBandaid]
--@RowVersionData dbo.RowVersionTable readonly
AS

BEGIN

RETURN; --for now until i fix this shit - shreck
--Static Parameters
DECLARE @OrderOffset INT;
DECLARE @OpcBasePath VARCHAR(50);
DECLARE @UncBasePath VARCHAR(100);  --using arc for matching in the file exists proc


EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;
EXEC EnvironmentVariables_Get N'OPCURL',@VariableValue = @OpcBasePath OUTPUT;
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

--Create temp table for OPPOs
DECLARE @tblOrdersProducts_ProductOptions TABLE 
([ordersProductsID] INT, [optionID] INT, [OptionCaption] VARCHAR(255), [optionPrice] MONEY, [optionGroupCaption] NVARCHAR(50), [textValue] NVARCHAR(4000), [optionQty] INT, [deletex] VARCHAR(50));


---when files are in the tblnopproductionfiles table we add the new oppos to OPPO
INSERT @tblOrdersProducts_ProductOptions ([ordersProductsID], [optionID], [OptionCaption], [optionPrice], [optionGroupCaption], [textValue], [optionQty], [deletex])
SELECT [nopOrderItemID],  a.[optionID]  ,a.[OptionCaption], 0 AS [optionPrice],  '', [CanvasURL], 0,'0'
FROM [tblNOPProductionFiles]  f
CROSS APPLY
(
	SELECT [optionID], [OptionCaption]
	FROM [tblProductOptions]
	WHERE [OptionCaption] IN ( 'CanvasHiResBack',
		'CanvasHiResEnvelope',
		'CanvasHiResFront',
		'CanvasHiResInside',
		'CanvasHiResPostcard',
		'CanvasHiResEnvelopeFront',
		'CanvasHiResEnvelopeBack')
	) a
LEFT JOIN [tblOrdersProducts_ProductOptions] oppo ON oppo.[optionID] = a.[optionID] AND oppo.[textValue] = f.[CanvasURL]
WHERE [createdate] > '2021-02-05 20:00:00.000'   --This will need to be the release date
	AND LEFT([gbsOrderID],3) <> 'NCC'
	AND oppo.[PKID] IS NULL --Dont add the same option
	AND f.[nopOrderItemID] <> @OrderOffset
	AND a.[OptionCaption] = CASE WHEN [Surface] = 'Front' THEN 'CanvasHiResFront'
		WHEN [Surface] = 'Back' THEN 'CanvasHiResBack'
		WHEN [Surface] = 'Greeting' THEN 'CanvasHiResInside'
		END;


--Additional oppos (files)
INSERT @tblOrdersProducts_ProductOptions ([ordersProductsID], [optionID], [OptionCaption], [optionPrice], [optionGroupCaption], [textValue], [deletex], [optionQty]	
)
SELECT c.[ordersProductsID]
,d.[optionID]
,c.[OptionCaption]
,c.[optionPrice]
,c.[optionGroupCaption]
,c.[textValue]
,c.[optionQty]
,c.[deletex]
FROM
(	SELECT 
	a.[ordersProductsID]
	,a.[optionID]
	,[OptionCaption] = CASE 
		WHEN a.[OptionCaption] LIKE '%back%pdf%' THEN 'Back ' + b.OptionCaptionAppend
		WHEN a.[OptionCaption] LIKE '%inside%pdf%' THEN 'Inside ' + b.OptionCaptionAppend
		WHEN a.[OptionCaption] LIKE '%Intranet%pdf%' THEN 'Front ' + b.OptionCaptionAppend
		WHEN a.[OptionCaption] LIKE '%Postcard%PDF%' THEN 'Postcard ' + b.OptionCaptionAppend
		ELSE a.[OptionCaption] + ' ' + b.OptionCaptionAppend
		END
	,a.[optionPrice]
	,a.[optionGroupCaption]
	,[textValue] = CASE
		--when b.OptionCaptionAppend = 'Canvas Url' then a.textValue
		WHEN b.OptionCaptionAppend = 'File Name' AND a.[OptionCaption] LIKE '%HiRes%' THEN [dbo].[fn_GetOppoFileName](a.[ordersProductsID],a.surfaceId,'pdf')
		WHEN b.OptionCaptionAppend = 'Print File' AND a.[OptionCaption] LIKE '%HiRes%' THEN @OpcBasePath + [dbo].[fn_GetOppoFileName](a.[ordersProductsID],a.surfaceId,'pdf')
		WHEN b.OptionCaptionAppend = 'UNC File' AND a.[OptionCaption] LIKE '%HiRes%' THEN @UNCBasePath + [dbo].[fn_GetOppoFileName](a.[ordersProductsID],a.surfaceId,'pdf')
		--when b.OptionCaptionAppend = 'File Name' and a.optionCaption like '%pdf%' then dbo.fn_GetOppoFileName(a.ordersProductsID,a.surfaceId,'pdf')
		--when b.OptionCaptionAppend = 'UNC File' and a.optionCaption like '%pdf%' then @UNCBasePath + dbo.fn_GetOppoFileName(a.ordersProductsID,a.surfaceId,'pdf')
		ELSE '' END
	,a.[optionQty]
	,[deletex] = '0'
	FROM 
	(
		SELECT 
		[ordersProductsID]
		,[optionID]
		,[OptionCaption]
		,[optionPrice]
		,[optionGroupCaption]
		,[textValue]
		,surfaceId = CASE
			WHEN [OptionCaption] LIKE '%Back%' THEN 2
			WHEN [OptionCaption] LIKE '%Inside%' THEN 3
			ELSE 1 END
		,[optionQty]
		FROM @tblOrdersProducts_ProductOptions
		WHERE [OptionCaption] IN
		(
		'CanvasHiResBack',
		'CanvasHiResEnvelope',
		'CanvasHiResFront',
		'CanvasHiResInside',
		'CanvasHiResPostcard',
		'CanvasHiResEnvelopeFront',
		'CanvasHiResEnvelopeBack'
		)   
	) a
	CROSS JOIN 
	(
	 --select OptionCaptionAppend = 'Canvas Url' union  The url should just be in the xml now.  No need to create it.
	 SELECT OptionCaptionAppend = 'File Name' UNION
	 SELECT OptionCaptionAppend = 'Print File' UNION
	 SELECT OptionCaptionAppend = 'UNC File'
	 ) b
) c
LEFT JOIN  [dbo].[tblProductOptions] d
	ON d.[isFileOppo] = 1
		AND c.[OptionCaption] = d.[OptionCaption];

INSERT [tblOrdersProducts_ProductOptions] ([ordersProductsID], [optionID], [OptionCaption], [optionPrice], [optionGroupCaption], [textValue], [optionQty], [deletex],[ordersProductsGUID])
SELECT DISTINCT [ordersProductsID], oppo.[optionID], [OptionCaption], [optionPrice], [optionGroupCaption], [textValue], [optionQty], oppo.[deletex] ,op.[ordersProductsGUID]
FROM @tblOrdersProducts_ProductOptions oppo
INNER JOIN tblOrders_Products op ON op.Id = oppo.OrdersProductsId



END;