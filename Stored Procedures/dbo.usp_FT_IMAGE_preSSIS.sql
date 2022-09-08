CREATE PROC [dbo].[usp_FT_IMAGE_preSSIS]

AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/26/10
-- Purpose     1/4 parts to SSIS badge flow
-------------------------------------------------------------------------------
-- Modification History
--01/26/10		created, jf.
-- 07/16/18	replaced "AND op.fastTrak_productType = 'Badge'" with "AND SUBSTRING(op.productCode, 1, 2) = 'NB'" in initial query, jf
--07/17/18		added back excel spreadsheet code, near ln200, jf
--07/25/18		updated initial query to match IMPO clauses in relation to tblOrders, OP, and OPPO, jf.
--07/26/18		added this back in: AND SUBSTRING(op.productCode, 6, 1) <> 'F', jf.
--08/17/18		added this exception: NB0TRB-001-100, jf.
--09/04/18		reverted above, jf.
--02/05/19		added anti-canvas clause in initial query, jf.
--02/05/19		added TITLE fix, jf.
--04/27/22      added displaypaymentStatus = 'Credit Due'

-------------------------------------------------------------------------------
--///////// IMAGE FILE CREATION //////////////
--// The image file IS created when either (1) a product qualifies to begin production AND its image file has never been created or (2) a product has been noted for reimage.
--// First run badges (this step takes 2-3 minutes) (edit JF: 10/15/2014)


--EXEC [usp_badges]
EXEC [usp_NewModBadges]

--// Wipe AND refresh data to account for possible data changes on the Intranet
DELETE FROM tblFT_Badges

INSERT INTO tblFT_Badges (ordersProductsID, orderNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, contact, title, COtextAll, COtext1, COtext2, sortNo, RO,
fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit, exportStatus)

SELECT DISTINCT
a.OPPO_ordersProductsID, a.orderNo, 
'Macintosh HD:Name Badge Central:Group Pictures:' + a.BKGND + '-X.gp', 'NB_image',
'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + a.orderNo + '_' + CONVERT(VARCHAR(255), a.OPPO_ordersProductsID) + '.pdf', 
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + a.orderNo + '_' + CONVERT(VARCHAR(255), a.OPPO_ordersProductsID) + '.log', 
'Graphic Business Solutions', 'PDF',
a.contact, a.title, a.COtextAll, a.COtext1, a.COtext2, a.sortNo, a.RO,
op.fastTrak_shippingLabelOption1, op.fastTrak_shippingLabelOption2, op.fastTrak_shippingLabelOption3, op.fastTrak_resubmit,
'Dirty'
FROM tblBadges a 
INNER JOIN tblOrders_Products op
	ON a.OPPO_ordersProductsID = op.[ID]
INNER JOIN tblOrders o
	ON o.orderID = op.orderID
WHERE op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) = 'NB'
AND a.contact NOT LIKE '%excel%'
AND a.contact NOT LIKE '%spreadsheet%'
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND SUBSTRING(op.productCode, 6, 1) <> 'F'
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND o.orderStatus NOT LIKE '%Waiting%'
AND o.displayPaymentStatus IN ('Good','Credit Due')
AND 
	(  
	   (op.fastTrak_imageFile_exported =  0 AND op.fastTrak_resubmit = 0) 
	OR 
		op.fastTrak_resubmit = 1
	)
AND a.sortNo <> 9999999
AND op.ID NOT IN -- ANTI CANVAS
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption IN ('CC State User ID', 'CC State ID', 'Intranet PDF'))
ORDER BY a.sortNo ASC

--NOP ISSUES
UPDATE tblFT_Badges
SET Title = ''
WHERE Title = 'Custom'

--// Alpha values determined by various combinations of these 3 fields: Title, COtext1, COtext2
-- A: missing nothing
UPDATE tblFT_Badges
SET alpha = 'A'
WHERE Title IS NOT NULL AND Title <> ''
AND COtext1 IS NOT NULL AND COtext1 <> ''
AND COtext2 IS NOT NULL AND COtext2 <> ''

-- B: missing COtext2 only
UPDATE tblFT_Badges
SET alpha = 'B'
WHERE Title IS NOT NULL AND Title <> ''
AND COtext1 IS NOT NULL AND COtext1 <> ''
AND (COtext2 IS NULL OR COtext2 = '')

-- C: missing COtext1 AND COtext2
UPDATE tblFT_Badges
SET alpha = 'C'
WHERE Title IS NOT NULL AND Title <> ''
AND (COtext1 IS NULL OR COtext1 = '')
AND (COtext2 IS NULL OR COtext2 = '')

-- D: missing everything
UPDATE tblFT_Badges
SET alpha = 'D'
WHERE (Title IS NULL OR Title = '')
AND (COtext1 IS NULL OR COtext1 = '')
AND (COtext2 IS NULL OR COtext2 = '')

-- E: missing title only
UPDATE tblFT_Badges
SET alpha = 'E'
WHERE (Title IS NULL OR Title = '')
AND COtext1 IS NOT NULL AND COtext1 <> ''
AND COtext2 IS NOT NULL AND COtext2 <> ''

-- F: missing title AND COtext 2
UPDATE tblFT_Badges
SET alpha = 'F'
WHERE (Title IS NULL OR Title = '')
AND COtext1 IS NOT NULL AND COtext1 <> ''
AND (COtext2 IS NULL OR COtext2 = '')

-- G: missing COtext1 only
UPDATE tblFT_Badges
SET alpha = 'G'
WHERE Title IS NOT NULL AND Title <> ''
AND COtext2 IS NOT NULL AND COtext2 <> ''
AND (COtext1 IS NULL OR COtext1 = '')

--// Now update the Template name based off alpha values
UPDATE tblFT_Badges
SET template = REPLACE(template, 'X.gp', alpha + '.gp')
WHERE template LIKE '%X.gp'
AND alpha IS NOT NULL

UPDATE tblFT_Badges
SET template = STUFF(template, 53, 1, 'X')
WHERE 
(template NOT LIKE '%X-0%' AND template LIKE '%-0%')
OR
(template NOT LIKE '%X-1%' AND template LIKE '%-1%')
OR
(template NOT LIKE '%X-2%' AND template LIKE '%-2%')
OR
(template NOT LIKE '%X-3%' AND template LIKE '%-3%')
OR
(template NOT LIKE '%X-4%' AND template LIKE '%-4%')
OR
(template NOT LIKE '%X-5%' AND template LIKE '%-5%')
OR
(template NOT LIKE '%X-6%' AND template LIKE '%-6%')
OR
(template NOT LIKE '%X-7%' AND template LIKE '%-7%')
OR
(template NOT LIKE '%X-8%' AND template LIKE '%-8%')
OR
(template NOT LIKE '%X-9%' AND template LIKE '%-9%')

--// Mark rows as clean.
UPDATE tblFT_Badges
SET exportStatus = 'Clean'
WHERE exportStatus = 'Dirty'

--// Initiate rows for export.
UPDATE tblFT_Badges
SET exportStatus = 'Ready for Export'
WHERE
exportStatus = 'Clean'
AND ordersProductsID IN
	-- get non-exported products available for FT
	(SELECT [ID]
	FROM tblOrders_Products
	WHERE deleteX <> 'yes'
	AND [ID] IS NOT NULL
	AND fastTrak_imageFile_exported = 0
	AND orderID IN
		(SELECT orderID 
		FROM tblOrders 
		WHERE orderStatus <> 'cancelled'
		AND orderStatus <> 'failed'
		AND orderStatus <> 'Waiting For Payment'
		AND orderStatus <> 'GTG-Waiting For Payment'
		AND orderStatus <> 'Pending'
		AND orderID > 444333222))
OR
exportStatus = 'Clean'
AND ordersProductsID IN
	-- get resubmitted products available for FT
	(SELECT [ID]
	FROM tblOrders_Products
	WHERE deleteX <> 'yes'
	AND [ID] IS NOT NULL
	AND fastTrak_resubmit = 1
	AND fastTrak_reimage = 1
	AND orderID IN
		(SELECT orderID 
		FROM tblOrders 
		WHERE orderStatus <> 'cancelled'
		AND orderStatus <> 'failed'
		AND orderStatus <> 'Waiting For Payment'
		AND orderStatus <> 'GTG-Waiting For Payment'
		AND orderStatus <> 'Pending'
		AND orderID > 444333222))

--// added the orderNos below as testing on 10/22, JF -- added back in 7/17/18, jf.
DELETE FROM tblFT_Badges 
WHERE contact LIKE '%Spredsheet%' AND logFilePath NOT LIKE '%HOM357494%'
OR contact LIKE '%Spreadsheet%' AND logFilePath NOT LIKE '%HOM357494%'
OR contact LIKE '%Email%' AND logFilePath NOT LIKE '%HOM357494%'
OR contact LIKE '%E-mail%' AND logFilePath NOT LIKE '%HOM357494%'
OR contact LIKE '%Excel%' AND logFilePath NOT LIKE '%HOM357494%'

--// Create tblFT_Badges Export file (to be used by SSIS, deduped as per Production's needs)
DELETE FROM tblFT_Badges_forExport
INSERT INTO tblFT_Badges_forExport (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, contact, title, COtextAll, COtext1, COtext2, RO, fastTrak_resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3)

SELECT DISTINCT
template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, contact, title, COtextAll, COtext1, COtext2, RO, fastTrak_resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3
FROM tblFT_Badges
WHERE exportStatus = 'Ready for Export'
ORDER BY fastTrak_resubmit DESC, fastTrak_shippingLabelOption1 DESC, fastTrak_shippingLabelOption2 DESC, fastTrak_shippingLabelOption3 DESC