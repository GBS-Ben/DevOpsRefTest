CREATE PROCEDURE [dbo].[ImposerBCCount_iFrame_02052021]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     09/10/18
-- Purpose    Calcs Imposer BC data for Console Display.
-------------------------------------------------------------------------------
-- Modification History

--09/10/18		Created, jf.

-------------------------------------------------------------------------------

TRUNCATE TABLE ImposerBusinessCardOPIDs 

--Simplex Insert---------------------------------------------------------------------------------------------------------------------------
INSERT INTO ImposerBusinessCardOPIDs (OPID, ProductQuantity, Plex)
SELECT DISTINCT op.ID, op.ProductQuantity, 'Simplex'
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s 
	ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op 
	ON a.orderID = op.orderID
INNER JOIN tblProducts p 
	ON op.productID = p.productID
INNER JOIN tblOrdersProducts_productOptions oppo
	ON op.ID = oppo.ordersProductsID
INNER JOIN tblOPPO_fileExists x
	ON oppo.PKID = x.PKID
WHERE

--1. Simplex Designation ----------------------------------
op.ID NOT IN
	--This subquery shows DUPLEX OPIDs
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
				--Regular Duplex BCs
				optionCaption IN ('Product Back', 'Back Intranet PDF')
			OR
				-- CYO Duplex BCs
				optionCaption IN ('File Name 1', 'File Name 2')
				AND textValue NOT LIKE '%/%'
				AND textValue LIKE '%-BACK-%'
			)
	AND textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', 
		 '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', 
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 
		 'BLANK')
	AND ordersProductsID NOT IN
		--Blank Backs
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 564)
	)

--2. Order Qualification ----------------------------------
AND DATEDIFF(MI, a.created_on, GETDATE()) > 10
AND a.orderDate > CONVERT(DATETIME, '02/01/2018')
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus = 'Good'

--3. Product Qualification ----------------------------------
AND SUBSTRING(p.productCode, 1, 2) = 'BP' 

--4. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType = 'fasTrak'
AND (
		--4.a
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		AND op.[ID] IN
				(SELECT ordersProductsID
				FROM tblOrdersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionCaption = 'OPC')		
		--4.b
		OR op.fastTrak_status = 'Good to Go'
		--4.
		OR op.fastTrak_resubmit = 1
		)

--5. Image Check ----------------------------------
AND x.fileExists = 1

--Duplex Insert---------------------------------------------------------------------------------------------------------------------------
INSERT INTO ImposerBusinessCardOPIDs (OPID, ProductQuantity, Plex)
SELECT DISTINCT op.ID, op.ProductQuantity, 'Duplex'
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s 
	ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op 
	ON a.orderID = op.orderID
INNER JOIN tblProducts p 
	ON op.productID = p.productID
INNER JOIN tblOrdersProducts_productOptions oppo
	ON op.ID = oppo.ordersProductsID
INNER JOIN tblOPPO_fileExists x
	ON oppo.PKID = x.PKID
WHERE

--1. Duplex Designation ----------------------------------
op.ID IN
	--This subquery shows DUPLEX OPIDs
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
				--Regular Duplex BCs
				optionCaption IN ('Product Back', 'Back Intranet PDF')
			OR
				-- CYO Duplex BCs
				optionCaption IN ('File Name 1', 'File Name 2')
				AND textValue NOT LIKE '%/%'
				AND textValue LIKE '%-BACK-%'
			)
	AND textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', 
		 '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', 
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 
		 'BLANK')
	AND ordersProductsID NOT IN
		--Blank Backs
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 564)
	)

--2. Order Qualification ----------------------------------
AND DATEDIFF(MI, a.created_on, GETDATE()) > 10
AND a.orderDate > CONVERT(DATETIME, '02/01/2018')
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus = 'Good'

--3. Product Qualification ----------------------------------
AND SUBSTRING(p.productCode, 1, 2) = 'BP' 

--4. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType = 'fasTrak'
AND (
		--4.a
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		AND op.[ID] IN
				(SELECT ordersProductsID
				FROM tblOrdersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionCaption = 'OPC')		
		--4.b
		OR op.fastTrak_status = 'Good to Go'
		--4.
		OR op.fastTrak_resubmit = 1
		)

--5. Image Check ----------------------------------
AND x.fileExists = 1

-- Calculate Metrics----------------------------------------------------------------------------------------------------------------------------------------
UPDATE ImposerBusinessCardOPIDs
SET ProductQuantity = ProductQuantity * 100

UPDATE ImposerBusinessCardOPIDs
SET ProductQuantity = ProductQuantity * 2
WHERE Plex = 'Duplex'

DECLARE @CardSides DECIMAL (18, 0),
				@Impressions DECIMAL (18, 0),
				@RunTime DECIMAL (18, 1)

SET @CardSides = (SELECT SUM(ProductQuantity)
									FROM ImposerBusinessCardOPIDs)

IF @CardSides IS NULL
BEGIN
	SET @CardSides = 0
END

SET @Impressions = @CardSides/36

IF @Impressions IS NULL
BEGIN
	SET @Impressions = 0
END

SET @RunTime = (@Impressions / 2000)

IF @RunTime IS NULL
BEGIN
	SET @RunTime = 0
END


UPDATE ImposerBusinessCardCount
SET CardSides = @CardSides,
	   Impressions = @Impressions,
	   RunTime = @RunTime