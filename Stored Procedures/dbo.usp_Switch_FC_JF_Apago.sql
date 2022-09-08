CREATE procEDURE [dbo].[usp_Switch_FC_JF_Apago] 
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     07/11/16
Purpose     Pulls first class products (FC) into Switch for production.
-------------------------------------------------------------------------------
Modification History

07/11/16		New
09/30/16		Truncation, G2G in primary INSERT.
10/18/16		Fixed G2G template file names.
11/01/16		updated shipsWith Stock section.
12/02/16		Added option456 data to initial query, near LN 115.
12/29/16		Added customBackground code to end of sproc.
01/27/16		Added optionID = '518' code in initial query.
02/20/17		Pulled Baseball Schedule Delay code out (optionID 456).
02/20/17		Removed orderStatus checks against "Delivered" and "Transit" in intial query.
03/28/17		Added SN to PN, jf.
11/07/17		pulled out BP/BC, jf
11/20/17		removed liststock, jf
01/11/18			2016 upgrade changes, bs
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
04/03/18		Killed SN logic with fire, jf.
04/27/18		Added secondary logic to variableWholeName, jf.
06/28/18		JF, added updates to tblProducts.fastTrak_productType sections to account for processType lookups vs. tblProduct lookups.
08/09/18		JF, added optionID 456 to suppress bball.
08/23/18		JF, reverted the 456 dealio.
08/27/18		JF, added op.ProcessType='fastrak' and op.fastTrak_resubmit =1 to initial query. Removed "%Waiting%" orderStatus check too.
09/06/18		JF, added "243" section.
10/08/18		JF, matched custom insertion section to look like QC so that it avoids updating image field if it is OPC.
10/16/18		JF, set backName = NULL
12/14/18		JF, suppression.
12/27/18		JF, added "EXISTS" and "NOT EXISTS" checks for variableWholeName to accomodate how NOP handles Canvas now.
04/17/19		JF, Football hold is in effect, y'all.
05/14/19		JF, FB released.
07/09/19		JF, vwn, cals and canvas.
07/11/19		JF, updated variableWholeName for Cals.
08/28/19		JF, Basketball suppression.
11/14/19		JF, added readyForSwitch check.
11/20/19		JF, modified step 4.a in initial query. for more info on what this is about, see stored proc: [popArtGate].
11/20/19		JF, updated initial query to model other flows in opid qualification.
11/20/19		JF, added final update statement that mimics the BC flow; it prevents future runs of same resubbed OPIDs into subsequent flows.
12/20/19		JF, CRUD.
12/29/19		BS, Added GOOD TO GO file rename logic to exclude J and FA
12/30/19		BS, supress baseball until schedules are ready
01/27/19		JF, added credit due section up top.
01/27/20		CT, Testing Baseball PrintQuality, commenting out Baseball supression Ln:146
01/27/20		CT, Revert Back to BB Suppression, Ln:146
02/14/20		JF, I had to remove the BB suppression code in the initial query. As it was written, it was only allowing Baseball FC's to come thru.
05/05/20		JF, suppress FB.
06/28/20		BS, added football to VariableWholeName
07/2/20			BS, Increased the time for orders to wait before entering the flow
07/08/20		JF, suppress BB as per Banks request.
07/09/20		JF, release FB TBD, done so by adjusting initial query. See inline notes.
07/10/20		JF, suppress FB as per Banks request.
08/04/20		JF, Added stripper to init query.
08/30/20		BS removed football gate
10/13/20		JF, Added resubmission section that modifies ShipsWith value if OPID is resubbed.
11/23/20		JF, LEN(orderNo) IN (9,10)
12/02/20		CKB, iFrame conversion changes
12/30/20		BS, Baseball gate 2021
02/08/21		BS, Ship Now BB released
02/25/21		JF, removed BB gate
03/04/21		JF, added variablewholename work just like QM and QC today.
03/04/21		JF, matched the fileExists INIT section to QC and QM
03/11/21		JF, updated variableWholeName section, removing G2G logic from 12/29/19
03/25/21		JF, fb gate
04/21/21		CKB, modified file check #5
04/27/21		CKB, Markful
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

BEGIN TRY

TRUNCATE TABLE tblSwitch_FC
INSERT INTO tblSwitch_FC (orderID, orderNo, orderDate, customerID, 
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
WHERE
--1. Order Qualification ----------------------------------
DATEDIFF(MI, a.created_on, GETDATE()) > 60 --increased the wait time to 1 hour from 10 minutes
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus IN ('Good', 'Credit Due')

--2. Product Qualification ----------------------------------
AND SUBSTRING(p.productCode, 3, 2) = 'FC'
AND SUBSTRING(p.productCode, 1, 2) IN
	(SELECT productCode
	FROM tblSwitch_productCodes)

--3. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType = 'fasTrak'

AND op.id IN (556216328, 556216334, 556216391, 556216439, 556216480, 556216526, 556216533, 556216578, 556216622, 556216628, 556217129)



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


--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// fix productQuantity if fasTrak_newQTY value exists
UPDATE a
SET productQuantity = b.fastTrak_newQTY
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY

--// variableTopName
UPDATE a
SET variableTopName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '') END
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption in ('File Name 2','CanvasHiResFront UNC File') -- added canvas for iFrame conversion
AND ( SUBSTRING(a.productCode, 1, 2) = 'BK'
OR SUBSTRING(a.productCode, 1, 2) = 'HY')

--BS 12/30/2019 Baseball in Canvas Baby --06/02/20 added football
UPDATE a
SET variableTopName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE '\\Arc\archives\webstores\OPC\' + b.textValue END
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption IN  ('Intranet PDF','CanvasHiResFront UNC File') -- added canvas for iFrame conversion
AND  SUBSTRING(a.productCode, 1, 2) IN ( 'BB', 'FB')

UPDATE a
SET variableTopName = '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption LIKE '%Team%'
AND (SUBSTRING(a.productCode, 1, 2) = 'FB'
OR SUBSTRING(a.productCode, 1, 2) = 'BB'
OR SUBSTRING(a.productCode, 1, 2) = 'BK'
OR SUBSTRING(a.productCode, 1, 2) = 'HY')
AND variableTopName = '' --this prevents overwrite of previous UPDATE statement.

--// confirm that non-sport FCs have variableTopName that are blank.
UPDATE tblSwitch_FC
SET variableTopName = ''
WHERE SUBSTRING(productCode, 1, 2) <> 'FB'
AND SUBSTRING(productCode, 1, 2) <> 'BB'
AND SUBSTRING(productCode, 1, 2) <> 'BK'
AND SUBSTRING(productCode, 1, 2) <> 'HY'


--// variableBottomName; tiered.
UPDATE tblSwitch_FC
SET variableBottomName = orderNo + '_' + CONVERT(VARCHAR(255), ordersProductsID) + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) = '243'

UPDATE tblSwitch_FC
SET variableBottomName = productCode + '.pdf'
WHERE SUBSTRING(productCode, 8, 3) <> '243'
AND (SUBSTRING(productCode, 1, 2) = 'FB'
OR SUBSTRING(productCode, 1, 2) = 'BB'
OR SUBSTRING(productCode, 1, 2) = 'BK'
OR SUBSTRING(productCode, 1, 2) = 'HY')

--BEGIN VARIABLE WHOLENAME ---------------------------------------------------------------------------
--// variablewholename; if not sport, and not canvas, then OPC value.
UPDATE a
SET variableWholeName = '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BK'
AND SUBSTRING(a.productCode, 1, 2) <> 'HY'
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- not canvas/OPC - iFrame

--// variablewholename; if not sport, if not calendar, but is canvas, then OPC value.
-- (1/2) 
UPDATE a
SET variableWholeName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '') END
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE a.variableWholeName = ''
AND b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('Intranet PDF','CanvasHiResFront UNC File') -- added canvas for iFrame conversion
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BK'
AND SUBSTRING(a.productCode, 1, 2) <> 'HY'
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- canvas/OPC - iFrame
AND SUBSTRING(a.productCode, 1, 2) <> 'CA'

-- (2/2) 
--Calendars, now developed in Canvas 5 as of 7/9/19, simply need the path amended to the front of the textValue.
UPDATE a
SET variableWholeName = CASE WHEN b.optionCaption = 'CanvasHiResFront UNC File' THEN b.textValue ELSE '\\Arc\archives\webstores\OPC\' + ISNULL(b.textValue, 'MissingImage') END
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('Intranet PDF','CanvasHiResFront UNC File') -- added canvas for iFrame conversion
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- canvas/OPC - iFrame
AND (SUBSTRING(a.productCode, 1, 2) = 'CA' OR SUBSTRING(a.productCode, 1, 2) = 'FB')

--// GLUON
UPDATE a
SET variableWholeName = '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.textValue LIKE '%.pdf'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(a.productCode, 1, 2) <> 'FB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BB'
AND SUBSTRING(a.productCode, 1, 2) <> 'BK'
AND SUBSTRING(a.productCode, 1, 2) <> 'HY'
AND a.variableWholeName = ''
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx
	WHERE a.ordersProductsID = oppx.ordersProductsID 
	AND oppx.optionID in (535,399))	-- not canvas/OPC - iFrame

--END VARIABLE WHOLENAME ---------------------------------------------------------------------------

--// backName update.
UPDATE tblSwitch_FC
SET backName = NULL

--//DEALING WITH 243			No iFrame conversion.  None found since 2018
UPDATE tblSwitch_FC
SET variableTopName  = ''
WHERE SUBSTRING(productCode, 8, 3) = '243'
AND productCode LIKE 'BK%'

UPDATE a
SET variableWholeName = '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND SUBSTRING(productCode, 8, 3) = '243'			-- 243 not used in FC - iFrame
AND productCode LIKE 'BK%'

--// secondary check on variableWholeName where "File Name 2" does not exist in Canvas 3.5, 04/27/18
UPDATE a
SET variableWholeName = '\\Arc\archives\webstores\OPC\' + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_FC a 
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.textValue LIKE '%.pdf%'
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Intranet PDF'
AND SUBSTRING(productCode, 8, 3) = '243'			--  not present with these modifiers on live - iFrame
AND productCode LIKE 'BK%'

UPDATE tblSwitch_FC
SET variableBottomName  = ''
WHERE SUBSTRING(productCode, 8, 3) = '243'			
AND productCode LIKE 'BK%'

UPDATE x
SET 
variableWholeName = '\\Arc\archives\webstores\OPC\' + REPLACE(REPLACE(orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(50), ordersProductsID) + '.pdf'
FROM tblSwitch_FC x
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

/*
shipsWith update.
	Custom = If a custom product is with order (excluding pens and paper business cards)
	FasTrak = if another FasTrak product is with order (excluding OPC FC's)
	Stock = if more than 6 stock line items with order (excluding NameBadge accessories)
	Ship = all else (already default)
*/

--// Custom = (1/2) If a custom product is with order (excluding pens and paper business cards)
UPDATE tblSwitch_FC
SET shipsWith = 'Custom'
WHERE orderID IN
	(SELECT DISTINCT orderID 
	FROM tblOrders_Products 
	WHERE deleteX <> 'yes'
	AND orderID IS NOT NULL
	AND SUBSTRING(productCode, 3, 2) <> 'FC'
	AND productID IN
		 (SELECT DISTINCT productID 
		 FROM tblProducts 
		 WHERE productType = 'Custom' 
		 AND productID IS NOT NULL
		 AND SUBSTRING(productCode, 1, 2) <> 'PN' --pens
))

--// Custom = (2/2) If a FC product is in the order that is NOT an OPC order
UPDATE tblSwitch_FC
SET shipsWith = 'Custom'
WHERE shipsWith <> 'Custom'
AND orderID IN
	(SELECT DISTINCT orderID 
	FROM tblOrders_Products 
	WHERE deleteX <> 'yes'
	AND orderID IS NOT NULL
	AND SUBSTRING(productCode, 3, 2) = 'FC'
	AND [ID] NOT IN
		(SELECT DISTINCT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'OPC')		-- OPC remain the same with iFrame conversion
	 )
	 
--// FasTrak = (1/1) If another FasTrak product is with order (excluding OPC FCs)
UPDATE tblSwitch_FC
SET shipsWith = 'FasTrak'
WHERE shipsWith <> 'Custom'
AND orderID IN
	(SELECT DISTINCT orderID 
	FROM tblOrders_Products 
	WHERE deleteX <> 'yes'
	AND orderID IS NOT NULL
	AND SUBSTRING(productCode, 3, 2) <> 'FC'
	AND processType = 'fasTrak')	
	
--// Local pickup, will call
UPDATE tblSwitch_FC
SET shipsWith = 'Local Pickup'
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

--// Stock = (1/1) If more than 6 stock line items with order (excluding NameBadge accessories)
TRUNCATE TABLE tblSwitch_FC_stockCount
INSERT INTO tblSwitch_FC_stockCount (orderID, stockCount)
SELECT DISTINCT a.orderID, b.[ID]
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productType = 'Stock')

UPDATE tblSwitch_FC
SET shipsWith = 'Stock'
WHERE orderID IN
	(SELECT orderID 
	FROM tblSwitch_FC_stockCount
	GROUP BY orderID
	HAVING COUNT(orderID) > 5)

-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
UPDATE x
SET resubmit = 1
FROM tblSwitch_FC x
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND op.fastTrak_resubmit = 1
	AND op.ID = x.ordersProductsID)

-- For any OPID that has been resubbed, update ShipsWith accordingly
IF OBJECT_ID('tempdb..#tempResubChoiceFC') IS NOT NULL 
DROP TABLE #tempResubChoiceFC

CREATE TABLE #tempResubChoiceFC (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @NumberRecords_rs INT, 
				 @RowCount_rs INT,
				 @OPID_rs INT,
				 @MostRecent_ResubChoice_rs INT

INSERT INTO #tempResubChoiceFC (OPID)
SELECT DISTINCT ordersProductsID
FROM tblSwitch_FC
WHERE resubmit = 1

SET @NumberRecords_rs = @@RowCount
SET @RowCount_rs = 1

WHILE @RowCount_rs <= @NumberRecords_rs
BEGIN
	 SELECT @OPID_rs = OPID
	 FROM #tempResubChoiceFC
	 WHERE RowID = @RowCount_rs

	 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
															FROM tblSwitch_resubOption
															WHERE OPID = @OPID_rs
															ORDER BY resubmitDate DESC)
	
	UPDATE tblSwitch_FC
	SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
	WHERE ordersProductsID = @OPID_rs	 

	SET @RowCount_rs = @RowCount_rs + 1
END
-- RESUBMISSION SECTION -------------------------------------------------------------------------------END

--// shipType Update
--// default
UPDATE tblSwitch_FC
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE tblSwitch_FC
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE tblSwitch_FC
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE tblSwitch_FC
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE tblSwitch_FC
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

TRUNCATE TABLE tblSwitch_FC_distinctIDCount
INSERT INTO tblSwitch_FC_distinctIDCount (orderID, ordersProductsID)
SELECT DISTINCT orderID, ordersProductsID
FROM tblSwitch_FC

TRUNCATE TABLE tblSwitch_FC_distinctIDCount2
INSERT INTO tblSwitch_FC_distinctIDCount2 (orderID, countOrderID)
SELECT orderID, COUNT(orderID) AS 'countOrderID'
FROM tblSwitch_FC_distinctIDCount
GROUP BY orderID
ORDER BY orderID

UPDATE tblSwitch_FC
SET totalCount = b.countOrderID
FROM tblSwitch_FC a INNER JOIN tblSwitch_FC_distinctIDCount2 b
ON a.orderID = b.orderID

UPDATE tblSwitch_FC
SET displayCount = NULL,
multiCount = totalCount

--// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin PCU
--// Counts (multiCount and totalCount)
IF OBJECT_ID(N'tblSwitch_FC_displayCount', N'U') IS NOT NULL
DROP TABLE tblSwitch_FC_displayCount

CREATE TABLE tblSwitch_FC_displayCount 
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
TRUNCATE TABLE tblSwitch_FC_displayCount
INSERT INTO tblSwitch_FC_displayCount (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM tblSwitch_FC
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
	FROM tblSwitch_FC_displayCount
	WHERE RowID = @RowCount
	
	UPDATE tblSwitch_FC
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM tblSwitch_FC
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE tblSwitch_FC
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE tblSwitch_FC
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE tblSwitch_FC SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ displayCount calculation
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end.

	--// Background
	UPDATE tblSwitch_FC
	SET background = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Background File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.background <> b.textValue

	UPDATE tblSwitch_FC
	SET background = REPLACE(background, '.eps', '.pdf')
	WHERE background LIKE '%.eps'

	--// templateFile
	UPDATE tblSwitch_FC
	SET templateFile = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Layout File Name'			-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.templateFile <> b.textValue

	--// team1FileName
	UPDATE tblSwitch_FC
	SET team1FileName = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 1 File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.team1FileName <> b.textValue

	--// team2FileName
	UPDATE tblSwitch_FC
	SET team2FileName = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 2 File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.team2FileName <> b.textValue

	--// team3FileName
	UPDATE tblSwitch_FC
	SET team3FileName = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 3 File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.team3FileName <> b.textValue

	--// team4FileName
	UPDATE tblSwitch_FC
	SET team4FileName = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 4 File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.team4FileName <> b.textValue

	--// team5FileName
	UPDATE tblSwitch_FC
	SET team5FileName = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 5 File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.team5FileName <> b.textValue

	--// team6FileName
	UPDATE tblSwitch_FC
	SET team6FileName = b.textValue
	FROM tblSwitch_FC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 6 File Name'		-- leave as-is iframe
	AND b.deleteX <> 'yes'
	AND a.team6FileName <> b.textValue


--//  Update team(X)FileName with generic "01" image name
UPDATE tblSwitch_FC
SET team1FileName = REPLACE (team1FileName, SUBSTRING(team1FileName, CHARINDEX('.', team1FileName) - 3, 7), '01' + SUBSTRING(team1FileName, CHARINDEX('.', team1FileName) - 1, 5))
WHERE team1FileName <> ''
AND team1FileName IS NOT NULL

UPDATE tblSwitch_FC
SET team2FileName = REPLACE (team2FileName, SUBSTRING(team2FileName, CHARINDEX('.', team2FileName) - 3, 7), '01' + SUBSTRING(team2FileName, CHARINDEX('.', team2FileName) - 1, 5))
WHERE team2FileName <> ''
AND team2FileName IS NOT NULL

UPDATE tblSwitch_FC
SET team3FileName = REPLACE (team3FileName, SUBSTRING(team3FileName, CHARINDEX('.', team3FileName) - 3, 7), '01' + SUBSTRING(team3FileName, CHARINDEX('.', team3FileName) - 1, 5))
WHERE team3FileName <> ''
AND team3FileName IS NOT NULL

UPDATE tblSwitch_FC
SET team4FileName = REPLACE (team4FileName, SUBSTRING(team4FileName, CHARINDEX('.', team4FileName) - 3, 7), '01' + SUBSTRING(team4FileName, CHARINDEX('.', team4FileName) - 1, 5))
WHERE team4FileName <> ''
AND team4FileName IS NOT NULL

UPDATE tblSwitch_FC
SET team5FileName = REPLACE (team5FileName, SUBSTRING(team5FileName, CHARINDEX('.', team5FileName) - 3, 7), '01' + SUBSTRING(team5FileName, CHARINDEX('.', team5FileName) - 1, 5))
WHERE team5FileName <> ''
AND team5FileName IS NOT NULL

UPDATE tblSwitch_FC
SET team6FileName = REPLACE (team6FileName, SUBSTRING(team6FileName, CHARINDEX('.', team6FileName) - 3, 7), '01' + SUBSTRING(team6FileName, CHARINDEX('.', team6FileName) - 1, 5))
WHERE team6FileName <> ''
AND team6FileName IS NOT NULL

--// Set flags
UPDATE tblSwitch_FC SET switch_approve = 0
UPDATE tblSwitch_FC SET switch_print = 0
UPDATE tblSwitch_FC SET switch_approveDate = GETDATE()
UPDATE tblSwitch_FC SET switch_printDate = GETDATE()
UPDATE tblSwitch_FC SET switch_createDate = GETDATE()

--/////////////////////////////////////////
--// CUSTOM WORK --////////////////////////
--/////////////////////////////////////////

--// customProductCount
TRUNCATE TABLE tblSwitch_FC_countCustom
INSERT INTO tblSwitch_FC_countCustom (orderID, countCustom)
SELECT a.orderID, COUNT(DISTINCT(SUBSTRING(b.productCode, 1, 4))) AS 'countCustom'
FROM tblSwitch_FC a 
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	 WHERE productType = 'Custom' 
	 AND productID IS NOT NULL
	 AND SUBSTRING(productCode, 1, 2) <> 'PN')
AND SUBSTRING(b.productCode, 3, 2) <> 'FC'
GROUP BY a.orderID

UPDATE tblSwitch_FC
SET customProductCount = b.countCustom
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_countCustom b
	ON a.orderID = b.orderID

--// Populate customProductCode fields
TRUNCATE TABLE tblSwitch_FC_listCustom
INSERT INTO tblSwitch_FC_listCustom (orderID, productCodePrefix)
SELECT DISTINCT a.orderID, SUBSTRING(b.productCode, 1 ,4) AS 'productCodePrefix'
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	 WHERE productType = 'Custom' 
	 AND productID IS NOT NULL
	 AND SUBSTRING(productCode, 1, 2) <> 'PN')
AND SUBSTRING(b.productCode, 3, 2) <> 'FC'

UPDATE tblSwitch_FC
SET customProductCode1 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listCustom b
ON a.orderID = b.orderID

UPDATE tblSwitch_FC
SET customProductCode2 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listCustom b
ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix

UPDATE tblSwitch_FC
SET customProductCode3 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listCustom b
ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix
AND customProductCode2 <> ''
AND customProductCode2 <> b.productCodePrefix

UPDATE tblSwitch_FC
SET customProductCode4 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listCustom b
ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix
AND customProductCode2 <> ''
AND customProductCode2 <> b.productCodePrefix
AND customProductCode3 <> ''
AND customProductCode3 <> b.productCodePrefix

--/////////////////////////////////////////
--// FASTRAK WORK --///////////////////////
--/////////////////////////////////////////

--// FTProductCount
TRUNCATE TABLE tblSwitch_FC_countFT
INSERT INTO tblSwitch_FC_countFT (orderID, countFT)
SELECT a.orderID, COUNT(DISTINCT(SUBSTRING(b.productCode, 1, 4))) AS 'countFT'
FROM tblSwitch_FC a 
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND SUBSTRING(b.productCode, 3, 2) <> 'FC'
GROUP BY a.orderID

UPDATE tblSwitch_FC
SET fasTrakProductCount = b.countFT
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_countFT b
	ON a.orderID = b.orderID

--// Populate fasTrakProductCode fields
TRUNCATE TABLE tblSwitch_FC_listFT
INSERT INTO tblSwitch_FC_listFT (orderID, productCodePrefix)
SELECT DISTINCT a.orderID, SUBSTRING(b.productCode, 1 ,4) AS 'productCodePrefix'
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND SUBSTRING(b.productCode, 3, 2) <> 'FC'

UPDATE tblSwitch_FC
SET fasTrakProductCode1 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listFT b
ON a.orderID = b.orderID

UPDATE tblSwitch_FC
SET fasTrakProductCode2 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listFT b
ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix

UPDATE tblSwitch_FC
SET fasTrakProductCode3 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listFT b
ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix
AND fasTrakProductCode2 <> ''
AND fasTrakProductCode2 <> b.productCodePrefix

UPDATE tblSwitch_FC
SET fasTrakProductCode4 = b.productCodePrefix
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listFT b
ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix
AND fasTrakProductCode2 <> ''
AND fasTrakProductCode2 <> b.productCodePrefix
AND fasTrakProductCode3 <> ''
AND fasTrakProductCode3 <> b.productCodePrefix

--/////////////////////////////////////////
--// STOCK WORK --/////////////////////////
--/////////////////////////////////////////

--// stockProductCount
TRUNCATE TABLE tblSwitch_FC_countStock
INSERT INTO tblSwitch_FC_countStock (orderID, countStock)
SELECT a.orderID, COUNT(DISTINCT(b.productCode)) AS 'countStock'
FROM tblSwitch_FC a 
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Stock'
	AND SUBSTRING(productCode, 1, 2) <> 'NB'
	AND SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productCode <> 'AM-16')
--AND SUBSTRING(b.productCode, 3, 2) <> 'FC'
AND b.productCode <> ''
AND b.productCode IS NOT NULL
GROUP BY a.orderID

UPDATE tblSwitch_FC
SET stockProductCount = b.countStock
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_countStock b
	ON a.orderID = b.orderID

--// Populate stockProductCode fields
TRUNCATE TABLE tblSwitch_FC_listStock
INSERT INTO tblSwitch_FC_listStock (orderID, productCode)
SELECT DISTINCT a.orderID, b.productCode AS 'productCode'
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Stock'
	AND SUBSTRING(productCode, 1, 2) <> 'NB'
	AND SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productCode <> 'AM-16')
--AND SUBSTRING(b.productCode, 3, 2) <> 'FC'
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_FC
SET stockProductCode1 = b.productCode
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listStock b
ON a.orderID = b.orderID

UPDATE tblSwitch_FC
SET stockProductCode2 = b.productCode
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listStock b
ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode

UPDATE tblSwitch_FC
SET stockProductCode3 = b.productCode
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listStock b
ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode

UPDATE tblSwitch_FC
SET stockProductCode4 = b.productCode
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listStock b
ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode
AND stockProductCode3 <> ''
AND stockProductCode3 <> b.productCode

UPDATE tblSwitch_FC
SET stockProductCode5 = b.productCode
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listStock b
ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode
AND stockProductCode3 <> ''
AND stockProductCode3 <> b.productCode
AND stockProductCode4 <> ''
AND stockProductCode4 <> b.productCode

UPDATE tblSwitch_FC
SET stockProductCode6 = b.productCode
FROM tblSwitch_FC a
INNER JOIN tblSwitch_FC_listStock b
ON a.orderID = b.orderID
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

UPDATE tblSwitch_FC
SET stockProductQuantity1 = b.productQuantity,
	stockProductDescription1 = b.productName
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.stockProductCode1 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_FC
SET stockProductQuantity2 = b.productQuantity,
	stockProductDescription2 = b.productName
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.stockProductCode2 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_FC
SET stockProductQuantity3 = b.productQuantity,
	stockProductDescription3 = b.productName
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.stockProductCode3 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_FC
SET stockProductQuantity4 = b.productQuantity,
	stockProductDescription4 = b.productName
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.stockProductCode4 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_FC
SET stockProductQuantity5 = b.productQuantity,
	stockProductDescription5 = b.productName
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.stockProductCode5 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_FC
SET stockProductQuantity6 = b.productQuantity,
	stockProductDescription6 = b.productName
FROM tblSwitch_FC a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.stockProductCode6 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

--// Update those products which do NOT have UV coating, signfied by "0" in UV column.
/* 
GNFC00-019	Babysitter Checklist
GNFC00-020	Emergency First Aid
GNFC00-021	Emergency Phone Numbers
GNFC00-022	Important Phone Numbers
GNFC00-023	Numeros de Emergencia
GNFC00-025	Primeros Auxilios
*/
UPDATE tblSwitch_FC
SET UV = 0
WHERE productCode = 'GNFC00-019'
OR productCode = 'GNFC00-020'
OR productCode = 'GNFC00-021'
OR productCode = 'GNFC00-022'
OR productCode = 'GNFC00-023'
OR productCode = 'GNFC00-025'

--// change PSD to PDF extension; 12/29/15 jf.
UPDATE tblSwitch_FC
SET variableTopName = REPLACE(variableTopName, '.psd', '.pdf')
WHERE variableTopName LIKE '%.psd'

UPDATE tblSwitch_FC
SET variableBottomName = REPLACE(variableBottomName, '.psd', '.pdf')
WHERE variableBottomName LIKE '%.psd'

UPDATE tblSwitch_FC
SET variableWholeName = REPLACE(variableWholeName, '.psd', '.pdf')
WHERE variableWholeName LIKE '%.psd'

UPDATE tblSwitch_FC
SET background = REPLACE(background, '.psd', '.pdf')
WHERE background LIKE '%.psd'

--// update customBackground value; new, 12/29/16 jf.
UPDATE tblSwitch_FC
SET customBackground = b.optionCaption
FROM tblSwitch_FC a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'			-- no equivalent found iFrame

TRUNCATE TABLE tblSwitch_FC_ForOutput
INSERT INTO tblSwitch_FC_ForOutput (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground
FROM tblSwitch_FC 
ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

--INSERT INTO tblSwitch_FCLog (PKID, ordersProductsID, insertedOn)
--SELECT DISTINCT PKID, ordersProductsID, GETDATE()
--FROM tblSwitch_FC_ForOutput

--Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'FC'
,a.PKID
,a.ordersProductsID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from tblSwitch_FC_ForOutput b
       where a.PKID = b.PKID
       for json path)
from tblSwitch_FC_ForOutput a

-- Update OPID status fields indicating successful submission to switch
UPDATE tblOrders_Products
SET switch_create = 1,
	fastTrak_status = 'In Production',
	fastTrak_status_lastModified = GETDATE(),
	fastTrak_resubmit = 0
FROM tblOrders_Products op
INNER JOIN tblSwitch_FC_ForOutput t ON op.ID = t.ordersProductsID

SELECT *
FROM tblSwitch_FC_ForOutput 
ORDER BY PKID, orderID, displayCount, ordersProductsID, packetValue ASC

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH