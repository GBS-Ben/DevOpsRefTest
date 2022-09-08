CREATE PROCEDURE [dbo].[usp_Switch_NBS] 
AS
/*
-------------------------------------------------------------------------------
Author      Cherilyn Browne	
Created     03/07/22
Purpose     Pulls Shaped Name Badges into Switch for production.
-------------------------------------------------------------------------------
Modification History

03/07/22		New - modeled from usp_Switch_QM
-------------------------------------------------------------------------------
*/
DECLARE @flowName AS VARCHAR(20) = 'NBS'

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'NBS Switch SP', @lastRunDate;

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

DECLARE @OrderOffset INT; 
EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;


BEGIN TRY

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FLAG
-- Flags
DECLARE @Flag BIT
SET @Flag = (SELECT FlagStatus FROM Flags WHERE FlagName = 'ImposerNBS')
					   
--IF @Flag = 0
--BEGIN
UPDATE Flags
SET FlagStatus = 1
WHERE FlagName = 'ImposerNBS'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FILE EXISTS

--First, validate image files
EXEC usp_OPPO_validateFile 'NBS'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CREATE MAIN QUERY
IF OBJECT_ID('tempdb..#ImposerNBS') IS NOT NULL 
DROP TABLE #ImposerNBS
CREATE TABLE #ImposerNBS (
	[orderID] [int] NULL,
	[orderNo] [nvarchar](255) NULL,
	[orderDate] [datetime] NULL,
	[customerID] [int] NULL,
	[shippingAddressID] [int] NULL,
	[shipCompany] [nvarchar](255) NULL,
	[shipFirstName] [nvarchar](255) NULL,
	[shipLastName] [nvarchar](255) NULL,
	[shipAddress1] [nvarchar](255) NULL,
	[shipAddress2] [nvarchar](255) NULL,
	[shipCity] [nvarchar](255) NULL,
	[shipState] [nvarchar](255) NULL,
	[shipZip] [nvarchar](255) NULL,
	[shipCountry] [nvarchar](255) NULL,
	[shipPhone] [nvarchar](255) NULL,
	[productCode] [nvarchar](50) NULL,
	[productName] [nvarchar](255) NULL,
	[shortName] [nvarchar](255) NULL,
	[productQuantity] [int] NULL,
	[packetValue] [nvarchar](50) NULL,
	[variableTopName] [nvarchar](255) NULL,
	[variableBottomName] [nvarchar](255) NULL,
	[variableWholeName] [nvarchar](255) NULL,
	[backName] [nvarchar](255) NULL,
	[numUnits] [int] NULL,
	[displayedQuantity] [int] NULL,
	[ordersProductsID] [int] NULL,
	[shipsWith] [nvarchar](255) NULL,
	[resubmit] [bit] NULL,
	[shipType] [nvarchar](50) NULL,
	[samplerRequest] [nvarchar](50) NULL,
	[multiCount] [int] NULL,
	[totalCount] [int] NULL,
	[displayCount] [nvarchar](50) NULL,
	[background] [nvarchar](255) NULL,
	[templateFile] [nvarchar](255) NULL,
	[team1FileName] [nvarchar](255) NULL,
	[team2FileName] [nvarchar](255) NULL,
	[team3FileName] [nvarchar](255) NULL,
	[team4FileName] [nvarchar](255) NULL,
	[team5FileName] [nvarchar](255) NULL,
	[team6FileName] [nvarchar](255) NULL,
	[groupID] [int] NULL,
	[productID] [int] NULL,
	[parentProductID] [int] NULL,
	[switch_create] [bit] NULL,
	[switch_createDate] [datetime] NULL,
	[switch_approve] [bit] NULL,
	[switch_approveDate] [datetime] NULL,
	[switch_print] [bit] NULL,
	[switch_printDate] [datetime] NULL,
	[switch_import] [bit] NULL,
	[mo_orders_Products] [datetime] NULL,
	[mo_orders] [datetime] NULL,
	[mo_customers] [datetime] NULL,
	[mo_customers_ShippingAddress] [datetime] NULL,
	[mo_oppo] [datetime] NULL,
	[customProductCount] [int] NULL,
	[customProductCode1] [nvarchar](50) NULL,
	[customProductCode2] [nvarchar](50) NULL,
	[customProductCode3] [nvarchar](50) NULL,
	[customProductCode4] [nvarchar](50) NULL,
	[fasTrakProductCount] [int] NULL,
	[fasTrakProductCode1] [nvarchar](50) NULL,
	[fasTrakProductCode2] [nvarchar](50) NULL,
	[fasTrakProductCode3] [nvarchar](50) NULL,
	[fasTrakProductCode4] [nvarchar](50) NULL,
	[stockProductCount] [int] NULL,
	[stockProductQuantity1] [int] NULL,
	[stockProductCode1] [nvarchar](50) NULL,
	[stockProductDescription1] [nvarchar](255) NULL,
	[stockProductQuantity2] [int] NULL,
	[stockProductCode2] [nvarchar](50) NULL,
	[stockProductDescription2] [nvarchar](255) NULL,
	[stockProductQuantity3] [int] NULL,
	[stockProductCode3] [nvarchar](50) NULL,
	[stockProductDescription3] [nvarchar](255) NULL,
	[stockProductQuantity4] [int] NULL,
	[stockProductCode4] [nvarchar](50) NULL,
	[stockProductDescription4] [nvarchar](255) NULL,
	[stockProductQuantity5] [int] NULL,
	[stockProductCode5] [nvarchar](50) NULL,
	[stockProductDescription5] [nvarchar](255) NULL,
	[stockProductQuantity6] [int] NULL,
	[stockProductCode6] [nvarchar](50) NULL,
	[stockProductDescription6] [nvarchar](255) NULL,
	[UV] [bit] NULL,
	[customBackground] [nvarchar](255) NULL)

INSERT INTO #ImposerNBS (orderID, orderNo, orderDate, customerID, 
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
--1. Order Qualification ----------------------------------
DATEDIFF(MI, a.created_on, GETDATE()) > 60  --increase the time so Calendars and FB have time to load in
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus IN ('Good', 'Credit Due')

--2. Product Qualification ----------------------------------
AND op.productCode like 'NB__S%' and op.productCode not like 'NB___U%'

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

--3. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType IN ('fasTrak','Custom')
AND (
		--3.a
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		AND NOT EXISTS
				(SELECT TOP 1 1 ordersProductsID
				FROM tblOrdersProducts_productOptions opp2
				WHERE deleteX <> 'yes'
				AND RIGHT(textValue, 2) = '_J'		--default layout - same before/after  no iFrame conversion needed
				AND opp2.ordersProductsID = op.ID)
		OR op.fastTrak_status = 'Good to Go'
		--3.c
		OR op.fastTrak_resubmit = 1
		)

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

-- For any OPID that is missing an image, send an email
IF OBJECT_ID('tempdb..#tempPSUFileCheckImposerNBS') IS NOT NULL 
DROP TABLE #tempPSUFileCheckImposerNBS

CREATE TABLE #tempPSUFileCheckImposerNBS (
RowID INT IDENTITY(1, 1), 
FILE_EXISTS_ROWID INT, 
OPID INT)

DECLARE @FILE_EXISTS_ROWID INT,
				 @OPIDX INT,
				 @NumberRecords_x INT, 
				 @RowCount_x INT

INSERT INTO #tempPSUFileCheckImposerNBS (FILE_EXISTS_ROWID, OPID)
SELECT x.rowID, q.ordersProductsID
FROM tblOPPO_fileExists x 
INNER JOIN #ImposerNBS q ON x.OPID = q.ordersProductsID
WHERE x.fileExists = 0
AND x.ignoreCheck = 0
ORDER BY x.rowID, q.ordersProductsID

--send email
SET @NumberRecords_x = @@ROWCOUNT
SET @RowCount_x = 1

WHILE @RowCount_x <= @NumberRecords_x
BEGIN
	 SELECT @FILE_EXISTS_ROWID = FILE_EXISTS_ROWID,
				   @OPIDX = OPID
	 FROM #tempPSUFileCheckImposerNBS
	 WHERE RowID = @RowCount_x

	 EXEC usp_OPPO_fileExist_sendEmail @FILE_EXISTS_ROWID, @OPIDX

SET @RowCount_x = @RowCount_x + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// INSERT DATA
--insert data into #tblSwitch_NBS based on file existence
DROP TABLE IF EXISTS #tblSwitch_NBS

SELECT DISTINCT IDENTITY(INT,1,1) AS PKID,
q.orderID, q.orderNo, q.orderDate, q.customerID, q.shippingAddressID, q.shipCompany, q.shipFirstName, q.shipLastName, 
q.shipAddress1, q.shipAddress2, q.shipCity, q.shipState, q.shipZip, q.shipCountry, q.shipPhone, q.productCode, q.productName, 
q.shortName, q.productQuantity, q.packetValue, q.variableTopName, q.variableBottomName, q.variableWholeName, q.backName, 
q.numUnits, q.displayedQuantity, q.ordersProductsID, q.shipsWith, q.resubmit, q.shipType, q.samplerRequest, q.multiCount, 
q.totalCount, q.displayCount, q.background, q.templateFile, q.team1FileName, q.team2FileName, q.team3FileName, 
q.team4FileName, q.team5FileName, q.team6FileName, q.productID, q.parentProductID, q.mo_orders_Products, q.mo_orders, 
q.mo_customers_ShippingAddress, q.switch_create, q.switch_import,customProductCount, q.customProductCode1, 
q.customProductCode2, q.customProductCode3, q.customProductCode4, q.fasTrakProductCount, q.fasTrakProductCode1, 
q.fasTrakProductCode2, q.fasTrakProductCode3, q.fasTrakProductCode4, q.stockProductCount, q.stockProductQuantity1, 
q.stockProductCode1, q.stockProductDescription1, q.stockProductQuantity2, q.stockProductCode2, q.stockProductDescription2, 
q.stockProductQuantity3, q.stockProductCode3, q.stockProductDescription3, q.stockProductQuantity4, q.stockProductCode4, 
q.stockProductDescription4, q.stockProductQuantity5, q.stockProductCode5, q.stockProductDescription5, 
q.stockProductQuantity6, q.stockProductCode6, q.stockProductDescription6, 
templateJson=cast(null as varchar(8000)),
switch_approve = 0,
switch_print = 0,
switch_approveDate = GETDATE(),
switch_printDate = GETDATE(),
switch_createDate = GETDATE(),
cast(null as int) as groupID,
cast(null as datetime) as Mo_customers,
cast(null as datetime) as Mo_oppo,
cast(0 as bit) as Uv,
cast(null as nvarchar(255)) as Custombackground

INTO #tblSwitch_NBS
FROM #ImposerNBS q


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Do Work
--// fix productQuantity if fasTrak_newQTY value exists
UPDATE a
SET productQuantity = b.fastTrak_newQTY
FROM #tblSwitch_NBS a
INNER JOIN tblOrders_Products b	ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY



--BEGIN VARIABLE WHOLENAME ---------------------------------------------------------------------------
--// variablewholename; 
UPDATE a
SET variableWholeName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE @UncBasePath + ISNULL(b.textValue, 'MissingImage') END
FROM #tblSwitch_NBS a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('CanvasHiResFront UNC File')

UPDATE a
SET variableWholeName = @UncBasePath + ISNULL(b.textValue, 'MissingImage') 
FROM #tblSwitch_NBS a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('Intranet PDF')
AND ISNULL(variableWholeName, '') = ''
--AND EXISTS
--	(SELECT TOP 1 1
--	FROM tblOrdersProducts_productOptions oppx
--	WHERE a.ordersProductsID = oppx.ordersProductsID 
--	AND oppx.optionID in (535,399))	-- canvas/OPC - iFrame

--END VARIABLE WHOLENAME ---------------------------------------------------------------------------

--// backName update.
UPDATE a
SET backName = b.textValue
FROM #tblSwitch_NBS a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.deleteX <> 'yes'
AND b.optionCaption IN ( 'Product Back','Back Design','CanvasHiResBack UNC File')
AND b.textValue <> 'BLANK'


--// update all Custom Inserted OPIDs to the hardcoded PDF path in the archive directory; jf 10/12/2016.
UPDATE x
SET 
variableWholeName = @UncBasePath + REPLACE(REPLACE(orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(50), ordersProductsID) + '.pdf'
FROM #tblSwitch_NBS x
WHERE ISNULL(variableWholeName, '') = ''
AND ISNULL(variableTopName, '') = ''


--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
SET @json = (SELECT orderid,@flowName as switchflow from #tblSwitch_NBS FOR JSON PATH);
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
FROM #tblSwitch_NBS s
LEFT JOIN #tmpShip t on s.orderID = t.orderID;

UPDATE s
SET shipsWith = 'Local Pickup'
FROM #tblSwitch_NBS s
INNER JOIN tblOrders o ON s.orderid = o.orderid
	WHERE (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')


-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
UPDATE x
SET resubmit = 1
FROM #tblSwitch_NBS x
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND op.fastTrak_resubmit = 1
	AND op.ID = x.ordersProductsID)

-- For any OPID that has been resubbed, update ShipsWith accordingly
IF OBJECT_ID('tempdb..#tempResubChoice_NBS') IS NOT NULL 
DROP TABLE #tempResubChoice_NBS

CREATE TABLE #tempResubChoice_NBS (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @NumberRecords_rs INT, 
				 @RowCount_rs INT,
				 @OPID_rs INT,
				 @MostRecent_ResubChoice_rs INT

INSERT INTO #tempResubChoice_NBS (OPID)
SELECT DISTINCT ordersProductsID
FROM #tblSwitch_NBS
WHERE resubmit = 1

SET @NumberRecords_rs = @@RowCount
SET @RowCount_rs = 1

WHILE @RowCount_rs <= @NumberRecords_rs
BEGIN
	 SELECT @OPID_rs = OPID
	 FROM #tempResubChoice_NBS
	 WHERE RowID = @RowCount_rs

	 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
															FROM tblSwitch_resubOption
															WHERE OPID = @OPID_rs
															ORDER BY resubmitDate DESC)
	
	UPDATE #tblSwitch_NBS
	SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
	WHERE ordersProductsID = @OPID_rs	 

	SET @RowCount_rs = @RowCount_rs + 1
END
-- RESUBMISSION SECTION -------------------------------------------------------------------------------END

--// shipType Update
--// default
UPDATE #tblSwitch_NBS
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE #tblSwitch_NBS
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE #tblSwitch_NBS
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE #tblSwitch_NBS
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE #tblSwitch_NBS
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

--// Run counts to populate totalCount column, which grabs the number of distinct ordersProductIDs per orderID.
DROP TABLE IF EXISTS #tblSwitch_NBS_distinctIDCount
SELECT DISTINCT orderID, ordersProductsID
INTO #tblSwitch_NBS_distinctIDCount
FROM #tblSwitch_NBS

DROP TABLE IF EXISTS #tblSwitch_NBS_distinctIDCount2
SELECT orderID, COUNT(orderID) AS 'countOrderID'
INTO #tblSwitch_NBS_distinctIDCount2
FROM #tblSwitch_NBS_distinctIDCount
GROUP BY orderID
ORDER BY orderID

UPDATE #tblSwitch_NBS
SET totalCount = b.countOrderID
FROM #tblSwitch_NBS a 
INNER JOIN #tblSwitch_NBS_distinctIDCount2 b ON a.orderID = b.orderID

UPDATE #tblSwitch_NBS
SET displayCount = NULL,
multiCount = totalCount

--// Counts (multiCount and totalCount)
DROP TABLE IF EXISTS #tblSwitch_NBS_displayCount

CREATE TABLE #tblSwitch_NBS_displayCount 
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
TRUNCATE TABLE #tblSwitch_NBS_displayCount
INSERT INTO #tblSwitch_NBS_displayCount (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM #tblSwitch_NBS
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
	FROM #tblSwitch_NBS_displayCount
	WHERE RowID = @RowCount
	
	UPDATE #tblSwitch_NBS
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM #tblSwitch_NBS
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE #tblSwitch_NBS
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE #tblSwitch_NBS
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE #tblSwitch_NBS SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'


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
	FROM #tblSwitch_NBS s
INNER JOIN #tmpShip t on s.orderID = t.orderID

UPDATE #tblSwitch_NBS
SET variableTopName = REPLACE(variableTopName, '.psd', '.pdf')
WHERE variableTopName LIKE '%.psd'

UPDATE #tblSwitch_NBS
SET variableBottomName = REPLACE(variableBottomName, '.psd', '.pdf')
WHERE variableBottomName LIKE '%.psd'

UPDATE #tblSwitch_NBS
SET variableWholeName = REPLACE(variableWholeName, '.psd', '.pdf')
WHERE variableWholeName LIKE '%.psd'

UPDATE #tblSwitch_NBS
SET background = REPLACE(background, '.psd', '.pdf')
WHERE background LIKE '%.psd'

UPDATE #tblSwitch_NBS
SET customBackground = b.optionCaption
FROM #tblSwitch_NBS a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'

--/////////////////////////// Template Json ///////////////////////////////////////////
UPDATE a
SET templateJson = ISNULL(b.textValue,'')
FROM #tblSwitch_NBS a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionCaption in ('Template Specs')

UPDATE a
SET templateFile = b.textValue
FROM #tblSwitch_NBS a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionCaption in ('Template')
--/////////////////////////// Template Json ///////////////////////////////////////////


DROP TABLE IF EXISTS #tblSwitch_NBS_ForOutput
SELECT IDENTITY(INT,1,1) AS PKID, s.orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, s.productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground, templateJson
INTO #tblSwitch_NBS_ForOutput
FROM #tblSwitch_NBS s
ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OTHER STUFF
--Set flag back to '0'.
UPDATE Flags
SET FlagStatus = 0
WHERE FlagName = 'ImposerNBS'


--Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'NBS'
,a.PKID
,a.ordersProductsID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from #tblSwitch_NBS_ForOutput b
       where a.PKID = b.PKID
       for json path)
from #tblSwitch_NBS_ForOutput a

-- Update OPID status fields indicating successful submission to switch
UPDATE op
SET switch_create = 1,
	--fastTrak_status = 'In House',
	fastTrak_status = 'In Production',
	fastTrak_status_lastModified = GETDATE(),
	fastTrak_resubmit = 0
FROM tblOrders_Products op
INNER JOIN #tblSwitch_NBS_ForOutput q ON op.ID = q.ordersProductsID
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OUTPUT

SELECT *
FROM #tblSwitch_NBS_ForOutput 
ORDER BY PKID, orderID, displayCount, ordersProductsID, packetValue ASC

END TRY
BEGIN CATCH
	EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH