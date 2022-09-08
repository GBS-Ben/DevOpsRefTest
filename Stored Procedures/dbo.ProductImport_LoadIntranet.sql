CREATE PROCEDURE [dbo].[ProductImport_LoadIntranet]
AS
SET NOCOUNT ON;

BEGIN TRY

/*
Script Purpose: Part of the product importer process.  This procedure loads the products from the ProductImport_ETL table to the HOM LIVE db.
*/
    
	DECLARE @IntranetDate DATETIME2 = getdate()
	--set @ProcessDate = '2021-12-21 13:46:33.0366667';

	--Update processDate
	UPDATE gbsAcquire_ProductImport_ETL 
	SET IntranetDate = @IntranetDate
	WHERE IntranetDate IS NULL;
	
WITH cteProduct_ETL AS (

	SELECT p.[productOnline]
	,p.[canOrder]
	,p.[productCode]
	,p.[productIndex]
	,p.[productName]
	,p.[productHeader]
	,p.[shortName]
	,p.[shortDescription]
	,p.[extendedDescription]
	,p.[warranty]
	,p.[costPrice]
	,p.[retailPrice]
	,p.[salePrice]
	,p.[no_shipping]
	,p.[downloadable]
	,p.[downloadableFileName]
	,p.[downloadableShipped]
	,p.[downloadableDaysValid]
	,p.[dateAvailable]
	,p.[onOrder]
	,p.[stock_AutoReduce]
	,p.[stock_LowNoOrder]
	,p.[stock_LowLevel]
	,p.[weight]
	,p.[dimensionW]
	,p.[dimensionH]
	,p.[dimensionD]
	,p.[manufacturer]
	,p.[supplierID]
	,p.[imageThumbnail]
	,p.[image1]
	,p.[image1Large]
	,p.[image2]
	,p.[image2Large]
	,p.[image3]
	,p.[image3Large]
	,p.[placedInCartCount]
	,p.[numberSoldCount]
	,p.[viewCount]
	,p.[soldValue]
	,p.[status_mode]
	,p.[status_auto_Low]
	,p.[status_auto_inStock]
	,p.[status_man]
	,p.[taxApplies]
	,p.[displayOrderGroup]
	,p.[itemType] as productType
	,p.[itemStyle]
	,p.[inventoryCount]
	,ISNULL(p.[inventoryCountDate],'1974-01-01 00:00:00.000') as inventoryCountDate
	,p.[parentProductID]
	,p.[productMultiplier]
	,p.[productCompany]
	,1 as [numUnits]
	,p.[stock_Level]
	FROM homlive_tblProducts p
	INNER JOIN gbsAcquire_ProductImport_ETL e on p.productCode = e.productCode
	WHERE p.[productCode] IS NOT NULL
	  AND IntranetDate   = @IntranetDate
	  AND e.rownum in (select max(rownum) from gbsAcquire_ProductImport_ETL e2 group by productCode)
)

	MERGE INTO dbo.tblProducts as tgt
	USING cteProduct_ETL as src ON tgt.productCode = src.productCode
	WHEN NOT MATCHED BY TARGET THEN
		INSERT    
			([productOnline]
           ,[canOrder]
           ,[productCode]
           ,[productIndex]
           ,[productName]
           ,[productHeader]
           ,[shortName]
           ,[shortDescription]
           ,[extendedDescription]
           ,[warranty]
           ,[costPrice]
           ,[retailPrice]
           ,[salePrice]
           ,[no_shipping]
           ,[downloadable]
           ,[downloadableFileName]
           ,[downloadableShipped]
           ,[downloadableDaysValid]
           ,[dateAvailable]
           ,[onOrder]
           ,[stock_AutoReduce]
           ,[stock_LowNoOrder]
           ,[stock_LowLevel]
           ,[weight]
           ,[dimensionW]
           ,[dimensionH]
           ,[dimensionD]
           ,[manufacturer]
           ,[supplierID]
           ,[imageThumbnail]
           ,[image1]
           ,[image1Large]
           ,[image2]
           ,[image2Large]
           ,[image3]
           ,[image3Large]
           ,[placedInCartCount]
           ,[numberSoldCount]
           ,[viewCount]
           ,[soldValue]
           ,[status_mode]
           ,[status_auto_Low]
           ,[status_auto_inStock]
           ,[status_man]
           ,[taxApplies]
           ,[displayOrderGroup]
           ,[productType]
           ,[itemStyle]
           ,[inventoryCount]
           ,[inventoryCountDate]
           ,[parentProductID]
           ,[productMultiplier]
           ,[productCompany]
           ,[numUnits]
           ,[stock_Level])
		VALUES
		   ([productOnline]
           ,[canOrder]
           ,[productCode]
           ,[productIndex]
           ,[productName]
           ,[productHeader]
           ,[productName]
           ,[shortDescription]
           ,[extendedDescription]
           ,[warranty]
           ,[costPrice]
           ,[retailPrice]
           ,[salePrice]
           ,[no_shipping]
           ,[downloadable]
           ,[downloadableFileName]
           ,[downloadableShipped]
           ,[downloadableDaysValid]
           ,[dateAvailable]
           ,[onOrder]
           ,[stock_AutoReduce]
           ,[stock_LowNoOrder]
           ,[stock_LowLevel]
           ,[weight]
           ,[dimensionW]
           ,[dimensionH]
           ,[dimensionD]
           ,[manufacturer]
           ,[supplierID]
           ,[imageThumbnail]
           ,[image1]
           ,[image1Large]
           ,[image2]
           ,[image2Large]
           ,[image3]
           ,[image3Large]
           ,[placedInCartCount]
           ,[numberSoldCount]
           ,[viewCount]
           ,[soldValue]
           ,[status_mode]
           ,[status_auto_Low]
           ,[status_auto_inStock]
           ,[status_man]
           ,[taxApplies]
           ,[displayOrderGroup]
           ,[productType]
           ,[itemStyle]
           ,[inventoryCount]
           ,[inventoryCountDate]
           ,[parentProductID]
           ,[productMultiplier]
           ,[productCompany]
           ,[numUnits]
           ,[stock_Level])
	WHEN MATCHED THEN
	UPDATE SET
           [costPrice] = src.[costPrice]
          ,[retailPrice] = src.[retailPrice]
          ,[salePrice] = src.[salePrice]
          ,[weight] = src.[weight]
          ,[dimensionW] = src.[dimensionW]
          ,[dimensionH] = src.[dimensionH]
          ,[productType] = src.[productType];
--          ,[no_shipping] = src.[no_shipping]
 --          ,[downloadable] = src.[downloadable]
 --          ,[downloadableFileName] = src.[downloadableFileName]
 --          ,[downloadableShipped] = src.[downloadableShipped]
 --          ,[downloadableDaysValid] = src.[downloadableDaysValid]
 --          ,[dateAvailable] = src.[dateAvailable]
 --          ,[onOrder] = src.[onOrder]
 --          ,[stock_AutoReduce] = src.[stock_AutoReduce]
 --          ,[stock_LowNoOrder] = src.[stock_LowNoOrder]
 --          ,[stock_LowLevel] = src.[stock_LowLevel]
 --          ,[dimensionD] = src.[dimensionD]
 --          ,[manufacturer] = src.[manufacturer]
 --          ,[supplierID] = src.[supplierID]
 --          ,[imageThumbnail] = src.[imageThumbnail]
 --          ,[image1] = src.[image1]
 --          ,[image1Large] = src.[image1Large]
 --          ,[image2] = src.[image2]
 --          ,[image2Large] = src.[image2Large]
 --          ,[image3] = src.[image3]
 --          ,[image3Large] = src.[image3Large]
 --          ,[placedInCartCount] = src.[placedInCartCount]
 --          ,[numberSoldCount] = src.[numberSoldCount]
 --          ,[viewCount] = src.[viewCount]
 --          ,[soldValue] = src.[soldValue]
 --          ,[status_mode] = src.[status_mode]
 --          ,[status_auto_Low] = src.[status_auto_Low]
 --          ,[status_auto_inStock] = src.[status_auto_inStock]
 --          ,[status_man] = src.[status_man]
 --          ,[taxApplies] = src.[taxApplies]
 --          ,[displayOrderGroup] = src.[displayOrderGroup]
 --          ,[itemStyle] = src.[itemStyle]
 --          ,[inventoryCount] = src.[inventoryCount]
 --          ,[inventoryCountDate] = src.[inventoryCountDate]
 --          ,[productMultiplier] = src.[productMultiplier]
 --          ,[productCompany] = src.[productCompany]
 --          ,[numUnits] = src.[numUnits]
 --          ,[stock_Level] = src.[stock_Level];

	UPDATE p SET parentProductID = pp.productID
	FROM dbo.tblProducts p
	INNER JOIN gbsAcquire_ProductImport_ETL e on p.productCode = e.productCode
	INNER join homlive_tblProducts h ON p.productCode = h.productCode
	INNER JOIN dbo.tblProducts pp on h.parentProductCode = pp.productCode
	WHERE IntranetDate = @IntranetDate

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXECUTE [dbo].[usp_StoredProcedureErrorLog];

END CATCH