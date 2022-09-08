﻿CREATE procEDURE [dbo].[usp_Switch_CM]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     08/3/16
Purpose     Pulls CAR MAG products (CM) into Switch for production.
-------------------------------------------------------------------------------
Modification History

08/03/16		New
09/30/16		Truncation, G2G in primary INSERT.
10/31/16		Updated near LN 221; changed "> 5" to ">= 1" as per email request from KH/AC on 10/31/16.
11/01/16		updated shipsWith Stock section.
12/29/16		Added customBackground code to end of sproc.
01/27/16		Added optionID = '518' code in initial query.
02/13/16		Updated shipsWith Stock section to look for custom, FT before setting to stock.
03/28/17		Added SN to PN, jf.
11/07/17		pulled out BP/BC, jf
11/20/17		removed liststock, jf
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
04/03/18		Killed SN logic with fire, jf.
04/27/18		Added secondary logic to variableWholeName, jf.
06/28/18		JF, added updates to tblProducts.fastTrak_productType sections to account for processType lookups vs. tblProduct lookups.
08/30/18		Added "AND op.processType = 'fasTrak'" to initial query, jf.
12/27/18		JF, added "EXISTS" and "NOT EXISTS" checks for variableWholeName to accomodate how NOP handles Canvas now.
11/14/19		JF, added readyForSwitch check.
11/20/19		JF, modified step 4.a in initial query. for more info on what this is about, see stored proc: [popArtGate].
11/20/19		JF, updated initial query to model other flows in opid qualification.
11/20/19		JF, added final update statement that mimics the BC flow; it prevents future runs of same resubbed OPIDs into subsequent flows.
12/20/19		JF, CRUD.
01/27/19		JF, added Credit Due at top.
06/16/20		JF, fixed SHIPSWITH=Custom to look at processType. Need to rewrite all of this.
08/04/20		JF, Added stripper to init query.
09/09/20		JF, Added fileExists fix to init query.
10/13/20		JF, Added resubmission section that modifies ShipsWith value if OPID is resubbed.
10/23/20		JF, LEN(orderNo) IN (9,10)
12/02/20		CKB, iFrame conversion changes
04/21/21		CKB, modified file check #5
12/17/21		CKB, fix stock count to match QC logic - clickup #1wv1ntt 
02/11/22		CKB, modified sports gate logic to be data driven group gates - clickup #1x7bmfc
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

DECLARE @flowName AS VARCHAR(20) = 'CM'


DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'CM Switch SP', @lastRunDate;

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

BEGIN TRY 

TRUNCATE TABLE tblSwitch_CM
INSERT INTO tblSwitch_CM (orderID, orderNo, orderDate, customerID, 
shippingAddressID, shipCompany, shipFirstName, shipLastName, 
shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, 
productCode, productName, 
shortName, productQuantity, 
packetValue, 
variableTopName, 
variableBottomName, 
variableWholeName, 
backName, 
numUnits, 
displayedQuantity, 
ordersProductsID, 
shipsWith, 
resubmit, 
shipType, 
samplerRequest, 
multiCount, totalCount,
displayCount, 
background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, 
productID, parentProductID, 
mo_orders_Products, mo_orders, mo_customers_ShippingAddress, 
switch_create, switch_import,
customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, 
fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, 
stockProductCount, 
stockProductQuantity1, stockProductCode1, stockProductDescription1, 
stockProductQuantity2, stockProductCode2, stockProductDescription2, 
stockProductQuantity3, stockProductCode3, stockProductDescription3, 
stockProductQuantity4, stockProductCode4, stockProductDescription4, 
stockProductQuantity5, stockProductCode5, stockProductDescription5, 
stockProductQuantity6, stockProductCode6, stockProductDescription6)

SELECT
a.orderID, a.orderNo, a.orderDate, a.customerID, 
[dbo].[fn_BadCharacterStripper_noLower](s.shippingAddressID) AS shippingAddressID, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Company) AS shipping_Company, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Firstname) AS shipping_Firstname, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_surName) AS shipping_surName, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Street) AS shipping_Street, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Street2) AS shipping_Street2, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Suburb) AS shipping_Suburb, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_State) AS shipping_State, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_PostCode) AS shipping_PostCode, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Country) AS shipping_Country, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Phone) AS shipping_Phone, 
op.productCode, op.productName, 
'' AS 'shortName',
op.productQuantity, 
'1 of 1' AS 'packetValue',
'' AS 'variableTopName',
'' AS 'variableBottomName',
'' AS 'variableWholeName',
'' AS 'backName', 
p.numUnits,
op.productQuantity * p.numUnits AS 'displayedQuantity',
op.[ID],
'Ship' AS 'shipsWith',
0 AS 'resubmit',
'Ship' AS shipType,
'' AS samplerRequest,
'' AS 'multiCount', '' AS 'totalCount',
'' AS 'displayCount',
'' AS background, '' AS templateFile, '' AS team1FileName, '' AS team2FileName, '' AS team3FileName, '' AS team4FileName, '' AS team5FileName, '' AS team6FileName,
p.productID, p.parentProductID,
op.modified_on, a.modified_on, s.modified_on, 
0 AS 'switch_create', 0 AS 'switch_import',  
0 AS 'customProductCount', '' AS 'customProductCode1', '' AS 'customProductCode2', '' AS 'customProductCode3', '' AS 'customProductCode4', 
0 AS 'fasTrakProductCount', '' AS 'fasTrakProductCode1', '' AS 'fasTrakProductCode2', '' AS 'fasTrakProductCode3', '' AS 'fasTrakProductCode4', 
0 AS 'stockProductCount',
0 AS 'stockProductQuantity1', '' AS 'stockProductCode1', '' AS 'stockProductDescription1',
0 AS 'stockProductQuantity2', '' AS 'stockProductCode2', '' AS 'stockProductDescription2',
0 AS 'stockProductQuantity3', '' AS 'stockProductCode3', '' AS 'stockProductDescription3',
0 AS 'stockProductQuantity4', '' AS 'stockProductCode4', '' AS 'stockProductDescription4',
0 AS 'stockProductQuantity5', '' AS 'stockProductCode5', '' AS 'stockProductDescription5',
0 AS 'stockProductQuantity6', '' AS 'stockProductCode6', '' AS 'stockProductDescription6'
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
LEFT JOIN tblSkuGroup sg ON p.productCode LIKE sg.skuPattern
LEFT JOIN tblSkuGroupGate g ON sg.skuGroup = g.skuGroup
WHERE
DATEDIFF(MI, a.created_on, GETDATE()) > 60
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.orderStatus NOT LIKE '%Waiting%'
AND op.processType = 'fasTrak'
AND a.displayPaymentStatus IN ('Good', 'Credit Due')
AND op.deleteX <> 'yes'
AND (SUBSTRING(p.productCode, 1, 2) = 'CM'
	AND p.productCode <> 'CMJU00-01')
AND op.[ID] NOT IN 
	(SELECT ordersProductsID 
	FROM tblSwitch_CM 
	WHERE ordersProductsID IS NOT NULL)

--2.1  Gate
AND (sg.skuGroup IS NULL OR -- not a sport product
		(sg.[include]= 1  --pattern is good
			AND NOT EXISTS (SELECT *
							FROM tblproducts p2
							INNER JOIN tblSkuGroup sg2 ON p2.productCode LIKE sg2.skuPattern
							WHERE sg2.skugroup = sg.skugroup and p2.productCode = p.productCode AND sg2.[include]= 0)  --pattern is not excluded e.g. BKIN%
			-- sport is turned on or is 'good to go' or 'ship now'
			AND (g.[Include] = 1	
				OR (g.gtgOverride = 1 and op.fastTrak_status = 'Good to Go')
				OR (g.shipNowOverride = 1 and EXISTS (SELECT TOP 1 1 FROM tblOrdersProducts_ProductOptions x WHERE x.ordersProductsID = op.Id AND x.textValue = 'TBD Schedule' AND deletex <> 'yes'))
				)
		 )
	)

AND (
		--4.a
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		AND EXISTS
				(SELECT TOP 1 1
				FROM tblOrdersProducts_productOptions opp1
				WHERE deleteX <> 'yes'
				AND optionCaption = 'OPC'
				AND opp1.ordersProductsID = op.ID)
		AND NOT EXISTS
				(SELECT TOP 1 1 ordersProductsID
				FROM tblOrdersProducts_productOptions opp2
				WHERE deleteX <> 'yes'
				AND RIGHT(textValue, 2) = '_J'		--default layout - same before/after  no iFrame conversion needed
				AND opp2.ordersProductsID = op.ID)
		--4.b
		OR op.fastTrak_status = 'Good to Go'
		--4.c
		OR op.fastTrak_resubmit = 1
		)
AND op.ID NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 518)		--- leave as-is iFrame---
AND a.orderDate > CONVERT(DATETIME, '09/01/2019')

--5. Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND EXISTS			--must have a file	
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.OPID = op.id)

AND NOT EXISTS		-- none of the files can be missing/broken		
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.id)





--// fix productQuantity if fasTrak_newQTY value exists
UPDATE tblSwitch_CM
SET productQuantity = b.fastTrak_newQTY
FROM tblSwitch_CM a
INNER JOIN tblOrders_Products b
	ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY

--// variableBottomName; tiered.
UPDATE tblSwitch_CM
SET variableBottomName = orderNo + '_' + CONVERT(VARCHAR(255), ordersProductsID) + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) = '243'

UPDATE tblSwitch_CM														-- there are no 243 CM records in live - iFrame
SET variableBottomName = productCode + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) <> '243'

--// variableWholeName - GLUON
UPDATE tblSwitch_CM
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_CM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- not canvas/OPC - iFrame

--// variableWholeName - CANVAS
UPDATE tblSwitch_CM
SET variableWholeName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '') END
FROM tblSwitch_CM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE a.variableWholeName = ''
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('Intranet PDF','CanvasHiResFront UNC File')	-- added canvas for iFrame conversion
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))		-- canvas/OPC - iFrame

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
SET @json = (SELECT orderid,@flowName as switchflow from tblSwitch_CM FOR JSON PATH);
EXECUTE @RC = [dbo].[GetShipsWith] 
   @json
  ,@retJson OUTPUT

SELECT   orderID
		,customProductCount
		,customProductCode1
		,customProductCode2
		,customProductCode3
		,customProductCode4
		,fasTrakProductCount
		,fasTrakProductCode1
		,fasTrakProductCode2
		,fasTrakProductCode3
		,fasTrakProductCode4
		,stockProductCount
		,stockProductCode1
		,stockProductDescription1
		,stockProductQuantity1
		,stockProductCode2
		,stockProductDescription2
		,stockProductQuantity2
		,stockProductCode3
		,stockProductDescription3
		,stockProductQuantity3
		,stockProductCode4
		,stockProductDescription4
		,stockProductQuantity4
		,stockProductCode5
		,stockProductDescription5
		,stockProductQuantity5
		,stockProductCode6
		,stockProductDescription6
		,stockProductQuantity6
	INTO #tmpShip
		FROM OPENJSON(@retJson)
		WITH  (		orderID int '$.orderID',
		CustomProductCount int '$.CustomProductCount',
		customProductCode1 varchar(255) '$.customProductCode1',
		customProductCode2 varchar(255) '$.customProductCode2',
		customProductCode3 varchar(255) '$.customProductCode3',
		customProductCode4 varchar(255) '$.customProductCode4',
		FasTrakProductCount int '$.FasTrakProductCount',
		FasTrakProductCode1 varchar(255) '$.FasTrakProductCode1',
		FasTrakProductCode2 varchar(255) '$.FasTrakProductCode2',
		FasTrakProductCode3 varchar(255) '$.FasTrakProductCode3',
		FasTrakProductCode4 varchar(255) '$.FasTrakProductCode4',
		StockProductCount int '$.StockProductCount',
		StockProductCode1 varchar(255) '$.StockProductCode1',
		StockProductDescription1 varchar(255) '$.StockProductDescription1',
		StockProductQuantity1 varchar(255) '$.StockProductQuantity1',
		StockProductCode2 varchar(255) '$.StockProductCode2',
		StockProductDescription2 varchar(255) '$.StockProductDescription2',
		StockProductQuantity2 varchar(255) '$.StockProductQuantity2',
		StockProductCode3 varchar(255) '$.StockProductCode3',
		StockProductDescription3 varchar(255) '$.StockProductDescription3',
		StockProductQuantity3 varchar(255) '$.StockProductQuantity3',
		StockProductCode4 varchar(255) '$.StockProductCode4',
		StockProductDescription4 varchar(255) '$.StockProductDescription4',
		StockProductQuantity4 varchar(255) '$.StockProductQuantity4',
		StockProductCode5 varchar(255) '$.StockProductCode5',
		StockProductDescription5 varchar(255) '$.StockProductDescription5',
		StockProductQuantity5 varchar(255) '$.StockProductQuantity5',
		StockProductCode6 varchar(255) '$.StockProductCode6',
		StockProductDescription6 varchar(255) '$.StockProductDescription6',
		StockProductQuantity6 varchar(255) '$.StockProductQuantity6')

-- Custom. If an OPID from this flow ships with another OPID that is not a pen and has processType = 'Custom', then set shipsWith = 'custom' for current OPID.

UPDATE s
SET shipsWith = CASE WHEN t.CustomProductCount > 0  THEN 'Custom'
					 WHEN t.FasTrakProductCount > 0 THEN 'Fastrak'
					 WHEN t.StockProductCount > 0 THEN 'Stock'
					 ELSE 'Ship' END
FROM tblSwitch_CM s
LEFT JOIN #tmpShip t on s.orderID = t.orderID;

UPDATE s
SET shipsWith = 'Local Pickup'
FROM tblSwitch_CM s
INNER JOIN tblOrders o ON s.orderid = o.orderid
	WHERE (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')


-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
UPDATE x
SET resubmit = 1
FROM tblSwitch_CM x
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND op.fastTrak_resubmit = 1
	AND op.ID = x.ordersProductsID)

-- For any OPID that has been resubbed, update ShipsWith accordingly
IF OBJECT_ID('tempdb..#tempResubChoiceCM') IS NOT NULL 
DROP TABLE #tempResubChoiceCM

CREATE TABLE #tempResubChoiceCM (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @NumberRecords_rs INT, 
				 @RowCount_rs INT,
				 @OPID_rs INT,
				 @MostRecent_ResubChoice_rs INT

INSERT INTO #tempResubChoiceCM (OPID)
SELECT DISTINCT ordersProductsID
FROM tblSwitch_CM
WHERE resubmit = 1

SET @NumberRecords_rs = @@RowCount
SET @RowCount_rs = 1

WHILE @RowCount_rs <= @NumberRecords_rs
BEGIN
	 SELECT @OPID_rs = OPID
	 FROM #tempResubChoiceCM
	 WHERE RowID = @RowCount_rs

	 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
															FROM tblSwitch_resubOption
															WHERE OPID = @OPID_rs
															ORDER BY resubmitDate DESC)
	
	UPDATE tblSwitch_CM
	SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
	WHERE ordersProductsID = @OPID_rs	 

	SET @RowCount_rs = @RowCount_rs + 1
END
-- RESUBMISSION SECTION -------------------------------------------------------------------------------END


--// shipType Update
--// default
UPDATE tblSwitch_CM
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE tblSwitch_CM
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE tblSwitch_CM
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE tblSwitch_CM
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE tblSwitch_CM
SET shipType = 'Local Pickup'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE 
	LEN(orderNo) IN (9,10) 
	AND (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
		OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will%')
	OR 
	LEN(orderNo) IN (9,10) 
	AND (CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')
	)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ displayCount calculation
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ begin.
--// Run counts to populate totalCount column, which grabs the number of distinct ordersProductIDs per orderID.

TRUNCATE TABLE tblSwitch_CM_distinctIDCount
INSERT INTO tblSwitch_CM_distinctIDCount (orderID, ordersProductsID)
SELECT DISTINCT orderID, ordersProductsID
FROM tblSwitch_CM

TRUNCATE TABLE tblSwitch_CM_distinctIDCount2
INSERT INTO tblSwitch_CM_distinctIDCount2 (orderID, countOrderID)
SELECT orderID, COUNT(orderID) AS 'countOrderID'
FROM tblSwitch_CM_distinctIDCount
GROUP BY orderID
ORDER BY orderID

UPDATE tblSwitch_CM
SET totalCount = b.countOrderID
FROM tblSwitch_CM a 
INNER JOIN tblSwitch_CM_distinctIDCount2 b
	ON a.orderID = b.orderID

UPDATE tblSwitch_CM
SET displayCount = NULL,
multiCount = totalCount

--// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin PCU
--// Counts (multiCount and totalCount)
IF OBJECT_ID(N'tblSwitch_CM_displayCount', N'U') IS NOT NULL
DROP TABLE tblSwitch_CM_displayCount

CREATE TABLE tblSwitch_CM_displayCount 
	(RowID INT IDENTITY(1, 1), 
	orderID INT, 
	ordersProductsID INT, 
	totalCount INT)
DECLARE @NumberRecords INT, @RowCount INT
DECLARE @orderID INT
DECLARE @ordersProductsID INT
DECLARE @totalCount INT
DECLARE @topMultiCount INT


--// Create table that houses all orderIDs that have more than 1 DISTINCT ordersProductsID in them.
TRUNCATE TABLE tblSwitch_CM_displayCount
INSERT INTO tblSwitch_CM_displayCount (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM tblSwitch_CM
WHERE orderID IS NOT NULL
AND totalCount <> 1
ORDER BY orderID, ordersProductsID
 
-- Get the number of records in the temporary table
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

--// Begin iterative update on multiCount on all orderIDs that have more than 1 DISTINCT ordersProductsID in them.
WHILE @RowCount < = @NumberRecords
BEGIN

	SELECT @orderID = orderID, 
	@ordersProductsID = ordersProductsID,
	@totalCount = totalCount
	FROM tblSwitch_CM_displayCount
	WHERE RowID = @RowCount
	
	UPDATE tblSwitch_CM
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM tblSwitch_CM
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE tblSwitch_CM
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE tblSwitch_CM
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE tblSwitch_CM SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ displayCount calculation
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end.
--// Background
UPDATE tblSwitch_CM
SET background = b.textValue
FROM tblSwitch_CM a
INNER JOIN tblOrdersProducts_ProductOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE  b.optionCaption = 'Background File Name'				-- not present in CM records -  iFrame
AND b.deleteX <> 'yes'
AND a.background <> b.textValue

UPDATE tblSwitch_CM
SET background = REPLACE(background, '.eps', '.pdf')
WHERE background LIKE '%.eps'

--// templateFile
UPDATE tblSwitch_CM
SET templateFile = b.textValue
FROM tblSwitch_CM a
INNER JOIN tblOrdersProducts_ProductOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE  b.optionCaption = 'Layout File Name'			-- not present in CM records -  iFrame
AND b.deleteX <> 'yes'
AND a.templateFile <> b.textValue

--// Set flags
UPDATE tblSwitch_CM SET switch_approve = 0
UPDATE tblSwitch_CM SET switch_print = 0
UPDATE tblSwitch_CM SET switch_approveDate = GETDATE()
UPDATE tblSwitch_CM SET switch_printDate = GETDATE()
UPDATE tblSwitch_CM SET switch_createDate = GETDATE()

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////// SHIPS WITH COUNTS ///////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


UPDATE s
SET  customProductCount = ISNULL(t.customProductCount,0)
	,customProductCode1 = t.customProductCode1
	,customProductCode2 = t.customProductCode2
	,customProductCode3 = t.customProductCode3
	,customProductCode4 = t.customProductCode4
	,fasTrakProductCount = ISNULL(t.fasTrakProductCount,0)
	,fasTrakProductCode1 = t.fasTrakProductCode1
	,fasTrakProductCode2 = t.fasTrakProductCode2
	,fasTrakProductCode3 = t.fasTrakProductCode3
	,fasTrakProductCode4 = t.fasTrakProductCode4
	,stockProductCount = ISNULL(t.stockProductCount,0)
	,stockProductCode1 = t.stockProductCode1
	,stockProductCode2 = t.stockProductCode2
	,stockProductCode3 = t.stockProductCode3
	,stockProductCode4 = t.stockProductCode4
	,stockProductQuantity1 = t.stockproductQuantity1
	,stockProductQuantity2 = t.stockproductQuantity2
	,stockProductQuantity3 = t.stockproductQuantity3
	,stockProductQuantity4 = t.stockproductQuantity4
	,stockProductQuantity5 = t.stockproductQuantity5
	,stockProductQuantity6 = t.stockproductQuantity6
	,stockProductDescription1 = t.stockproductDescription1
	,stockProductDescription2 = t.stockproductDescription2
	,stockProductDescription3 = t.stockproductDescription3
	,stockProductDescription4 = t.stockproductDescription4
	,stockProductDescription5 = t.stockproductDescription5
	,stockProductDescription6 = t.stockproductDescription6
	FROM tblSwitch_CM s
INNER JOIN #tmpShip t on s.orderID = t.orderID


--// change PSD to PDF extension; 12/29/15 jf.
UPDATE tblSwitch_CM
SET variableTopName = REPLACE(variableTopName, '.psd', '.pdf')
WHERE variableTopName LIKE '%.psd'

UPDATE tblSwitch_CM
SET variableBottomName = REPLACE(variableBottomName, '.psd', '.pdf')
WHERE variableBottomName LIKE '%.psd'

UPDATE tblSwitch_CM
SET variableWholeName = REPLACE(variableWholeName, '.psd', '.pdf')
WHERE variableWholeName LIKE '%.psd'

--// update customBackground value; new, 12/29/16 jf.
UPDATE tblSwitch_CM
SET customBackground = b.optionCaption
FROM tblSwitch_CM a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'

TRUNCATE TABLE tblSwitch_CM_ForOutput
INSERT INTO tblSwitch_CM_ForOutput (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground
FROM tblSwitch_CM 
ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

--INSERT INTO tblSwitch_CMLog (PKID, ordersProductsID, insertedOn)
--SELECT DISTINCT PKID, ordersProductsID, GETDATE()
--FROM tblSwitch_CM_ForOutput

--Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'CM'
,a.PKID
,a.ordersProductsID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from tblSwitch_CM_ForOutput b
       where a.PKID = b.PKID
       for json path)
from tblSwitch_CM_ForOutput a

-- Update OPID status fields indicating successful submission to switch
UPDATE tblOrders_Products
SET switch_create = 1,
	fastTrak_status = 'In Production',
	fastTrak_status_lastModified = GETDATE(),
	fastTrak_resubmit = 0
FROM tblOrders_Products op
INNER JOIN tblSwitch_CM_ForOutput t ON op.ID = t.ordersProductsID

SELECT *
FROM tblSwitch_CM_ForOutput 
ORDER BY PKID, orderID, displayCount, ordersProductsID, packetValue ASC



END TRY
BEGIN CATCH

--Capture errors if they happen
EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH