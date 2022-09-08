CREATE PROC [dbo].[usp_FT_IMPO_preSSIS_NEW]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/25/16
-- Purpose     Preps IMPO data for production. 2 sections: OVAL and REC.
-------------------------------------------------------------------------------
-- Modification History

-- 10/25/16		Created.
-- 02/21/18		Updated to include CANVAS products and bypass IMAGE.
-------------------------------------------------------------------------------
SET XACT_ABORT ON

BEGIN TRY
    BEGIN TRANSACTION

--////////////////////////////////////////////// OVAL FILE CREATION //////////////////////////////////////////////////////////////////////////////////////////
DECLARE @stamp NVARCHAR(255)
SET @stamp = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / OVAL -------------------------------------------------------------------
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
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.sortNo <> 9999999
ORDER BY o.orderNo, x.OPPO_ordersProductsID

--CANVAS / OVAL -------------------------------------------------------------------
INSERT INTO tblFT_Badges_OVAL (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
'Macintosh HD:Name Badge Central:Impo Templates:16up.OV_Merge_NEW.qxp' AS 'template',
'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp + '_O.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp + '_O.log' AS 'logFilePath',
'Graphic Business Solutions',
'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), op.ID) + '.pdf' as 'Badge',
'999999', op.ID, 'isFALSE'
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE 
op.fastTrak_productType = 'Badge'
AND SUBSTRING(op.productCode, 5, 1) = 'O'
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.ID IN
	(SELECT ordersproductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Canvas'
	AND deleteX <> 'yes')
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_OVAL
	WHERE ordersproductsID IS NOT NULL)
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
	[resubmit] [nchar](10) NULL
) ON [PRIMARY]

INSERT INTO [tblFT_Badges_OVAL_forExport] (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit)
SELECT template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit
FROM tblFT_Badges_OVAL
ORDER BY resubmit DESC, Badge ASC

--////////////////////////////////////////////// REC FILE CREATION //////////////////////////////////////////////////////////////////////////////////////////
DECLARE @stamp2 NVARCHAR(255)
SET @stamp2 = NULL
SET @stamp2 = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))


--OLDSCHOOL / REC -------------------------------------------------------------------
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
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.sortNo <> 9999999
ORDER BY o.orderNo, x.OPPO_ordersProductsID

--CANVAS / REC -------------------------------------------------------------------
INSERT INTO tblFT_badges_REC (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
SELECT
 'Macintosh HD:Name Badge Central:Impo Templates:22up.RC_Merge_NEW.qxp' AS 'template', 'NB_imposition' AS 'DDFname',
'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp2 + '_R.pdf' AS 'outputPath',
'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp2 + '_R.log' AS 'logFilePath',
'Graphic Business Solutions', 'PDF', 'MERGE CENTRAL:Badge Automation:NAME BADGE SINGLE:' + CONVERT(NVARCHAR(255), o.orderNo) + '_' + CONVERT(NVARCHAR(255), op.ID) + '.pdf' as 'Badge',
'999999', op.ID, 'isFALSE'
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE 
op.fastTrak_productType = 'Badge'
AND SUBSTRING(op.productCode, 5, 1) = 'R'
AND op.deleteX <> 'yes'
AND op.fastTrak_imposed = 0
AND op.fastTrak_preventImposition = 0
AND op.fastTrak_resubmit = 0
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.ID IN
	(SELECT ordersproductsID
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Canvas'
	AND deleteX <> 'yes')
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_REC
	WHERE ordersproductsID IS NOT NULL)
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
	[resubmit] [nchar](10) NULL
) ON [PRIMARY]

INSERT INTO tblFT_Badges_REC_forExport (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit)
SELECT template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit
FROM tblFT_Badges_REC
ORDER BY resubmit DESC, Badge ASC

--////////////////////////////////////////////// RUN ADDITIONAL SPROCS //////////////////////////////////////////////////////////////////////////////////////////
EXEC [usp_FT_Badges_Labels]
EXEC [usp_FT_Badges_Tickets]
EXEC [usp_FT_Badges_pSlips]

COMMIT
END TRY
BEGIN CATCH
 ROLLBACK
END CATCH