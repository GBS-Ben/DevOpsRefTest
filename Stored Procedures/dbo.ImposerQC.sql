CREATE PROCEDURE [dbo].[ImposerQC]
AS
/*
-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			08/03/16
Purpose			Pulls quickcards products (QC) into Imposer for production.
-------------------------------------------------------------------------------
Modification History

08/03/16		New
09/30/16		Truncation, G2G in primary INSERT.
10/18/16		Fixed G2G template file names.
11/01/16		updated shipsWith Stock section.
12/02/16		Added option456 data to initial query, near LN 115.
12/29/16		Added customBackground code to end of sproc.
01/03/17		Added variableWholeName and variableTopName modifications towards end of sproc.
01/27/16		Added optionID = '518' code in initial query.
02/10/17		Added test line near LN 125.
02/20/17		Pulled Baseball Schedule Delay code out (optionID 456).
02/20/17		Removed orderStatus checks against "Delivered" and "Transit" in intial query.
03/28/17		Added SN to PN, jf.
11/07/17		pulled out BP/BC, jf
11/20/17		removed liststock, jf
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
04/03/18		Killed SN logic with fire, jf.
04/27/18		Added secondary logic to variableWholeName, jf.
06/28/18		JF, added updates to tblProducts.fastTrak_productType sections to account for processType lookups vs. tblProduct lookups.
07/09/18		JF, added subq that prevents FT products from appearing as Custom Insertion products when marked as "good to go". Near LN: 280.
08/09/18		JF, added optionID=456 to initial query to suppress Basketball schtuff.
08/23/18		JF, reverted the 456 dealio.
08/28/18		JF, updated intial query to match all other flows.
10/15/18		JF, added op.ProcessType='fastrak' and op.fastTrak_resubmit =1 to initial query. Removed "%Waiting%" orderStatus check too. (to match pre-rewrite)
10/15/18 		JF, added "243" section. (to match pre-rewrite)
10/16/18		JF, new code that does a fileExist check, initiates data with a temp table
10/17/18		JF, updated shipsWith to look at processType rather than productType
10/17/18		JF, new formatting.
10/17/18		JF, went live with the new code @1044AM.  Restore from sproc 'usp_Switch_QC_LIVEBAK_101718_01', if problems arise.
10/18/18		JF, added UPDATE at end of sproc for fastTrak_resubmit
10/24/18		JF, added switch_create, fastTrak_status updates to the end of sproc (near LN1059) to mirror concept in TRON.
10/24/18		JF, added: EXEC usp_OPPO_validateFile 'QC'
11/14/18		JF, updated initial query with more robust orderStatus check: (AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'In Transit USPS (Stamped)'))
11/14/18		JF, ImposerQC switch over today. Revert to [usp_Switch_QC] or its identical backup [usp_Switch_QC_BAKJF_111418] if things go fubar.
03/13/19		JF, removed "submitted_to_switch" update to OPID
04/27/21		CKB, Markful
-------------------------------------------------------------------------------
*/
BEGIN TRY
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CREATE MAIN QUERY
DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;



IF OBJECT_ID('tempdb..#ImposerQC') IS NOT NULL 
DROP TABLE #ImposerQC
CREATE TABLE #ImposerQC (
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
	[UV] [bit] NOT NULL,
	[customBackground] [nvarchar](255) NULL)

INSERT INTO #ImposerQC (orderID, orderNo, orderDate, customerID, 
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
s.shippingAddressID, s.shipping_Company, s.shipping_Firstname, s.shipping_surName, 
s.shipping_Street, s.shipping_Street2, s.shipping_Suburb, s.shipping_State, s.shipping_PostCode, s.shipping_Country, s.shipping_Phone, 
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
WHERE
--1. Order Qualification ----------------------------------
DATEDIFF(MI, a.created_on, GETDATE()) > 10
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'In Transit USPS (Stamped)')
AND a.displayPaymentStatus = 'Good'

--2. Product Qualification ----------------------------------
AND SUBSTRING(p.productCode, 3, 2) = 'QC'
AND SUBSTRING(p.productCode, 1, 2) IN
		(SELECT productCode
		FROM tblSwitch_productCodes)

--3. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType = 'fasTrak'
AND (
		--3.a
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		AND op.[ID] IN
				(SELECT ordersProductsID
				FROM tblOrdersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionCaption = 'OPC')		
		--3.b
		OR op.fastTrak_status = 'Good to Go'
		--3.c
		OR op.fastTrak_resubmit = 1
		)

--4. Unique to this product line -------------------------
AND op.ID NOT IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionID = 518) -- QuickCard Mailers

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FLAG
-- Flags
DECLARE @Flag BIT
SET @Flag = (SELECT FlagStatus FROM Flags WHERE FlagName = 'ImposerQC')
					   
--IF @Flag = 0
--BEGIN
UPDATE Flags
SET FlagStatus = 1
WHERE FlagName = 'ImposerQC'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FILE EXISTS

--First, validate image files
EXEC usp_OPPO_validateFile 'QC'

-- For any OPID that is missing an image, send an email
IF OBJECT_ID('tempdb..#tempPSUFileCheckImposerQC') IS NOT NULL 
DROP TABLE #tempPSUFileCheckImposerQC

CREATE TABLE #tempPSUFileCheckImposerQC (
RowID INT IDENTITY(1, 1), 
FILE_EXISTS_ROWID INT, 
OPID INT)

DECLARE @FILE_EXISTS_ROWID INT,
				 @OPIDX INT,
				 @NumberRecords_x INT, 
				 @RowCount_x INT

INSERT INTO #tempPSUFileCheckImposerQC (FILE_EXISTS_ROWID, OPID)
SELECT x.rowID, q.OPID
FROM tblOPPO_fileExists x 
INNER JOIN #ImposerQC q ON x.OPID = q.OPID
WHERE x.fileExists = 0
AND x.ignoreCheck = 0
ORDER BY x.rowID, q.OPID

--send email
SET @NumberRecords_x = @@ROWCOUNT
SET @RowCount_x = 1

WHILE @RowCount_x <= @NumberRecords_x
BEGIN
	 SELECT @FILE_EXISTS_ROWID = FILE_EXISTS_ROWID,
				   @OPIDX = OPID
	 FROM #tempPSUFileCheckImposerQC
	 WHERE RowID = @RowCount_x

	 EXEC usp_OPPO_fileExist_sendEmail @FILE_EXISTS_ROWID, @OPIDX

SET @RowCount_x = @RowCount_x + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// INSERT DATA
--insert data into tblSwitch_QC based on file existence
INSERT INTO tblSwitch_QC 
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

SELECT 
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
FROM #ImposerQC q
INNER JOIN tblOPPO_fileExists x ON x.OPID = q.OPID
WHERE x.fileExists = 0

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// DO WORK
--// fix productQuantity if fasTrak_newQTY value exists
UPDATE tblSwitch_QC
SET productQuantity = b.fastTrak_newQTY
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY

--// duplicate line items based on productQuantity for given ordersProductsID; use integers table for iterations.
TRUNCATE TABLE tblSwitch_QC_Bounce
INSERT INTO tblSwitch_QC_Bounce
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, 
CONVERT(VARCHAR(255), i.i) + ' of ' + CONVERT(VARCHAR(255), a.productQuantity) AS 'packetValue', 
variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6
FROM tblSwitch_QC a 
INNER JOIN integers i ON i.i <= (a.productQuantity * a.numUnits)
	--ON i.i <= a.productQuantity
WHERE i.i <> 0

--// Repopulate tblSwitch_QC with accurate data to begin more edits.
TRUNCATE TABLE tblSwitch_QC
INSERT INTO tblSwitch_QC (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, 1
FROM tblSwitch_QC_Bounce
ORDER BY ordersProductsID, packetValue

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '1 of', '01 of') WHERE packetValue LIKE '1 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '2 of', '02 of') WHERE packetValue LIKE '2 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '3 of', '03 of') WHERE packetValue LIKE '3 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '4 of', '04 of') WHERE packetValue LIKE '4 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '5 of', '05 of') WHERE packetValue LIKE '5 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '6 of', '06 of') WHERE packetValue LIKE '6 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '7 of', '07 of') WHERE packetValue LIKE '7 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '8 of', '08 of') WHERE packetValue LIKE '8 of%'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, '9 of', '09 of') WHERE packetValue LIKE '9 of%'

UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 1', 'of 01') WHERE packetValue LIKE '%of 1'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 2', 'of 02') WHERE packetValue LIKE '%of 2'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 3', 'of 03') WHERE packetValue LIKE '%of 3'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 4', 'of 04') WHERE packetValue LIKE '%of 4'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 5', 'of 05') WHERE packetValue LIKE '%of 5'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 6', 'of 06') WHERE packetValue LIKE '%of 6'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 7', 'of 07') WHERE packetValue LIKE '%of 7'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 8', 'of 08') WHERE packetValue LIKE '%of 8'
UPDATE tblSwitch_QC SET packetValue = REPLACE(packetValue, 'of 9', 'of 09') WHERE packetValue LIKE '%of 9'

--// variableTopName
UPDATE tblSwitch_QC
SET variableTopName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND (SUBSTRING(a.productCode, 1, 2) = 'FB'
OR SUBSTRING(a.productCode, 1, 2) = 'BB'
OR SUBSTRING(a.productCode, 1, 2) = 'BK')

UPDATE tblSwitch_QC
SET variableTopName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption LIKE '%Team%'
AND (SUBSTRING(a.productCode, 1, 2) = 'FB'
OR SUBSTRING(a.productCode, 1, 2) = 'BB'
OR SUBSTRING(a.productCode, 1, 2) = 'BK')
AND variableTopName = '' --this prevents overwrite of previous UPDATE statement.

--// confirm that non-sport (except for BK, HY, PG, NS) QCs have variableTopName that are blank.
UPDATE tblSwitch_QC
SET variableTopName = ''
WHERE SUBSTRING(productCode, 1, 2) <> 'FB'
AND SUBSTRING(productCode, 1, 2) <> 'BB'
AND SUBSTRING(productCode, 1, 2) <> 'BK'

--// variableBottomName; tiered.
UPDATE tblSwitch_QC
SET variableBottomName = orderNo + '_' + CONVERT(VARCHAR(255), ordersProductsID) + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) = '243'

UPDATE tblSwitch_QC
SET variableBottomName = productCode + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) <> '243'
AND (SUBSTRING(productCode, 1, 2) = 'FB'
OR SUBSTRING(productCode, 1, 2) = 'BB'
OR SUBSTRING(productCode, 1, 2) = 'BK')

--// variableWholeName; if NOT sport, then OPC value.
UPDATE tblSwitch_QC
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BK'

--// secondary check on variableWholeName where "File Name 2" does not exist in Canvas 3.5, 04/27/18
UPDATE tblSwitch_QC
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE a.variableWholeName = ''
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Intranet PDF'
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BK'

--// backName update.
UPDATE tblSwitch_QC
SET backName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_productOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Product Back'
AND b.textValue <> 'BLANK'

--// update all Custom Inserted OPIDs to the hardcoded PDF path in the archive directory; jf 10/12/2016.
UPDATE tblSwitch_QC
SET 
variableWholeName = @UncBasePath + REPLACE(REPLACE(orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(50), ordersProductsID) + '.pdf'
WHERE ordersProductsID IN
	(SELECT [ID]
	FROM tblOrders_Products
	WHERE deleteX <> 'yes'
	AND fastTrak_status = 'Good to Go'
	AND [ID] NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'OPC'))

--//DEALING WITH 243
UPDATE tblSwitch_QC
SET variableTopName  = ''
WHERE SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

UPDATE a
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

--// secondary check on variableWholeName where "File Name 2" does not exist in Canvas 3.5, 04/27/18
UPDATE a
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_QC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Intranet PDF'
AND SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

UPDATE tblSwitch_QC
SET variableBottomName  = ''
WHERE SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// SHIPSWITH
-- Custom. If an OPID from this flow ships with another OPID that is not a pen and has processType = 'Custom', then set shipsWith = 'custom' for current OPID.
UPDATE tblSwitch_QC
SET shipsWith = 'Custom'
WHERE orderID IN
		(SELECT orderID 
		FROM tblOrders_Products 
		WHERE deleteX <> 'yes'
		AND ID NOT IN
			(SELECT ordersProductsID
			FROM tblSwitch_QC)
		AND processType = 'Custom'
		AND SUBSTRING(productCode, 1, 2) <> 'PN')

-- fasTrak. If another fasTrak OPID ships with current OPID from this flow, and that other OPID is not a part of this current flow, then set shipsWith = 'fasTrak' for current OPID.
UPDATE tblSwitch_QC
SET shipsWith = 'fasTrak'
WHERE shipsWith <> 'Custom'
AND orderID IN
	(SELECT DISTINCT orderID 
	FROM tblOrders_Products 
	WHERE deleteX <> 'yes'
	AND ID NOT IN
			(SELECT ordersProductsID
			FROM tblSwitch_QC)
	AND processType = 'fasTrak')	 

-- Local Pickup / Will Call. If current OPID is on an order that is a local pickup (or will call) order, then set shipsWith = 'Local Pickup' for current OPID.
UPDATE tblSwitch_QC
SET shipsWith = 'Local Pickup'
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders
	WHERE CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// PRODUCT COUNTS
--// Stock = (1/1) If more than 5 stock line items with order (excluding NameBadge accessories)
TRUNCATE TABLE tblSwitch_QC_stockCount
INSERT INTO tblSwitch_QC_stockCount (orderID, stockCount)
SELECT DISTINCT a.orderID, b.[ID]
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND SUBSTRING(b.productCode, 1, 2) <> 'FM'
AND b.processType = 'Stock'

UPDATE tblSwitch_QC
SET shipsWith = 'Stock'
WHERE orderID IN
	(SELECT orderID 
	FROM tblSwitch_QC_stockCount
	GROUP BY orderID
	HAVING COUNT(orderID) > 5)

--// Resubmit (we don't currently have a way to do this; placeholder code)
UPDATE tblSwitch_QC
SET resubmit = 1
WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] 
	FROM tblOrders_Products
	WHERE deleteX <> 'yes'
	AND fastTrak_resubmit = 1)


--// shipType Update
--// default
UPDATE tblSwitch_QC
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE tblSwitch_QC
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE tblSwitch_QC
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE tblSwitch_QC
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE tblSwitch_QC
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
TRUNCATE TABLE tblSwitch_QC_distinctIDCount
INSERT INTO tblSwitch_QC_distinctIDCount (orderID, ordersProductsID)
SELECT DISTINCT orderID, ordersProductsID
FROM tblSwitch_QC

TRUNCATE TABLE tblSwitch_QC_distinctIDCount2
INSERT INTO tblSwitch_QC_distinctIDCount2 (orderID, countOrderID)
SELECT orderID, COUNT(orderID) AS 'countOrderID'
FROM tblSwitch_QC_distinctIDCount
GROUP BY orderID
ORDER BY orderID

UPDATE tblSwitch_QC
SET totalCount = b.countOrderID
FROM tblSwitch_QC a 
INNER JOIN tblSwitch_QC_distinctIDCount2 b ON a.orderID = b.orderID

UPDATE tblSwitch_QC
SET displayCount = NULL,
multiCount = totalCount

--// Counts (multiCount and totalCount)
IF OBJECT_ID(N'tblSwitch_QC_displayCount', N'U') IS NOT NULL
DROP TABLE tblSwitch_QC_displayCount

CREATE TABLE tblSwitch_QC_displayCount 
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
TRUNCATE TABLE tblSwitch_QC_displayCount
INSERT INTO tblSwitch_QC_displayCount (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM tblSwitch_QC
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
	FROM tblSwitch_QC_displayCount
	WHERE RowID = @RowCount
	
	UPDATE tblSwitch_QC
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM tblSwitch_QC
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE tblSwitch_QC
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE tblSwitch_QC
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE tblSwitch_QC SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// MORE UPDATES
--// Background
UPDATE tblSwitch_QC
SET background = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Background File Name'
AND b.deleteX <> 'yes'
AND a.background <> b.textValue

UPDATE tblSwitch_QC
SET background = REPLACE(background, '.eps', '.pdf')
WHERE background LIKE '%.eps'

--// templateFile
UPDATE tblSwitch_QC
SET templateFile = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Layout File Name'
AND b.deleteX <> 'yes'
AND a.templateFile <> b.textValue

--// team1FileName
UPDATE tblSwitch_QC
SET team1FileName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 1 File Name'
AND b.deleteX <> 'yes'
AND a.team1FileName <> b.textValue

--// team2FileName
UPDATE tblSwitch_QC
SET team2FileName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 2 File Name'
AND b.deleteX <> 'yes'
AND a.team2FileName <> b.textValue

--// team3FileName
UPDATE tblSwitch_QC
SET team3FileName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 3 File Name'
AND b.deleteX <> 'yes'
AND a.team3FileName <> b.textValue

--// team4FileName
UPDATE tblSwitch_QC
SET team4FileName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 4 File Name'
AND b.deleteX <> 'yes'
AND a.team4FileName <> b.textValue

--// team5FileName
UPDATE tblSwitch_QC
SET team5FileName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 5 File Name'
AND b.deleteX <> 'yes'
AND a.team5FileName <> b.textValue

--// team6FileName
UPDATE tblSwitch_QC
SET team6FileName = b.textValue
FROM tblSwitch_QC a, tblOrdersProducts_ProductOptions b
WHERE a.ordersProductsID = b.ordersProductsID
AND b.optionCaption = 'Team 6 File Name'
AND b.deleteX <> 'yes'
AND a.team6FileName <> b.textValue

--//  Update team(X)FileName with generic "01" image name (JF Edit: 082415)
UPDATE tblSwitch_QC
SET team1FileName = REPLACE (team1FileName, SUBSTRING(team1FileName, CHARINDEX('.', team1FileName) - 3, 7), '01' + SUBSTRING(team1FileName, CHARINDEX('.', team1FileName) - 1, 5))
WHERE team1FileName <> ''
AND team1FileName IS NOT NULL

UPDATE tblSwitch_QC
SET team2FileName = REPLACE (team2FileName, SUBSTRING(team2FileName, CHARINDEX('.', team2FileName) - 3, 7), '01' + SUBSTRING(team2FileName, CHARINDEX('.', team2FileName) - 1, 5))
WHERE team2FileName <> ''
AND team2FileName IS NOT NULL

UPDATE tblSwitch_QC
SET team3FileName = REPLACE (team3FileName, SUBSTRING(team3FileName, CHARINDEX('.', team3FileName) - 3, 7), '01' + SUBSTRING(team3FileName, CHARINDEX('.', team3FileName) - 1, 5))
WHERE team3FileName <> ''
AND team3FileName IS NOT NULL

UPDATE tblSwitch_QC
SET team4FileName = REPLACE (team4FileName, SUBSTRING(team4FileName, CHARINDEX('.', team4FileName) - 3, 7), '01' + SUBSTRING(team4FileName, CHARINDEX('.', team4FileName) - 1, 5))
WHERE team4FileName <> ''
AND team4FileName IS NOT NULL

UPDATE tblSwitch_QC
SET team5FileName = REPLACE (team5FileName, SUBSTRING(team5FileName, CHARINDEX('.', team5FileName) - 3, 7), '01' + SUBSTRING(team5FileName, CHARINDEX('.', team5FileName) - 1, 5))
WHERE team5FileName <> ''
AND team5FileName IS NOT NULL

UPDATE tblSwitch_QC
SET team6FileName = REPLACE (team6FileName, SUBSTRING(team6FileName, CHARINDEX('.', team6FileName) - 3, 7), '01' + SUBSTRING(team6FileName, CHARINDEX('.', team6FileName) - 1, 5))
WHERE team6FileName <> ''
AND team6FileName IS NOT NULL

--// Set flags
UPDATE tblSwitch_QC SET switch_approve = 0
UPDATE tblSwitch_QC SET switch_print = 0
UPDATE tblSwitch_QC SET switch_approveDate = GETDATE()
UPDATE tblSwitch_QC SET switch_printDate = GETDATE()
UPDATE tblSwitch_QC SET switch_createDate = GETDATE()

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CUSTOM WORK
--// customProductCount
TRUNCATE TABLE tblSwitch_QC_countCustom
INSERT INTO tblSwitch_QC_countCustom (orderID, countCustom)
SELECT a.orderID, COUNT(DISTINCT(SUBSTRING(b.productCode, 1, 4))) AS 'countCustom'
FROM tblSwitch_QC a 
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	 WHERE productType = 'Custom' 
	 AND productID IS NOT NULL
	 AND SUBSTRING(productCode, 1, 2) <> 'PN')
AND SUBSTRING(b.productCode, 3, 2) <> 'QC'
GROUP BY a.orderID

UPDATE tblSwitch_QC
SET customProductCount = b.countCustom
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_countCustom b ON a.orderID = b.orderID

--// Populate customProductCode fields
TRUNCATE TABLE tblSwitch_QC_listCustom
INSERT INTO tblSwitch_QC_listCustom (orderID, productCodePrefix)
SELECT DISTINCT a.orderID, SUBSTRING(b.productCode, 1 ,4) AS 'productCodePrefix'
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	 WHERE productType = 'Custom' 
	 AND productID IS NOT NULL
	 AND SUBSTRING(productCode, 1, 2) <> 'PN')
AND SUBSTRING(b.productCode, 3, 2) <> 'QC'

UPDATE tblSwitch_QC
SET customProductCode1 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listCustom b ON a.orderID = b.orderID

UPDATE tblSwitch_QC
SET customProductCode2 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listCustom b ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix

UPDATE tblSwitch_QC
SET customProductCode3 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listCustom b ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix
AND customProductCode2 <> ''
AND customProductCode2 <> b.productCodePrefix

UPDATE tblSwitch_QC
SET customProductCode4 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listCustom b ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix
AND customProductCode2 <> ''
AND customProductCode2 <> b.productCodePrefix
AND customProductCode3 <> ''
AND customProductCode3 <> b.productCodePrefix

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FASTRAK WORK
--// FTProductCount
TRUNCATE TABLE tblSwitch_QC_countFT
INSERT INTO tblSwitch_QC_countFT (orderID, countFT)
SELECT a.orderID, COUNT(DISTINCT(SUBSTRING(b.productCode, 1, 4))) AS 'countFT'
FROM tblSwitch_QC a 
INNER JOIN tblOrders_Products b 	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND SUBSTRING(b.productCode, 3, 2) <> 'QC'
GROUP BY a.orderID

UPDATE tblSwitch_QC
SET fasTrakProductCount = b.countFT
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_countFT b ON a.orderID = b.orderID

--// Populate fasTrakProductCode fields
TRUNCATE TABLE tblSwitch_QC_listFT
INSERT INTO tblSwitch_QC_listFT (orderID, productCodePrefix)
SELECT DISTINCT a.orderID, SUBSTRING(b.productCode, 1 ,4) AS 'productCodePrefix'
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND SUBSTRING(b.productCode, 3, 2) <> 'QC'

UPDATE tblSwitch_QC
SET fasTrakProductCode1 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listFT b	ON a.orderID = b.orderID

UPDATE tblSwitch_QC
SET fasTrakProductCode2 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listFT b	ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix

UPDATE tblSwitch_QC
SET fasTrakProductCode3 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listFT b	ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix
AND fasTrakProductCode2 <> ''
AND fasTrakProductCode2 <> b.productCodePrefix

UPDATE tblSwitch_QC
SET fasTrakProductCode4 = b.productCodePrefix
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listFT b	ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix
AND fasTrakProductCode2 <> ''
AND fasTrakProductCode2 <> b.productCodePrefix
AND fasTrakProductCode3 <> ''
AND fasTrakProductCode3 <> b.productCodePrefix

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// STOCK WORK
--// stockProductCount
TRUNCATE TABLE tblSwitch_QC_countStock
INSERT INTO tblSwitch_QC_countStock (orderID, countStock)
SELECT a.orderID, COUNT(DISTINCT(b.productCode)) AS 'countStock'
FROM tblSwitch_QC a 
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Stock'
	AND SUBSTRING(productCode, 1, 2) <> 'NB'
	AND SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productCode <> 'AM-16')
--AND SUBSTRING(b.productCode, 3, 2) <> 'QC'
AND b.productCode <> ''
AND b.productCode IS NOT NULL
GROUP BY a.orderID

UPDATE tblSwitch_QC
SET stockProductCount = b.countStock
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_countStock b ON a.orderID = b.orderID

--// Populate stockProductCode fields
TRUNCATE TABLE tblSwitch_QC_listStock
INSERT INTO tblSwitch_QC_listStock (orderID, productCode)
SELECT DISTINCT a.orderID, b.productCode AS 'productCode'
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Stock'
	AND SUBSTRING(productCode, 1, 2) <> 'NB'
	AND SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productCode <> 'AM-16')
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET stockProductCode1 = b.productCode
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listStock b ON a.orderID = b.orderID

UPDATE tblSwitch_QC
SET stockProductCode2 = b.productCode
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listStock b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode

UPDATE tblSwitch_QC
SET stockProductCode3 = b.productCode
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listStock b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode

UPDATE tblSwitch_QC
SET stockProductCode4 = b.productCode
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listStock b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode
AND stockProductCode3 <> ''
AND stockProductCode3 <> b.productCode

UPDATE tblSwitch_QC
SET stockProductCode5 = b.productCode
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listStock b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode
AND stockProductCode3 <> ''
AND stockProductCode3 <> b.productCode
AND stockProductCode4 <> ''
AND stockProductCode4 <> b.productCode

UPDATE tblSwitch_QC
SET stockProductCode6 = b.productCode
FROM tblSwitch_QC a
INNER JOIN tblSwitch_QC_listStock b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode
AND stockProductCode3 <> ''
AND stockProductCode3 <> b.productCode
AND stockProductCode4 <> ''
AND stockProductCode4 <> b.productCode
AND stockProductCode5 <> ''
AND stockProductCode5 <> b.productCode

UPDATE tblSwitch_QC
SET stockProductQuantity1 = b.productQuantity,
	stockProductDescription1 = b.productName
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE a.stockProductCode1 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET stockProductQuantity2 = b.productQuantity,
	stockProductDescription2 = b.productName
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode2 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET stockProductQuantity3 = b.productQuantity,
	stockProductDescription3 = b.productName
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode3 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET stockProductQuantity4 = b.productQuantity,
	stockProductDescription4 = b.productName
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode4 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET stockProductQuantity5 = b.productQuantity,
	stockProductDescription5 = b.productName
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode5 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET stockProductQuantity6 = b.productQuantity,
	stockProductDescription6 = b.productName
FROM tblSwitch_QC a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode6 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_QC
SET UV = 0
WHERE productCode = 'GNQC00-019'
OR productCode = 'GNQC00-020'
OR productCode = 'GNQC00-021'
OR productCode = 'GNQC00-022'
OR productCode = 'GNQC00-023'
OR productCode = 'GNQC00-025'
OR productCode = 'GNQC00-038'
OR productCode = 'GNQC00-042'
OR productCode = 'GNQC00-039'
OR productCode = 'GNQC00-044'

UPDATE tblSwitch_QC
SET variableTopName = REPLACE(variableTopName, '.psd', '.pdf')
WHERE variableTopName LIKE '%.psd'

UPDATE tblSwitch_QC
SET variableBottomName = REPLACE(variableBottomName, '.psd', '.pdf')
WHERE variableBottomName LIKE '%.psd'

UPDATE tblSwitch_QC
SET variableWholeName = REPLACE(variableWholeName, '.psd', '.pdf')
WHERE variableWholeName LIKE '%.psd'

UPDATE tblSwitch_QC
SET background = REPLACE(background, '.psd', '.pdf')
WHERE background LIKE '%.psd'

UPDATE tblSwitch_QC
SET customBackground = b.optionCaption
FROM tblSwitch_QC a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'

TRUNCATE TABLE tblSwitch_QC_ForOutput
INSERT INTO tblSwitch_QC_ForOutput (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground
FROM tblSwitch_QC 
ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OTHER STUFF
--Set flag back to '0'.
UPDATE Flags
SET FlagStatus = 0
WHERE FlagName = 'ImposerNCTickets'

INSERT INTO tblSwitch_QCLog (PKID, ordersProductsID, insertedOn)
SELECT DISTINCT PKID, ordersProductsID, GETDATE()
FROM tblSwitch_QC_ForOutput

-- Update OPID status fields indicating successful submission to switch
UPDATE op
SET switch_create = 1,
	--fastTrak_status = 'submitted_to_switch',
	fastTrak_status_lastModified = GETDATE(),
	fastTrak_resubmit = 0	
FROM tblOrders_Products op
INNER JOIN tblSwitch_QC_ForOutput q ON op.ID = q.ordersProductsID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OUTPUT

SELECT *
FROM tblSwitch_QC_ForOutput 
ORDER BY PKID, orderID, displayCount, ordersProductsID, packetValue ASC

END TRY
BEGIN CATCH
	EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH