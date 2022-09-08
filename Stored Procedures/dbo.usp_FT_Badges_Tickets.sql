CREATE PROC [dbo].[usp_FT_Badges_Tickets]

AS
/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		01/01/2015
Purpose		Generates data for ticket in FT automation.
-------------------------------------------------------------------------------
Modification History
08/03/16	created.
02/01/18		updated for canvas, jf.
03/02/18		added union subquery in initial section (eck), jf.
03/06/18	denote canvas OPID for proper display of images on ticket, jf
03/06/18	added image path creation for canvas OPIDs (near bottom of sproc), jf
03/15/18	removed "AND p.fastTrak_preventTicket = 0" from initial queries that poulate tblFT_Badges_Tickets. I did this 
				because it is redundant to the fact that if an OPID exists in tblFT_Badges_REC or tblFT_Badges_OVAL, then
				by default, it should get a ticket. But more importantly, the resubmission process may have not been resetting
				this value properly, which needs investigation. In the meantime, I commented it out. jf.
04/05/18	Added IF statement to DROP logic for color sequencing section, jf.
04/05/18	Added "AND b.fastTrak_newQTY <> 0" to QTY check near LN 135, jf.
05/23/18		updated both UNION ALL sections to include frameless tables, jf.
05/23/18		added line to CANVAS initial query b/c CANVAS OPIDs are starting to come in with corrected information that negates this section of code, jf
12/28/18		Updated for NOP, jf.
02/04/19		Updated Name for NOP, jf.
02/7/19		update line 569 to properly set canvas
05/14/19	Updated to PNG rather than PDF for 2nd to last statement in sproc, jf.
06/18/19	Removed unwanted characters from NAME column, last statement in sproc, jf.
06/28/20	Added Bad Character stripper to name
07/07/20	Near LN318, fixed an issue where duplicate OPPOs per OPID are appearing (probably due to OPPO work (Bindl)); see in-line notes, jf.
01/11/21	BS, Iframe conversion
03/25/21	BS, removed intranetPDF AGAIN
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

BEGIN TRY

DECLARE @stamp varchar(255)
SET @stamp = (SELECT CONVERT(VARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(VARCHAR(10), DATEPART(MS, getDate())))

--////////////////////////////////////////////////////////////////////////////////////////// OLDSCHOOL / TICKETS
TRUNCATE TABLE tblFT_Badges_Tickets
INSERT INTO tblFT_Badges_Tickets 
(template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, 
color, [image], frame, frame_symbol, [NAME], templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, 
fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit)

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
SUBSTRING([dbo].[fn_BadCharacterStripper](z.textValue), 1, 30) AS 'name',
'shape_template.gp' AS 'templateFile',
p.[ID] AS 'OPPO_ordersProductsID',
p.productCode AS 'productCode',
'isFALSE',
p.fastTrak_shippingLabelOption1, p.fastTrak_shippingLabelOption2, p.fastTrak_shippingLabelOption3, p.fastTrak_resubmit
FROM tblCustomers_ShippingAddress a 
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND (z.optionCaption LIKE '%Name:%' OR z.optionCaption = 'Agent Name')
AND z.deleteX <> 'yes'
AND p.ID IN
	 (SELECT ordersproductsID 
	 FROM tblFT_Badges_REC
	 UNION ALL
	 SELECT ordersproductsID 
	 FROM tblFT_Badges_OVAL
	 UNION ALL
	 SELECT ordersProductsID
	 FROM tblFT_Badges_REC_Frameless
	 UNION ALL
	 SELECT ordersProductsID
	 FROM tblFT_Badges_OVAL_Frameless)
GROUP BY a.orderNo, p.productQuantity, z.textValue, p.[ID], p.productCode, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, 
fastTrak_shippingLabelOption3, fastTrak_resubmit

--////////////////////////////////////////////////////////////////////////////////////////// CANVAS / TICKETS
INSERT INTO tblFT_Badges_Tickets 
(template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, 
color, [image], frame, frame_symbol, [NAME], templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, 
fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, fastTrak_resubmit)

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
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND z.deleteX <> 'yes'
AND z.optionCaption IN ('CanvasHiResFront File Name') --bjs iframe conversion  --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND p.ID IN
	 (SELECT ordersproductsID 
	 FROM tblFT_Badges_REC
	 UNION ALL
	 SELECT ordersproductsID 
	 FROM tblFT_Badges_OVAL
	 UNION ALL
	 SELECT ordersProductsID
	 FROM tblFT_Badges_REC_Frameless
	 UNION ALL
	 SELECT ordersProductsID
	 FROM tblFT_Badges_OVAL_Frameless)
AND p.ID NOT IN --added this line b/c CANVAS OPIDs are starting to come in with corrected information that negates this section of code, jf
	(SELECT OPPO_ordersProductsID
	FROM tblFT_Badges_Tickets)
GROUP BY a.orderNo, p.productQuantity, p.[ID], p.productCode, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, 
fastTrak_shippingLabelOption3, fastTrak_resubmit

--////////////////////////////////////////////////////////////////////////////////////////// QTY, SEQUENCING & TEMPLATE FIXES
--// Fix productQTY if there is a different value in tblOrders_Products.fastTrak_newQTY than the original QTY.
UPDATE tblFT_Badges_Tickets
SET QTY = b.fastTrak_newQTY
FROM tblFT_Badges_Tickets a
INNER JOIN tblOrders_Products b
	ON a.OPPO_ordersProductsID = b.ID
WHERE QTY <> b.fastTrak_newQTY
AND b.fastTrak_newQTY IS NOT NULL
AND b.fastTrak_newQTY <> 0

--// Fix color sequencing
IF OBJECT_ID(N'tblFT_Badges_ColorSequencer', N'U') IS NOT NULL 
DROP TABLE tblFT_Badges_ColorSequencer

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[tblFT_Badges_ColorSequencer]
([PKID] [int] IDENTITY(1,1) NOT NULL, [orderNo] [nvarchar](50) NULL) 
ON [PRIMARY]

INSERT INTO tblFT_Badges_ColorSequencer (orderNo)
SELECT DISTINCT orderNo
FROM tblFT_Badges_Tickets
ORDER BY orderNo ASC

UPDATE tblFT_Badges_Tickets
SET color = b.PKID
FROM tblFT_Badges_Tickets a
INNER JOIN [tblFT_Badges_ColorSequencer] b
	ON a.orderNo = b.orderNo

--// Fix templateFile value
UPDATE tblFT_Badges_Tickets
SET templateFile = 'oval_template.gp'
WHERE SUBSTRING(productCode, 5, 1) = 'O'

UPDATE tblFT_Badges_Tickets
SET templateFile = 'rectangle_template.gp'
WHERE SUBSTRING(productCode, 5, 1) = 'R'

UPDATE tblFT_Badges_Tickets
SET templateFile = ''
WHERE templateFile = 'shape_template.gp'

--////////////////////////////////////////////////////////////////////////////////////////// FRAME SYMBOLS
--// Fix frame_symbol values - CLASSIC -----------------------------------------------------
UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'F'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Frameless')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'K'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Black')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'S'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Silver')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'G'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Gold')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'D'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Frame'
	AND optionCaption = 'Bling')

--// Fix frame_symbol values - NOP -----------------------------------------------------
UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'F'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption = 'Frame Style'
	AND textValue = 'Frameless')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'K'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption = 'Frame Style'
	AND textValue = 'Black')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'S'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption = 'Frame Style'
	AND textValue = 'Silver')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'G'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption = 'Frame Style'
	AND textValue = 'Gold')

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'D'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption = 'Frame Style'
	AND textValue LIKE 'Bling%') -- currently, NOP is: 'Bling [+$12.00]'. Because this $ value might change, using a LIKE statement.

--// Mixed - CLASSIC -----------------------------------------------------
TRUNCATE TABLE tblFT_Badges_Mixed
INSERT INTO tblFT_Badges_Mixed (ordersProductsID, optionCaption)
SELECT DISTINCT ordersProductsID, optionCaption
FROM tblOrdersProducts_productOptions
WHERE deleteX <> 'yes'
AND optionGroupCaption = 'Frame'

TRUNCATE TABLE tblFT_Badges_Mixed_Clean
INSERT INTO tblFT_Badges_Mixed_Clean (ordersProductsID, IDcounter)
SELECT ordersProductsID, COUNT(ordersProductsID) AS 'IDcounter'
FROM tblFT_Badges_Mixed
GROUP BY ordersProductsID
HAVING COUNT(ordersProductsID) > 1
ORDER BY COUNT(ordersProductsID) DESC

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'M'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_Mixed_Clean
	WHERE IDcounter > 1)

--// Mixed - NOP -----------------------------------------------------
TRUNCATE TABLE tblFT_Badges_Mixed
INSERT INTO tblFT_Badges_Mixed (ordersProductsID, optionCaption)
SELECT DISTINCT ordersProductsID, LEFT(textValue, 255) AS optionCaption
FROM tblOrdersProducts_productOptions
WHERE deleteX <> 'yes'
AND optionCaption = 'Frame Style'
AND optionQTY <> 0 --Some OPPO duplication during ETL causes multiple "Frame Style" optionCaptions per OPID; the bad ones have QTY=0, so this pulling them out, 07JUL2020JF.

TRUNCATE TABLE tblFT_Badges_Mixed_Clean
INSERT INTO tblFT_Badges_Mixed_Clean (ordersProductsID, IDcounter)
SELECT ordersProductsID, COUNT(ordersProductsID) AS 'IDcounter'
FROM tblFT_Badges_Mixed
GROUP BY ordersProductsID
HAVING COUNT(ordersProductsID) > 1
ORDER BY COUNT(ordersProductsID) DESC

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'M'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_Mixed_Clean
	WHERE IDcounter > 1)

--// deal with unknown frames
UPDATE tblFT_Badges_Tickets
SET frame_symbol = ''
WHERE frame_symbol = 'X'

--////////////////////////////////////////////////////////////////////////////////////////// FRAME VALUES
--OVAL
UPDATE tblFT_Badges_Tickets
SET frame = 'OF.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'F'

UPDATE tblFT_Badges_Tickets
SET frame = 'OK.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'K'

UPDATE tblFT_Badges_Tickets
SET frame = 'OS.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'S'

UPDATE tblFT_Badges_Tickets
SET frame = 'OG.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'G'

UPDATE tblFT_Badges_Tickets
SET frame = 'OD.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'D'

UPDATE tblFT_Badges_Tickets
SET frame = 'OM.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = 'M'

UPDATE tblFT_Badges_Tickets
SET frame = ''
WHERE SUBSTRING(productCode, 5, 1) = 'O'
AND frame_symbol = ''

--Rectangle
UPDATE tblFT_Badges_Tickets
SET frame = 'RF.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'F'

UPDATE tblFT_Badges_Tickets
SET frame = 'RK.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'K'

UPDATE tblFT_Badges_Tickets
SET frame = 'RS.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'S'

UPDATE tblFT_Badges_Tickets
SET frame = 'RG.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'G'

UPDATE tblFT_Badges_Tickets
SET frame = 'RD.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'D'

UPDATE tblFT_Badges_Tickets
SET frame = 'RM.eps'
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = 'M'

UPDATE tblFT_Badges_Tickets
SET frame = ''
WHERE SUBSTRING(productCode, 5, 1) = 'R'
AND frame_symbol = ''

--// Now that frames are updated, go back to frame_symbol and put it in to English
--// "D"="Bling";"F"="Frameless";"K"="Black";"S"="Silver";"G"="Gold" or "MIX" = multi frame order

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'Frameless'
WHERE frame_symbol = 'F'

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'Bling'
WHERE frame_symbol = 'D'

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'Black'
WHERE frame_symbol = 'K'

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'Silver'
WHERE frame_symbol = 'S'

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'Gold'
WHERE frame_symbol = 'G'

UPDATE tblFT_Badges_Tickets
SET frame_symbol = 'MIX'
WHERE frame_symbol = 'M'

--////////////////////////////////////////////////////////////////////////////////////////// RESUBS
--// deal with label-less resubmits (these are now set to "0" in IMPO_postSSIS, as of 112514 JF)
UPDATE tblFT_Badges_Tickets
SET resubmit = 'isTRUE'
WHERE OPPO_ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// code below added to prep data by resub.
TRUNCATE TABLE tblFT_Badges_Tickets_forExport
INSERT INTO tblFT_Badges_Tickets_forExport (template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, color, [image], frame, 
frame_symbol, [NAME], templateFile, OPPO_ordersProductsID, productCode, resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, 
fastTrak_shippingLabelOption3, fastTrak_resubmit, canvas)
SELECT DISTINCT
template, DDFname, outputPath, logFilePath, outputStyle, orderNo, qty, color, [image], frame, frame_symbol, [NAME], templateFile, OPPO_ordersProductsID, 
productCode, resubmit, fastTrak_shippingLabelOption1, fastTrak_shippingLabelOption2, fastTrak_shippingLabelOption3, resubmit, '1'
FROM tblFT_Badges_Tickets a
ORDER BY a.resubmit DESC, orderNo ASC, OPPO_ordersProductsID ASC


--////////////////////////////////////////////////////////////////////////////////////////// CANVAS
--Denotes canvas OPID for proper display of images on ticket (non-bit b/c of data conversion in SSIS issues)
--UPDATE tblFT_Badges_Tickets_forExport
--SET canvas = '1'
--WHERE OPPO_ordersProductsID IN
--	(SELECT ordersproductsID
--	FROM tblOrdersProducts_productOptions
--	WHERE optionCaption = 'Canvas' OR optionCaption IN ('CC State User ID', 'CC State ID', 'Intranet PDF'))
--OR [NAME] = 'CANVAS'

--update the name value on NOP Canvas OPIDs
UPDATE a
SET [NAME] = oppx.textValue
FROM tblFT_Badges_Tickets_forExport a
INNER JOIN tblOrdersProducts_productOptions oppx ON a.OPPO_ordersProductsID = oppx.ordersProductsID
WHERE a.[NAME] = 'CANVAS'
AND oppx.optionCaption = 'Customer Name'

--Updates canvas OPID's path for proper display on ticket
UPDATE tblFT_Badges_Tickets_forExport
SET [image] = REPLACE(x.textValue, '/InProduction/General/', '')
FROM tblFT_Badges_Tickets_forExport a
INNER JOIN tblOrdersProducts_productOptions x ON a.OPPO_ordersProductsID = x.ordersProductsID
WHERE x.deleteX <> 'yes'
AND x.optionCaption IN ('CanvasHiResFront File Name') --bjs iframe conversion

--Update the NAME field to get rid of non [A-Z] characters
UPDATE tblFT_Badges_Tickets_forExport
SET [name] = dbo.fnStripInvalidCongDongCharacters ([name])
WHERE [name] IS NOT NULL

--////////////////////////////////////////////////////////////////////////////////////////// MIXTAPE
/*
Update formula field "mix" which is used to determine badge frame colors like so: 
		1xK.1xS.2xG.4xBLG	
Where:

		f		frameless	
		k		black
		s		silver
		g		gold
		blg		bling
*/

UPDATE tblFT_Badges_Tickets_forExport SET mix = ''

--// Mixed - CLASSIC -----------------------------------------------------
UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Frameless', 'xF')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Frameless'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Black', 'xK')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Black'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Silver', 'xS')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Silver'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Gold', 'xG')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Gold'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), optionCaption), 'Bling', 'xBLG')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Bling'

--// Mixed - NOP -----------------------------------------------------
UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), LEFT(textValue, 50)), 'Frameless', 'xF')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.textValue = 'Frameless'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), LEFT(textValue, 50)), 'Black', 'xK')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.textValue = 'Black'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), LEFT(textValue, 50)), 'Silver', 'xS')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.textValue = 'Silver'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), LEFT(textValue, 50)), 'Gold', 'xG')
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.textValue = 'Gold'

UPDATE tblFT_Badges_Tickets_forExport
SET mix = mix + REPLACE(CONVERT(NVARCHAR(50), optionQTY) + CONVERT(NVARCHAR(50), LEFT(textValue, 5)), 'Bling', 'xBLG') --only pull the left 5 characters for NOP Blings.
FROM tblFT_Badges_Tickets_forExport a 
INNER JOIN tblOrdersProducts_productOptions b ON TRY_CONVERT(int,SUBSTRING(a.[image], 11, 9)) = b.ordersProductsID
WHERE a.frame_symbol = 'MIX'
AND b.deleteX <> 'yes'
AND b.textValue LIKE 'Bling%'

/*
--this is the code that SSIS uses for export
SELECT DISTINCT
orderNo, qty, color, [image], frame, frame_symbol, mix, [NAME], templateFile, resubmit, canvas, OPPO_ordersProductsID
FROM tblFT_Badges_Tickets_forExport a
ORDER BY a.resubmit DESC, orderNo ASC, OPPO_ordersProductsID ASC
*/

END TRY
BEGIN CATCH

--Capture errors if they happen
EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH