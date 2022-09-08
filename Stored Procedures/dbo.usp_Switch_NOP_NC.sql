CREATE PROC [dbo].[usp_Switch_NOP_NC]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     08/3/16
Purpose     Pulls CANVAS note card products (NOP NC) into Switch for production.
-------------------------------------------------------------------------------
Modification History

06/22/17		New
06/29/17		Added envelope code
07/20/17		Added optionID = 535 section to initial query. This confirms that the OPID is OPC.
08/08/17		Added option_customEnvelope section.
08/08/17		Fixed tangerine zest orange issues from AC, jf.
08/10/17		Rewrote entire envelope section, jf.
08/29/17		Added LN225, 267 areas, regarding env_productCode and option_envelope; the "CU" suffix removal.
09/15/17		Added fullCard section near LN925 that relates to Market Center Cards in the flow, jf.
09/28/17		Added env_color = 'white' to the fullCard = 1 OPIDs, jf.
11/07/17		pulled out BP/BC, jf
11/08/17		set default option_envelope value for MCs, jf.
01/15/18		JF, added optionID 562 section to initial query to allow for MC Custom NCs.
01/15/18		JF, added custom MC NC section near LN950.
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
04/03/18		Killed SN logic with fire, jf.
06/27/18		JF, added envelope grouping for MC NCs. Only NOP NCs were working. Also added color section for MC NCs.
06/28/18		JF, added updates to tblProducts.fastTrak_productType sections to account for processType lookups vs. tblProduct lookups.
08/10/18		JF, added <1 price to fullCard spec near LN 1000.
08/16/18		JF, updated fullCard queries so that envelope default white image gets updated regardless of price change made on on 8/10
10/30/18		Removed NCC section from initial query. That now resides in ImposerNC, which went live today, jf.
12/14/18		JF, ISNULLed this mess: 	UPDATE tblSwitch_NOP_NC	SET shortName = ISNULL(RTRIM(SUBSTRING(productName, 1, (SELECT CHARINDEX('(', productName)-1))), productName) WHERE (shortName IS NULL OR shortName = '')	AND productName LIKE '('
01/18/19		JF, added "AND a.NOP = 1" to initial SELECTS; added the 3-part OR statement to this section to incorporate what was previously there:
				
				  AND (SUBSTRING(a.orderNo, 1, 3) = 'HOM' --this retrieves in Market Center custom notecards from HOM
				  AND op.ID IN
						(SELECT ordersProductsID
						FROM tblordersProducts_productOptions
						WHERE deleteX <> 'yes'
						AND optionID = 562) --Custom Market Center optionID
				 OR SUBSTRING(a.orderNo, 1, 3) = 'NCC'
				 )
11/12/19		JF, added [AND op.processType = 'fasTrak'] to primary query. Pulled out [AND (p.productType = 'Custom' OR p.productType = 'fasTrak')] from the primary query. this should help with the Furnished Art gate.
11/14/19		JF, added readyForSwitch check.
11/19/19		JF, killed MC code with satanic hellfire. (near LN1050)
02/05/20		JF, added Credit Due to main query.
02/11/20		CT, Added Select Date Constraints to keep old orders from flowing through (LN 139)
08/04/20		JF, Added stripper to init query.
09/09/20		JF, Added fileExists fix to init query.
10/13/20		JF, Added resubmission section that modifies ShipsWith value if OPID is resubbed.
11/23/20		JF, LEN(orderNo)
01/07/21		BS, iframe conversion
02/12/21		BS, Eliminate all old oppos and Customer Info filter
02/12/21		bs, removed a replace
02/17/21		CKB, Added check for oppos to first main query
02/23/21		CKB and JF and BJS did magic on the first main query to fix CKB's nightmare .. hehehe
04/21/21		CKB, modified file check #5
04/27/21		CKB, Markful
07/22/21		CKB, added validatefile
11/10/21		CKB, added processstatus
12/17/21		CKB, fix stock count to match QC logic - clickup #1wv1ntt 
02/11/22		CKB, modified sports gate logic to be data driven group gates - clickup #1x7bmfc
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

DECLARE @flowName AS VARCHAR(20) = 'NOP_NC'

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'NOP_NC Switch SP', @lastRunDate;

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

BEGIN TRY

	--First, validate image files
	EXEC usp_OPPO_validateFile 'NC'

	TRUNCATE TABLE tblSwitch_NOP_NC
	INSERT INTO tblSwitch_NOP_NC (orderID, orderNo, orderDate, customerID, 
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
	stockProductQuantity6, stockProductCode6, stockProductDescription6,
	groupID)

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
	a.sampler AS samplerRequest,
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
	0 AS 'stockProductQuantity6', '' AS 'stockProductCode6', '' AS 'stockProductDescription6',
	op.groupID
	FROM tblOrders a
	INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
	INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
	INNER JOIN tblProducts p ON op.productID = p.productID
	LEFT JOIN tblSkuGroup sg ON p.productCode LIKE sg.skuPattern
	LEFT JOIN tblSkuGroupGate g ON sg.skuGroup = g.skuGroup
	WHERE a.orderDate > CONVERT(DATETIME, '09/01/2019')
	AND DATEDIFF(MI, a.created_on, GETDATE()) > 60
	AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
	AND a.orderStatus NOT LIKE '%Waiting%'
	AND a.displayPaymentStatus IN ('Good', 'Credit Due')
	AND op.deleteX <> 'yes'
	AND op.processType = 'fasTrak'
	AND SUBSTRING(p.productCode, 1, 2) = 'NC'
	AND SUBSTRING(p.productCode, 3, 2) <> 'EV'
	AND op.[ID] NOT IN 
		(SELECT DISTINCT ordersProductsID 
		FROM tblSwitch_NOP_NC 
		WHERE ordersProductsID IS NOT NULL)
	AND op.switch_create = 0
	AND op.ID NOT IN
			(SELECT ordersProductsID
			FROM tblOrdersProducts_productOptions
			WHERE deleteX <> 'yes'
			AND optionID = 518
			)

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

	AND EXISTS  --1/7/21 BJS iframe conversion work here to ensure only canvas pass this way
		(SELECT TOP 1 ordersProductsID
		FROM tblOrdersProducts_productOptions opex
		WHERE opex.ordersProductsID = op.ID
		AND deleteX <> 'yes'
		AND (
				 optionID = 535 --canvas oppo, but it is being deprecated
				 OR optionID = 541 --1/7/21 BJS CC State ID should always be added to canvas products during iframe conversion
				 OR optionCaption LIKE 'CanvasHiRes%' --1/7/21 BJS Just to be extra sure canvas cards don't flow this way
			)
		)		
	AND (
		--1. This retrieves NOP HOM orders
		a.NOP = 1
		--2. This retrieves in Market Center custom notecards from HOM Classic
		OR SUBSTRING(a.orderNo, 1, 3) IN ('HOM','MRK')
		AND op.ID IN
			(SELECT ordersProductsID
			FROM tblordersProducts_productOptions
			WHERE deleteX <> 'yes'
			AND optionID = 562) --Custom Market Center optionID
		--3. This retrieves NCC orders
		OR SUBSTRING(a.orderNo, 1, 3) = 'NCC')

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

-- Oppo Check ---- Must have NC oppos --------------------------------
	AND (EXISTS				
					(SELECT TOP 1 1
						FROM tblOrdersProducts_ProductOptions oppo
						WHERE op.ID = oppo.ordersProductsID and optionID in (617,684,669)
					)
			OR EXISTS 
					(SELECT TOP 1 1
					FROM tblOrders o
					WHERE LEFT(o.orderNo, 3)  IN ('HOM','MRK')
					AND o.orderID = a.orderID)
			)

	--Sampler request text
	UPDATE tblSwitch_NOP_NC
	SET samplerRequest = 'NCC Sampler Pack'
	WHERE samplerRequest = 'yes'

	UPDATE tblSwitch_NOP_NC
	SET samplerRequest = NULL
	WHERE samplerRequest = 'no'

	--// fix productQuantity if fasTrak_newQTY value exists
	UPDATE tblSwitch_NOP_NC
	SET productQuantity = b.fastTrak_newQTY
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrders_Products b
		ON a.ordersProductsID = b.ID
	WHERE (b.fastTrak_newQTY IS NOT NULL 
		  AND b.fastTrak_newQTY <> 0 )
	AND a.productQuantity <> b.fastTrak_newQTY

	--option_cause	
	UPDATE tblSwitch_NOP_NC
	SET option_cause = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_cause IS NULL
	AND b.optionCaption = 'Charity'
	AND b.deleteX <> 'yes'

	-- update cause if changed
	UPDATE tblSwitch_NOP_NC
	SET option_cause = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_cause IS NOT NULL
	AND a.option_cause <> CONVERT(VARCHAR(MAX), b.textValue)
	AND b.optionCaption = 'Charity'
	AND b.deleteX <> 'yes'

	-- option_cause
	UPDATE tblSwitch_NOP_NC
	SET option_cause = 'No Cause Selected'
	WHERE option_cause IS NULL

	--option_customInside (GREETING)
	UPDATE tblSwitch_NOP_NC
	SET option_customInside = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  (a.option_customInside IS NULL 
		 OR a.option_customInside IN ( 'CanvasHiResInside File Name'))
	AND b.optionCaption = 'Greeting'
	AND b.deleteX <> 'yes'
	AND a.option_customInside IS NULL


	--option_customInside (GREETING)
	UPDATE tblSwitch_NOP_NC
	SET option_customInside = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  (NULLIF(a.option_customInside,'') IS NULL 
		 OR a.option_customInside IN ( 'Blank_inside.pdf', 'CanvasHiResInside File Name'))
	AND b.optionCaption = 'Greeting'
	AND b.deleteX <> 'yes'
	AND a.option_customInside IS NULL

	--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ ENVELOPES
	--// ENVELOPES BEGIN: 
	-- this code preps grouped envelopes so they can be referenced for the population of these fields.
	TRUNCATE TABLE tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection
	INSERT INTO tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection (ordersProductsID, optionCaption, textValue)
	SELECT DISTINCT ordersProductsID, optionCaption, textValue 
	FROM tblOrdersProducts_productOptions
	WHERE optionCaption = 'Group ID'

	--// update option_customEnvelope
	UPDATE tblSwitch_NOP_NC
	SET option_customEnvelope = c.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection x
		ON a.ordersproductsID = CONVERT(INT, x.textValue)
	INNER JOIN tblOrdersProducts_productOptions c
		ON x.ordersProductsID = c.ordersProductsID
	WHERE a.ordersProductsID <> x.ordersProductsID
	AND x.optionCaption = 'Group ID'
	AND c.optionCaption IN ('CanvasHiResEnvelopeBack File Name','CanvasHiResEnvelopeFront File Name') --bjs 1/7/21 iframe conversion
	AND c.deleteX <> 'yes'

	--NOP ENVELOPES
	-- bring in related envelope product information from groupID related envelope products.
	UPDATE tblSwitch_NOP_NC
	SET env_productCode = p.productCode,
	env_productName = p.productName,
	env_productQuantity = p.productQuantity,
	env_color = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection x
		ON a.ordersproductsID = CONVERT(INT, x.textValue)
	INNER JOIN tblOrders_Products p
		ON x.ordersProductsID = p.ID
	INNER JOIN tblOrdersProducts_productOptions b
		ON p.ID = b.ordersProductsID
	WHERE a.ordersProductsID <> x.ordersProductsID
	AND b.optionCaption = 'Envelope Color'

	--CANVAS MC ENVELOPES (which do not have the optionCaption = 'Group ID' as used in creating tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection. Rather, it uses tblOrders_Products.groupID like normal.
	UPDATE tblSwitch_NOP_NC
	SET env_productCode = b.productCode, 
	env_productName = b.productName, 
	env_productQuantity = b.productQuantity
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrders_Products b
		ON a.orderID = b.orderID
	WHERE SUBSTRING(b.productCode, 3, 2) = 'EV'
	AND a.groupID = b.groupID
	AND b.deleteX <> 'yes'
	AND a.env_productCode IS NULL
	AND a.env_productName IS NULL
	AND a.env_productQuantity IS NULL
	AND b.ID NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_ProductOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'Group ID')

	--CANVAS MC ENVELOPE COLORS. This section updates env_color as it is not passed through as an OPPO option like NOP NCs.
	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Red'
	WHERE env_productName LIKE '%Red%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Green'
	WHERE env_productName LIKE '%Green%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'White'
	WHERE env_productName LIKE '%White%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Kraft'
	WHERE env_productName LIKE '%Kraft%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Yellow'
	WHERE env_productName LIKE '%Yellow%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Gray'
	WHERE env_productName LIKE '%Gray%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Aqua Blue Ocean'
	WHERE env_productName LIKE '%Aqua Blue Ocean%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Cobalt Blue'
	WHERE env_productName LIKE '%Cobalt Blue%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Hot Pink'
	WHERE env_productName LIKE '%Hot Pink%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Key Lime'
	WHERE env_productName LIKE '%Key Lime%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Lilac Purple'
	WHERE env_productName LIKE '%Lilac Purple%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Plum Purple'
	WHERE env_productName LIKE '%Plum Purple%'
	AND env_color IS NULL

	UPDATE tblSwitch_NOP_NC
	SET env_color = 'Tangerine Zest'
	WHERE env_productName LIKE '%Tangerine Zest%'
	AND env_color IS NULL

	--Update productCodes with "CU" ending.
	UPDATE tblSwitch_NOP_NC
	SET env_productCode = REPLACE(env_productCode, 'CU', '')
	WHERE env_productCode LIKE '%CU'

	--1/3 option_envelope FRONT
	UPDATE tblSwitch_NOP_NC
	SET option_envelope = p.productCode + '.Front.pdf'
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection x
		ON a.ordersproductsID = CONVERT(INT, x.textValue)
	INNER JOIN tblOrders_Products p
		ON x.ordersProductsID = p.ID
	INNER JOIN tblOrdersProducts_productOptions b
		ON p.ID = b.ordersProductsID
	WHERE a.ordersProductsID <> x.ordersProductsID
	AND b.optionCaption IN ( 'CanvasHiResEnvelopeFront File Name')
	AND b.deleteX <> 'yes'

	--2/3 option_envelope BACK
	UPDATE tblSwitch_NOP_NC
	SET option_envelope = p.productCode + '.Back.pdf'
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions_NOP_SwitchEnvelopeConnection x
		ON a.ordersproductsID = CONVERT(INT, x.textValue)
	INNER JOIN tblOrders_Products p
		ON x.ordersProductsID = p.ID
	INNER JOIN tblOrdersProducts_productOptions b
		ON p.ID = b.ordersProductsID
	WHERE a.ordersProductsID <> x.ordersProductsID
	AND b.optionCaption IN ('CanvasHiResEnvelopeBack File Name')
	AND b.deleteX <> 'yes'

	--3/3 update default "no image" value if option_envelope <> one of the options above
	UPDATE tblSwitch_NOP_NC
	SET option_envelope = env_productCode + '.Front.pdf'
	WHERE (option_envelope NOT LIKE '%Front.pdf'
				 AND option_envelope NOT LIKE '%Back.pdf')
	OR option_envelope IS NULL

	UPDATE tblSwitch_NOP_NC
	SET option_envelope = REPLACE(option_envelope, 'CU', '')
	WHERE option_envelope LIKE '%CU.Front.pdf'
	OR option_envelope LIKE '%CU.Back.pdf'

	--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ END ENVELOPES
	--option_cov (CARD FRONT)
	UPDATE tblSwitch_NOP_NC
	SET option_cov = b.textvalue --REPLACE(b.textValue, @UncBasePath, '')
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption IN (  'CanvasHiResFront File Name' )
	AND b.deleteX <> 'yes'
	AND a.option_cov IS NULL

	--option_bak (CARD BACK)
	UPDATE tblSwitch_NOP_NC
	SET option_bak = b.textValue --REPLACE(b.textValue, @UncBasePath, '')
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption IN ( 'CanvasHiResBack File Name')
	AND b.deleteX <> 'yes'
	AND a.option_bak IS NULL

	--// Populate shortName column where NULL
	UPDATE tblSwitch_NOP_NC
	SET shortName = ISNULL(RTRIM(SUBSTRING(productName, 1, (SELECT CHARINDEX('(', productName)-1))), productName)
	WHERE (shortName IS NULL OR shortName = '')
	AND productName LIKE '('

	UPDATE tblSwitch_NOP_NC
	SET shortName = ISNULL(REPLACE(shortName, (SUBSTRING(shortName, 1, (SELECT CHARINDEX('-', productName)+1))), ''), shortName)
	WHERE shortName LIKE '%-%'
	AND shortName IS NOT NULL

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
SET @json = (SELECT orderid,@flowName as switchflow from tblSwitch_NOP_NC FOR JSON PATH);
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
FROM tblSwitch_NOP_NC s
LEFT JOIN #tmpShip t on s.orderID = t.orderID;

UPDATE s
SET shipsWith = 'Local Pickup'
FROM tblSwitch_NOP_NC s
INNER JOIN tblOrders o ON s.orderid = o.orderid
	WHERE (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')





	-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
	UPDATE x
	SET resubmit = 1
	FROM tblSwitch_NOP_NC x
	WHERE EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products op
		WHERE op.deleteX <> 'yes'
		AND op.fastTrak_resubmit = 1
		AND op.ID = x.ordersProductsID)

	-- For any OPID that has been resubbed, update ShipsWith accordingly
	IF OBJECT_ID('tempdb..#tempResubChoiceNOP_NC') IS NOT NULL 
	DROP TABLE #tempResubChoiceNOP_NC

	CREATE TABLE #tempResubChoiceNOP_NC (
	RowID INT IDENTITY(1, 1), 
	OPID INT)

	DECLARE @NumberRecords_rs INT, 
					 @RowCount_rs INT,
					 @OPID_rs INT,
					 @MostRecent_ResubChoice_rs INT

	INSERT INTO #tempResubChoiceNOP_NC (OPID)
	SELECT DISTINCT ordersProductsID
	FROM tblSwitch_NOP_NC
	WHERE resubmit = 1

	SET @NumberRecords_rs = @@RowCount
	SET @RowCount_rs = 1

	WHILE @RowCount_rs <= @NumberRecords_rs
	BEGIN
		 SELECT @OPID_rs = OPID
		 FROM #tempResubChoiceNOP_NC
		 WHERE RowID = @RowCount_rs

		 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
																FROM tblSwitch_resubOption
																WHERE OPID = @OPID_rs
																ORDER BY resubmitDate DESC)
	
		UPDATE tblSwitch_NOP_NC
		SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
		WHERE ordersProductsID = @OPID_rs	 

		SET @RowCount_rs = @RowCount_rs + 1
	END
	-- RESUBMISSION SECTION -------------------------------------------------------------------------------END

	
	--// shipType Update
	--// default
	UPDATE tblSwitch_NOP_NC
	SET shipType = 'Ship'
	WHERE shipType IS NULL

	--// 3 day
	UPDATE tblSwitch_NOP_NC
	SET shipType = '3 Day'
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblOrders
		WHERE LEN(orderNo) IN (9,10)
		AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

	--// 2 day
	UPDATE tblSwitch_NOP_NC
	SET shipType = '2 Day'
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblOrders
		WHERE LEN(orderNo) IN (9,10)
		AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

	--// Next day
	UPDATE tblSwitch_NOP_NC
	SET shipType = 'Next Day'
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblOrders
		WHERE LEN(orderNo) IN (9,10)
		AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

	--// Local pickup, will call
	UPDATE tblSwitch_NOP_NC
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
	TRUNCATE TABLE tblSwitch_NOP_NC_distinctIDCount
	INSERT INTO tblSwitch_NOP_NC_distinctIDCount (orderID, ordersProductsID)
	SELECT DISTINCT orderID, ordersProductsID
	FROM tblSwitch_NOP_NC

	TRUNCATE TABLE tblSwitch_NOP_NC_distinctIDCount2
	INSERT INTO tblSwitch_NOP_NC_distinctIDCount2 (orderID, countOrderID)
	SELECT orderID, COUNT(orderID) AS 'countOrderID'
	FROM tblSwitch_NOP_NC_distinctIDCount
	GROUP BY orderID
	ORDER BY orderID

	UPDATE tblSwitch_NOP_NC
	SET totalCount = b.countOrderID
	FROM tblSwitch_NOP_NC a 
	INNER JOIN tblSwitch_NOP_NC_distinctIDCount2 b
		ON a.orderID = b.orderID

	UPDATE tblSwitch_NOP_NC
	SET displayCount = NULL,
	multiCount = totalCount

	--// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin PCU
	--// Counts (multiCount and totalCount)
	IF OBJECT_ID(N'tblSwitch_NOP_NC_displayCount', N'U') IS NOT NULL
	DROP TABLE tblSwitch_NOP_NC_displayCount

	CREATE TABLE tblSwitch_NOP_NC_displayCount 
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
	TRUNCATE TABLE tblSwitch_NOP_NC_displayCount
	INSERT INTO tblSwitch_NOP_NC_displayCount (orderID, ordersProductsID, totalCount)
	SELECT DISTINCT orderID, ordersProductsID, totalCount
	FROM tblSwitch_NOP_NC
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
		FROM tblSwitch_NOP_NC_displayCount
		WHERE RowID = @RowCount
	
		UPDATE tblSwitch_NOP_NC
		SET @topMultiCount = (SELECT TOP 1 multiCount
							 FROM tblSwitch_NOP_NC
							 WHERE orderID = @orderID
							 ORDER BY multiCount ASC)
	
		UPDATE tblSwitch_NOP_NC
		SET multiCount = @topMultiCount - 1
		WHERE orderID = @orderID
		AND ordersProductsID = @ordersProductsID
		AND @topMultiCount - 1 <> 0	
	
		SET @RowCount = @RowCount + 1
	END

	UPDATE tblSwitch_NOP_NC
	SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

	--// update packetValue with sortable multi-digit numbers
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
	UPDATE tblSwitch_NOP_NC SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ displayCount calculation
	--// Set flags
	UPDATE tblSwitch_NOP_NC SET switch_approve = 0
	UPDATE tblSwitch_NOP_NC SET switch_print = 0
	UPDATE tblSwitch_NOP_NC SET switch_approveDate = GETDATE()
	UPDATE tblSwitch_NOP_NC SET switch_printDate = GETDATE()
	UPDATE tblSwitch_NOP_NC SET switch_createDate = GETDATE()

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
	FROM tblSwitch_NOP_NC s
INNER JOIN #tmpShip t on s.orderID = t.orderID

	--// update customBackground value
	UPDATE tblSwitch_NOP_NC
	SET customBackground = b.optionCaption
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionGroupCaption = 'Background'

	----// update custom fields for market center NCs from HOM
	--UPDATE tblSwitch_NOP_NC
	--SET option_cov = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	--FROM tblSwitch_NOP_NC a
	--INNER JOIN tblOrdersProducts_productOptions b
	--	ON a.ordersProductsID = b.ordersProductsID
	--WHERE NULLIF(a.option_cov,'') IS NULL
	--AND b.optionCaption IN ( 'Intranet PDF')
	--AND b.deleteX <> 'yes'

	UPDATE tblSwitch_NOP_NC
	SET option_cov = textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE NULLIF(a.option_cov,'') IS NULL
	AND b.optionCaption IN ('CanvasHiResFront File Name')
	AND b.deleteX <> 'yes'

	--UPDATE tblSwitch_NOP_NC
	--SET option_customInside = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	--FROM tblSwitch_NOP_NC a
	--INNER JOIN tblOrdersProducts_productOptions b
	--	ON a.ordersProductsID = b.ordersProductsID
	--WHERE NULLIF(a.option_customInside,'') IS NULL
	--AND b.optionCaption IN ( 'CanvasHiResInside File Name')
	--AND b.deleteX <> 'yes'

	UPDATE tblSwitch_NOP_NC
	SET option_customInside = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE NULLIF(a.option_customInside,'') IS NULL
	AND b.optionCaption IN ( 'CanvasHiResInside File Name')
	AND b.deleteX <> 'yes'

	--UPDATE tblSwitch_NOP_NC
	--SET option_bak = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	--FROM tblSwitch_NOP_NC a
	--INNER JOIN tblOrdersProducts_productOptions b
	--	ON a.ordersProductsID = b.ordersProductsID
	--WHERE NULLIF(a.option_bak,'') IS NULL
	--AND b.optionCaption IN ( 'Back Intranet PDF')
	--AND b.deleteX <> 'yes'

	UPDATE tblSwitch_NOP_NC
	SET option_bak = b.textValue
	FROM tblSwitch_NOP_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE NULLIF(a.option_bak,'') IS NULL
	AND b.optionCaption IN ( 'CanvasHiResBack File Name')
	AND b.deleteX <> 'yes'

	--// prep data for output
	TRUNCATE TABLE tblSwitch_NOP_NC_ForOutput
	INSERT INTO tblSwitch_NOP_NC_ForOutput (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, ordersProductsID, shipsWith, resubmit, shipType, displayCount, switch_create, switch_createDate, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, env_productCode, env_productName, env_productQuantity, env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, samplerRequest, displayedQuantity, option_customEnvelope, customBackground, fullCard)
	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, ordersProductsID, shipsWith, resubmit, shipType, displayCount, switch_create, switch_createDate, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, env_productCode, env_productName, env_productQuantity, env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, samplerRequest, displayedQuantity, option_customEnvelope, customBackground, fullCard
	FROM tblSwitch_NOP_NC 
	ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

	--INSERT INTO tblSwitch_NOP_NCLog (PKID, ordersProductsID, insertedOn)
	--SELECT DISTINCT PKID, ordersProductsID, GETDATE()
	--FROM tblSwitch_NOP_NC_ForOutput

	--Step to log current batch of OPID/Punits
	declare @CurrentDate datetime = getdate() --Get current date for batch
	insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
	select 
	flowName = 'NOP_NC'
	,a.PKID
	,a.ordersProductsID
	,batchTimestamp = @CurrentDate
	,jsonData = 
		   (select *
		   from tblSwitch_NOP_NC_ForOutput b
		   where a.PKID = b.PKID
		   for json path)
	from tblSwitch_NOP_NC_ForOutput a	-- Update OPID status fields indicating successful submission to switch

	UPDATE tblOrders_Products
	SET switch_create = 1,
		fastTrak_status = 'In Production',
		fastTrak_status_lastModified = GETDATE(),
		fastTrak_resubmit = 0
	FROM tblOrders_Products op
	INNER JOIN tblSwitch_NOP_NC_ForOutput t ON op.ID = t.ordersProductsID

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, ordersProductsID, shipsWith, resubmit, shipType, displayCount, switch_create, switch_createDate, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, env_productCode, env_productName, env_productQuantity, env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, samplerRequest, displayedQuantity, option_customEnvelope, fullCard
	FROM tblSwitch_NOP_NC_ForOutput 
	ORDER BY PKID, orderID, displayCount, ordersProductsID --, packetValue 
	ASC


END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH