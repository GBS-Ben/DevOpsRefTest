CREATE PROC [dbo].[usp_FT_IMPO_preSSIS]
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
--06/28/18		Updated orderStatus check; updated displayPaymentStatus check, on all main queries, jf.
--08/17/18		added this exception: NB0TRB-001-100, jf.
--09/04/18		Removed above, jf.
--02/05/19		CANVAS fixes per query, jf.
--02/05/19		FRAMELESS fixes per query, jf.
--12/13/19		ADDED File Exists to each main query, jf.
--07/01/20		Added, usp_NewModBadges to this query, since we don't run IMAGE any longer, jf.
--07/02/20		Removed all non-canvas operations, removed additional DROP operations, added table truncations prior to inserts, jf.
--01/11/21		BS, iframe conversion
--03/19/21		BS, removed intranetPDF from file name options
--05/11/21		BS, Added CCID to the Canvas Check
--04/27/22      added displaypaymentStatus = 'Credit Due'
-------------------------------------------------------------------------------
*/

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// RUN INITIAL BADGE CLEANER  //////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXEC [usp_NewModBadges]

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

--CANVAS / OVAL -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL
INSERT INTO tblFT_Badges_OVAL (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp + '_O.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(x.textValue, '/InProduction/General/', '') AS 'Badge',
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
AND DATEDIFF(MI, o.created_on, GETDATE()) > 60
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND o.orderStatus NOT LIKE '%Waiting%'
AND o.displayPaymentStatus IN ('Good','Credit Due')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND EXISTS -- CANVAS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE oppx.optionCaption IN ('CC State User ID', 'CC State ID', 'CanvasHiResFront', 'CCID')
	AND oppx.ordersProductsID = op.ID)
AND NOT EXISTS --NOT FRAMELESS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppz
	WHERE ((oppz.optionCaption = 'Frameless' 
			OR (oppz.optionCaption = 'Frame Style' 
			   AND oppz.textValue = 'Frameless'))
		  AND oppz.deleteX <> 'yes'
		  AND oppz.ordersProductsID = op.ID))
AND x.textValue LIKE '%.pdf%'
AND (x.optionCaption = 'CanvasHiResFront File Name')  --bjs iframe conversion
AND x.textValue NOT LIKE '%//%'
--Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.ID)
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

--// Deal with label-less resubmits
UPDATE a
SET resubmit = 'isTRUE'
FROM tblFT_Badges_OVAL a
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.fastTrak_shippingLabelOption1 = 1
	AND op.ID = a.ordersProductsID)

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

DECLARE @stamp2 NVARCHAR(255)
SET @stamp2 = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--CANVAS / OVAL FRAMELESS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL_Frameless 
INSERT INTO tblFT_Badges_OVAL_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp2 + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp2 + '_O.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(x.textValue, '/InProduction/General/', '') AS 'Badge',
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
AND DATEDIFF(MI, o.created_on, GETDATE()) > 60
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND o.orderStatus NOT LIKE '%Waiting%'
AND o.displayPaymentStatus IN ('Good','Credit Due')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND EXISTS -- CANVAS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE oppx.optionCaption IN ('CC State User ID', 'CC State ID', 'CanvasHiResFront', 'CCID')
	AND oppx.ordersProductsID = op.ID)
AND EXISTS -- FRAMELESS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppz
	WHERE ((oppz.optionCaption = 'Frameless' 
			OR (oppz.optionCaption = 'Frame Style' 
			   AND oppz.textValue = 'Frameless'))
		  AND oppz.deleteX <> 'yes'
		  AND oppz.ordersProductsID = op.ID))
AND x.textValue LIKE '%.pdf%'
AND (x.optionCaption = 'CanvasHiResFront File Name')  --bjs iframe conversion
AND x.textValue NOT LIKE '%//%'
--Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.ID)
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

--// Deal with label-less resubmits
UPDATE a
SET resubmit = 'isTRUE'
FROM tblFT_Badges_OVAL_Frameless a
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.fastTrak_shippingLabelOption1 = 1
	AND op.ID = a.ordersProductsID)

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

DECLARE @stamp3 NVARCHAR(255)
SET @stamp3 = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--CANVAS / REC -------------------------------------------------------------------
TRUNCATE TABLE tblFT_badges_REC 
INSERT INTO tblFT_badges_REC (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
 'Macintosh HD:Name Badge Central:Impo Templates:22up.RC_Merge_NEW.qxp' AS 'template', 'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp3 + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp3 + '_R.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(x.textValue, '/InProduction/General/', '') AS 'Badge',
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
AND DATEDIFF(MI, o.created_on, GETDATE()) > 60
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND o.orderStatus NOT LIKE '%Waiting%'
AND o.displayPaymentStatus IN ('Good','Credit Due')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND EXISTS -- CANVAS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE oppx.optionCaption IN ('CC State User ID', 'CC State ID', 'CanvasHiResFront', 'CCID')
	AND oppx.ordersProductsID = op.ID)
AND NOT EXISTS --NOT FRAMELESS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppz
	WHERE ((oppz.optionCaption = 'Frameless' 
			OR (oppz.optionCaption = 'Frame Style' 
			   AND oppz.textValue = 'Frameless'))
		  AND oppz.deleteX <> 'yes'
		  AND oppz.ordersProductsID = op.ID))
AND x.textValue LIKE '%.pdf%'
AND (x.optionCaption = 'CanvasHiResFront File Name')  --bjs iframe conversion
AND x.textValue NOT LIKE '%//%'
--Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.ID)
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

--// Deal with label-less resubmits
UPDATE a
SET resubmit = 'isTRUE'
FROM tblFT_badges_REC a
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.fastTrak_shippingLabelOption1 = 1
	AND op.ID = a.ordersProductsID)

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

DECLARE @stamp4 NVARCHAR(255)
SET @stamp4 = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))


--CANVAS / REC FRAMELESS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_REC_Frameless 
INSERT INTO tblFT_Badges_REC_Frameless (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.RC_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp4 + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp4 + '_R.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 
'Archives:webstores:OPC:' + REPLACE(x.textValue, '/InProduction/General/', '') AS 'Badge',
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
AND DATEDIFF(MI, o.created_on, GETDATE()) > 60
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND o.orderStatus NOT LIKE '%Waiting%'
AND o.displayPaymentStatus IN ('Good','Credit Due')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND EXISTS -- CANVAS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE oppx.optionCaption IN ('CC State User ID', 'CC State ID', 'CanvasHiResFront', 'CCID')
	AND oppx.ordersProductsID = op.ID)
AND EXISTS -- FRAMELESS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppz
	WHERE ((oppz.optionCaption = 'Frameless' 
			OR (oppz.optionCaption = 'Frame Style' 
			   AND oppz.textValue = 'Frameless'))
		  AND oppz.deleteX <> 'yes'
		  AND oppz.ordersProductsID = op.ID))
AND x.textValue LIKE '%.pdf%'
AND (x.optionCaption = 'CanvasHiResFront File Name')  --bjs iframe conversion
AND x.textValue NOT LIKE '%//%'
--Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.ID)
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

--// Deal with label-less resubmits
UPDATE a
SET resubmit = 'isTRUE'
FROM tblFT_Badges_REC_Frameless a
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.fastTrak_shippingLabelOption1 = 1
	AND op.ID = a.ordersProductsID)

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