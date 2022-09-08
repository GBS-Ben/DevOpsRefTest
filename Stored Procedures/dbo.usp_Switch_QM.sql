CREATE PROCEDURE [dbo].[usp_Switch_QM] 
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     07/11/16
Purpose     Pulls Quick Magnet products (QM) into Switch for production.
-------------------------------------------------------------------------------
Modification History

07/11/16		New
09/30/16		Truncation, G2G in primary INSERT.
10/18/16		Fixed G2G template file names.
11/01/16		updated shipsWith Stock section.
12/02/16		Added option456 data to initial query, near LN 115.
12/29/16		Added customBackground code to end of sproc.
01/03/17		Added variableWholeName and variableTopName modifications towards end of sproc
01/27/16		Added optionID = '518' code in initial query.
02/20/17		Pulled Baseball Schedule Delay code out (optionID 456).
02/20/17		Removed orderStatus checks against "Delivered" and "Transit" in intial query.
03/28/17		Added SN to PN, jf.
11/07/17		pulled out BP/BC, jf
11/20/17		removed liststock, jf
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
04/03/18		Killed SN logic with fire, jf.
04/27/18		Added secondary logic to variableWholeName, jf.
06/28/18		JF, added updates to tblProducts.fastTrak_productType sections to account for processType lookups vs. tblProduct lookups.
08/10/18		JF, added optionID 456 to suppress basketballs.
08/23/18		JF, reverted the 456 dealio.
08/28/18		JF, updated intial query to match all other flows.
09/06/18		JF, added "243" section.
11/29/18		JF, QM rewrite.
11/30/18		JF, Revert to this [usp_Switch_QM_BAKpriorToRewrite_113018_01], in case of fire.
12/14/18		JF, suppression.
12/27/18		JF, added "EXISTS" and "NOT EXISTS" checks for variableWholeName to accomodate how NOP handles Canvas now.
03/13/19		JF, removed "submitted_to_switch" OPID status update towards end of flow; it was causing OPIDs to stall if involved in a Switch error.
04/17/19		JF, Football hold is in effect, y'all.
05/14/19		JF, FB released.
06/18/19		JF, uncommented out FT status update at bottom of sproc and changed the value to 'In House'.
07/09/19		JF, variablewholename for calendars and canvas.
08/28/19		JF, Basketball suppression.
10/24/19		JF, Removed BK from split print file structure to full print file structure for non-canvas runs; LN404 and LN430.
11/14/19		JF, added readyForSwitch check.
11/26/19		JF, modified step 3.a in initial query. for more info on what this is about, see stored proc: [popArtGate].
12/20/19		JF, CRUD.
12/29/19		BS, Added GOOD TO GO file rename logic to exclude J and FA
12/30/19		BS, supress baseball until schedules are ready
01/27/20		CT, Testing Baseball PrintQuality, commenting out Baseball supression on ln: 234 and adding 'AND op.id = 555776239'
01/27/20		CT, Revert Back to Baseball Suppression ln:234
02/05/20		JF, Added Credit Due to main query.
05/05/20		JF, suppress FB.
06/28/20		BS, Added VariableWholeName Football
07/2/20			BS, Increased the time for orders to wait before entering the flow
07/08/20		JF, suppress BB as per Banks request.
07/09/20		JF, release FB TBD, done so by adjusting init query. See inline notes.
07/10/20		JF, suppress FB as per Banks request.
07/13/20		BS, Fixed back issue
07/15/20		BS, Football gate and release BB
08/04/20		JF, Added stripper to init query.
08/20/20		JF, updated fileExists nested query in init query; see inline notes.
08/30/20		BS, removed football gate
09/14/20		JF, added NOT EXISTS statement to query near LN408. 
09/25/20		JF, added pick-n-print clauses near LN 580; see inline notes.
10/12/20		BS, added support for Trivia
10/13/20		JF, Added resubmission section that modifies ShipsWith value if OPID is resubbed.
11/23/20		JF, LEN(orderNo) IN (9,10)
12/07/20		CKB, iFrame conversion changes
12/30/20		BS, Baseball gate 2021
02/08/21		BS, Ship NOW BB released
02/25/21		JF, removed BB gate
03/04/21		JF, updated variablewholename
03/04/21		JF, matched fileExist check in INIT to that of QC and FC.
03/11/21		JF, updated variableWholeName section, removing G2G logic from 12/29/19
03/25/21		JF, fb gate
04/21/21		CKB, modified file check #5
04/27/21		CKB, Markful
07/22/21		CKB, moved flag and validatefile to beginning
08/26/21		JF, added AND p.productCode NOT LIKE 'FB%097%' --as per BB instructions on 26AUG2021, jf.
09/17/21		JF, Basketball and Hockey GATE.
09/23/21		JF, KILLED Basketball and Hockey GATE.
09/24/21		JF, fixed variableWholeName section so that BK could get through.
11/10/21		CKB, added processstatus
12/17/21		CKB, fix stock count to match QC logic - clickup #1wv1ntt 
02/11/22		CKB, modified sports gate logic to be data driven group gates - clickup #1x7bmfc
-------------------------------------------------------------------------------
*/

DECLARE @flowName AS VARCHAR(20) = 'QM'

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'QM Switch SP', @lastRunDate;

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

BEGIN TRY

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FLAG
-- Flags
DECLARE @Flag BIT
SET @Flag = (SELECT FlagStatus FROM Flags WHERE FlagName = 'ImposerQM')
					   
--IF @Flag = 0
--BEGIN
UPDATE Flags
SET FlagStatus = 1
WHERE FlagName = 'ImposerQM'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FILE EXISTS

--First, validate image files
EXEC usp_OPPO_validateFile 'QM'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CREATE MAIN QUERY
IF OBJECT_ID('tempdb..#ImposerQM') IS NOT NULL 
DROP TABLE #ImposerQM
CREATE TABLE #ImposerQM (
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

INSERT INTO #ImposerQM (orderID, orderNo, orderDate, customerID, 
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
AND SUBSTRING(p.productCode, 3, 2) = 'QM'
AND SUBSTRING(p.productCode, 1, 2) IN
		(SELECT productCode
		FROM tblSwitch_productCodes)


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
AND op.processType = 'fasTrak'
AND (
		--3.a
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
		OR op.fastTrak_status = 'Good to Go'
		--3.c
		OR op.fastTrak_resubmit = 1
		)

--4. Unique to this product line -------------------------
 AND op.ID NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 518)		-- leave as-is iFrame
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
IF OBJECT_ID('tempdb..#tempPSUFileCheckImposerQM') IS NOT NULL 
DROP TABLE #tempPSUFileCheckImposerQM

CREATE TABLE #tempPSUFileCheckImposerQM (
RowID INT IDENTITY(1, 1), 
FILE_EXISTS_ROWID INT, 
OPID INT)

DECLARE @FILE_EXISTS_ROWID INT,
				 @OPIDX INT,
				 @NumberRecords_x INT, 
				 @RowCount_x INT

INSERT INTO #tempPSUFileCheckImposerQM (FILE_EXISTS_ROWID, OPID)
SELECT x.rowID, q.ordersProductsID
FROM tblOPPO_fileExists x 
INNER JOIN #ImposerQM q ON x.OPID = q.ordersProductsID
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
	 FROM #tempPSUFileCheckImposerQM
	 WHERE RowID = @RowCount_x

	 EXEC usp_OPPO_fileExist_sendEmail @FILE_EXISTS_ROWID, @OPIDX

SET @RowCount_x = @RowCount_x + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// INSERT DATA
--insert data into tblSwitch_QM based on file existence
TRUNCATE TABLE tblSwitch_QM
INSERT INTO tblSwitch_QM 
(orderID, orderNo, orderDate, customerID, 
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

SELECT DISTINCT
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
q.stockProductQuantity6, q.stockProductCode6, q.stockProductDescription6
FROM #ImposerQM q
INNER JOIN tblOPPO_fileExists x ON x.OPID = q.ordersProductsID
WHERE x.fileExists = 1
AND x.ignoreCheck = 0
AND NOT EXISTS				
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = x.OPID
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOPPO_fileExists ee
		WHERE ee.readyForSwitch = 1
		AND e.OPID = ee.OPID))


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Do Work
--// fix productQuantity if fasTrak_newQTY value exists
UPDATE a
SET productQuantity = b.fastTrak_newQTY
FROM tblSwitch_QM a
INNER JOIN tblOrders_Products b	ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY

--// variableTopName
UPDATE a
SET variableTopName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '') END
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('File Name 2','CanvasHiResFront UNC File')		--added canvas - iFrame
AND (SUBSTRING(a.productCode, 1, 2) = 'FB'
OR SUBSTRING(a.productCode, 1, 2) = 'BB'
OR SUBSTRING(a.productCode, 1, 2) = 'BK')

--BS 12/30/2019 Baseball in Canvas Baby
UPDATE a
SET variableTopName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE @UncBasePath + b.textValue END
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('Intranet PDF','CanvasHiResFront UNC File')		--added canvas - iFrame
AND  SUBSTRING(a.productCode, 1, 2) IN  ('BB', 'TV')


UPDATE a
SET variableTopName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption LIKE '%Team%'
AND (SUBSTRING(a.productCode, 1, 2) = 'FB'
OR SUBSTRING(a.productCode, 1, 2) = 'BB'
OR SUBSTRING(a.productCode, 1, 2) = 'BK')
AND variableTopName = '' --this prevents overwrite of previous UPDATE statement.

--// confirm that non-sport (except for BK, HY, PG, NS) QMs have variableTopName that are blank.
UPDATE tblSwitch_QM
SET variableTopName = ''
WHERE SUBSTRING(productCode, 1, 2) <> 'FB'
AND SUBSTRING(productCode, 1, 2) <> 'BB'
AND SUBSTRING(productCode, 1, 2) <> 'TV'

--// variableBottomName; tiered.
UPDATE tblSwitch_QM
SET variableBottomName = orderNo + '_' + CONVERT(VARCHAR(255), ordersProductsID) + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) = '243'

UPDATE tblSwitch_QM
SET variableBottomName = REPLACE(productCode, 'QM', 'QC') + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) <> '243'
AND (SUBSTRING(productCode, 1, 2) = 'FB'
OR SUBSTRING(productCode, 1, 2) = 'BB'
OR SUBSTRING(productCode, 1, 2) = 'BK'
OR SUBSTRING(productCode, 1, 2) = 'TV'
)

--BEGIN VARIABLE WHOLENAME ---------------------------------------------------------------------------
--// variablewholename; if not sport, and not canvas, then OPC value.
UPDATE a
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'TV'
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))		--not canvas/OPC - iFrame

--// variablewholename; if not sport, if not calendar, but is canvas, then OPC value.
-- (1/2) 
UPDATE a
SET variableWholeName = CASE WHEN b.optionCaption= 'CanvasHiResFront UNC File' THEN b.textValue ELSE @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '') END
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE a.variableWholeName = ''
AND b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('Intranet PDF','CanvasHiResFront UNC File')
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
--AND SUBSTRING(a.productCode, 1, 2) <> 'BK' --pulled out on 9/24/21, jf.
AND SUBSTRING(a.productCode, 1, 2) <> 'TV'
--AND EXISTS
--	(SELECT TOP 1 1
--	FROM tblOrdersProducts_productOptions oppx
--	WHERE a.ordersProductsID = oppx.ordersProductsID 
--	AND oppx.optionID in (535,399))	-- canvas/OPC - iFrame
AND SUBSTRING(a.productCode, 1, 2) <> 'CA'

-- (2/2) 
--Calendars, now developed in Canvas 5 as of 7/9/19, simply need the path amended to the front of the textValue.
UPDATE a
SET variableWholeName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE @UncBasePath + ISNULL(b.textValue, 'MissingImage') END
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('Intranet PDF','CanvasHiResFront UNC File')
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- canvas/OPC - iFrame
AND (SUBSTRING(a.productCode, 1, 2) = 'CA' )

UPDATE a
SET variableWholeName = b.textValue
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('CanvasHiResFront UNC File')
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- canvas/OPC - iFrame
AND (SUBSTRING(a.productCode, 1, 2) = 'FB' )

--// GLUON
UPDATE a
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BK'
AND SUBSTRING(a.productCode, 1, 2) <> 'TV'
AND a.variableWholeName = ''
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	--not canvas/OPC - iFrame

--END VARIABLE WHOLENAME ---------------------------------------------------------------------------

--// backName update.
UPDATE a
SET backName = b.textValue
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.deleteX <> 'yes'
AND b.optionCaption IN ( 'Product Back','Back Design','CanvasHiResBack UNC File')
AND b.textValue <> 'BLANK'

--//DEALING WITH 243
UPDATE tblSwitch_QM
SET variableTopName  = ''
WHERE SUBSTRING(productCode, 8, 3) = '243'		-- not since 2018 - iFrame
AND productCode LIKE 'BK%'

UPDATE a
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

--// secondary check on variableWholeName where "File Name 2" does not exist in Canvas 3.5, 04/27/18
UPDATE a
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QM a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Intranet PDF'
AND SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

UPDATE tblSwitch_QM
SET variableBottomName  = ''
WHERE SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

--// update all Custom Inserted OPIDs to the hardcoded PDF path in the archive directory; jf 10/12/2016.
UPDATE x
SET 
variableWholeName = '\\Arc\archives\webstores\OPC\' + REPLACE(REPLACE(orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(50), ordersProductsID) + '.pdf'
FROM tblSwitch_QM x
WHERE ISNULL(variableWholeName, '') = ''
AND ISNULL(variableTopName, '') = ''
AND NOT EXISTS --12/29/19 BS - Exclude the Furnished Art Templates
			(SELECT TOP 1 1 
			FROM tblOrdersProducts_productOptions opp2
			WHERE deleteX <> 'yes'
			AND RIGHT(textValue, 2) = '_J'
			AND opp2.ordersProductsID = x.ordersProductsID)
AND NOT EXISTS  --12/29/19 BS - Exclude the Furnished Art Products 
			(SELECT TOP 1 1 
			FROM tblOrders_Products op2
			WHERE deleteX <> 'yes'
			AND CHARINDEX('FA',ProductCode) > 0
			AND op2.ID = x.ordersProductsID)


--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
SET @json = (SELECT orderid,@flowName as switchflow from tblSwitch_QM FOR JSON PATH);
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
FROM tblSwitch_QM s
LEFT JOIN #tmpShip t on s.orderID = t.orderID;

UPDATE s
SET shipsWith = 'Local Pickup'
FROM tblSwitch_QM s
INNER JOIN tblOrders o ON s.orderid = o.orderid
	WHERE (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')

-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
UPDATE x
SET resubmit = 1
FROM tblSwitch_QM x
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND op.fastTrak_resubmit = 1
	AND op.ID = x.ordersProductsID)

-- For any OPID that has been resubbed, update ShipsWith accordingly
IF OBJECT_ID('tempdb..#tempResubChoice_QM') IS NOT NULL 
DROP TABLE #tempResubChoice_QM

CREATE TABLE #tempResubChoice_QM (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @NumberRecords_rs INT, 
				 @RowCount_rs INT,
				 @OPID_rs INT,
				 @MostRecent_ResubChoice_rs INT

INSERT INTO #tempResubChoice_QM (OPID)
SELECT DISTINCT ordersProductsID
FROM tblSwitch_QM
WHERE resubmit = 1

SET @NumberRecords_rs = @@RowCount
SET @RowCount_rs = 1

WHILE @RowCount_rs <= @NumberRecords_rs
BEGIN
	 SELECT @OPID_rs = OPID
	 FROM #tempResubChoice_QM
	 WHERE RowID = @RowCount_rs

	 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
															FROM tblSwitch_resubOption
															WHERE OPID = @OPID_rs
															ORDER BY resubmitDate DESC)
	
	UPDATE tblSwitch_QM
	SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
	WHERE ordersProductsID = @OPID_rs	 

	SET @RowCount_rs = @RowCount_rs + 1
END
-- RESUBMISSION SECTION -------------------------------------------------------------------------------END

--// shipType Update
--// default
UPDATE tblSwitch_QM
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE tblSwitch_QM
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE tblSwitch_QM
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE tblSwitch_QM
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE tblSwitch_QM
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
TRUNCATE TABLE tblSwitch_QM_distinctIDCount
INSERT INTO tblSwitch_QM_distinctIDCount (orderID, ordersProductsID)
SELECT DISTINCT orderID, ordersProductsID
FROM tblSwitch_QM

TRUNCATE TABLE tblSwitch_QM_distinctIDCount2
INSERT INTO tblSwitch_QM_distinctIDCount2 (orderID, countOrderID)
SELECT orderID, COUNT(orderID) AS 'countOrderID'
FROM tblSwitch_QM_distinctIDCount
GROUP BY orderID
ORDER BY orderID

UPDATE tblSwitch_QM
SET totalCount = b.countOrderID
FROM tblSwitch_QM a 
INNER JOIN tblSwitch_QM_distinctIDCount2 b ON a.orderID = b.orderID

UPDATE tblSwitch_QM
SET displayCount = NULL,
multiCount = totalCount

--// Counts (multiCount and totalCount)
IF OBJECT_ID(N'tblSwitch_QM_displayCount', N'U') IS NOT NULL
DROP TABLE tblSwitch_QM_displayCount

CREATE TABLE tblSwitch_QM_displayCount 
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
TRUNCATE TABLE tblSwitch_QM_displayCount
INSERT INTO tblSwitch_QM_displayCount (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM tblSwitch_QM
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
	FROM tblSwitch_QM_displayCount
	WHERE RowID = @RowCount
	
	UPDATE tblSwitch_QM
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM tblSwitch_QM
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE tblSwitch_QM
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE tblSwitch_QM
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE tblSwitch_QM SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// MORE UPDATES
--// Background
UPDATE tblSwitch_QM
SET background = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Background File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.background <> b.textValue

UPDATE tblSwitch_QM
SET background = REPLACE(background, '.eps', '.pdf')
WHERE background LIKE '%.eps'

--// templateFile
UPDATE tblSwitch_QM
SET templateFile = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Layout File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.templateFile <> b.textValue

--// team1FileName
UPDATE tblSwitch_QM
SET team1FileName = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 1 File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.team1FileName <> b.textValue

--// team2FileName
UPDATE tblSwitch_QM
SET team2FileName = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 2 File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.team2FileName <> b.textValue

--// team3FileName
UPDATE tblSwitch_QM
SET team3FileName = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 3 File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.team3FileName <> b.textValue

--// team4FileName
UPDATE tblSwitch_QM
SET team4FileName = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 4 File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.team4FileName <> b.textValue

--// team5FileName
UPDATE tblSwitch_QM
SET team5FileName = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 5 File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.team5FileName <> b.textValue

--// team6FileName
UPDATE tblSwitch_QM
SET team6FileName = b.textValue
FROM tblSwitch_QM a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 6 File Name'		--leave as-is - iFrame
AND b.deleteX <> 'yes'
AND a.team6FileName <> b.textValue

--//  Update team(X)FileName with generic "01" image name (JF Edit: 082415)
UPDATE tblSwitch_QM
SET team1FileName = REPLACE (team1FileName, SUBSTRING(team1FileName, CHARINDEX('.', team1FileName) - 3, 7), '01' + SUBSTRING(team1FileName, CHARINDEX('.', team1FileName) - 1, 5))
WHERE team1FileName <> ''
AND team1FileName IS NOT NULL

UPDATE tblSwitch_QM
SET team2FileName = REPLACE (team2FileName, SUBSTRING(team2FileName, CHARINDEX('.', team2FileName) - 3, 7), '01' + SUBSTRING(team2FileName, CHARINDEX('.', team2FileName) - 1, 5))
WHERE team2FileName <> ''
AND team2FileName IS NOT NULL

UPDATE tblSwitch_QM
SET team3FileName = REPLACE (team3FileName, SUBSTRING(team3FileName, CHARINDEX('.', team3FileName) - 3, 7), '01' + SUBSTRING(team3FileName, CHARINDEX('.', team3FileName) - 1, 5))
WHERE team3FileName <> ''
AND team3FileName IS NOT NULL

UPDATE tblSwitch_QM
SET team4FileName = REPLACE (team4FileName, SUBSTRING(team4FileName, CHARINDEX('.', team4FileName) - 3, 7), '01' + SUBSTRING(team4FileName, CHARINDEX('.', team4FileName) - 1, 5))
WHERE team4FileName <> ''
AND team4FileName IS NOT NULL

UPDATE tblSwitch_QM
SET team5FileName = REPLACE (team5FileName, SUBSTRING(team5FileName, CHARINDEX('.', team5FileName) - 3, 7), '01' + SUBSTRING(team5FileName, CHARINDEX('.', team5FileName) - 1, 5))
WHERE team5FileName <> ''
AND team5FileName IS NOT NULL

UPDATE tblSwitch_QM
SET team6FileName = REPLACE (team6FileName, SUBSTRING(team6FileName, CHARINDEX('.', team6FileName) - 3, 7), '01' + SUBSTRING(team6FileName, CHARINDEX('.', team6FileName) - 1, 5))
WHERE team6FileName <> ''
AND team6FileName IS NOT NULL

--// Set flags
UPDATE tblSwitch_QM SET switch_approve = 0
UPDATE tblSwitch_QM SET switch_print = 0
UPDATE tblSwitch_QM SET switch_approveDate = GETDATE()
UPDATE tblSwitch_QM SET switch_printDate = GETDATE()
UPDATE tblSwitch_QM SET switch_createDate = GETDATE()

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
	FROM tblSwitch_QM s
INNER JOIN #tmpShip t on s.orderID = t.orderID

UPDATE tblSwitch_QM
SET UV = 0
WHERE productCode = 'GNQM00-019'
OR productCode = 'GNQM00-020'
OR productCode = 'GNQM00-021'
OR productCode = 'GNQM00-022'
OR productCode = 'GNQM00-023'
OR productCode = 'GNQM00-025'
OR productCode = 'GNQM00-038'
OR productCode = 'GNQM00-042'
OR productCode = 'GNQM00-039'
OR productCode = 'GNQM00-044'

UPDATE tblSwitch_QM
SET variableTopName = REPLACE(variableTopName, '.psd', '.pdf')
WHERE variableTopName LIKE '%.psd'

UPDATE tblSwitch_QM
SET variableBottomName = REPLACE(variableBottomName, '.psd', '.pdf')
WHERE variableBottomName LIKE '%.psd'

UPDATE tblSwitch_QM
SET variableWholeName = REPLACE(variableWholeName, '.psd', '.pdf')
WHERE variableWholeName LIKE '%.psd'

UPDATE tblSwitch_QM
SET background = REPLACE(background, '.psd', '.pdf')
WHERE background LIKE '%.psd'

UPDATE tblSwitch_QM
SET customBackground = b.optionCaption
FROM tblSwitch_QM a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'

TRUNCATE TABLE tblSwitch_QM_ForOutput
INSERT INTO tblSwitch_QM_ForOutput (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground
FROM tblSwitch_QM 
ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OTHER STUFF
--Set flag back to '0'.
UPDATE Flags
SET FlagStatus = 0
WHERE FlagName = 'ImposerQM'

--INSERT INTO tblSwitch_QMLog (PKID, ordersProductsID, insertedOn)
--SELECT DISTINCT PKID, ordersProductsID, GETDATE()
--FROM tblSwitch_QM_ForOutput

--Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'QM'
,a.PKID
,a.ordersProductsID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from tblSwitch_QM_ForOutput b
       where a.PKID = b.PKID
       for json path)
from tblSwitch_QM_ForOutput a

-- Update OPID status fields indicating successful submission to switch
UPDATE op
SET switch_create = 1,
	--fastTrak_status = 'In House',
	fastTrak_status = 'In Production',
	fastTrak_status_lastModified = GETDATE(),
	fastTrak_resubmit = 0
FROM tblOrders_Products op
INNER JOIN tblSwitch_QM_ForOutput q ON op.ID = q.ordersProductsID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OUTPUT

SELECT *
FROM tblSwitch_QM_ForOutput 
ORDER BY PKID, orderID, displayCount, ordersProductsID, packetValue ASC

END TRY
BEGIN CATCH
	EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH