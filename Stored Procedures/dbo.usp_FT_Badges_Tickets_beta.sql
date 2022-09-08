CREATE PROC [dbo].[usp_FT_Badges_Tickets_beta]

AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		01/01/2015
-- Purpose		Generates data for ticket in FT automation.
--						TESTING
-------------------------------------------------------------------------------
-- Modification History
-- 08/03/16	    created.
-- 02/01/18		updated for canvas, jf.
-- 03/02/18		added union subquery in initial section (eck), jf.
-- 03/06/18		denote canvas OPID for proper display of images on ticket, jf
-- 03/06/18		added image path creation for canvas OPIDs (near bottom of sproc), jf
-- 03/15/18		removed "AND p.fastTrak_preventTicket = 0" from initial queries that poulate tblFT_Badges_Tickets_beta. I did this 
--						because it is redundant to the fact that if an OPID exists in tblFT_Badges_REC or tblFT_Badges_OVAL, then
--						by default, it should get a ticket. But more importantly, the resubmission process may have not been resetting
--						this value properly, which needs investigation. In the meantime, I commented it out. jf.
-------------------------------------------------------------------------------
SET NOCOUNT ON;

BEGIN TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @stamp varchar(255)
SET @stamp = (SELECT CONVERT(VARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / TICKETS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_Tickets_beta
INSERT INTO tblFT_Badges_Tickets_beta 
(template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, 
color, [image], frame, frame_symbol, [name], templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit)

SELECT DISTINCT
'Macintosh HD:Users:duffman:Desktop:Name Badge Central:Group Pictures:NameBadge_JobTicket.qxp' AS 'template', 
'NameBadge_JobTicket' AS 'DDFname',
'Macintosh HD:GBS Hot Folder:Output:ImposedFiles:' + @stamp + '_T.pdf' as 'outputPath', 
'Macintosh HD:GBS Hot Folder:Output:Logs:' + @stamp + '_T.log' as 'logFilePath', 
'Graphic Business Solutions' as 'outputStyle', 
a.orderNo AS 'orderNo',
p.productQuantity AS 'qty',
9 AS 'color',
a.orderNo + '_' + CONVERT(VARCHAR(50), p.[ID]) + '.pdf' AS 'image',
'XX.eps' AS 'frame',
'X' AS 'frame_symbol',
SUBSTRING(z.textValue, 1, 30) AS 'name',
'shape_template.gp' AS 'templateFile',
p.[ID] AS 'OPPO_ordersProductsID',
p.productCode AS 'productCode',
'isFALSE',
p.fastTrak_shippingLabelOption1, p.fastTrak_shippingLabelOption2, p.fastTrak_shippingLabelOption3, p.fastTrak_resubmit
FROM tblCustomers_ShippingAddress a 
INNER JOIN tblOrders o 
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p 
	ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z 
	ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND z.optionCaption LIKE '%Name:%'
AND z.deleteX <> 'yes'
--AND p.fastTrak_preventTicket = 0 
AND p.ID IN
	 (SELECT ordersproductsID 
	 FROM tblFT_Badges_REC_beta
	 UNION ALL
	 SELECT ordersproductsID 
	 FROM tblFT_Badges_OVAL_beta)
GROUP BY a.orderNo, p.productQuantity, z.textValue, p.[ID], p.productCode, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit

--CANVAS / TICKETS -------------------------------------------------------------------
INSERT INTO tblFT_Badges_Tickets_beta 
(template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, 
color, [image], frame, frame_symbol, name, templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit)

SELECT DISTINCT
'Macintosh HD:Users:duffman:Desktop:Name Badge Central:Group Pictures:NameBadge_JobTicket.qxp' AS 'template', 
'NameBadge_JobTicket' AS 'DDFname',
'Macintosh HD:GBS Hot Folder:Output:ImposedFiles:' + @stamp + '_T.pdf' as 'outputPath', 
'Macintosh HD:GBS Hot Folder:Output:Logs:' + @stamp + '_T.log' as 'logFilePath', 
'Graphic Business Solutions' as 'outputStyle', 
a.orderNo AS 'orderNo',
p.productQuantity AS 'qty',
9 AS 'color',
a.orderNo + '_' + CONVERT(VARCHAR(50), p.[ID]) + '.pdf' AS 'image',
'XX.eps' AS 'frame',
'X' AS 'frame_symbol',
'CANVAS' AS 'name',
'shape_template.gp' AS 'templateFile',
p.[ID] AS 'OPPO_ordersProductsID',
p.productCode AS 'productCode',
'isFALSE',
p.fastTrak_shippingLabelOption1, p.fastTrak_shippingLabelOption2, p.fastTrak_shippingLabelOption3, p.fastTrak_resubmit
FROM tblCustomers_ShippingAddress a 
INNER JOIN tblOrders o 
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p 
	ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z 
	ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND z.deleteX <> 'yes'
AND z.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
--AND p.fastTrak_preventTicket = 0
AND p.ID IN
	 (SELECT ordersproductsID 
	 FROM tblFT_Badges_REC_beta
	 UNION ALL
	 SELECT ordersproductsID 
	 FROM tblFT_Badges_OVAL_beta)
GROUP BY a.orderNo, p.productQuantity, p.[ID], p.productCode, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// Fix productQTY if there is a different value in tblOrders_Products.fastTrak_newQTY than the original QTY.
UPDATE tblFT_Badges_Tickets_beta
SET QTY = b.fastTrak_newQTY
FROM tblFT_Badges_Tickets_beta a
INNER JOIN tblOrders_Products b
	ON a.OPPO_ordersProductsID = b.ID
WHERE QTY <> b.fastTrak_newQTY
AND b.fastTrak_newQTY IS NOT NULL
AND b.fastTrak_newQTY <> 0

--// Fix color sequencing
IF OBJECT_ID(N'tblFT_Badges_ColorSequencer_beta', N'U') IS NOT NULL 
DROP TABLE tblFT_Badges_ColorSequencer_beta

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[tblFT_Badges_ColorSequencer_beta]
([PKID] [int] IDENTITY(1,1) NOT NULL, [orderNo] [nvarchar](50) NULL) 
ON [PRIMARY]

INSERT INTO tblFT_Badges_ColorSequencer_beta (orderNo)
SELECT DISTINCT orderNo
FROM tblFT_Badges_Tickets_beta
ORDER BY orderNo ASC

UPDATE tblFT_Badges_Tickets_beta
SET color = b.PKID
FROM tblFT_Badges_Tickets_beta a
INNER JOIN [tblFT_Badges_ColorSequencer_beta] b
	ON a.orderNo = b.orderNo

--// Fix templateFile value
UPDATE tblFT_Badges_Tickets_beta
SET templateFile = 'oval_template.gp'
WHERE SUBSTRING(productCode, 5, 1) = 'O'

UPDATE tblFT_Badges_Tickets_beta
SET templateFile = 'rectangle_template.gp'
WHERE SUBSTRING(productCode, 5, 1) = 'R'

UPDATE tblFT_Badges_Tickets_beta
SET templateFile = ''
WHERE templateFile = 'shape_template.gp'

--// Fix frame_symbol values
UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'F'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Frameless')

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'K'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Black')

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'S'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Silver')

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'G'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Gold')

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'D'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Bling')

-- //deal with badge that have more than one frame color chosen per badge (MIXED) (112514 JF)
TRUNCATE TABLE tblFT_Badges_Mixed_beta
INSERT INTO tblFT_Badges_Mixed_beta (ordersProductsID, optionCaption)
SELECT DISTINCT ordersProductsID, optionCaption
FROM tblOrdersProducts_productOptions
WHERE deleteX <> 'yes'
AND optionGroupCaption = 'Frame'

TRUNCATE TABLE tblFT_Badges_Mixed_Clean_beta
INSERT INTO tblFT_Badges_Mixed_Clean_beta (ordersProductsID, IDcounter)
SELECT ordersProductsID, COUNT(ordersProductsID) as 'IDcounter'
FROM tblFT_Badges_Mixed_beta
GROUP BY ordersProductsID
HAVING COUNT(ordersProductsID) > 1
ORDER BY COUNT(ordersProductsID)  DESC

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'M'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_Mixed_Clean_beta
	WHERE IDcounter > 1)

--// deal with unknown frames
UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = ''
WHERE frame_symbol = 'X'

--// Fix frame values
--ovals first
UPDATE tblFT_Badges_Tickets_beta
SET frame = 'OF.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'F'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'OK.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'K'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'OS.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'S'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'OG.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'G'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'OD.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'D'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'OM.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'M'

UPDATE tblFT_Badges_Tickets_beta
SET frame = ''
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = ''

--rectangles next
UPDATE tblFT_Badges_Tickets_beta
SET frame = 'RF.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'F'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'RK.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'K'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'RS.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'S'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'RG.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'G'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'RD.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'D'

UPDATE tblFT_Badges_Tickets_beta
SET frame = 'RM.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'M'

UPDATE tblFT_Badges_Tickets_beta
SET frame = ''
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = ''

--// Now that frames are updated, go back to frame_symbol and put it in to English
--// "D"="Bling";"F"="Frameless";"K"="Black";"S"="Silver";"G"="Gold" or "MIX" = multi frame order

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'Frameless'
WHERE frame_symbol = 'F'

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'Bling'
WHERE frame_symbol = 'D'

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'Black'
WHERE frame_symbol = 'K'

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'Silver'
WHERE frame_symbol = 'S'

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'Gold'
WHERE frame_symbol = 'G'

UPDATE tblFT_Badges_Tickets_beta
SET frame_symbol = 'MIX'
WHERE frame_symbol = 'M'

--// deal with label-less resubmits (these are now set to "0" in IMPO_postSSIS, as of 112514 JF)
UPDATE tblFT_Badges_Tickets_beta
SET resubmit = 'isTRUE'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// code below added to prep data by resub.
TRUNCATE TABLE tblFT_Badges_Tickets_forExport_beta
INSERT INTO tblFT_Badges_Tickets_forExport_beta (template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, color, [image], frame, frame_symbol, [name], templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit, canvas)
SELECT DISTINCT
template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, color, [image], frame, frame_symbol, [name], templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, resubmit, '0'
FROM tblFT_Badges_Tickets_beta a
ORDER BY a.resubmit DESC, orderNo ASC, OPPO_ordersProductsID ASC

/*
--// update formula field "mix" which is used to determine badge frame colors like so:

1xK.1xS.2xG.4xBLG	

f	frameless	
k	black
s	silver
g	gold
blg	bling
*/

UPDATE tblFT_Badges_Tickets_forExport_beta
SET mix = ''

UPDATE tblFT_Badges_Tickets_forExport_beta
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Frameless', 'xF')
FROM tblFT_Badges_Tickets_forExport_beta a 
INNER JOIN tblOrdersProducts_productOptions b
	ON SUBSTRING(a.[image], 11, 9) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Frameless'

UPDATE tblFT_Badges_Tickets_forExport_beta
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Black', 'xK')
FROM tblFT_Badges_Tickets_forExport_beta a 
INNER JOIN tblOrdersProducts_productOptions b
	ON SUBSTRING(a.[image], 11, 9) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Black'

UPDATE tblFT_Badges_Tickets_forExport_beta
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Silver', 'xS')
FROM tblFT_Badges_Tickets_forExport_beta a 
INNER JOIN tblOrdersProducts_productOptions b
	ON SUBSTRING(a.[image], 11, 9) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Silver'

UPDATE tblFT_Badges_Tickets_forExport_beta
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Gold', 'xG')
FROM tblFT_Badges_Tickets_forExport_beta a 
INNER JOIN tblOrdersProducts_productOptions b
	ON SUBSTRING(a.[image], 11, 9) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Gold'

UPDATE tblFT_Badges_Tickets_forExport_beta
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Bling', 'xBLG')
FROM tblFT_Badges_Tickets_forExport_beta a 
INNER JOIN tblOrdersProducts_productOptions b
	ON SUBSTRING(a.[image], 11, 9) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Bling'

--Denotes canvas OPID for proper display of images on ticket (non-bit b/c of data conversion in SSIS issues)
UPDATE tblFT_Badges_Tickets_forExport_beta
SET canvas = '1'
WHERE OPPO_ordersProductsID IN
	(SELECT ordersproductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Canvas')

--Updates canvas OPID's path for proper display on ticket
UPDATE tblFT_Badges_Tickets_forExport_beta
SET [image] = REPLACE(x.textValue, '/InProduction/General/', '')
FROM tblFT_Badges_Tickets_forExport_beta a
INNER JOIN tblOrdersProducts_productOptions x
	ON a.OPPO_ordersProductsID = x.ordersProductsID
WHERE x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' 

END TRY
BEGIN CATCH

--Capture errors if they happen
EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH