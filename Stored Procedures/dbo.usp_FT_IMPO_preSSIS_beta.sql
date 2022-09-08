CREATE PROC [dbo].[usp_FT_IMPO_preSSIS_beta]
AS
/*
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/25/16
-- Purpose     Preps IMPO data for production. 2 sections: OVAL and REC.
					  TESTING
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
-------------------------------------------------------------------------------
*/
SET XACT_ABORT ON

BEGIN TRY
    BEGIN TRANSACTION

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// OVAL FILE CREATION //////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DECLARE @stamp NVARCHAR(255)
SET @stamp = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))

--OLDSCHOOL / OVAL -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_OVAL_beta
INSERT INTO tblFT_Badges_OVAL_beta (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
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
--AND op.[ID] IN
--	(SELECT DISTINCT ordersProductsID
--	FROM tblFT_Badges
--	WHERE ordersProductsID IS NOT NULL)
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
INSERT INTO tblFT_Badges_OVAL_beta (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
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
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_Badges_OVAL_beta
	WHERE ordersproductsID IS NOT NULL)
ORDER BY o.orderNo, op.ID

--// 16 UP --------------------------------------------------------------------------------------
IF OBJECT_ID(N'tempPSU_resubmitQTY_OVAL_beta', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_OVAL_beta

CREATE TABLE tempPSU_resubmitQTY_OVAL_beta (
RowID INT IDENTITY(1, 1), 
ordersProductsID INT,
QTY INT)

DECLARE @NumberRecords INT, @RowCount INT
DECLARE @ordersProductsID INT
DECLARE @runSQL NVARCHAR(255), @counted INT, @QTY INT, @numberToRemove INT

INSERT INTO tempPSU_resubmitQTY_OVAL_beta (ordersProductsID, QTY)
SELECT DISTINCT [ID], fastTrak_newQTY
FROM tblOrders_Products
WHERE 
[ID] IN
	(SELECT DISTINCT ordersProductsID
	 FROM tblFT_Badges_OVAL_beta
	 WHERE ordersProductsID IS NOT NULL	)
AND fastTrak_newQTY IS NOT NULL
AND fastTrak_newQTY <> 0
AND fastTrak_newQTY <> productQuantity

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @ordersProductsID = ordersProductsID
	FROM tempPSU_resubmitQTY_OVAL_beta
	WHERE RowID = @RowCount

	SET @QTY = (
				SELECT SUM(QTY) 
				FROM tempPSU_resubmitQTY_OVAL_beta
				WHERE ordersProductsID = @ordersProductsID
				)

	SET @counted = (
					 SELECT COUNT(*)
					 FROM tblFT_Badges_OVAL_beta 
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

		DELETE FROM tblFT_QTYResubmit_sortNo_Cycler_beta
		SET @runSQL = NULL
		SET @runSQL =
		'INSERT INTO tblFT_QTYResubmit_sortNo_Cycler_beta (ordersProductsID, sortNo)
		SELECT TOP ' + CONVERT(VARCHAR(50), @numberToRemove) + ' ordersProductsID, sortNo FROM tblFT_Badges_OVAL_beta WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsID) + ' ORDER BY sortNo DESC'
		EXEC (@runSQL)


		SET @runSQL = NULL
		SET @runSQL = 'DELETE FROM tblFT_Badges_OVAL_beta WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsID) + ' 
					   AND sortNo IN (SELECT DISTINCT sortNo FROM tblFT_QTYResubmit_sortNo_Cycler_beta WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsID) + ' AND sortNo IS NOT NULL)'
		EXEC (@runSQL)

		SET @RowCount = @RowCount + 1
	END			
END

IF OBJECT_ID(N'tempPSU_resubmitQTY_OVAL_beta', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_OVAL_beta	

--// Deal with label-less resubmits
UPDATE tblFT_Badges_OVAL_beta
SET resubmit = 'isTRUE'
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// Create final table, used for SSIS export
IF OBJECT_ID(N'[tblFT_Badges_OVAL_forExport_beta]', N'U') IS NOT NULL 
DROP TABLE [dbo].[tblFT_Badges_OVAL_forExport_beta]

CREATE TABLE [dbo].[tblFT_Badges_OVAL_forExport_beta](
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

INSERT INTO [tblFT_Badges_OVAL_forExport_beta] (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit, ordersProductsID, orderNo)
SELECT a.template, a.DDFname, a.outputPath, a.logFilePath, a.outputStyle, a.outputFormat, a.badge, a.resubmit, a.ordersProductsID, b.orderNo
FROM tblFT_Badges_OVAL_beta a
INNER JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
INNER JOIN tblOrders b
	ON op.orderID = b.orderID
ORDER BY a.resubmit DESC, b.orderNo, a.ordersProductsID

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// REC FILE CREATION //////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @stamp2 NVARCHAR(255)
SET @stamp2 = NULL
SET @stamp2 = (SELECT CONVERT(NVARCHAR(10), DATEPART(MM, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(DD, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(YY, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(HH, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(SS, getDate())) + 
				CONVERT(NVARCHAR(10), DATEPART(MS, getDate())))


--OLDSCHOOL / REC -------------------------------------------------------------------
TRUNCATE TABLE tblFT_badges_REC_beta
INSERT INTO tblFT_badges_REC_beta (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
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
INSERT INTO tblFT_badges_REC_beta (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, Badge, sortNo, ordersProductsID, resubmit)
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
--AND op.fastTrak_imposed = 0 
AND (op.fastTrak_imposed = 0 OR o.orderNo = 'HOM719750' ) --TESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTEST
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderID > 444333222
AND op.productCode NOT LIKE 'NBCU%'
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND x.deleteX <> 'yes'
AND x.optionCaption = 'Intranet PDF' --this indicates CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
AND op.ID NOT IN
	(SELECT ordersproductsID
	FROM tblFT_badges_REC_beta
	WHERE ordersproductsID IS NOT NULL)
ORDER BY o.orderNo, op.ID

--select * from tblFT_badges_REC_beta --(A) 

--// 22 UP --------------------------------------------------------------------------------------
IF OBJECT_ID(N'tempPSU_resubmitQTY_REC_beta', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_REC_beta

CREATE TABLE tempPSU_resubmitQTY_REC_beta (
RowID INT IDENTITY(1, 1), 
ordersProductsID INT,
QTY INT)

DECLARE @NumberRecordsRec INT, @RowCountRec INT
DECLARE @ordersProductsIDRec INT
DECLARE @runSQLRec VARCHAR(255), @countedRec INT, @QTYRec INT, @numberToRemoveRec INT

INSERT INTO tempPSU_resubmitQTY_REC_beta (ordersProductsID, QTY)
SELECT DISTINCT [ID], fastTrak_newQTY
FROM tblOrders_Products
WHERE 
[ID] IN
	(SELECT DISTINCT ordersProductsID
	 FROM tblFT_badges_REC_beta
	 WHERE ordersProductsID IS NOT NULL)
AND fastTrak_newQTY IS NOT NULL
AND fastTrak_newQTY <> 0
AND fastTrak_newQTY <> productQuantity

--select * from tempPSU_resubmitQTY_REC_beta --(B) 

SET @NumberRecordsRec = @@RowCount
SET @RowCountRec = 1

WHILE @RowCountRec <= @NumberRecordsRec
BEGIN

	SELECT @ordersProductsIDRec = ordersProductsID
	FROM tempPSU_resubmitQTY_REC_beta
	WHERE RowID = @RowCountRec

	SET @QTYRec = (
				SELECT SUM(QTY) 
				FROM tempPSU_resubmitQTY_REC_beta
				WHERE ordersProductsID = @ordersProductsIDRec
				)

	SET @countedRec = (
					 SELECT COUNT(*)
					 FROM tblFT_badges_REC_beta 
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

		DELETE FROM tblFT_QTYResubmit_sortNo_Cycler_beta
		SET @runSQLRec = NULL
		SET @runSQLRec =
		'INSERT INTO tblFT_QTYResubmit_sortNo_Cycler_beta (ordersProductsID, sortNo)
		SELECT TOP ' + CONVERT(VARCHAR(50), @numberToRemoveRec) + ' ordersProductsID, sortNo FROM tblFT_badges_REC_beta WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDRec) + ' ORDER BY sortNo DESC'
		EXEC (@runSQLRec)


		SET @runSQLRec = NULL
		SET @runSQLRec = 'DELETE FROM tblFT_badges_REC_beta WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDRec) + ' 
					   AND sortNo IN (SELECT DISTINCT sortNo FROM tblFT_QTYResubmit_sortNo_Cycler_beta WHERE ordersProductsID = ' + CONVERT(VARCHAR(255), @ordersProductsIDRec) + ' AND sortNo IS NOT NULL)'
		EXEC (@runSQLRec)

		SET @RowCountRec = @RowCountRec + 1
	END			
END

IF OBJECT_ID(N'tempPSU_resubmitQTY_REC_beta', N'U') IS NOT NULL 
DROP TABLE tempPSU_resubmitQTY_REC_beta	

--// Deal with label-less resubmits
UPDATE tblFT_badges_REC_beta
SET resubmit = 'isTRUE'
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE fastTrak_shippingLabelOption1 = 1)

--// Create final table, used for SSIS export
IF OBJECT_ID(N'[tblFT_Badges_REC_forExport_beta]', N'U') IS NOT NULL 
DROP TABLE [dbo].tblFT_Badges_REC_forExport_beta

CREATE TABLE [dbo].tblFT_Badges_REC_forExport_beta(
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

INSERT INTO tblFT_Badges_REC_forExport_beta (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, badge, resubmit, ordersProductsID, orderNo)
SELECT a.template, a.DDFname, a.outputPath, a.logFilePath, a.outputStyle, a.outputFormat, a.badge, a.resubmit, a.ordersProductsID, b.orderNo
FROM tblFT_badges_REC_beta a
INNER JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
INNER JOIN tblOrders b
	ON op.orderID = b.orderID
ORDER BY a.resubmit DESC, b.orderNo, a.ordersProductsID

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////// RUN ADDITIONAL SPROCS //////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXEC [usp_FT_Badges_Tickets_beta]
EXEC [usp_FT_Badges_pSlips_beta]

COMMIT
END TRY
BEGIN CATCH
 ROLLBACK
END CATCH

/* TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST 
--reset test 
usp_geteverything 'HOM719750'
update tblorders_products set fasttrak_imposed = 1 where id = 445500360
*/