CREATE VIEW [dbo].[OPIDSwitchFlow]

AS

WITH cteBPLux AS (
	SELECT ordersProductsID 
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_products op ON op.id = oppo.ordersProductsID 
		WHERE  op.deleteX <> 'yes' and oppo.deletex <> 'yes'
		AND ((optionCaption='Paper Stock' AND (textValue like '%32%pt%' or textValue like '%52%pt%')) OR oppo.optionID in (573,574,575))
),
cteBPRnd AS (
	SELECT ordersProductsID 
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_products op ON op.id = oppo.ordersProductsID 
		WHERE  op.deleteX <> 'yes' and oppo.deletex <> 'yes'
		AND ((optionCaption='Corners' AND textValue like 'Round%') or oppo.optionid in (571))
)

SELECT o.orderID,o.orderNo,op.id as OPID,p.productcode,op.productQuantity,
	CASE 
		 -- BC flow
		 WHEN SUBSTRING(p.productCode, 1, 2) = 'BP' 
		  AND c1.ordersProductsID IS NULL AND c2.ordersProductsID IS NULL AND op.productQuantity >= 5 THEN 'BC'
		 -- BC 100 flow
		 WHEN SUBSTRING(p.productCode, 1, 2) = 'BP' 
		  AND c1.ordersProductsID IS NULL AND c2.ordersProductsID IS NULL AND op.productQuantity < 5 THEN 'BC 100'
		 -- BCROUND flow
		 WHEN SUBSTRING(p.productCode, 1, 2) = 'BP' 
			AND c1.ordersProductsID IS NULL AND c2.ordersProductsID IS NOT NULL
			AND op.productQuantity >= 5 THEN 'BCROUND'
		 -- BCROUND 100 flow
		 WHEN SUBSTRING(p.productCode, 1, 2) = 'BP' 
			AND c1.ordersProductsID IS NULL AND c2.ordersProductsID IS NOT NULL
			AND op.productQuantity < 5 THEN 'BCROUND 100'
		  -- BC Luxe flow
		 WHEN  SUBSTRING(p.productCode, 1, 2) = 'BP' 
		  AND c1.ordersProductsID IS NOT NULL THEN 'BC-LUX'
		-- BU flow
		WHEN SUBSTRING(p.productCode, 3, 2) = 'BU'  AND SUBSTRING(p.productCode,1,2) <> 'NC' THEN 'BU'
		-- CACX flow
		WHEN (SUBSTRING(p.productCode, 3, 2) = 'CH' OR SUBSTRING(p.productCode, 3, 2) = 'CC')  AND SUBSTRING(p.productCode,1,2) <> 'NC' THEN 'CACX'
		-- CM
		WHEN (SUBSTRING(p.productCode, 1, 2) = 'CM' AND p.productCode <> 'CMJU00-01')  AND SUBSTRING(p.productCode,1,2) <> 'NC'  THEN 'CM'
		-- EX
		WHEN SUBSTRING(p.productCode, 3, 2) = 'EX'  AND LEFT(p.productCode,2) NOT IN ('NB','NC','AP') THEN 'EX'
		-- FC
		WHEN SUBSTRING(p.productCode, 3, 2) = 'FC' AND SUBSTRING(p.productCode,1,2) <> 'NC' THEN 'FC'
		-- JU
		WHEN SUBSTRING(p.productCode, 3, 2) = 'JU' THEN 'JU'
		-- CF
		WHEN SUBSTRING(p.productCode,1,2) = 'CF' THEN 'CF'
		-- NC
		WHEN SUBSTRING(p.productCode, 1, 2) = 'NC'
		 AND SUBSTRING(p.productCode, 3, 2) <> 'EV'
		 AND p.productCode NOT IN ('NCFAH6-00001', 'NCFAV6-00001')
		 AND NOT EXISTS  --1/7/21 BJS iframe conversion work here
			(SELECT TOP 1 ordersProductsID
			FROM tblOrdersProducts_productOptions opex
			WHERE opex.ordersProductsID = op.ID
			AND deleteX <> 'yes'
			AND (optionID = 518 --QuickCard Mailer optionID
					 OR optionID = 535 --Canvas optionID --1/7/21 BJS This isn't always added
					 OR optionID = 541 --1/7/21 BJS CC State ID should always be added to canvas products during iframe conversion
					 OR optionCaption LIKE 'CanvasHiRes%' --1/7/21 BJS Just to be extra sure canvas cards don't flow this way
					 OR optionID = 562 --Custom Market Center optionID
				))  THEN 'NC'
		-- NOP_NC
		WHEN SUBSTRING(p.productCode, 1, 2) = 'NC'
		AND SUBSTRING(p.productCode, 3, 2) <> 'EV'
			AND (
			--1. This retrieves NOP HOM orders
			o.NOP = 1
			--2. This retrieves in Market Center custom notecards from HOM Classic
			OR SUBSTRING(o.orderNo, 1, 3) IN ('HOM','MRK')
			AND op.ID IN
				(SELECT ordersProductsID
				FROM tblordersProducts_productOptions
				WHERE op.id = ordersProductsID AND deleteX <> 'yes'
				AND optionID = 562) --Custom Market Center optionID
			--3. This retrieves NCC orders
			OR SUBSTRING(o.orderNo, 1, 3) = 'NCC') THEN 'NOP_NC'
		-- QC
		WHEN SUBSTRING(p.productCode, 3, 2) = 'QC' THEN 'QC'
		-- QM
		WHEN  SUBSTRING(p.productCode, 3, 2) = 'QM' THEN 'QM'
		-- SN
		WHEN SUBSTRING(op.productCode, 1, 2) = 'SN'
		 AND op.processType <> 'stock' THEN 'SN'
		-- NBS
		WHEN op.productCode LIKE 'NB__S%' 
		 AND op.productCode NOT LIKE 'NB___U%' THEN 'NBS'
		-- NB
		WHEN op.fastTrak_productType = 'Badge'
		 AND op.productCode NOT LIKE 'NBCU%'
		 AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
		 AND (op.productCode NOT LIKE 'NB__S%' OR op.productCode LIKE 'NB___U%') THEN 'NB'
		WHEN op.productCode LIKE 'NB__S%' 
		 AND op.productCode NOT LIKE 'NB___U%' THEN 'NBS'
		WHEN LEFT(op.productCode,2) = 'PC'   AND SUBSTRING(p.productCode,1,2) <> 'NC' THEN 'PC'
		WHEN LEFT(op.productCode,2) = 'SN' THEN 'SN'
		WHEN op.productCode = 'AP00' 
			OR (LEFT(op.productCode,2) = 'AP' AND (select top 1 1 from tblOrdersProducts_ProductOptions where ordersproductsid = op.id)  IS NULL)  THEN 'AP - OTH'
		WHEN LEFT(op.productCode,2) = 'AP' AND logo.Decoration = 'Embroidery' THEN 'AP - EMB'
		WHEN LEFT(op.productCode,2) = 'AP' AND logo.Decoration = 'Heat Transfer' THEN 'AP - HP'
		ELSE ''
	END AS 'SwitchFlow'
	,SUBSTRING(op.productCode, 1 ,4) AS 'ProductCategory'
	--,CASE 
	--	WHEN LEFT(op.productCode,2) = 'AP' THEN 'APPAREL'
	--	WHEN LEFT(op.productCode,2) = 'SN' THEN 'SIGN'
	--	WHEN LEFT(op.productCode,4) IN ('CACC','CACH') THEN 'CALPAD'
	--	WHEN LEFT(op.productCode,4) = 'GNNC' THEN 'NOTEPAD'
	--	WHEN LEFT(op.productCode,2) = 'CM' THEN 'CARMAG'
	--	WHEN LEFT(op.productCode,2) = 'BP' 
	--	 AND c1.ordersProductsID IS NULL THEN 'BC-STD'
	--	WHEN LEFT(op.productCode,2) = 'BP' 
	--	 AND c1.ordersProductsID IS NOT NULL THEN 'BC-LUX'
	--	WHEN LEFT(op.productCode,2) = 'BM' THEN 'BC-MAG'
	--	WHEN LEFT(op.productCode,4) IN ('GNCC','GNCH') THEN 'VTNPAD'
	--	WHEN LEFT(op.productCode,2) = 'MK' THEN 'MASK'
	--	WHEN LEFT(op.productCode,4) = 'GNQC' THEN 'QC-SPC'
	--	WHEN LEFT(op.productCode,4) = 'BBQC' THEN 'QC-BAS'
	--	WHEN LEFT(op.productCode,4) = 'BKQC' THEN 'QC-BSK'
	--	WHEN LEFT(op.productCode,4) = 'HKQC' THEN 'QC-HKY'
	--	WHEN LEFT(op.productCode,4) = 'CAQC' THEN 'QC-CAL'
	--	WHEN LEFT(op.productCode,4) = 'FBQC' THEN 'QC-FTBL'
	--	WHEN LEFT(op.productCode,2) = 'LH' THEN 'LTRHD'
	--	WHEN op.productCode LIKE 'NB__S%' 
	--	 AND op.productCode NOT LIKE 'NB___U%' THEN 'NB-LUX'
	--	WHEN op.fastTrak_productType = 'Badge'
	--	 AND op.productCode NOT LIKE 'NBCU%'
	--	 AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100') 
	--	 AND (op.productCode NOT LIKE 'NB__S%' OR op.productCode LIKE 'NB___U%') THEN 'NB'
	--	ELSE LEFT(op.productCode,4) END AS 'ProductCategory'
	,op.processType
	,op.FastTrak_Status
	FROM tblorders_products op
	INNER join tblProducts p on op.productID = p.productID
	INNER JOIN tblOrders o on op.orderID = o.orderID
	LEFT JOIN tblProducts sp ON op.productID = sp.productID AND (SUBSTRING(sp.productCode, 1, 2) = 'NB' OR SUBSTRING(sp.productCode, 1, 2) = 'FM' 	OR sp.productCode = 'AM-16')
	LEFT JOIN cteBPLux c1 on c1.ordersProductsID = op.id
	LEFT JOIN cteBPRnd c2 on c2.ordersProductsID = op.id
	LEFT JOIN AP_LogoType logo on op.productCode LIKE logo.sku_pattern + '%'
GO

