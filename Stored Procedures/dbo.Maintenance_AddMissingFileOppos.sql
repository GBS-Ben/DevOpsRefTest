CREATE PROCEDURE [dbo].[Maintenance_AddMissingFileOppos] 
AS
BEGIN
/* This procedure fixes missing file name, unc file and print file oppos*/
--
---
--

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;
DECLARE @OpcBasePath VARCHAR(50); 
EXEC EnvironmentVariables_Get N'OPCURL',@VariableValue = @OpcBasePath OUTPUT;

/* Load up the fronts that are missing */
INSERT [tblOrdersProducts_ProductOptions] (
[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty]	,[ordersProductsGUID] ,[created_on]	,[modified_on])
SELECT [ordersProductsID],	770, 'CanvasHiResFront File Name',	[optionPrice],[optionGroupCaption],	
 ISNULL((SELECT TOP 1 REPLACE(textValue,@UncBasePath,'') FROM tblOrdersProducts_ProductOptions z WHERE z.ordersProductsId = op.Id
						AND z.optioncaption ='CanvasHiResFront UNC File'
						AND z.deletex <> 'yes'
						),
	[dbo].[fn_GetOppoFileName]([ordersProductsID],1,'.pdf')) --if the unc doesnt exist, we create a new name
	,0	,[optionQty]	,op.[ordersProductsGUID],GETDATE()	,GETDATE() 
FROM tblOrders o 
INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
WHERE orderStatus NOT IN ('cancelled','failed')
	 AND ProductCode NOT LIKE 'EV%'
	 AND optioncaption ='CanvasHiResFront'
	 AND oppo.deletex <> 'yes'
	 AND NOT EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsId = op.Id
						AND x.optioncaption ='CanvasHiResFront File Name'
						AND x.deletex <> 'yes'
						) 

						

INSERT [tblOrdersProducts_ProductOptions] (
[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty]	,[ordersProductsGUID],[created_on]	,[modified_on])
SELECT [ordersProductsID],	759, 'CanvasHiResFront UNC File',	[optionPrice],[optionGroupCaption],	
 (SELECT TOP 1 @UncBasePath + textValue FROM tblOrdersProducts_ProductOptions z WHERE z.ordersProductsId = op.Id
						AND z.optioncaption ='CanvasHiResFront File Name'
						AND z.deletex <> 'yes'
						) --if the unc doesnt exist, we create a new name
	,0	,[optionQty]	,op.[ordersProductsGUID],GETDATE()	,GETDATE() 
FROM tblOrders o 
INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
WHERE orderStatus NOT IN ('cancelled','failed')
	 AND ProductCode NOT LIKE 'EV%'
	 AND optioncaption ='CanvasHiResFront'
	 AND oppo.deletex <> 'yes'
	 AND NOT EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsId = op.Id
						AND x.optioncaption ='CanvasHiResFront UNC File'
						AND x.deletex <> 'yes'
						) 

				
INSERT [tblOrdersProducts_ProductOptions] (
[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty]	,[ordersProductsGUID],[created_on]	,[modified_on])
SELECT [ordersProductsID],	748, 'CanvasHiResFront Print File',	[optionPrice],[optionGroupCaption],	
(SELECT TOP 1 @OpcBasePath + textValue FROM tblOrdersProducts_ProductOptions z WHERE z.ordersProductsId = op.Id
						AND z.optioncaption ='CanvasHiResFront File Name'
						AND z.deletex <> 'yes'
						) 
						,0	,[optionQty]	,op.[ordersProductsGUID] ,GETDATE()	,GETDATE() 
FROM tblOrders o 
INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
WHERE orderStatus NOT IN ('cancelled','failed')
	 AND ProductCode NOT LIKE 'EV%' 
	 AND optioncaption ='CanvasHiResFront'
	 AND oppo.deletex <> 'yes'
	 AND NOT EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsId = op.Id
						AND x.optioncaption ='CanvasHiResFront Print File'
						AND x.deletex <> 'yes'
						) 


/* Load up the backs that are missing */
INSERT [tblOrdersProducts_ProductOptions] (
[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty],[ordersProductsGUID]	,[created_on]	,[modified_on])
SELECT [ordersProductsID],	753, 'CanvasHiResBack File Name',	[optionPrice],[optionGroupCaption],	
 ISNULL((SELECT TOP 1 REPLACE(textValue,@UncBasePath,'') FROM tblOrdersProducts_ProductOptions z WHERE z.ordersProductsId = op.Id
						AND z.optioncaption ='CanvasHiResBack UNC File'
						AND z.deletex <> 'yes'
						),
	[dbo].[fn_GetOppoFileName]([ordersProductsID],1,'.pdf')) --if the unc doesnt exist, we create a new name
	,0	,[optionQty]	,op.[ordersProductsGUID],GETDATE()	,GETDATE() 
FROM tblOrders o 
INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
WHERE orderStatus NOT IN ('cancelled','failed')
	 AND ProductCode NOT LIKE 'EV%'
	 AND optioncaption ='CanvasHiResBack'
	 AND oppo.deletex <> 'yes'
	 AND NOT EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsId = op.Id
						AND x.optioncaption ='CanvasHiResBack File Name'
						AND x.deletex <> 'yes'
						) 

						

INSERT [tblOrdersProducts_ProductOptions] (
[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty]	,[ordersProductsGUID],[created_on]	,[modified_on])
SELECT [ordersProductsID],	764, 'CanvasHiResBack UNC File',	[optionPrice],[optionGroupCaption],	
 (SELECT TOP 1 @UncBasePath + textValue FROM tblOrdersProducts_ProductOptions z WHERE z.ordersProductsId = op.Id
						AND z.optioncaption ='CanvasHiResBack File Name'
						AND z.deletex <> 'yes'
						) --if the unc doesnt exist, we create a new name
	,0	,[optionQty],op.[ordersProductsGUID]	,GETDATE()	,GETDATE() 
FROM tblOrders o 
INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
WHERE orderStatus NOT IN ('cancelled','failed')
	 AND ProductCode NOT LIKE 'EV%'
	 AND optioncaption ='CanvasHiResBack'
	 AND oppo.deletex <> 'yes'
	 AND NOT EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsId = op.Id
						AND x.optioncaption ='CanvasHiResBack UNC File'
						AND x.deletex <> 'yes'
						) 

				
INSERT [tblOrdersProducts_ProductOptions] (
[ordersProductsID],	[optionID]	,[OptionCaption],	[optionPrice]	,[optionGroupCaption],	[textValue]	,[deletex]	,[optionQty],[ordersProductsGUID]	,[created_on]	,[modified_on])
SELECT [ordersProductsID],	760, 'CanvasHiResBack Print File',	[optionPrice],[optionGroupCaption],	
(SELECT TOP 1 @OpcBasePath + textValue FROM tblOrdersProducts_ProductOptions z WHERE z.ordersProductsId = op.Id
						AND z.optioncaption ='CanvasHiResBack File Name'
						AND z.deletex <> 'yes'
						) 
						,0	,[optionQty]	,op.[ordersProductsGUID],GETDATE()	,GETDATE() 
FROM tblOrders o 
INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
WHERE orderStatus NOT IN ('cancelled','failed')
	 AND ProductCode NOT LIKE 'EV%' 
	 AND optioncaption ='CanvasHiResBack'
	 AND oppo.deletex <> 'yes'
	 AND NOT EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsId = op.Id
						AND x.optioncaption ='CanvasHiResBack Print File'
						AND x.deletex <> 'yes'
						) 

DELETE FileDownloadLog 
where logid IN (select logid 
from FileDownloadLog f WHERE DownloadFileName IS NULL
and exists (select * from tblordersproducts_productoptions x  WHERE f.OrdersProductsid = x.OrdersProductsId 
				and deletex <> 'yes' AND optionCaption LIKE 'canvashi%file name') 
				)

DELETE	FileDownloadLog 
where logid IN (select logid 
from  FileDownloadLog f WHERE DownloadUNCFile IS NULL 
and exists (select * from tblordersproducts_productoptions x  WHERE f.OrdersProductsid = x.OrdersProductsId 
				AND deletex <> 'yes'
				AND optionCaption LIKE 'canvashi%UNC File') 
				AND downloadfilename like  '2021%'
				)
					
EXEC [dbo].[Maintenance_LoadFilesToDownload]
 

END