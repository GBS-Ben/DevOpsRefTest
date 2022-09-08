CREATE PROC [dbo].[usp_getProducts]
AS
DECLARE @flag varchar(50)

SET @flag=(select distinct flag from [dbo].[HOMLive_tblNewProductsReady] where flag is NOT NULL)

IF @flag='Yes'
BEGIN
    SET IDENTITY_INSERT tblProducts ON

			INSERT INTO tblProducts (productID, productOnline, canOrder, productCode, productName,  extendedDescription, costPrice,retailPrice, 
			salePrice, no_shipping, downloadableShipped,downloadableDaysValid, dateAvailable, onOrder, stock_Level, stock_AutoReduce, 
			stock_LowNoOrder,stock_LowLevel, [weight], dimensionW, dimensionH, supplierID,  inventoryCount, inventoryCountDate, parentProductID,
			numUnits,
			taxApplies, productType, fastTrak, fastTrak_productType, productCompany)
			SELECT productID, 1, canOrder, productCode, productName,
				extendedDescription, costPrice,
			retailPrice, salePrice, no_shipping, downloadableShipped,
			downloadableDaysValid, dateAvailable, 0,
				stock_Level, stock_AutoReduce, stock_LowNoOrder,
			stock_LowLevel, [weight], dimensionW, dimensionH, 
			supplierID,  inventoryCount, 
			CONVERT(DATETIME,'01/01/1974'), -- < -- you might need to either grab "inventoryCountDate", or if it is NULL, use convert(datetime,'01/01/1974')
			productID, -- <---- this is the parentProductID value, default here is productID.
			1, -- < -- you might need to change this "numUnits" to 10 if it is a SP.
			0,'fasTrak',1,'Name Badge',
			'MRK'
			FROM [dbo].[HOMLive_tblProducts]
			WHERE productID NOT IN  
									(SELECT DISTINCT productID 
									FROM tblProducts 
									WHERE productID IS NOT NULL) 
			AND productID>202179
			AND SUBSTRING(productCode, 1, 2) = 'NB'

    SET IDENTITY_INSERT tblProducts OFF

--// get product options; edited JF 042016
DELETE FROM tbl_getProducts_productOptions_Diff
INSERT INTO tbl_getProducts_productOptions_Diff (productID, optionID, optionGroupID, optionPrice, optionDiscountApplies)
SELECT  TOP 10000 productID, optionID, optionGroupID, optionPrice, optionDiscountApplies
FROM [dbo].[HOMLive_tblProduct_ProductOptions]
ORDER BY productID DESC

INSERT INTO tblProduct_ProductOptions (productID, optionID, optionGroupID, optionPrice, optionDiscountApplies)
SELECT productID, optionID, optionGroupID, optionPrice, optionDiscountApplies
FROM tbl_getProducts_productOptions_Diff
WHERE productID NOT IN 
					(SELECT DISTINCT productID 
					FROM tblProduct_ProductOptions 
					WHERE productID is NOT NULL
					AND productID IN
						(SELECT DISTINCT productID 
						FROM tblProducts 
						WHERE SUBSTRING(productCode, 1, 2) = 'NB')
					)
AND productID IN 
					(SELECT DISTINCT productID 
					FROM tblProducts 
					WHERE SUBSTRING(productCode, 1, 2) = 'NB')

INSERT INTO tblProducts_Categories (productID, categoryID, hiddenInSearch)
SELECT productID, '2', hiddenInSearch
FROM [dbo].[HOMLive_tblProducts_Categories]
WHERE productID NOT IN 
					(SELECT DISTINCT productID 
					FROM tblProducts_Categories 
					WHERE productID IS NOT NULL)
AND productID IN 
					(SELECT DISTINCT productID 
					FROM tblProducts 
					WHERE productCode like 'NB%') 

UPDATE [dbo].[HOMLive_tblNewProductsReady]
SET flag='No'

END