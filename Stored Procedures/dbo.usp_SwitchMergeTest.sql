CREATE PROCEDURE [dbo].[usp_SwitchMergeTest]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/27/16
-- Purpose     Preps select sports-related product data for switch automation.
--					Runs in tandem to usp_SuperMerge.
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/7/16		Major changes noted throughout for first live test of usage.
--	7/8/16		Removed pathing from photo, logo, overflow fields. (commented out)
-- 7/12/16		Changes to productBack path and DDF Name value.
-- 7/27/16		Added tblSwitchMerge_templateReference work at end of sproc.
-- 10/18/16		Changed initial query to check against tblSwitchMerge_templateReference.
-------------------------------------------------------------------------------
-- 1. Empty table for fresh data
TRUNCATE TABLE tblSwitchMergeTest

--2. Populate table with initial values
INSERT INTO tblSwitchMergeTest (PKID, orderNo, ordersProductsID, productID, productCode, productName, productQuantity, 
							template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, jobProductID)
SELECT DISTINCT SUBSTRING(a.orderNo, 4, 6), a.orderNo, b.[ID], b.productID, b.productCode, b.productName, b.productQuantity,
'HOM_Shortrun:SwitchMergeIn:Templates:X.gp',
'SwitchMerge',
'HOM_Shortrun:~HOM Test Jobs:' + SUBSTRING(a.orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), b.ID) + ':' + SUBSTRING(a.orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), b.ID) + '.HOM.qxp', 
'ART DEPARTMENT-NEW:For SQL:FastTrak:Merge:Logs:' + SUBSTRING(a.orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), b.ID) + '.log', 
'Graphic Business Solutions',
'QXP',
SUBSTRING(a.orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), b.ID)
FROM tblOrders a
JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.processType = 'Custom'			
--// old method as of 10/18/16; jf.
--AND (
--			(SUBSTRING(b.productCode, 3, 2) = 'QC' 
--			OR SUBSTRING(b.productCode, 3, 2) = 'QM' 
--			OR SUBSTRING(b.productCode, 3, 2) = 'FC'
--			)
--								 AND 

--			(SUBSTRING(b.productCode, 1, 2) = 'FB' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'BB' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'BK' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'HY' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'PG' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'HB' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'BH' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'NS' 
--			OR SUBSTRING(b.productCode, 1, 2) = 'VB')

--								  OR

--			b.productCode LIKE 'CA%'
--		)

AND 
SUBSTRING(b.productCode, 1, 3) IN
(SELECT SUBSTRING(productCode, 1, 3)
FROM tblSwitchMerge_templateReference
WHERE productCode IS NOT NULL)

AND a.orderType = 'Custom'
AND b.ID NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'OPC')
AND SUBSTRING(a.orderNo, 4, 6) NOT IN 
		(SELECT PKID
		FROM tblSwitchMergeTest
		WHERE PKID IS NOT NULL)
AND DATEDIFF(dd, a.orderDate, GETDATE()) < 160
AND DATEDIFF(MI, a.created_on, GETDATE()) > 10
AND a.orderStatus <> 'delivered'
AND a.orderStatus <> 'cancelled'
AND a.orderStatus <> 'failed'
AND a.orderStatus NOT LIKE '%transit%'
AND a.orderStatus NOT LIKE '%DOCK%'
AND b.switchMerge_create = 0
ORDER BY SUBSTRING(a.orderNo, 4, 6)

--2.5 Remove records from tblSwitchMergeTest that do not have a corresponding template in tblSwitchMerge_TemplateReference
DELETE FROM tblSwitchMergeTest
WHERE 
SUBSTRING(productCode, 1, 4) + SUBSTRING(productCode, 7, 4) NOT IN
	(SELECT SUBSTRING(productCode, 1, 4) + SUBSTRING(productCode, 7, 4) 
	FROM tblSwitchMerge_TemplateReference
	WHERE LEN(productCode) > 3)
AND SUBSTRING(productCode, 1, 2) NOT IN
	(SELECT SUBSTRING(productCode, 1, 2)
	FROM tblSwitchMerge_TemplateReference
	WHERE LEN(productCode) = 3) --171

-- 3. Do field updates
--INPUT 1 (yourname)
UPDATE tblSwitchMergeTest
SET yourName = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 1:%'
AND a.yourname IS NULL
AND p.deleteX <> 'yes'

--INPUT 2 (yourcompany)
UPDATE tblSwitchMergeTest
SET yourcompany = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 2:%'
	  OR 
	  CONVERT(VARCHAR(255), p.optionCaption) LIKE '%Background Color%')
AND p.deleteX <> 'yes'

--INPUT 3 (input1)
UPDATE tblSwitchMergeTest
SET input1 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 3:%'
 OR CONVERT(VARCHAR(255), p.optionCaption) LIKE '%Text Color%')
AND p.deleteX <> 'yes'

--INPUT 4 /a
UPDATE tblSwitchMergeTest
SET input2 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 4:%'
 OR CONVERT(VARCHAR(255), p.optionGroupCaption) LIKE '%Frame%')
AND p.deleteX <> 'yes'

--INPUT 5 /a
UPDATE tblSwitchMergeTest
SET input3 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 5:%'
 OR CONVERT(VARCHAR(255), p.optionGroupCaption) LIKE '%Shape%')
AND p.deleteX <> 'yes'

--INPUT 6 /a
UPDATE tblSwitchMergeTest
SET input4 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 6:%'
AND p.deleteX <> 'yes'

--INPUT 7
UPDATE tblSwitchMergeTest
SET input5 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 7:%'
AND p.deleteX <> 'yes'

--INPUT 8
UPDATE tblSwitchMergeTest
SET input6 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 8:%'
AND p.deleteX <> 'yes'

--INPUT 9
UPDATE tblSwitchMergeTest
SET input7 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 9:%'
AND p.deleteX <> 'yes'

--INPUT 10
UPDATE tblSwitchMergeTest
SET input8 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 10:%'
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET marketCenterName = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Market Center Name:%'
AND p.deleteX <> 'yes'

--topImage
/*
	1. If that opid has that product option, and the value is "Default", then the value for the topImage field is: "<first six characters of the product code>-top<last two characters of product code>.gp"
	2. If that opid has that product option, and the value is "Black", then the value for the topImage field is: "<first six characters of the product code>-topBK.gp"
	3. If that opid has that product option, and the value is "White", then the value for the topImage field is: "<first six characters of the product code>-topWH.gp"
	4. If the opid has no product option "Background" (I think that's optionID 375), then leave the topImage field null,
*/
--1.
UPDATE tblSwitchMergeTest
SET topImage = SUBSTRING(productCode, 1, 6) + '-top' + RIGHT(productCode, 2) + '.gp'
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = '375'
	AND optionCaption = 'Default')

--2.
UPDATE tblSwitchMergeTest
SET topImage = SUBSTRING(productCode, 1, 6) + '-top' + 'BK.gp'
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = '376'
	AND optionCaption = 'Black')

--3.
UPDATE tblSwitchMergeTest
SET topImage = SUBSTRING(productCode, 1, 6) + '-top' + 'WH.gp'
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = '377'
	AND optionCaption = 'White')

--4.
UPDATE tblSwitchMergeTest
SET topImage = NULL
WHERE topImage NOT LIKE '%.gp'

--5.
UPDATE tblSwitchMergeTest
SET topImage = 'HOM_Shortrun:SwitchMergeIn:CustomMagnetBackgrounds:Tops:' + topImage
WHERE topImage IS NOT NULL
AND topImage <> ''

--csz
UPDATE tblSwitchMergeTest
SET csz = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'City/state/zip:%'
AND p.deleteX <> 'yes'

--yourName2
UPDATE tblSwitchMergeTest
SET yourName2 = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Your name:%'
AND p.deleteX <> 'yes'

--streetAddress
UPDATE tblSwitchMergeTest
SET streetAddress = CONVERT(VARCHAR(255), p.textValue)
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Street address:%'
AND p.deleteX <> 'yes'

--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
-- 3	A. Realtor Symbol
-- 4	B. Equal Housing Opportunity Symbol
-- 5	C. Realtor - MLS Combo Symbol
-- 6	D. ABR Symbol
-- 7	E. CRS Symbol
-- 8	F. GRI Symbol
-- 9	G. CRB Symbol
-- 10	H. WCR Symbol
-- 11	I. CRP Symbol
-- 12	J. MLS Symbol
-- 13	K. e-Pro Symbol
-- 14	L. SRES Symbol
-- 15	M. FDIC Symbol
-- 141	N. Equal Housing Lender Symbol
-- 155	O. NAHREP Symbol

--400/401/402  VARIOUS NEW Symbol Types
--400 is always Symbol #1, 401 is Symbol #2, 402 is Symbol #3

--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.textValue
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 400
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 3
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 4
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 5
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 6
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 7
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 8
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 9
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 10
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 11
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 12
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 13
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 14
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 15
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 141
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionID = 155
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionCaption LIKE '%facebook%'
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionCaption LIKE '%linkedin%'
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionCaption LIKE '%SFR%'
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol1 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol1 IS NULL
AND p.optionCaption LIKE '%Twitter%'
AND p.deleteX <> 'yes'

--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2
UPDATE tblSwitchMergeTest
SET profsymbol2 = p.textValue
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 401
AND p.textValue <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 3
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 4
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 5
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 6
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 7
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 8
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 9
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 10
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 11
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 12
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 13
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 14
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 15
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 141
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 155
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%facebook%'
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%linkedin%'
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%SFR%'
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol2 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol2 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%Twitter%'
AND p.optionCaption <> a.profsymbol1
AND p.deleteX <> 'yes'

--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3
UPDATE tblSwitchMergeTest
SET profsymbol3 = p.textValue
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 402
AND p.textValue <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.textValue <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 3
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 4
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 5
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 6
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 7
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 8
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 9
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 10
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 11
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 12
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 13
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 14
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 15
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 141
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionID = 155
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%Facebook%'
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%linkedin%'
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%SFR%'
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

UPDATE tblSwitchMergeTest
SET profsymbol3 = p.optionCaption
FROM tblSwitchMergeTest a
JOIN tblOrdersProducts_ProductOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE a.profsymbol3 IS NULL
AND a.profsymbol1 IS NOT NULL
AND p.optionCaption LIKE '%Twitter%'
AND p.optionCaption <> a.profsymbol1
AND a.profsymbol2 IS NOT NULL
AND p.optionCaption <> a.profsymbol2
AND p.deleteX <> 'yes'

--// Get symbol file names
--400 series updates first.
/*
realtor
equal housing opportunity
facebook
realtor-mls combo
mls
linkedin
abr
twitter
gri
crs
sfr
equal housing lender
Realtor - MLS Combo
e-pro
sres
wcr
crp
nahrep
fdic
crb
multi-million *** no background avail.
cdpe *** no background avail.
gold-key *** no background avail.
nar *** no background avail.
mrp *** no background avail.
youtube *** no background avail.
instagram black *** no background avail.
Pinterest Red *** no background avail.
*/

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'A.Realtor.R.Stroke.eps'
WHERE profsymbol1 = 'realtor'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'A.Realtor.R.Stroke.eps'
WHERE profsymbol2 = 'realtor'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'A.Realtor.R.Stroke.eps'
WHERE profsymbol3 = 'realtor'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'A.Realtor.R.Stroke.eps'
WHERE profsymbol1 LIKE '%Realtor Symbol%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'A.Realtor.R.Stroke.eps'
WHERE profsymbol2 LIKE '%Realtor Symbol%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'A.Realtor.R.Stroke.eps'
WHERE profsymbol3 LIKE '%Realtor Symbol%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'B.EqualHousing.Stroke.eps'
WHERE profsymbol1 LIKE '%Equal Housing Opportunity%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'B.EqualHousing.Stroke.eps'
WHERE profsymbol2 LIKE '%Equal Housing Opportunity%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'B.EqualHousing.Stroke.eps'
WHERE profsymbol3 LIKE '%Equal Housing Opportunity%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol1 LIKE '%realtor-mls combo%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol2 LIKE '%realtor-mls combo%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol3 LIKE '%realtor-mls combo%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol1 LIKE '%Realtor/MLS%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol2 LIKE '%Realtor/MLS%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol3 LIKE '%Realtor/MLS%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'J.MLS.Stroked.eps'
WHERE profsymbol1 = 'mls'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'J.MLS.Stroked.eps'
WHERE profsymbol2 = 'mls'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'J.MLS.Stroked.eps'
WHERE profsymbol1 LIKE '%MLS Symbol%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'J.MLS.Stroked.eps'
WHERE profsymbol2 LIKE '%MLS Symbol%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'J.MLS.Stroked.eps'
WHERE profsymbol3 LIKE '%MLS Symbol%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'J.MLS.Stroked.eps'
WHERE profsymbol3 = 'mls'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'D.abr.Stroke.eps'
WHERE profsymbol1 LIKE '%ABR%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'D.abr.Stroke.eps'
WHERE profsymbol2 LIKE '%ABR%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'D.abr.Stroke.eps'
WHERE profsymbol3 LIKE '%ABR%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'E.crs.Stroke.eps'
WHERE profsymbol1 LIKE '%CRS%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'E.crs.Stroke.eps'
WHERE profsymbol2 LIKE '%CRS%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'E.crs.Stroke.eps'
WHERE profsymbol3 LIKE '%CRS%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'F.gri.Stroke.eps'
WHERE profsymbol1 LIKE '%GRI%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'F.gri.Stroke.eps'
WHERE profsymbol2 LIKE '%GRI%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'F.gri.Stroke.eps'
WHERE profsymbol3 LIKE '%GRI%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'N.EHLender.Stroke.eps'
WHERE profsymbol1 LIKE '%Equal Housing Lender%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'N.EHLender.Stroke.eps'
WHERE profsymbol2 LIKE '%Equal Housing Lender%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'N.EHLender.Stroke.eps'
WHERE profsymbol3 LIKE '%Equal Housing Lender%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol1 LIKE '%Realtor - MLS Combo%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol2 LIKE '%Realtor - MLS Combo%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'C.Realtor.MLS.Stroke.eps'
WHERE profsymbol3 LIKE '%Realtor - MLS Combo%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'K.epro.Stroke.eps'
WHERE profsymbol1 LIKE '%e-Pro%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'K.epro.Stroke.eps'
WHERE profsymbol2 LIKE '%e-Pro%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'K.epro.Stroke.eps'
WHERE profsymbol3 LIKE '%e-Pro%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'L.sres.Stroke.eps'
WHERE profsymbol1 LIKE '%SRES%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'L.sres.Stroke.eps'
WHERE profsymbol2 LIKE '%SRES%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'L.sres.Stroke.eps'
WHERE profsymbol3 LIKE '%SRES%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'H.WCI.Stroke.eps'
WHERE profsymbol1 LIKE '%WCR%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'H.WCI.Stroke.eps'
WHERE profsymbol2 LIKE '%WCR%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'H.WCI.Stroke.eps'
WHERE profsymbol3 LIKE '%WCR%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'I.crp.stroke.eps'
WHERE profsymbol1 LIKE '%CRP%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'I.crp.stroke.eps'
WHERE profsymbol2 LIKE '%CRP%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'I.crp.stroke.eps'
WHERE profsymbol3 LIKE '%CRP%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'M.FDIC.Stroke.eps'
WHERE profsymbol1 LIKE '%FDIC%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'M.FDIC.Stroke.eps'
WHERE profsymbol2 LIKE '%FDIC%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'M.FDIC.Stroke.eps'
WHERE profsymbol3 LIKE '%FDIC%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'O.NAHREP.Stroke.eps'
WHERE profsymbol1 LIKE '%NAHREP%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'O.NAHREP.Stroke.eps'
WHERE profsymbol2 LIKE '%NAHREP%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'O.NAHREP.Stroke.eps'
WHERE profsymbol3 LIKE '%NAHREP%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'G.crb.Stroke.eps'
WHERE profsymbol1 LIKE '%CRB%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'G.crb.Stroke.eps'
WHERE profsymbol2 LIKE '%CRB%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'G.crb.Stroke.eps'
WHERE profsymbol3 LIKE '%CRB%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'Facebook.Stroke.eps'
WHERE profsymbol1 LIKE '%facebook%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'Facebook.Stroke.eps'
WHERE profsymbol2 LIKE '%facebook%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'Facebook.Stroke.eps'
WHERE profsymbol3 LIKE '%facebook%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'LinkedIn.Stroke.eps'
WHERE profsymbol1 LIKE '%linkedin%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'LinkedIn.Stroke.eps'
WHERE profsymbol2 LIKE '%linkedin%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'LinkedIn.Stroke.eps'
WHERE profsymbol3 LIKE '%linkedin%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'SFR.Stroke.eps'
WHERE profsymbol1 LIKE '%SFR%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'SFR.Stroke.eps'
WHERE profsymbol2 LIKE '%SFR%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'SFR.Stroke.eps'
WHERE profsymbol3 LIKE '%SFR%'

UPDATE tblSwitchMergeTest
SET profsymbol1 = 'Twitter.Stroke.eps'
WHERE profsymbol1 LIKE '%twitter%'

UPDATE tblSwitchMergeTest
SET profsymbol2 = 'Twitter.Stroke.eps'
WHERE profsymbol2 LIKE '%twitter%'

UPDATE tblSwitchMergeTest
SET profsymbol3 = 'Twitter.Stroke.eps'
WHERE profsymbol3 LIKE '%twitter%'


--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.

--BKGND_OLD
UPDATE tblSwitchMergeTest
SET bkgnd_old = x.artBackgroundImageName
FROM tblSwitchMergeTest a
JOIN tblProducts x
	ON a.productID = x.productID
WHERE a.bkgnd_old IS NULL
AND x.artBackgroundImageName IS NOT NULL

-- FIX NCC ROWS
UPDATE tblSwitchMergeTest
SET yourName = NULL
WHERE orderNo IN 
	(SELECT orderNo
	FROM tblOrders
	WHERE orderID IN 
		(SELECT orderID
		 FROM tblOrders_Products
		 WHERE productID IN 
			 (SELECT productID
			 FROM tblProducts
			 WHERE productCompany = 'NCC')))

--ENTERDATE
UPDATE tblSwitchMergeTest
SET enterDate = CONVERT(VARCHAR(255), DATEPART(MONTH, GETDATE())) + '/' + CONVERT(VARCHAR(255), DATEPART(DAY, GETDATE())) + '/' + CONVERT(VARCHAR(255), DATEPART(YEAR, GETDATE()))
WHERE enterDate IS NULL
AND orderNo IS NOT NULL

--DELETE STOCK-ONLY ORDERS
DELETE FROM tblSwitchMergeTest
WHERE orderNo IN 
	(SELECT orderNo
	 FROM tblOrders
	 WHERE orderType = 'Stock')

--DELETE NULL ORDERNO'S
DELETE FROM tblSwitchMergeTest
WHERE orderNo IS NULL

DELETE FROM tblSwitchMergeTest
WHERE orderNo NOT IN 
	(SELECT orderNo
	 FROM tblOrders a
	 WHERE DATEDIFF(dd, a.orderDate, GETDATE()) < 170
 	 AND a.orderStatus <> 'delivered'
	 AND a.orderStatus <> 'cancelled'
	 AND a.orderStatus NOT LIKE '%transit%'
	 AND a.orderStatus NOT LIKE '%DOCK%'
	 AND a.orderType = 'Custom'
	 AND a.orderID IN 
		 (SELECT orderID
		 FROM tblOrders_Products
		 WHERE deleteX <> 'yes'
		 AND productCode NOT LIKE '%NB%'
	 AND orderID IS NOT NULL))
AND productCode <> 'NB00SU-001'

-- 4. Clean data so that it is in the format required by Production.
-- FIX productQuantity
UPDATE tblSwitchMergeTest
SET productQuantity = productQuantity * 500
WHERE productCode LIKE 'BC%'
AND productQuantity IS NOT NULL

UPDATE tblSwitchMergeTest
SET productQuantity = productQuantity * 500
WHERE productCode LIKE 'KWBC%'
AND productQuantity IS NOT NULL

UPDATE tblSwitchMergeTest
SET productQuantity = productQuantity * 250
WHERE productCode LIKE 'GNNC%'
AND productQuantity IS NOT NULL

UPDATE tblSwitchMergeTest
SET productQuantity = productQuantity * 100
WHERE productCode NOT LIKE 'BC%'
AND productCode NOT LIKE 'GNNC%'
AND productCode NOT LIKE 'HLBG%'
AND productQuantity IS NOT NULL

-- FIX groupPicture
UPDATE tblSwitchMergeTest
SET groupPicture = ''
WHERE groupPicture IS NULL

UPDATE tblSwitchMergeTest
SET groupPicture = productCode + '.gp'
WHERE productCode NOT LIKE 'BB%'
AND productCode NOT LIKE 'FB%'
AND productCode NOT LIKE 'BK%'
AND productCode NOT LIKE 'HY%'
AND productCode NOT LIKE 'HB%'
AND productCode NOT LIKE 'BH%'
AND productCode NOT LIKE 'CA%'
AND productCode NOT LIKE 'PG%'
AND groupPicture NOT LIKE '%.gp'
AND groupPicture NOT LIKE '%.eps'

UPDATE tblSwitchMergeTest
SET groupPicture = productCode + '.eps'
WHERE groupPicture NOT LIKE '%.gp'
AND groupPicture NOT LIKE '%.eps'
AND (productCode LIKE 'FB%' 
	OR productCode LIKE 'BK%' 
	OR productCode LIKE 'BB%' 
	OR productCode LIKE 'HY%'
	OR productCode LIKE 'BH%'
	OR productCode LIKE 'PG%'
	OR productCode LIKE 'CA%'
	OR productCode LIKE 'HB%')

UPDATE tblSwitchMergeTest
SET groupPicture = productCode + '.gp'
WHERE groupPicture NOT LIKE '%.gp'
AND groupPicture NOT LIKE '%.eps'
AND (productCode LIKE 'BC%'
	OR productName LIKE '%calendar%'
	OR productName LIKE '%Halloween Bag%')

UPDATE tblSwitchMergeTest
SET groupPicture = productCode + '.eps'
WHERE productCode NOT LIKE 'BC%'
AND productName NOT LIKE '%Halloween Bag%'
AND groupPicture NOT LIKE '%.gp'
AND groupPicture NOT LIKE '%.eps'

--All products starting with BB, FB, BK, and HY should have QC changed to QS and QM changed to QS.
UPDATE tblSwitchMergeTest
SET groupPicture = REPLACE(groupPicture, 'QC', 'QS')
WHERE groupPicture LIKE 'BB%'
OR groupPicture LIKE 'FB%'
OR groupPicture LIKE 'BK%'
OR groupPicture LIKE 'HY%'
OR groupPicture LIKE 'PG%'
OR groupPicture LIKE 'HB%'
OR groupPicture LIKE 'BH%'

UPDATE tblSwitchMergeTest
SET groupPicture = REPLACE(groupPicture, 'QM', 'QS')
WHERE groupPicture LIKE 'BB%'
OR groupPicture LIKE 'FB%'
OR groupPicture LIKE 'BK%'
OR groupPicture LIKE 'HY%'
OR groupPicture LIKE 'PG%'
OR groupPicture LIKE 'HB%'
OR groupPicture LIKE 'BH%'

--//new code; jf 7/7/16.
UPDATE tblSwitchMergeTest
SET groupPicture = 'HOM_Shortrun:SwitchMergeIn:CustomMagnetBackgrounds:' + SUBSTRING(productCode, 1, 2) + ':' + groupPicture
WHERE groupPicture IS NOT NULL
AND groupPicture <> ''

-- wipe projectName
UPDATE tblSwitchMergeTest
SET projectName = NULL

-- FIX bkgnd_old
UPDATE tblSwitchMergeTest
SET bkgnd_old = REPLACE(REPLACE(bkgnd_old, 'QC', 'QS'), 'QM', 'QS')
WHERE productCode LIKE 'FB%'
OR productCode LIKE 'BB%'
OR productCode LIKE 'HK%'
OR productCode LIKE 'BK%'

UPDATE tblSwitchMergeTest
SET bkgnd_old = REPLACE(bkgnd_old, 'SP', '')
WHERE bkgnd_old LIKE '%SP'

-- FIX sequencing for orders that have more than 1 custom product in the order (XXXXX_1, XXXXX_2, etc.)
TRUNCATE TABLE tblSwitchMergeTest_Sequencer

INSERT INTO tblSwitchMergeTest_Sequencer (PKID, countPKID)
SELECT PKID AS 'PKID', COUNT(PKID) AS 'countPKID'
FROM tblSwitchMergeTest
GROUP BY PKID
HAVING COUNT(PKID) > 1
ORDER BY COUNT(PKID) DESC

UPDATE tblSwitchMergeTest
SET sequencer = b.countPKID
FROM tblSwitchMergeTest a, tblSwitchMergeTest_Sequencer b
WHERE a.PKID = b.PKID

UPDATE tblSwitchMergeTest_Sequencer
SET lowestArb = b.arb
FROM tblSwitchMergeTest_Sequencer a, tblSwitchMergeTest b
WHERE a.PKID = b.PKID
AND b.arb IN 
	(SELECT TOP 1 arb
	FROM tblSwitchMergeTest
	WHERE PKID = a.PKID
	ORDER BY arb ASC)

UPDATE tblSwitchMergeTest
SET PKID = CONVERT(VARCHAR(50), a.PKID) + '_' + CONVERT(VARCHAR(50), (a.arb-b.lowestArb+1))
FROM tblSwitchMergeTest a, tblSwitchMergeTest_Sequencer b
WHERE a.PKID = b.PKID

--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
--SET NULLS: for comparitive clauses to follow.
UPDATE tblSwitchMergeTest
SET logo1 = ''
WHERE logo1 IS NULL

UPDATE tblSwitchMergeTest
SET logo2 = ''
WHERE logo2 IS NULL

UPDATE tblSwitchMergeTest
SET photo1 = ''
WHERE photo1 IS NULL

UPDATE tblSwitchMergeTest
SET photo2 = ''
WHERE photo2 IS NULL

UPDATE tblSwitchMergeTest
SET overflow1 = ''
WHERE overflow1 IS NULL

UPDATE tblSwitchMergeTest
SET overflow2 = ''
WHERE overflow2 IS NULL

UPDATE tblSwitchMergeTest
SET overflow3 = ''
WHERE overflow3 IS NULL

UPDATE tblSwitchMergeTest
SET overflow4 = ''
WHERE overflow4 IS NULL

UPDATE tblSwitchMergeTest
SET overflow5 = ''
WHERE overflow5 IS NULL

UPDATE tblSwitchMergeTest
SET previousJobArt = ''
WHERE previousJobArt IS NULL

UPDATE tblSwitchMergeTest
SET previousJobInfo = ''
WHERE previousJobInfo IS NULL

UPDATE tblSwitchMergeTest
SET artInstructions = ''
WHERE artInstructions IS NULL

--- PART 1/1 (Create-Your-Own Merge Columns): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblSwitchMergeTest
SET backgroundFileName = ''
WHERE backgroundFileName IS NULL

UPDATE tblSwitchMergeTest
SET layoutFileName = ''
WHERE layoutFileName IS NULL

UPDATE tblSwitchMergeTest
SET productBack = ''
WHERE productBack IS NULL

UPDATE tblSwitchMergeTest
SET team1FileName = ''
WHERE team1FileName IS NULL

UPDATE tblSwitchMergeTest
SET team2FileName = ''
WHERE team2FileName IS NULL

UPDATE tblSwitchMergeTest
SET team3FileName = ''
WHERE team3FileName IS NULL

UPDATE tblSwitchMergeTest
SET team4FileName = ''
WHERE team4FileName IS NULL

UPDATE tblSwitchMergeTest
SET team5FileName = ''
WHERE team5FileName IS NULL

UPDATE tblSwitchMergeTest
SET team6FileName = ''
WHERE team6FileName IS NULL

UPDATE tblSwitchMergeTest
SET backgroundFileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Background File Name'
AND b.deleteX <> 'yes'
AND a.backgroundFileName <> b.textValue

UPDATE tblSwitchMergeTest
SET layoutFileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Layout File Name'
AND b.deleteX <> 'yes'
AND a.layoutFileName <> b.textValue

--// new update to extension on productBack as of 7/7/16; jf.
--	  additional update to add path to productBack; 7/12/16; jf.
UPDATE tblSwitchMergeTest
SET productBack = 'HOM_Shortrun:SwitchMergeIn:Backs:' + b.textValue + '.eps'
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Product Back'
AND b.deleteX <> 'yes'
AND a.productBack <> b.textValue

UPDATE tblSwitchMergeTest
SET team1FileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 1 File Name'
AND b.deleteX <> 'yes'
AND a.team1FileName <> b.textValue

UPDATE tblSwitchMergeTest
SET team2FileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 2 File Name'
AND b.deleteX <> 'yes'
AND a.team2FileName <> b.textValue

UPDATE tblSwitchMergeTest
SET team3FileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 3 File Name'
AND b.deleteX <> 'yes'
AND a.team3FileName <> b.textValue

UPDATE tblSwitchMergeTest
SET team4FileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 4 File Name'
AND b.deleteX <> 'yes'
AND a.team4FileName <> b.textValue

UPDATE tblSwitchMergeTest
SET team5FileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 5 File Name'
AND b.deleteX <> 'yes'
AND a.team5FileName <> b.textValue

UPDATE tblSwitchMergeTest
SET team6FileName = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 6 File Name'
AND b.deleteX <> 'yes'
AND a.team6FileName <> b.textValue

--- PART 1/3 (LOGO): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ******** LOGO1 ************
UPDATE tblSwitchMergeTest
SET logo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.logo1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.logo1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.logo1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.logo1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.logo1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue

-- ******** LOGO2 ************
UPDATE tblSwitchMergeTest
SET logo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.logo1 <> ''
AND a.logo2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.logo1 <> ''
AND a.logo2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.logo1 <> ''
AND a.logo2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.logo1 <> ''
AND a.logo2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.logo1 <> ''
AND a.logo2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue

--- PART 2/3 (PHOTO): ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ******** PHOTO1 ************
UPDATE tblSwitchMergeTest
SET photo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.photo1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.photo1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.photo1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.photo1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.photo1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue

-- ******** PHOTO2 ************
UPDATE tblSwitchMergeTest
SET photo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.photo1 <> ''
AND a.photo2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.photo1 <> ''
AND a.photo2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.photo1 <> ''
AND a.photo2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.photo1 <> ''
AND a.photo2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.photo1 <> ''
AND a.photo2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue

--- PART 3/3 (OVERFLOW): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ******** OVERFLOW1 ************
UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 1%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 2%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 3%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 4%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue

-- ******** OVERFLOW2 ************
UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 1%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 2%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 3%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 4%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue

-- ******** OVERFLOW3 ************
UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 1%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 2%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 3%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 4%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue

-- ******** OVERFLOW4 ************
UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 1%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 2%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 3%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name 4%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue

-- ******** OVERFLOW5 ************
UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE '%-v%'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'logo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'photo%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue LIKE 'misc%'
AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

-- ******** MISC ************
--MISC LOGOS
UPDATE tblSwitchMergeTest
SET logo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE '%logo%'
AND a.logo1 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET logo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE '%logo%'
AND a.logo1 <> ''
AND a.logo2 = ''
AND b.deleteX <> 'yes'
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

--MISC PHOTOS
UPDATE tblSwitchMergeTest
SET photo1 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE '%phot%'
AND a.photo1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET photo2 = b.textValue
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE '%File Name%'
AND b.textValue LIKE '%phot%'
AND a.photo1 <> ''
AND a.photo2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

--MISC UNKNOWN FILES
UPDATE tblSwitchMergeTest
SET overflow1 = LEFT(b.textValue, 255)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.overflow1 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow2 = LEFT(b.textValue, 255)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.overflow1 <> ''
AND a.overflow2 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow3 = LEFT(b.textValue, 255)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow4 = LEFT(b.textValue, 255)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

UPDATE tblSwitchMergeTest
SET overflow5 = LEFT(b.textValue, 255)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption LIKE 'File Name%'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.overflow1 <> ''
AND a.overflow2 <> ''
AND a.overflow3 <> ''
AND a.overflow4 <> ''
AND a.overflow5 = ''
AND b.deleteX <> 'yes'
AND a.photo1 <> b.textValue
AND a.photo2 <> b.textValue
AND a.logo1 <> b.textValue
AND a.logo2 <> b.textValue
AND a.overflow1 <> b.textValue
AND a.overflow2 <> b.textValue
AND a.overflow3 <> b.textValue
AND a.overflow4 <> b.textValue
AND a.overflow5 <> b.textValue

-- ******** THE INSTRUCTIONS ************
UPDATE tblSwitchMergeTest
SET previousJobArt = LEFT(b.textValue, 250)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Previous Job Art'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.previousJobArt <> b.textValue

UPDATE tblSwitchMergeTest
SET previousJobInfo = LEFT(b.textValue, 250)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Previous Job Info'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.previousJobInfo <> b.textValue

UPDATE tblSwitchMergeTest
SET artInstructions = LEFT(b.textValue, 250)
FROM tblSwitchMergeTest a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Art Instructions'
AND b.textValue IS NOT NULL
AND b.textValue <> ''
AND a.artInstructions <> b.textValue

--// CLEAN BEGIN ------------------------------------------------------------------------------------------------------------------------------
--yourName FIELD
UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#174', '®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '(R)', '®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&amp', '&')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&quot', '"')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'REALTOR', 'REALTOR®')
WHERE yourName NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, 'REALTORS', 'REALTORS®')
WHERE yourName NOT LIKE '%REALTORS®%'
AND yourName LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '®®', '®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, ',', ', ')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, ' ', ' ')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, ' ', ' ')

UPDATE tblSwitchMergeTest
SET yourName = REPLACE(yourName, '®', '<V>®<P>')

--yourCompany FIELD
UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#174', '®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '(R)', '®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&amp', '&')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&quot', '"')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'REALTOR', 'REALTOR®')
WHERE yourCompany NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, 'REALTORS', 'REALTORS®')
WHERE yourCompany NOT LIKE '%REALTORS®%'
AND yourCompany LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '®®', '®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, ',', ', ')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, ' ', ' ')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, ' ', ' ')

UPDATE tblSwitchMergeTest
SET yourCompany = REPLACE(yourCompany, '®', '<V>®<P>')

--input1 FIELD
UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'REALTOR', 'REALTOR®')
WHERE input1 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, 'REALTORS', 'REALTORS®')
WHERE input1 NOT LIKE '%REALTORS®%'
AND input1 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '®®', '®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, ',', ', ')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input1 = REPLACE(input1, '®', '<V>®<P>')

--input2 FIELD
UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'REALTOR', 'REALTOR®')
WHERE input2 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, 'REALTORS', 'REALTORS®')
WHERE input2 NOT LIKE '%REALTORS®%'
AND input2 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '®®', '®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, ',', ', ')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input2 = REPLACE(input2, '®', '<V>®<P>')

--input3 FIELD
UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'REALTOR', 'REALTOR®')
WHERE input3 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, 'REALTORS', 'REALTORS®')
WHERE input3 NOT LIKE '%REALTORS®%'
AND input3 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '®®', '®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, ',', ', ')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input3 = REPLACE(input3, '®', '<V>®<P>')

--input4 FIELD
UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'REALTOR', 'REALTOR®')
WHERE input4 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, 'REALTORS', 'REALTORS®')
WHERE input4 NOT LIKE '%REALTORS®%'
AND input4 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '®®', '®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, ',', ', ')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input4 = REPLACE(input4, '®', '<V>®<P>')

--input5 FIELD
UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'REALTOR', 'REALTOR®')
WHERE input5 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, 'REALTORS', 'REALTORS®')
WHERE input5 NOT LIKE '%REALTORS®%'
AND input5 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '®®', '®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, ',', ', ')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input5 = REPLACE(input5, '®', '<V>®<P>')

--input6 FIELD
UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'REALTOR', 'REALTOR®')
WHERE input6 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, 'REALTORS', 'REALTORS®')
WHERE input6 NOT LIKE '%REALTORS®%'
AND input6 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '®®', '®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, ',', ', ')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input6 = REPLACE(input6, '®', '<V>®<P>')

--input7 FIELD
UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'REALTOR', 'REALTOR®')
WHERE input7 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, 'REALTORS', 'REALTORS®')
WHERE input7 NOT LIKE '%REALTORS®%'
AND input7 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '®®', '®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, ',', ', ')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input7 = REPLACE(input7, '®', '<V>®<P>')

--input8 FIELD
UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#174', '®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '(R)', '®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&amp', '&')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&quot', '"')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'REALTOR', 'REALTOR®')
WHERE input8 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, 'REALTORS', 'REALTORS®')
WHERE input8 NOT LIKE '%REALTORS®%'
AND input8 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '®®', '®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, ',', ', ')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, ' ', ' ')

UPDATE tblSwitchMergeTest
SET input8 = REPLACE(input8, '®', '<V>®<P>')

--marketCenterName FIELD
UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#174', '®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '(R)', '®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&amp', '&')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&quot', '"')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'REALTOR', 'REALTOR®')
WHERE marketCenterName NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, 'REALTORS', 'REALTORS®')
WHERE marketCenterName NOT LIKE '%REALTORS®%'
AND marketCenterName LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '®®', '®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, ',', ', ')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, ' ', ' ')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, ' ', ' ')

UPDATE tblSwitchMergeTest
SET marketCenterName = REPLACE(marketCenterName, '®', '<V>®<P>')

--topImage FIELD
UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#174', '®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '(R)', '®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&amp', '&')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&quot', '"')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'REALTOR', 'REALTOR®')
WHERE topImage NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, 'REALTORS', 'REALTORS®')
WHERE topImage NOT LIKE '%REALTORS®%'
AND topImage LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '®®', '®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, ',', ', ')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, ' ', ' ')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, ' ', ' ')

UPDATE tblSwitchMergeTest
SET topImage = REPLACE(topImage, '®', '<V>®<P>')

--streetAddress FIELD
UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#174', '®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '(R)', '®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&amp', '&')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&quot', '"')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'REALTOR', 'REALTOR®')
WHERE streetAddress NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, 'REALTORS', 'REALTORS®')
WHERE streetAddress NOT LIKE '%REALTORS®%'
AND streetAddress LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '®®', '®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, ',', ', ')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, ' ', ' ')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, ' ', ' ')

UPDATE tblSwitchMergeTest
SET streetAddress = REPLACE(streetAddress, '®', '<V>®<P>')

--csz FIELD
UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#174', '®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '(R)', '®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&amp', '&')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&quot', '"')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'REALTOR', 'REALTOR®')
WHERE csz NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, 'REALTORS', 'REALTORS®')
WHERE csz NOT LIKE '%REALTORS®%'
AND csz LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '®®', '®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, ',', ', ')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, ' ', ' ')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, ' ', ' ')

UPDATE tblSwitchMergeTest
SET csz = REPLACE(csz, '®', '<V>®<P>')

--yourName2 FIELD
UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#174', '®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '(R)', '®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&amp', '&')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&quot', '"')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'REALTOR', 'REALTOR®')
WHERE yourName2 NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, 'REALTORS', 'REALTORS®')
WHERE yourName2 NOT LIKE '%REALTORS®%'
AND yourName2 LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '®®', '®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, ',', ', ')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, ' ', ' ')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, ' ', ' ')

UPDATE tblSwitchMergeTest
SET yourName2 = REPLACE(yourName2, '®', '<V>®<P>')

--artInstructions FIELD
UPDATE tblSwitchMergeTest
SET artInstructions = LEFT(artInstructions, 230)
WHERE Len(artInstructions) > 230

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#174', '®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '(R)', '®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&amp', '&')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&quot', '"')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'REALTOR', 'REALTOR®')
WHERE artInstructions NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, 'REALTORS', 'REALTORS®')
WHERE artInstructions NOT LIKE '%REALTORS®%'
AND artInstructions LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '®®', '®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, CHAR(13) + CHAR(10), ' ')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, ',', ', ')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, ' ', ' ')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, ' ', ' ')

UPDATE tblSwitchMergeTest
SET artInstructions = REPLACE(artInstructions, '®', '<V>®<P>')

--previousJobArt FIELD
UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#174', '®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '(R)', '®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&amp', '&')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&quot', '"')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'REALTOR', 'REALTOR®')
WHERE previousJobArt NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, 'REALTORS', 'REALTORS®')
WHERE previousJobArt NOT LIKE '%REALTORS®%'
AND previousJobArt LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '®®', '®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, ',', ', ')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, CHAR(13) + CHAR(10), ' ')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, ' ', ' ')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, ' ', ' ')

UPDATE tblSwitchMergeTest
SET previousJobArt = REPLACE(previousJobArt, '®', '<V>®<P>')

--previousJobInfo FIELD
UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#174;', '®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#174', '®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '(R)', '®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&amp;', '&')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&amp', '&')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&quot;', '"')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&quot', '"')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#233;', 'é')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#233', 'é')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#241;', 'ñ')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#241', 'ñ')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#211;', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#243;', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#211', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '&#243', 'Ó')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'realtor', 'REALTOR')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR', 'REALTOR®')
WHERE previousJobInfo NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, 'REALTORS', 'REALTORS®')
WHERE previousJobInfo NOT LIKE '%REALTORS®%'
AND previousJobInfo LIKE '%REALTORS%'

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '®®', '®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '®-', ' ® -')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '-®', ' - ®')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, ',', ', ')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, CHAR(13) + CHAR(10), ' ')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, ' ', ' ')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, ' ', ' ')

UPDATE tblSwitchMergeTest
SET previousJobInfo = REPLACE(previousJobInfo, '®', '<V>®<P>')

--// CLEAN END--------------------------------------------------------------------------------------------------------------------------------------------
--// Update 2 columns in the SwitchMergeTest when a product is an OPC product (JF 092514)
UPDATE tblSwitchMergeTest
SET overflow1 = 'OPC'
WHERE ordersProductsID IN 
	(SELECT ordersProductsID
	 FROM tblOrdersProducts_productOptions
	 WHERE optionCaption = 'OPC')

UPDATE tblSwitchMergeTest
SET logo1 = RIGHT(logo1, CHARINDEX('/', REVERSE(logo1)) - 1)
WHERE logo1 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET logo2 = RIGHT(logo2, CHARINDEX('/', REVERSE(logo2)) - 1)
WHERE logo2 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET photo1 = RIGHT(photo1, CHARINDEX('/', REVERSE(photo1)) - 1)
WHERE photo1 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET photo2 = RIGHT(photo2, CHARINDEX('/', REVERSE(photo2)) - 1)
WHERE photo2 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET overflow1 = RIGHT(overflow1, CHARINDEX('/', REVERSE(overflow2)) - 1)
WHERE overflow1 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET overflow2 = RIGHT(overflow2, CHARINDEX('/', REVERSE(overflow2)) - 1)
WHERE overflow2 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET overflow3 = RIGHT(overflow3, CHARINDEX('/', REVERSE(overflow3)) - 1)
WHERE overflow3 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET overflow4 = RIGHT(overflow4, CHARINDEX('/', REVERSE(overflow4)) - 1)
WHERE overflow4 LIKE '%/%'

UPDATE tblSwitchMergeTest
SET overflow5 = RIGHT(overflow5, CHARINDEX('/', REVERSE(overflow5)) - 1)
WHERE overflow5 LIKE '%/%'

--// new updates to logo, photo and overflow fields; jf 7/7/16.
--	  pulled out by JF as per AC request; 7/11/16.
--UPDATE tblSwitchMergeTest
--SET logo1 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':' + logo1
--WHERE logo1 IS NOT NULL
--AND logo1 <> ''

--UPDATE tblSwitchMergeTest
--SET logo2 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + logo2
--WHERE logo2 IS NOT NULL
--AND logo2 <> ''

--UPDATE tblSwitchMergeTest
--SET photo1 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + photo1
--WHERE photo1 IS NOT NULL
--AND photo1 <> ''

--UPDATE tblSwitchMergeTest
--SET photo2 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + photo2
--WHERE photo2 IS NOT NULL
--AND photo2 <> ''

--UPDATE tblSwitchMergeTest
--SET overflow1 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + overflow1
--WHERE overflow1 IS NOT NULL
--AND overflow1 <> ''

--UPDATE tblSwitchMergeTest
--SET overflow2 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + overflow2
--WHERE overflow2 IS NOT NULL
--AND overflow2 <> ''

--UPDATE tblSwitchMergeTest
--SET overflow3 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + overflow3
--WHERE overflow3 IS NOT NULL
--AND overflow3 <> ''

--UPDATE tblSwitchMergeTest
--SET overflow4 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + overflow4
--WHERE overflow4 IS NOT NULL
--AND overflow4 <> ''

--UPDATE tblSwitchMergeTest
--SET overflow5 = 'HOM_Shortrun:~HOM Active Jobs:' + SUBSTRING(orderNo, 4, 6) + '_' +  CONVERT(VARCHAR(50), ordersProductsID) + ':'  + overflow5
--WHERE overflow5 IS NOT NULL
--AND overflow5 <> ''

--// new updates to profSymbol fields; jf 7/7/16.
UPDATE tblSwitchMergeTest
SET profSymbol1 = 'HOM_Shortrun:SwitchMergeIn:Realtor symbols Stroked:' + profSymbol1
WHERE profSymbol1 IS NOT NULL
AND profSymbol1 <> '' 

UPDATE tblSwitchMergeTest
SET profSymbol2 = 'HOM_Shortrun:SwitchMergeIn:Realtor symbols Stroked:' + profSymbol2
WHERE profSymbol2 IS NOT NULL
AND profSymbol2 <> '' 

UPDATE tblSwitchMergeTest
SET profSymbol3 = 'HOM_Shortrun:SwitchMergeIn:Realtor symbols Stroked:' + profSymbol3
WHERE profSymbol3 IS NOT NULL
AND profSymbol3 <> '' 

--// Template work; jf 9/27/16.
--//-----------------------------------------------------------------------------------------------------------------------
--//Denull productBack
UPDATE tblSwitchMergeTest
SET productBack = ''
WHERE productBack IS NULL

--1. SET TEMPLATES
--CA
UPDATE tblSwitchMergeTest
SET template = REPLACE(template, 'X.gp', b.templateBase)
--select a.template, a.productBack, b.*
FROM tblSwitchMergeTest a
JOIN tblSwitchMerge_templateReference b
	ON SUBSTRING(a.productCode, 1, 4) = SUBSTRING(b.productCode, 1, 4)
WHERE SUBSTRING(a.productCode, 7, 4) = SUBSTRING(b.productCode, 7, 4)
AND a.productCode LIKE 'CA%'

--SPORTS
UPDATE tblSwitchMergeTest
SET template = REPLACE(template, 'X.gp', b.templateBase)
--select a.template. a.productBack, b.*
FROM tblSwitchMergeTest a
JOIN tblSwitchMerge_templateReference b
	ON SUBSTRING(a.productCode, 1, 3) = SUBSTRING(b.productCode, 1, 3)
WHERE LEN(b.productCode) = 3

--SPORTS
UPDATE tblSwitchMergeTest
SET template = REPLACE(template, 'X.gp', b.templateBase)
--select a.template. a.productBack, b.*
FROM tblSwitchMergeTest a
JOIN tblSwitchMerge_templateReference b
	ON SUBSTRING(a.productCode, 1, 4) = SUBSTRING(b.productCode, 1, 4)
WHERE LEN(b.productCode) = 4

--EXACT MATCHES
UPDATE tblSwitchMergeTest
SET template = REPLACE(template, 'X.gp', b.templateBase)
--select  *
FROM tblSwitchMergeTest a
JOIN tblSwitchMerge_templateReference b
	ON a.productCode = b.productCode

--2. SET FONT COLORS (currently only applies to CA products)
UPDATE tblSwitchMergeTest
SET 
yourName = '<c"' + b.fontColor + '">' + yourName,
yourCompany = '<c"' + b.fontColor + '">' + yourCompany,
input1 = '<c"' + b.fontColor + '">' + input1,
input2 = '<c"' + b.fontColor + '">' + input2,
input3 = '<c"' + b.fontColor + '">' + input3,
input4 = '<c"' + b.fontColor + '">' + input4,
input5 = '<c"' + b.fontColor + '">' + input5,
input6 = '<c"' + b.fontColor + '">' + input6
--select a.*
FROM tblSwitchMergeTest a
JOIN tblSwitchMerge_templateReference b
	ON SUBSTRING(a.productCode, 1, 4) = SUBSTRING(b.productCode, 1, 4)
WHERE SUBSTRING(a.productCode, 7, 4) = SUBSTRING(b.productCode, 7, 4)
AND a.productCode LIKE 'CA%'
AND b.fontColor IS NOT NULL

--3. PRODUCT BACK CONSIDERATIONS
--if there is a productBack for an OPID, then add "D" prior to extension.
UPDATE tblSwitchMergeTest
SET template = REPLACE(template, '.gp', 'D.gp')
WHERE productBack IS NOT NULL
AND productBack <> ''

--select * from tblSwitchMerge_templateReference
--select * FROM tblSwitchMergeTest