
CREATE PROC [dbo].[usp_FT_Badges_pSlips]

AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		01/01/2015
-- Purpose		Generates data for pSlips in FT automation.
-------------------------------------------------------------------------------
-- Modification History
-- 08/03/16	Added badgeQTY updates to reflect resubs, jf.
-- 08/24/16		Added missing line #65 that DELETES temp table for badgeQTY, jf.
-- 08/26/16		Added LINE 86 to denull newQTY value before next statement's logic, jf.
-- 08/26/16		Refer to notes on LINE 102, broked it out into 2 sections, jf.
-- 08/31/16		Moved PSU code to bottom of sproc, jf.
-- 08/31/16		Moved RE-ORDER code to bottom of sproc, right above PSU, jf.
-- 12/28/16		Added pinBack QTY section near LINE 312, jf.
-- 04/07/17		Added shipType local pickup check to shipping_Street, jf.
-- 08/22/17		Commented out "BP" (business card) expection in SHIPSWITH area of code, jf.
-- 11/20/17		Updated orderType = "custom" assignation to exclude custom envelopes from triggering update, jf.
-- 02/01/18		Updated JOIN statements, jf.
-- 02/01/18		Updated for CANVAS, jf.
-- 02/02/18		added union subquery in initial section (eck), jf.
-- 03/15/18		for the same reasons that are described in [usp_FT_Badges_Tickets], I have removed the prevention clause, "AND p.fastTrak_preventLabel = 0", from
--						the first two insert statements, jf.
-- 03/15/18		added fastTrak_shippingLabelOption1 check to initial two insert statements to prevent the creation of a pslip for a resubmitted OPID where the first choice ("Print Badge Only") was chosen, jf.
-- 03/15/18		removed the "AND p.fastTrak_preventLabel = 0" check from the "New Quantity Calculation" section towards the bottom of the sproc, since it is redundant, as noted two comments above this one, jf.
--04/17/18		updated resub QTY calc to looke at SUM(newQTY) rather than actual since KH wants this value to be summation of only resubbed amounts in the event than an OPID w/in an order is resubbed, jf.
-- 05/23/18		added line to CANVAS initial query b/c CANVAS OPIDs are starting to come in with corrected information that negates this section of code, jf
-- 02/21/19		JF, for some reason, the pSlip data is duplicated now. Added dedup code at end of procedure.
-- 03/15/19		JF, pulled out label check in first two queries; if the OPID exists in one of the four tables checked, good enough.
-- 04/02/19		JF, uncommented the fastTrak_shippingLabelOption1 lines in the two initial queries, b/c it was causing production error (1) to show on pSlip (carla).
-- 07/11/19		JF, changed NB00MB_QTY Quantity to see if it will stop doubling. near ln378; if it's not accurate, go back to commented out code.
-- 07/16/19	JF, pulled back the code change mentioned  on 7/11 notes above.
-- 09/10/19		JF, added subquery in oldschool insert that pulls out canvas, and removed a testing line from the insert that shouldn't have been there (AND orderNo = 'HOM234660')
-- 09/25/19		JF, updated the "orderType" section, which is really the SHIPSWITH section. Made the code better.
-- 11/25/19		JF, qualified OPPO lookup on Canvas section of pslip generation with "539".
-- 11/23/20		JF, LEN(orderNo) IN (9,10)
-- 02/10/21		BS, Removed IntranetPdf from Canvas count
--06/03/21		JF, took into account Shaped Badges in calculating the SHIPSWITH stuff
-------------------------------------------------------------------------------

--OLDSCHOOL / PSLIPS -------------------------------------------------------------------
TRUNCATE TABLE tblFT_Badges_pSlips
INSERT INTO tblFT_Badges_pSlips 
(orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType)

SELECT DISTINCT
o.orderNo AS 'orderNo',
SUM(p.productQuantity) AS 'badgeQTY',
'' AS 'FMNB1', 0 AS 'FMNB1_QTY', '' AS 'FMNB2', 0 AS 'FMNB2_QTY', '' AS 'FMNB3', 0 AS 'FMNB3_QTY', 0 AS 'NB00MB_QTY', '' AS 'pinBack', '' AS 'orderType'
FROM tblOrders o
INNER JOIN tblOrders_Products p 
	ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z 
	ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND (z.optionCaption LIKE 'Name:%'  OR z.optionCaption = 'Agent Name')
AND z.deleteX <> 'yes'
--AND p.fastTrak_preventLabel = 0 --pulled these two checks out. If the OPID is in one of the tables below, it qualifies for a label.
AND p.ID NOT IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption  NOT IN ( 'Intranet PDF', 'CanvasHiResFront') --bjs iframe conversion 
	)-- THIS IS CANVAS, We don't want that in the oldschool insert.
AND p.fastTrak_shippingLabelOption1 <> 1
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
GROUP BY o.orderNo
ORDER BY o.orderNo ASC

--CANVAS / PSLIPS -------------------------------------------------------------------
INSERT INTO tblFT_Badges_pSlips 
(orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType)

SELECT DISTINCT
o.orderNo AS 'orderNo',
SUM(p.productQuantity) AS 'badgeQTY',
'' AS 'FMNB1', 0 AS 'FMNB1_QTY', '' AS 'FMNB2', 0 AS 'FMNB2_QTY', '' AS 'FMNB3', 0 AS 'FMNB3_QTY', 0 AS 'NB00MB_QTY', '' AS 'pinBack', '' AS 'orderType'
FROM tblOrders o
INNER JOIN tblOrders_Products p 
	ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z 
	ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND z.deleteX <> 'yes'
AND (z.optionCaption  IN ( 'CanvasHiResFront') --bjs iframe conversion
	--AND z.optionID = 539
	) --THIS IS CANVAS (it is exclusive to CANVAS OPIDs) as well as supplies the row needed for the image path.
--AND p.fastTrak_preventLabel = 0 --pulled these two checks out. If the OPID is in one of the tables below, it qualifies for a label.
AND p.fastTrak_shippingLabelOption1 <> 1
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
GROUP BY o.orderNo
ORDER BY o.orderNo

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
--//Set values for C/G/I columns
UPDATE tblFT_Badges_pSlips
SET FMNB1 = p.productCode
FROM tblFT_Badges_pSlips a 
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p
	ON o.orderID = p.orderID
WHERE
p.deleteX <> 'yes'
AND p.productCode = 'FMNB21-001'

UPDATE tblFT_Badges_pSlips
SET FMNB2 = p.productCode
FROM tblFT_Badges_pSlips a 
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p
	ON o.orderID = p.orderID
WHERE
p.deleteX <> 'yes'
AND p.productCode = 'FMNB21-002'

UPDATE tblFT_Badges_pSlips
SET FMNB3 = p.productCode
FROM tblFT_Badges_pSlips a 
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p
	ON o.orderID = p.orderID
WHERE
p.deleteX <> 'yes'
AND p.productCode = 'FMNB21-003'

--// Grab total QTY per orderNo, for FMNBs
DELETE FROM tblFT_Badges_pSlips_PKIDMIRROR
INSERT INTO tblFT_Badges_pSlips_PKIDMIRROR (FMNB_QTY, FMNB_productCode, orderNo)
SELECT SUM(p.productQuantity) AS 'FMNB_QTY', p.productCode AS 'FMNB_productCode', o.orderNo AS 'orderNo'
FROM tblFT_Badges_pSlips a 
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p
	ON o.orderID = p.orderID
WHERE
p.deleteX <> 'yes'
AND p.productCode LIKE 'FMNB21-%'
GROUP BY o.orderNo, p.productCode

--//Set QTYs for FMNBs (3 different possibilities, thus 3 statements)
UPDATE tblFT_Badges_pSlips
SET FMNB1_QTY = o.FMNB_QTY
FROM tblFT_Badges_pSlips a 
INNER JOIN tblFT_Badges_pSlips_PKIDMIRROR o
	ON a.orderNo = o.orderNo
WHERE a.FMNB1 = o.FMNB_productCode

UPDATE tblFT_Badges_pSlips
SET FMNB2_QTY = o.FMNB_QTY
FROM tblFT_Badges_pSlips a 
INNER JOIN tblFT_Badges_pSlips_PKIDMIRROR o
	ON a.orderNo = o.orderNo
WHERE a.FMNB2 = o.FMNB_productCode

UPDATE tblFT_Badges_pSlips
SET FMNB3_QTY = o.FMNB_QTY
FROM tblFT_Badges_pSlips a 
INNER JOIN tblFT_Badges_pSlips_PKIDMIRROR o
	ON a.orderNo = o.orderNo
WHERE a.FMNB3 = o.FMNB_productCode

--// Grab total QTY per orderNo
DELETE FROM tblFT_Badges_pSlips_PKIDMIRROR2

INSERT INTO tblFT_Badges_pSlips_PKIDMIRROR2 (NB00MB, orderNo)
SELECT SUM(p.productQuantity) AS 'NB00MB', o.orderNo AS 'orderNo'
FROM tblFT_Badges_pSlips a 
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p
	ON o.orderID = p.orderID
WHERE
p.deleteX <> 'yes'
AND p.productCode LIKE 'NB00MB%'
GROUP BY o.orderNo

--//Set QTY for NB00MB if applicable
UPDATE tblFT_Badges_pSlips
SET NB00MB_QTY = o.NB00MB
FROM tblFT_Badges_pSlips a 
INNER JOIN tblFT_Badges_pSlips_PKIDMIRROR2 o
	ON a.orderNo = o.orderNo

--// This section introduced on 12/11/15, jf. (SHIPSWITH)
--// Set orderType; this field dictates what, if any, types of products are shipping with the badge. This is known as shipsWith elsewhere. ORDERTYPE means SHIPSWITH, in this stored procedure.
-- at this point, orderType = ''.

--Custom goes first, because Custom reigns supreme.
UPDATE f
SET orderType = 'Custom'
FROM tblFT_Badges_pSlips f
INNER JOIN tblOrders o ON o.orderNo = f.orderNo
INNER JOIN tblOrders_Products op ON op.orderID = o.orderID
WHERE op.deleteX <> 'yes'
AND op.processType = 'Custom' -- grab all custom processTypes...
AND (op.productName NOT LIKE '%Badge%' 
		 OR SUBSTRING(op.productCode, 5, 2) = 'SB') --except if it is a badge that is not a shaped badge
AND SUBSTRING(op.productCode, 3, 2) <> 'EV' -- or an envelope...
AND SUBSTRING(op.productCode, 1, 2) <> 'PN' -- or a pen.

--FT goes next.
UPDATE f
SET orderType = 'fasTrak'
FROM tblFT_Badges_pSlips f
INNER JOIN tblOrders o ON o.orderNo = f.orderNo
INNER JOIN tblOrders_Products op ON op.orderID = o.orderID
WHERE f.orderType <> 'Custom' --didn't get set to 'custom' above. 
AND op.deleteX <> 'yes'
AND op.processType = 'fasTrak' -- grab all FT processTypes...
AND op.productName NOT LIKE '%Badge%' --except if it is a badge...
AND SUBSTRING(op.productCode, 1, 2) <> 'PN' -- or a pen.

--Stock goes last.
UPDATE f
SET orderType = 'Stock'
FROM tblFT_Badges_pSlips f
INNER JOIN tblOrders o ON o.orderNo = f.orderNo
INNER JOIN tblOrders_Products op ON op.orderID = o.orderID
WHERE f.orderType <> 'Custom' --didn't get set to 'custom' above. 
AND f.orderType <> 'fasTrak' --didn't get set to 'fastrak' above. 
AND op.deleteX <> 'yes'
AND op.processType = 'Stock' -- grab all FT processTypes...
AND op.productName NOT LIKE '%Badge%' --except if it is a badge.


--What's left.
UPDATE tblFT_Badges_pSlips
SET orderType = 'SHIP'
WHERE orderType = ''

UPDATE f
SET orderType = 'SHIP'
FROM tblFT_Badges_pSlips f
INNER JOIN tblOrders o ON o.orderNo = f.orderNo
INNER JOIN tblOrders_Products op ON op.orderID = o.orderID
WHERE op.fastTrak_shippingLabelOption3 = 1
AND op.deleteX <> 'yes'


--//Clean up QTYs
UPDATE tblFT_Badges_pSlips
SET FMNB1_QTY = NULL
WHERE FMNB1_QTY = 0

UPDATE tblFT_Badges_pSlips
SET FMNB2_QTY = NULL
WHERE FMNB2_QTY = 0

UPDATE tblFT_Badges_pSlips
SET FMNB3_QTY = NULL
WHERE FMNB3_QTY = 0

UPDATE tblFT_Badges_pSlips
SET NB00MB_QTY = NULL
WHERE NB00MB_QTY = 0

--// Update shipType column with appropriate phrase.
--//  As for the phrasing, the default, meaning that the user didn’t select any special shipping option, is just “SHIP”, then the others are “3 Day”, “2 Day”, and “Next Day”, as well as “Local Pickup”.

--// default
UPDATE tblFT_Badges_pSlips
SET shipType = 'SHIP'
WHERE shipType IS NULL

--// 3 day
UPDATE tblFT_Badges_pSlips
SET shipType = '3 Day'
WHERE orderNo IN
(SELECT DISTINCT orderNo
FROM tblOrders
WHERE LEN(orderNo) IN (9,10)
AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE tblFT_Badges_pSlips
SET shipType = '2 Day'
WHERE orderNo IN
(SELECT DISTINCT orderNo
FROM tblOrders
WHERE LEN(orderNo) IN (9,10)
AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// next day
UPDATE tblFT_Badges_pSlips
SET shipType = 'Next Day'
WHERE orderNo IN
(SELECT DISTINCT orderNo
FROM tblOrders
WHERE LEN(orderNo) IN (9,10)
AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// local pickup, will call
UPDATE tblFT_Badges_pSlips
SET shipType = 'Local Pickup'
WHERE orderNo IN
(SELECT DISTINCT orderNo
FROM tblOrders
WHERE 
LEN(orderNo) IN (9,10) AND (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will%')
OR LEN(orderNo) IN (9,10) AND (CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local pickup%')
OR LEN(orderNo) IN (9,10) AND (CONVERT(VARCHAR(255), shipping_Street) LIKE '%local pickup%')
)

--// Bring in pinback QTY into NB00MB_QTY
UPDATE tblFT_Badges_pSlips
SET NB00MB_QTY = b.productQuantity
FROM tblFT_Badges_pSlips a
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products b ON o.orderID = b.orderID
WHERE b.productCode = 'NB00MB-001'
AND b.fastTrak_shippingLabelOption3 <> 1 
AND b.deleteX <> 'yes'
AND a.NB00MB_QTY IS NULL

--this code might have fubared things; commented out on 7/16/19, jf
--UPDATE a
--SET NB00MB_QTY = (SELECT SUM(ISNULL(op.productQuantity,0))
--FROM tblFT_Badges_pSlips a 
--INNER JOIN tblOrders o ON a.orderNo = o.orderNo
--INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
--WHERE op.ProductCode LIKE 'NB00MB%'
--AND op.deleteX <>'yes')

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
--// Reorder pSlip data by orderNo; new edit JF 1/18/16
DELETE FROM tblFT_Badges_pSlips_reOrder
INSERT INTO tblFT_Badges_pSlips_reOrder (orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType)
SELECT orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType
FROM tblFT_Badges_pSlips
ORDER BY orderNo

DELETE FROM tblFT_Badges_pSlips
INSERT INTO tblFT_Badges_pSlips (orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType)
SELECT orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType
FROM tblFT_Badges_pSlips_reOrder
ORDER BY orderNo

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
---------------------------------------------------------------------------------------------------------------------------------// BEGIN PSU
--Last but not least, this section of code can be deadlock-prone, so it was moved to the back of the sproc to make sure that everything above runs successfully.

--This section of code generates the SUM of badge QTY per orderNo.
--It's broken down into 2 processes: the first operates (1.) when there is a resubmission in the order. We only want to calculate resubs if that's the case. 
--So, badgeQTY is equal to only the SUM of badgeQTYs for resubmitted OPIDs within the order.
--The second operation (2.) will calculate the SUM of badgeQTYS for OPIDs within an order that has NO resubmissions within it.
--Each calc only existing records with fastTrak_preventLabel = 0; meaning that it's either new or a new resub. (this concept has been removed as of 3/15/18, jf. see notes above)

--0. But first, prior to loops, prep temp data that is referenced ---------------------------------------------------------------------------

--//Update badgeQTY with the sum off all original and/or resubbed QTYs per OPID
DELETE FROM tblFT_Badges_pSlips_QTYCalc
INSERT INTO tblFT_Badges_pSlips_QTYCalc (OPID, orderNo, originalQTY)
SELECT DISTINCT p.[ID], o.orderNo, p.productQuantity
FROM tblOrders_Products p
INNER JOIN tblOrders o
	ON p.orderID = o.orderID
WHERE p.deleteX <> 'yes'
AND p.productCode LIKE 'NB%'
--AND p.fastTrak_preventLabel = 0
AND o.orderNo IN
		(SELECT orderNo
		FROM tblFT_Badges_pSlips
		WHERE orderNo IS NOT NULL)

UPDATE tblFT_Badges_pSlips_QTYCalc
SET newQTY = p.fastTrak_newQTY
FROM tblFT_Badges_pSlips_QTYCalc a
INNER JOIN tblOrders_Products p
	ON a.OPID = p.[ID]
WHERE p.fastTrak_newQTY <> ''
--AND p.fastTrak_preventLabel = 0
AND p.fastTrak_newQTY IS NOT NULL

UPDATE tblFT_Badges_pSlips_QTYCalc
SET newQTY = 0
WHERE newQTY IS NULL

UPDATE tblFT_Badges_pSlips_QTYCalc
SET actualQTY = originalQTY
WHERE newQTY = 0

UPDATE tblFT_Badges_pSlips_QTYCalc
SET actualQTY = newQTY
WHERE newQTY <> 0

--1. THERE IS A RESUB PRESENT IN ORDER --------------------------------------------------------------------------------------------------
--Create temp table
IF OBJECT_ID(N'tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER', N'U') IS NOT NULL 
DROP TABLE tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER

CREATE TABLE tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER (
 RowID INT IDENTITY(1, 1), 
 orderNo VARCHAR(50),
 actualQTY INT
)
DECLARE @NumberRecords INT, @RowCount INT
DECLARE @orderNo VARCHAR(50), @actualQTY INT

--Populate temp table
INSERT INTO tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER (orderNo, actualQTY)
SELECT DISTINCT 
orderNo, SUM(newQTY)
FROM [tblFT_Badges_pSlips_QTYCalc]
WHERE orderNo IN
	(SELECT orderNo
	FROM [tblFT_Badges_pSlips_QTYCalc]
	WHERE newQTY <> 0)
GROUP BY orderNo

-- Get the number of records in the temp table
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

-- Update badgeQTY
WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @orderNo = orderNo,
			 @actualQTY = actualQTY
	FROM tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER
	WHERE RowID = @RowCount

	UPDATE tblFT_Badges_pSlips
	SET badgeQTY = b.actualQTY
	FROM tblFT_Badges_pSlips a
	INNER JOIN tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER b
		ON a.orderNo = b.orderNo

	SET @RowCount = @RowCount + 1
END

-- drop temp table
IF OBJECT_ID(N'tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER', N'U') IS NOT NULL 
DROP TABLE tempPSU_QTYFIX_THERE_IS_A_RESUB_PRESENT_IN_ORDER

--2. THERE ARE NO RESUBS PRESENT IN ORDER --------------------------------------------------------------------------------------------------
--Create temp table
IF OBJECT_ID(N'tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER', N'U') IS NOT NULL 
DROP TABLE tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER

CREATE TABLE tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER (
 RowID INT IDENTITY(1, 1), 
 orderNo VARCHAR(50),
 actualQTY INT
)
DECLARE @NumberRecords_z INT, @RowCount_z INT
DECLARE @orderNo_z VARCHAR(50), @actualQTY_z INT

--Populate temp table
INSERT INTO tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER (orderNo, actualQTY)
SELECT DISTINCT 
orderNo, SUM(actualQTY)
FROM [tblFT_Badges_pSlips_QTYCalc]
WHERE orderNo NOT IN
	(SELECT orderNo
	FROM [tblFT_Badges_pSlips_QTYCalc]
	WHERE newQTY <> 0)
GROUP BY orderNo

-- Get the number of records in the temp table
SET @NumberRecords_z = @RowCount_z
SET @RowCount_z = 1

-- Update badgeQTY
WHILE @RowCount_z <= @NumberRecords_z
BEGIN
	SELECT @orderNo_z = orderNo,
			 @actualQTY_z = actualQTY
	FROM tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER
	WHERE RowID = @RowCount_z

	UPDATE tblFT_Badges_pSlips
	SET badgeQTY = b.actualQTY
	FROM tblFT_Badges_pSlips a
	INNER JOIN tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER b
		ON a.orderNo = b.orderNo

	SET @RowCount_z = @RowCount_z + 1
END

-- drop temp table
IF OBJECT_ID(N'tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER', N'U') IS NOT NULL 
DROP TABLE tempPSU_QTYFIX_NO_RESUBS_PRESENT_IN_ORDER
-------------------------------------------------------------------------------------------------------------------------------// END PSU

-- dedup

TRUNCATE TABLE tblFT_Badges_pSlips_Dedup
INSERT INTO tblFT_Badges_pSlips_Dedup (orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType)
SELECT DISTINCT orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType
FROM tblFT_Badges_pSlips
ORDER BY orderNo

TRUNCATE TABLE tblFT_Badges_pSlips
INSERT INTO tblFT_Badges_pSlips (orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType)
SELECT DISTINCT orderNo, badgeQTY, FMNB1, FMNB1_QTY, FMNB2, FMNB2_QTY, FMNB3, FMNB3_QTY, NB00MB_QTY, pinBack, orderType, shipType
FROM tblFT_Badges_pSlips_Dedup
ORDER BY orderNo

--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////--////