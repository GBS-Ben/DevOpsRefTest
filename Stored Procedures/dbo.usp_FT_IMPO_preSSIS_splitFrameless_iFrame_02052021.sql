CREATE PROC [dbo].[usp_FT_IMPO_preSSIS_splitFrameless_iFrame_02052021]
AS
/*
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/25/16
-- Purpose     Preps IMPO data for production. 2 sections: OVAL and REC.
-------------------------------------------------------------------------------
-- Modification History

-- 10/25/16		Created.
-- 02/21/18		Updated to include CANVAS products and bypass IMAGE.
-- 02/27/18		Updated to reflect new path:
							NEW:	Archives:webstores:OPC:onrzye-NBTHOB-r421416-s1.pdf 
							OLD: 	MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:HOM704291_445466480.pdf
--02/28/18		Removed the following clauses from CANVAS checks because it does not go thru IMAGE step, jf:
							AND op.fastTrak_preventImposition = 0
							AND op.fastTrak_resubmit = 0
--03/01/18		Capitalized "Archives" as per Stolze, jf.
--03/01/18		Added fastTrak_newQTY <> 0 (just search for it, it was only looking for NULL), jf.
--03/22/18		Updated export table structure and sort choices to accommodate Canvas Badges for both the OVAL and REC DBs, jf.
--04/09/18		Added WFP to orderstatus check, throughout, jf.
--04/11/18		Add inner join on integer to iterate canvas badge rows, jf.
--05/21/18		Split out to: OVAL, REC, FRAMELESS OVAL, FRAMELESS REC, jf.
--05/31/18		Added all MIX-related code to deal with OPIDs that have both frameless and non-frameless iterations within the OPIDS, thus having different pUnits that go through different production flows, jf.
-------------------------------------------------------------------------------
*/
SET XACT_ABORT ON

BEGIN TRY
    BEGIN TRANSACTION
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ MIX OPID WORK (BEGIN)
--Before any OVAL/REC/fOVAL/fREC INSERTS are done, this section will prep badge OPIDs to properly identify frame-type for any OPID that has...
--... a frameless optionID in OPPO (this could be solo-frameless or mixed with non-frameless on a single OPID).
/*
Frame Type		optionID
Frameless			455
Silver				362
Black				359
Bling				360
Gold  				361
*/

--this table will be used as source data for the INSERTS in relation to MIXED OPIDs
TRUNCATE TABLE tblBadges_Splitter
INSERT INTO tblBadges_Splitter (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, 
COtext1, COtext2, RO, orderNo, pkid, OPPO_ordersProductsID, QTY, orderID, productCode)

SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, 
COtext1, COtext2, RO, orderNo, pkid, OPPO_ordersProductsID, QTY, orderID, productCode
FROM tblBadges
ORDER BY sortNo

--this table will capture the MIXED OPIDs so that we can cycle through them and split them out of the un-normalized OPPO table structure
IF OBJECT_ID(N'tblBadges_Splitter_Bounce', N'U') IS NOT NULL 
DROP TABLE tblBadges_Splitter_Bounce

CREATE TABLE tblBadges_Splitter_Bounce (
 RowID INT IDENTITY(1, 1), 
OPPO_ordersProductsID INT
)

DECLARE 
@NumberRecordsMIX INT, 
@RowCountMIX INT

DECLARE @OPPO_ordersProductsID INT = 0

DECLARE
@COUNT_BLACK INT = 0,
@COUNT_BLING INT = 0,
@COUNT_GOLD INT = 0,
@COUNT_SILVER INT = 0,
@COUNT_FRAMELESS INT = 0,
@SQLStatement NVARCHAR(4000)

--insert OPIDs which are split between frameless and non-frameless badge types on a single OPID (Mixed Badges)
INSERT INTO tblBadges_Splitter_Bounce (OPPO_ordersProductsID)
SELECT DISTINCT OPPO_ordersProductsID
FROM tblBadges_Splitter
WHERE OPPO_ordersProductsID
IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = 455)
AND OPPO_ordersProductsID
IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID IN (359, 360, 361, 362))

SET @NumberRecordsMIX = @@ROWCOUNT
SET @RowCountMIX = 1

WHILE @RowCountMIX <= @NumberRecordsMIX
BEGIN
 SET @OPPO_ordersProductsID = (SELECT OPPO_ordersProductsID
														 FROM tblBadges_Splitter_Bounce
														 WHERE RowID = @RowCountMIX)

 -- Set counts
 SET @COUNT_BLACK = 0
 SET @COUNT_BLACK = (SELECT optionQTY
												FROM tblOrdersProducts_ProductOptions
												WHERE deleteX <> 'yes'
												AND optionID = 359
												AND ordersProductsID = @OPPO_ordersProductsID)

IF @COUNT_BLACK IS NULL
BEGIN
	SET @COUNT_BLACK = 0
END

 SET @COUNT_BLING = 0
 SET @COUNT_BLING = (SELECT optionQTY
												FROM tblOrdersProducts_ProductOptions
												WHERE deleteX <> 'yes'
												AND optionID = 360
												AND ordersProductsID = @OPPO_ordersProductsID)

IF @COUNT_BLING IS NULL
BEGIN
	SET @COUNT_BLING = 0
END

 SET @COUNT_GOLD = 0
 SET @COUNT_GOLD = (SELECT optionQTY
												FROM tblOrdersProducts_ProductOptions
												WHERE deleteX <> 'yes'
												AND optionID = 361
												AND ordersProductsID = @OPPO_ordersProductsID)

IF @COUNT_GOLD IS NULL
BEGIN
	SET @COUNT_GOLD = 0
END

 SET @COUNT_SILVER = 0
 SET @COUNT_SILVER = (SELECT optionQTY
												FROM tblOrdersProducts_ProductOptions
												WHERE deleteX <> 'yes'
												AND optionID = 362
												AND ordersProductsID = @OPPO_ordersProductsID)

 IF @COUNT_SILVER IS NULL
BEGIN
	SET @COUNT_SILVER = 0
END

 SET @COUNT_FRAMELESS = 0
 SET @COUNT_FRAMELESS = (SELECT optionQTY
												FROM tblOrdersProducts_ProductOptions
												WHERE deleteX <> 'yes'
												AND optionID = 455
												AND ordersProductsID = @OPPO_ordersProductsID)

IF @COUNT_FRAMELESS IS NULL
BEGIN
	SET @COUNT_FRAMELESS = 0
END

-- BLACK
IF @COUNT_BLACK <> 0
BEGIN
	SET @SQLStatement = N'
			UPDATE tblBadges_Splitter
			SET oppo_PKID = b.ordersProductsID,
			oppo_frame_optionID = b.optionID,
			oppo_frame_optionCaption = b.optionCaption,
			oppo_frame_optionQty = b.optionQty
			FROM tblBadges_Splitter a
			INNER JOIN tblOrdersProducts_productOptions b
				ON a.OPPO_ordersProductsID = b.ordersProductsID
			WHERE a.OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' 
			AND b.optionID = 359
			AND a.oppo_frameless <> 1
			AND a.oppo_frame_optionID IS NULL
			AND a.sortNo IN
				(SELECT TOP '+ CONVERT(NVARCHAR(50), @COUNT_BLACK) + '  sortNo FROM tblBadges_Splitter WHERE OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' AND oppo_PKID IS NULL)'

EXEC(@SQLStatement);
END

-- BLING
IF @COUNT_BLING <> 0
BEGIN
	SET @SQLStatement = N'
			UPDATE tblBadges_Splitter
			SET oppo_PKID = b.ordersProductsID,
			oppo_frame_optionID = b.optionID,
			oppo_frame_optionCaption = b.optionCaption,
			oppo_frame_optionQty = b.optionQty
			FROM tblBadges_Splitter a
			INNER JOIN tblOrdersProducts_productOptions b
				ON a.OPPO_ordersProductsID = b.ordersProductsID
			WHERE a.OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' 
			AND b.optionID = 360
			AND a.oppo_frameless <> 1
			AND a.oppo_frame_optionID IS NULL
			AND a.sortNo IN
				(SELECT TOP '+ CONVERT(NVARCHAR(50), @COUNT_BLING) + '  sortNo FROM tblBadges_Splitter WHERE OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' AND oppo_PKID IS NULL)'

EXEC(@SQLStatement);
END

-- GOLD
IF @COUNT_GOLD <> 0
BEGIN
	SET @SQLStatement = N'
			UPDATE tblBadges_Splitter
			SET oppo_PKID = b.ordersProductsID,
			oppo_frame_optionID = b.optionID,
			oppo_frame_optionCaption = b.optionCaption,
			oppo_frame_optionQty = b.optionQty
			FROM tblBadges_Splitter a
			INNER JOIN tblOrdersProducts_productOptions b
				ON a.OPPO_ordersProductsID = b.ordersProductsID
			WHERE a.OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' 
			AND b.optionID = 361
			AND a.oppo_frameless <> 1
			AND a.oppo_frame_optionID IS NULL
			AND a.sortNo IN
				(SELECT TOP '+ CONVERT(NVARCHAR(50), @COUNT_GOLD) + '  sortNo FROM tblBadges_Splitter WHERE OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' AND oppo_PKID IS NULL)'

EXEC(@SQLStatement);
END

-- SILVER
IF @COUNT_SILVER <> 0
BEGIN
	SET @SQLStatement = N'
			UPDATE tblBadges_Splitter
			SET oppo_PKID = b.ordersProductsID,
			oppo_frame_optionID = b.optionID,
			oppo_frame_optionCaption = b.optionCaption,
			oppo_frame_optionQty = b.optionQty
			FROM tblBadges_Splitter a
			INNER JOIN tblOrdersProducts_productOptions b
				ON a.OPPO_ordersProductsID = b.ordersProductsID
			WHERE a.OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' 
			AND b.optionID = 362
			AND a.oppo_frameless <> 1
			AND a.oppo_frame_optionID IS NULL
			AND a.sortNo IN
				(SELECT TOP '+ CONVERT(NVARCHAR(50), @COUNT_SILVER) + '  sortNo FROM tblBadges_Splitter WHERE OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' AND oppo_PKID IS NULL)'

EXEC(@SQLStatement);
END

-- FRAMELESS
IF @COUNT_FRAMELESS <> 0
BEGIN
	SET @SQLStatement = N'
			UPDATE tblBadges_Splitter
			SET oppo_PKID = b.ordersProductsID,
			oppo_frame_optionID = b.optionID,
			oppo_frame_optionCaption = b.optionCaption,
			oppo_frame_optionQty = b.optionQty,
			oppo_frameless = 1
			FROM tblBadges_Splitter a
			INNER JOIN tblOrdersProducts_productOptions b
				ON a.OPPO_ordersProductsID = b.ordersProductsID
			WHERE a.OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' 
			AND b.optionID = 455
			AND a.oppo_frameless <> 1
			AND a.oppo_frame_optionID IS NULL
			AND a.sortNo IN
				(SELECT TOP '+ CONVERT(NVARCHAR(50), @COUNT_FRAMELESS) + '  sortNo FROM tblBadges_Splitter WHERE OPPO_ordersProductsID = ' + CONVERT(NVARCHAR(50), @OPPO_ordersProductsID) + ' AND oppo_PKID IS NULL)'

EXEC(@SQLStatement);
END

SET @RowCountMIX = @RowCountMIX + 1
END

IF OBJECT_ID(N'tblBadges_Splitter_Bounce', N'U') IS NOT NULL 
DROP TABLE tblBadges_Splitter_Bounce

-- tblBadges_Splitter now contains the necessary information on how an individual OPID can be comprised of both normal and frameless badges. From here, we can use this information to inform IMPO.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++MIX OPID WORK (END)

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// OVAL FILE CREATION //////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @stamp NVARCHAR(255)
SET @stamp = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / OVAL / NONMIXED -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL
INSERT INTO tblFT_Badges_OVAL (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT 
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp + '_O.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), x.OPPO_ordersProductsID) + '.pdf' as 'Badge',
x.sortNo, x.OPPO_ordersProductsID, 'isFALSE'
FROM tblBadges x
INNER JOIN tblOrders_Products op
	ON x.OPPO_ordersProductsID = op.[ID]
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE x.RO = 'O'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.sortNo <> 9999999
AND op.[ID] NOT IN --remove framless products
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, x.OPPO_ordersProductsID

--OLDSCHOOL / OVAL / MIXED -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL
INSERT INTO tblFT_Badges_OVAL (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT 
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp + '_O.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), s.OPPO_ordersProductsID) + '.pdf' as 'Badge',
i.i, s.OPPO_ordersProductsID, 'isFALSE'
FROM tblOrders o
INNER JOIN tblOrders_Products op
	ON op.orderID = o.orderID
INNER JOIN tblBadges_Splitter s
	ON op.ID = s.OPPO_ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND s.oppo_frame_optionQty
WHERE s.oppo_PKID IS NOT NULL
AND s.oppo_frameless = 0
AND SUBSTRING(s.productCode, 5, 1) = 'O'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.[ID] IN -- grab OPIDs that have Frameless pUnits within
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, s.OPPO_ordersProductsID

--CANVAS / OVAL / NONMIXED -------------------------------------------------------------------
INSERT INTO tblFT_Badges_OVAL (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp + '_O.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(textValue, '/InProduction/General/', '') AS 'Badge',
i.i, op.ID, 'isFALSE'
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
INNER JOIN tblOrdersProducts_productOptions x
	ON op.ID = x.ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND op.productQuantity 
WHERE 
op.fastTrak_productType = 'Badge'
AND SUBSTRING(op.productCode, 5, 1) = 'O'
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_OVAL
	WHERE ordersproductsID IS NOT NULL)
AND op.[ID] NOT IN --remove framless products
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, op.ID

--// 16 UP --------------------------------------------------------------------------------------
IF OBJECT_ID(N'tempPSU_resubmitQTY_OVAL', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_OVAL

CREATE TABLE tempPSU_resubmitQTY_OVAL (
RowID INT IDENTITY(1, 1), 
ordersProductsID INT,
QTY INT)

DECLARE @NumberRecords INT, @RowCount INT
DECLARE @ordersProductsID INT
DECLARE @runSQL NVARCHAR(255), @counted INT, @QTY INT, @numberToRemove INT

INSERT INTO tempPSU_resubmitQTY_OVAL (ordersProductsID, QTY)
SELECT DISTINCT [ID], fastTrak_newQTY
FROM tblOrders_Products
WHERE 
[ID] IN
	(SELECT DISTINCT ordersProductsID
	 FROM tblFT_badges_OVAL
	 WHERE ordersProductsID IS NOT NULL	)
AND fastTrak_newQTY IS NOT NULL
AND fastTrak_newQTY <> 0
AND fastTrak_newQTY <> productQuantity

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @ordersProductsID = ordersProductsID
	FROM tempPSU_resubmitQTY_OVAL
	WHERE RowID = @RowCount

	SET @QTY = (
				SELECT SUM(QTY) 
				FROM tempPSU_resubmitQTY_OVAL
				WHERE ordersProductsID = @ordersProductsID
				)

	SET @counted = (
					 SELECT COUNT(*)
					 FROM tblFT_badges_OVAL 
					 WHERE ordersProductsID = @ordersProductsID 
					)
	
	IF @QTY IS NULL
		BEGIN
			SET @RowCount = @RowCount + 1		
		END

	IF @QTY = 0
		BEGIN
			SET @RowCount = @RowCount + 1		
		END

	IF @counted IS NULL
		BEGIN
			SET @RowCount = @RowCount + 1		
		END

	IF @counted = 0
		BEGIN
			SET @RowCount = @RowCount + 1		
		END

	IF @QTY >= @counted
		BEGIN
			SET @RowCount = @RowCount + 1		
		END

	ELSE
	BEGIN
		SET @numberToRemove = @counted - @QTY

		DELETE FROM tblFT_QTYResubmit_sortNo_Cycler
		SET @runSQL = NULL
		SET @runSQL =
		'INSERT INTO tblFT_QTYResubmit_sortNo_Cycler (ordersProductsID, sortNo)
		SELECT TOP ' + CONVERT(VARCHAR(50), @numberToRemove) + ' ordersProductsID, sortNo FROM tblFT_badges_OVAL WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsID) + ' ORDER BY sortNo DESC'
		EXEC (@runSQL)


		SET @runSQL = NULL
		SET @runSQL = 'DELETE FROM tblFT_badges_OVAL WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsID) + ' 
					   AND sortNo IN (SELECT DISTINCT sortNo FROM tblFT_QTYResubmit_sortNo_Cycler WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsID) + ' AND sortNo IS NOT NULL)'
		EXEC (@runSQL)

		SET @RowCount = @RowCount + 1
	END			
END

IF OBJECT_ID(N'tempPSU_resubmitQTY_OVAL', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_OVAL	

--// Deal with label-less resubmits
UPDATE tblFT_Badges_OVAL
SET resubmit = 'isTRUE'
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// Create final table, used for SSIS export
IF OBJECT_ID(N'[tblFT_Badges_OVAL_forExport]', N'U') IS NOT NULL 
DROP TABLE [dbo].[tblFT_Badges_OVAL_forExport]

CREATE TABLE [dbo].[tblFT_Badges_OVAL_forExport](
	[template] [varchar](255) NOT NULL,
	[DDFname] [varchar](255) NOT NULL,
	[outputPath] [varchar](255) NULL,
	[logfilePath] [varchar](255) NULL,
	[outputStyle] [varchar](255) NOT NULL,
	[outputFormat] [varchar](255) NULL,
	[Badge] [varchar](255) NULL,
	[sortNo] [int] IDENTITY(1,1) NOT NULL,
	[ordersProductsID] [int] NULL,
	[resubmit] [nchar](10) NULL,
	[orderNo] [varchar](255) NULL
) ON [PRIMARY]

INSERT INTO [tblFT_Badges_OVAL_forExport] (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit, ordersProductsID, orderNo)
SELECT a.template, a.DDFname, a.outputPath, a.logFilePath, a.outputStyle, a.outputFormat, a.badge, a.resubmit, a.ordersProductsID, b.orderNo
FROM tblFT_Badges_OVAL a
INNER JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
INNER JOIN tblOrders b
	ON op.orderID = b.orderID
ORDER BY a.resubmit DESC, b.orderNo, a.ordersProductsID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// OVAL FILE CREATION  - FRAMELESS ////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @stampA NVARCHAR(255)
SET @stampA = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / OVAL / NONMIXED / FRAMELESS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL_Frameless
INSERT INTO tblFT_Badges_OVAL_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT 
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stampA + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stampA + '_O.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), x.OPPO_ordersProductsID) + '.pdf' as 'Badge',
x.sortNo, x.OPPO_ordersProductsID, 'isFALSE'
FROM tblBadges x
INNER JOIN tblOrders_Products op
	ON x.OPPO_ordersProductsID = op.[ID]
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE x.RO = 'O'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.sortNo <> 9999999
AND op.[ID] IN --this confirms that only non-mixed opids are brought in on this query
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = 455)
AND op.[ID] NOT IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID IN (359, 360, 361, 362))
ORDER BY o.orderNo, x.OPPO_ordersProductsID

--OLDSCHOOL / OVAL / MIXED / FRAMELESS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL_Frameless
INSERT INTO tblFT_Badges_OVAL_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT DISTINCT
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stampA + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stampA + '_O.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), s.OPPO_ordersProductsID) + '.pdf' as 'Badge',
i.i, s.OPPO_ordersProductsID, 'isFALSE'
FROM tblOrders o
INNER JOIN tblOrders_Products op
	ON op.orderID = o.orderID
INNER JOIN tblBadges_Splitter s
	ON op.ID = s.OPPO_ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND s.oppo_frame_optionQty
WHERE s.oppo_PKID IS NOT NULL
AND s.oppo_frameless = 1
AND SUBSTRING(s.productCode, 5, 1) = 'O'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.[ID] IN -- grab OPIDs that have Frameless pUnits within
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
AND o.orderNo = 'HOM728216'
ORDER BY s.OPPO_ordersProductsID, i.i

--CANVAS / OVAL / NONMIXED / FRAMELESS -------------------------------------------------------------------
INSERT INTO tblFT_Badges_OVAL_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stampA + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stampA + '_O.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(textValue, '/InProduction/General/', '') AS 'Badge',
i.i, op.ID, 'isFALSE'
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
INNER JOIN tblOrdersProducts_productOptions x
	ON op.ID = x.ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND op.productQuantity 
WHERE 
op.fastTrak_productType = 'Badge'
AND SUBSTRING(op.productCode, 5, 1) = 'O'
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_OVAL_Frameless
	WHERE ordersproductsID IS NOT NULL)
AND op.[ID] IN --remove framless products
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, op.ID

--// 16 UP --------------------------------------------------------------------------------------
IF OBJECT_ID(N'tempPSU_resubmitQTY_OVAL_FRAMELESS', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_OVAL_FRAMELESS

CREATE TABLE tempPSU_resubmitQTY_OVAL_FRAMELESS (
RowID INT IDENTITY(1, 1), 
ordersProductsID INT,
QTY INT)

DECLARE @NumberRecordsA INT, @RowCountA INT
DECLARE @ordersProductsIDA INT
DECLARE @runSQLA NVARCHAR(255), @countedA INT, @QTYA INT, @numberToRemoveA INT

INSERT INTO tempPSU_resubmitQTY_OVAL_FRAMELESS (ordersProductsID, QTY)
SELECT DISTINCT [ID], fastTrak_newQTY
FROM tblOrders_Products
WHERE 
[ID] IN
	(SELECT DISTINCT ordersProductsID
	 FROM tblFT_Badges_OVAL_Frameless
	 WHERE ordersProductsID IS NOT NULL	)
AND fastTrak_newQTY IS NOT NULL
AND fastTrak_newQTY <> 0
AND fastTrak_newQTY <> productQuantity

SET @NumberRecordsA = @@RowCount
SET @RowCountA = 1

WHILE @RowCountA <= @NumberRecordsA
BEGIN
	SELECT @ordersProductsIDA = ordersProductsID
	FROM tempPSU_resubmitQTY_OVAL_FRAMELESS
	WHERE RowID = @RowCountA

	SET @QTYA = (
				SELECT SUM(QTY) 
				FROM tempPSU_resubmitQTY_OVAL_FRAMELESS
				WHERE ordersProductsID = @ordersProductsIDA
				)

	SET @countedA = (
					 SELECT COUNT(*)
					 FROM tblFT_Badges_OVAL_Frameless 
					 WHERE ordersProductsID = @ordersProductsIDA 
					)
	
	IF @QTYA IS NULL
		BEGIN
			SET @RowCountA = @RowCountA + 1		
		END

	IF @QTYA = 0
		BEGIN
			SET @RowCountA = @RowCountA + 1		
		END

	IF @countedA IS NULL
		BEGIN
			SET @RowCountA = @RowCountA + 1		
		END

	IF @countedA = 0
		BEGIN
			SET @RowCountA = @RowCountA + 1		
		END

	IF @QTYA >= @countedA
		BEGIN
			SET @RowCountA = @RowCountA + 1		
		END

	ELSE
	BEGIN
		SET @numberToRemoveA = @countedA - @QTYA

		DELETE FROM tblFT_QTYResubmit_sortNo_Cycler
		SET @runSQLA = NULL
		SET @runSQLA =
		'INSERT INTO tblFT_QTYResubmit_sortNo_Cycler (ordersProductsID, sortNo)
		SELECT TOP ' + CONVERT(VARCHAR(50), @numberToRemoveA) + ' ordersProductsID, sortNo FROM tblFT_Badges_OVAL_Frameless WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDA) + ' ORDER BY sortNo DESC'
		EXEC (@runSQLA)


		SET @runSQLA = NULL
		SET @runSQLA = 'DELETE FROM tblFT_Badges_OVAL_Frameless WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDA) + ' 
					   AND sortNo IN (SELECT DISTINCT sortNo FROM tblFT_QTYResubmit_sortNo_Cycler WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDA) + ' AND sortNo IS NOT NULL)'
		EXEC (@runSQLA)

		SET @RowCountA = @RowCountA + 1
	END			
END

IF OBJECT_ID(N'tempPSU_resubmitQTY_OVAL_FRAMELESS', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_OVAL_FRAMELESS	

--// Deal with label-less resubmits
UPDATE tblFT_Badges_OVAL_Frameless
SET resubmit = 'isTRUE'
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// Create final table, used for SSIS export
IF OBJECT_ID(N'[tblFT_Badges_OVAL_Frameless_forExport]', N'U') IS NOT NULL 
DROP TABLE [dbo].[tblFT_Badges_OVAL_Frameless_forExport]

CREATE TABLE [dbo].[tblFT_Badges_OVAL_Frameless_forExport](
	[template] [varchar](255) NOT NULL,
	[DDFname] [varchar](255) NOT NULL,
	[outputPath] [varchar](255) NULL,
	[logfilePath] [varchar](255) NULL,
	[outputStyle] [varchar](255) NOT NULL,
	[outputFormat] [varchar](255) NULL,
	[Badge] [varchar](255) NULL,
	[sortNo] [int] IDENTITY(1,1) NOT NULL,
	[ordersProductsID] [int] NULL,
	[resubmit] [nchar](10) NULL,
	[orderNo] [varchar](255) NULL
) ON [PRIMARY]

INSERT INTO [tblFT_Badges_OVAL_Frameless_forExport] (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit, ordersProductsID, orderNo)
SELECT a.template, a.DDFname, a.outputPath, a.logFilePath, a.outputStyle, a.outputFormat, a.badge, a.resubmit, a.ordersProductsID, b.orderNo
FROM tblFT_Badges_OVAL_Frameless a
INNER JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
INNER JOIN tblOrders b
	ON op.orderID = b.orderID
ORDER BY a.resubmit DESC, b.orderNo, a.ordersProductsID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// REC FILE CREATION //////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DECLARE @stamp2 NVARCHAR(255)
SET @stamp2 = NULL
SET @stamp2 = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / REC / NONMIXED -------------------------------------------------------------------
TRUNCATE TABLE tblFT_badges_REC
INSERT INTO tblFT_badges_REC (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT 
 'Macintosh HD:Name Badge Central:Impo Templates:22up.RC_Merge_NEW.qxp' AS 'template', 'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp2 + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp2 + '_R.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), x.orderNo) + '_' + CONVERT(NVARCHAR(255), x.OPPO_ordersProductsID) + '.pdf' as 'Badge',
x.sortNo, x.OPPO_ordersProductsID,
'isFALSE'
FROM tblBadges x
INNER JOIN tblOrders_Products op
	ON x.OPPO_ordersProductsID = op.[ID]
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE x.RO = 'R'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.sortNo <> 9999999
AND op.[ID] NOT IN --remove framless products
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, x.OPPO_ordersProductsID

--OLDSCHOOL / REC / MIXED -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL
INSERT INTO tblFT_Badges_OVAL (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT 
'Macintosh HD:Name Badge Central:Impo Templates:16up.RC_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp2 + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp2 + '_R.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), s.OPPO_ordersProductsID) + '.pdf' as 'Badge',
i.i, s.OPPO_ordersProductsID, 'isFALSE'
FROM tblOrders o
INNER JOIN tblOrders_Products op
	ON op.orderID = o.orderID
INNER JOIN tblBadges_Splitter s
	ON op.ID = s.OPPO_ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND s.oppo_frame_optionQty
WHERE s.oppo_PKID IS NOT NULL
AND s.oppo_frameless = 0
AND SUBSTRING(s.productCode, 5, 1) = 'R'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.[ID] IN -- grab OPIDs that have Frameless pUnits within
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, s.OPPO_ordersProductsID

--CANVAS / REC / NONMIXED -------------------------------------------------------------------
INSERT INTO tblFT_badges_REC (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
 'Macintosh HD:Name Badge Central:Impo Templates:22up.RC_Merge_NEW.qxp' AS 'template', 'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp2 + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp2 + '_R.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(textValue, '/InProduction/General/', '') AS 'Badge',
i.i, op.ID, 'isFALSE'
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
INNER JOIN tblOrdersProducts_productOptions x
	ON op.ID = x.ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND op.productQuantity 
WHERE 
op.fastTrak_productType = 'Badge'
AND SUBSTRING(op.productCode, 5, 1) = 'R'
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_REC
	WHERE ordersproductsID IS NOT NULL)
AND op.[ID] NOT IN --remove framless products
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, op.ID

--// 22 UP --------------------------------------------------------------------------------------
IF OBJECT_ID(N'tempPSU_resubmitQTY_REC', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_REC

CREATE TABLE tempPSU_resubmitQTY_REC (
RowID INT IDENTITY(1, 1), 
ordersProductsID INT,
QTY INT)

DECLARE @NumberRecordsRec INT, @RowCountRec INT
DECLARE @ordersProductsIDRec INT
DECLARE @runSQLRec VARCHAR(255), @countedRec INT, @QTYRec INT, @numberToRemoveRec INT

INSERT INTO tempPSU_resubmitQTY_REC (ordersProductsID, QTY)
SELECT DISTINCT [ID], fastTrak_newQTY
FROM tblOrders_Products
WHERE 
[ID] IN
	(SELECT DISTINCT ordersProductsID
	 FROM tblFT_badges_REC
	 WHERE ordersProductsID IS NOT NULL)
AND fastTrak_newQTY IS NOT NULL
AND fastTrak_newQTY <> 0
AND fastTrak_newQTY <> productQuantity

SET @NumberRecordsRec = @@RowCount
SET @RowCountRec = 1

WHILE @RowCountRec <= @NumberRecordsRec
BEGIN

	SELECT @ordersProductsIDRec = ordersProductsID
	FROM tempPSU_resubmitQTY_REC
	WHERE RowID = @RowCountRec

	SET @QTYRec = (
				SELECT SUM(QTY) 
				FROM tempPSU_resubmitQTY_REC
				WHERE ordersProductsID = @ordersProductsIDRec
				)

	SET @countedRec = (
					 SELECT COUNT(*)
					 FROM tblFT_badges_REC 
					 WHERE ordersProductsID = @ordersProductsIDRec 
					)
	
	IF @QTYRec IS NULL
		BEGIN
			SET @RowCountRec = @RowCountRec + 1		
		END

	IF @QTYRec = 0
		BEGIN
			SET @RowCountRec = @RowCountRec + 1		
		END

	IF @countedRec IS NULL
		BEGIN
			SET @RowCountRec = @RowCountRec + 1		
		END

	IF @countedRec = 0
		BEGIN
			SET @RowCountRec = @RowCountRec + 1		
		END

	IF @QTYRec >= @countedRec
		BEGIN
			SET @RowCountRec = @RowCountRec + 1		
		END

	ELSE
	BEGIN
		SET @numberToRemoveRec = @countedRec - @QTYRec

		DELETE FROM tblFT_QTYResubmit_sortNo_Cycler
		SET @runSQLRec = NULL
		SET @runSQLRec =
		'INSERT INTO tblFT_QTYResubmit_sortNo_Cycler (ordersProductsID, sortNo)
		SELECT TOP ' + CONVERT(VARCHAR(50), @numberToRemoveRec) + ' ordersProductsID, sortNo FROM tblFT_badges_REC WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDRec) + ' ORDER BY sortNo DESC'
		EXEC (@runSQLRec)


		SET @runSQLRec = NULL
		SET @runSQLRec = 'DELETE FROM tblFT_badges_REC WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDRec) + ' 
					   AND sortNo IN (SELECT DISTINCT sortNo FROM tblFT_QTYResubmit_sortNo_Cycler WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDRec) + ' AND sortNo IS NOT NULL)'
		EXEC (@runSQLRec)

		SET @RowCountRec = @RowCountRec + 1
	END			
END

IF OBJECT_ID(N'tempPSU_resubmitQTY_REC', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_REC	

--// Deal with label-less resubmits
UPDATE tblFT_badges_REC
SET resubmit = 'isTRUE'
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// Create final table, used for SSIS export
IF OBJECT_ID(N'[tblFT_Badges_REC_forExport]', N'U') IS NOT NULL 
DROP TABLE [dbo].tblFT_Badges_REC_forExport

CREATE TABLE [dbo].tblFT_Badges_REC_forExport(
	[template] [varchar](255) NOT NULL,
	[DDFname] [varchar](255) NOT NULL,
	[outputPath] [varchar](255) NULL,
	[logfilePath] [varchar](255) NULL,
	[outputStyle] [varchar](255) NOT NULL,
	[outputFormat] [varchar](255) NULL,
	[Badge] [varchar](255) NULL,
	[sortNo] [int] IDENTITY(1,1) NOT NULL,
	[ordersProductsID] [int] NULL,
	[resubmit] [nchar](10) NULL,
	[orderNo] [varchar](255) NULL
) ON [PRIMARY]

INSERT INTO tblFT_Badges_REC_forExport (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit, ordersProductsID, orderNo)
SELECT a.template, a.DDFname, a.outputPath, a.logFilePath, a.outputStyle, a.outputFormat, a.badge, a.resubmit, a.ordersProductsID, b.orderNo
FROM tblFT_Badges_REC a
INNER JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
INNER JOIN tblOrders b
	ON op.orderID = b.orderID
ORDER BY a.resubmit DESC, b.orderNo, a.ordersProductsID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// REC FILE CREATION  - FRAMELESS //////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @stampB NVARCHAR(255)
SET @stampB = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / REC / NONMIXED / FRAMELESS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_REC_Frameless
INSERT INTO tblFT_Badges_REC_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT 
'Macintosh HD:Name Badge Central:Impo Templates:16up.RC_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stampB + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stampB + '_R.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), x.OPPO_ordersProductsID) + '.pdf' as 'Badge',
x.sortNo, x.OPPO_ordersProductsID, 'isFALSE'
FROM tblBadges x
INNER JOIN tblOrders_Products op
	ON x.OPPO_ordersProductsID = op.[ID]
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE x.RO = 'R'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.sortNo <> 9999999
AND op.[ID] IN --this confirms that only non-mixed opids are brought in on this query
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = 455)
AND op.[ID] NOT IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID IN (359, 360, 361, 362))
ORDER BY o.orderNo, x.OPPO_ordersProductsID

--OLDSCHOOL / REC / MIXED / FRAMELESS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL_Frameless
INSERT INTO tblFT_Badges_OVAL_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT DISTINCT
'Macintosh HD:Name Badge Central:Impo Templates:16up.RC_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stampB + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stampB + '_R.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), s.OPPO_ordersProductsID) + '.pdf' as 'Badge',
i.i, s.OPPO_ordersProductsID, 'isFALSE'
FROM tblOrders o
INNER JOIN tblOrders_Products op
	ON op.orderID = o.orderID
INNER JOIN tblBadges_Splitter s
	ON op.ID = s.OPPO_ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND s.oppo_frame_optionQty
WHERE s.oppo_PKID IS NOT NULL
AND s.oppo_frameless = 1
AND SUBSTRING(s.productCode, 5, 1) = 'R'
AND op.deleteX <> 'yes'
AND op.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges
	WHERE ordersProductsID IS NOT NULL)
AND op.fastTrak_imageFile_exported = 1
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.[ID] IN -- grab OPIDs that have Frameless pUnits within
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
AND o.orderNo = 'HOM728216'
ORDER BY s.OPPO_ordersProductsID, i.i

--CANVAS / REC / NONMIXED / FRAMELESS -------------------------------------------------------------------
INSERT INTO tblFT_Badges_REC_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.RC_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stampB + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stampB + '_R.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(textValue, '/InProduction/General/', '') AS 'Badge',
i.i, op.ID, 'isFALSE'
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
INNER JOIN tblOrdersProducts_productOptions x
	ON op.ID = x.ordersProductsID
INNER JOIN integers i
ON i.i BETWEEN 1 AND op.productQuantity 
WHERE 
op.fastTrak_productType = 'Badge'
AND SUBSTRING(op.productCode, 5, 1) = 'R'
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('failed', 'cancelled', 'Waiting For Payment')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_REC_Frameless
	WHERE ordersproductsID IS NOT NULL)
AND op.[ID] IN --remove framless products
	(SELECT DISTINCT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Frameless'
	AND deleteX <> 'yes')
ORDER BY o.orderNo, op.ID

--// 16 UP --------------------------------------------------------------------------------------
IF OBJECT_ID(N'tempPSU_resubmitQTY_REC_FRAMELESS', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_REC_FRAMELESS

CREATE TABLE tempPSU_resubmitQTY_REC_FRAMELESS (
RowID INT IDENTITY(1, 1), 
ordersProductsID INT,
QTY INT)

DECLARE @NumberRecordsB INT, @RowCountB INT
DECLARE @ordersProductsIDB INT
DECLARE @runSQLB NVARCHAR(255), @countedB INT, @QTYB INT, @numberToRemoveB INT

INSERT INTO tempPSU_resubmitQTY_REC_FRAMELESS (ordersProductsID, QTY)
SELECT DISTINCT [ID], fastTrak_newQTY
FROM tblOrders_Products
WHERE 
[ID] IN
	(SELECT DISTINCT ordersProductsID
	 FROM tblFT_Badges_REC_Frameless
	 WHERE ordersProductsID IS NOT NULL	)
AND fastTrak_newQTY IS NOT NULL
AND fastTrak_newQTY <> 0
AND fastTrak_newQTY <> productQuantity

SET @NumberRecordsB = @@RowCount
SET @RowCountB = 1

WHILE @RowCountB <= @NumberRecordsB
BEGIN
	SELECT @ordersProductsIDB = ordersProductsID
	FROM tempPSU_resubmitQTY_REC_FRAMELESS
	WHERE RowID = @RowCountB

	SET @QTYB = (
				SELECT SUM(QTY) 
				FROM tempPSU_resubmitQTY_REC_FRAMELESS
				WHERE ordersProductsID = @ordersProductsIDB
				)

	SET @countedB = (
					 SELECT COUNT(*)
					 FROM tblFT_Badges_REC_Frameless 
					 WHERE ordersProductsID = @ordersProductsIDB 
					)
	
	IF @QTYB IS NULL
		BEGIN
			SET @RowCountB = @RowCountB + 1		
		END

	IF @QTYB = 0
		BEGIN
			SET @RowCountB = @RowCountB + 1		
		END

	IF @countedB IS NULL
		BEGIN
			SET @RowCountB = @RowCountB + 1		
		END

	IF @countedB = 0
		BEGIN
			SET @RowCountB = @RowCountB + 1		
		END

	IF @QTYB >= @countedB
		BEGIN
			SET @RowCountB = @RowCountB + 1		
		END

	ELSE
	BEGIN
		SET @numberToRemoveB = @countedB - @QTYB

		DELETE FROM tblFT_QTYResubmit_sortNo_Cycler
		SET @runSQLB = NULL
		SET @runSQLB =
		'INSERT INTO tblFT_QTYResubmit_sortNo_Cycler (ordersProductsID, sortNo)
		SELECT TOP ' + CONVERT(VARCHAR(50), @numberToRemoveB) + ' ordersProductsID, sortNo FROM tblFT_Badges_REC_Frameless WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDB) + ' ORDER BY sortNo DESC'
		EXEC (@runSQLB)


		SET @runSQLB = NULL
		SET @runSQLB = 'DELETE FROM tblFT_Badges_REC_Frameless WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDB) + ' 
					   AND sortNo IN (SELECT DISTINCT sortNo FROM tblFT_QTYResubmit_sortNo_Cycler WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDB) + ' AND sortNo IS NOT NULL)'
		EXEC (@runSQLB)

		SET @RowCountB = @RowCountB + 1
	END			
END

IF OBJECT_ID(N'tempPSU_resubmitQTY_REC_FRAMELESS', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_REC_FRAMELESS	

--// Deal with label-less resubmits
UPDATE tblFT_Badges_REC_Frameless
SET resubmit = 'isTRUE'
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// Create final table, used for SSIS export
IF OBJECT_ID(N'[tblFT_Badges_REC_Frameless_forExport]', N'U') IS NOT NULL 
DROP TABLE [dbo].[tblFT_Badges_REC_Frameless_forExport]

CREATE TABLE [dbo].[tblFT_Badges_REC_Frameless_forExport](
	[template] [varchar](255) NOT NULL,
	[DDFname] [varchar](255) NOT NULL,
	[outputPath] [varchar](255) NULL,
	[logfilePath] [varchar](255) NULL,
	[outputStyle] [varchar](255) NOT NULL,
	[outputFormat] [varchar](255) NULL,
	[Badge] [varchar](255) NULL,
	[sortNo] [int] IDENTITY(1,1) NOT NULL,
	[ordersProductsID] [int] NULL,
	[resubmit] [nchar](10) NULL,
	[orderNo] [varchar](255) NULL
) ON [PRIMARY]

INSERT INTO [tblFT_Badges_REC_Frameless_forExport] (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit, ordersProductsID, orderNo)
SELECT a.template, a.DDFname, a.outputPath, a.logFilePath, a.outputStyle, a.outputFormat, a.badge, a.resubmit, a.ordersProductsID, b.orderNo
FROM tblFT_Badges_REC_Frameless a
INNER JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
INNER JOIN tblOrders b
	ON op.orderID = b.orderID
ORDER BY a.resubmit DESC, b.orderNo, a.ordersProductsID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// RUN ADDITIONAL SPROCS //////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXEC [usp_FT_Badges_Tickets]
EXEC [usp_FT_Badges_pSlips]

COMMIT
END TRY
BEGIN CATCH
 ROLLBACK
END CATCH