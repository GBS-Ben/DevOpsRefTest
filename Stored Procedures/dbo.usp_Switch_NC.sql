CREATE PROCEDURE [dbo].[usp_Switch_NC]
AS
/*
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/3/16
-- Purpose     Pulls NON-CANVAS note card products (NC) into Switch for production.
-------------------------------------------------------------------------------
-- Modification History

08/03/16		New
09/30/16		Truncation, G2G in primary INSERT.
10/21/16	Added option_customEnvelope code, located near LN 412.
10/22/16	Removed shipsWith logic near LN 671.
11/01/16		updated shipsWith Stock section.
12/29/16	Added customBackground code to end of sproc.
01/17/17	added "AND (p.productType = 'Custom' OR p.productType = 'fasTrak')" phrase throughout to capture the fact that NC are now FT products.
01/17/17	added the following section to 2 areas near LN 1086 to help pull out NCEVs from Job Ticket when they should not be counted as singular stock product.
						--AND b.ID NOT IN
						--	(SELECT ID
						--	FROM tblOrders_Products
						--	WHERE SUBSTRING(b.productCode, 1, 4) = 'NCEV' 
						--	AND b.groupID <> 0)
01/24/17	added LN 427 regarding generic option_envelope color code, vs having specific blocks of color code.
						removed block of env_color code starting near LN 280
01/27/16		Added optionID = '518' code in initial query.
02/20/17		Removed orderStatus checks against "Delivered" and "Transit" in intial query.
03/28/17		Added SN to PN, jf.
09/19/17		Added fullCard section near LN 925 that relates to Market Center Cards in the flow. This is copied over from the NOP_NC version of the flow, jf.
09/22/17		Modified fullCard section, jf.
09/27/17		Modified option_envelope section to look at 1,12 vs 1,14 in substring, which effectively ignores "CU" suffixes, jf.
09/28/17		Added env_color = 'white' to the fullCard = 1 OPIDs, jf.
10/20/17		JF, fixed CU section around LN 590
11/07/17		pulled out BP/BC, jf
11/08/17		set default option_envelope value for MCs, jf.
11/16/17		Added exceptions: NCFAH6-00001, NCFAV6-00001 to initial query as per DW request, jf.
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
03/14/18		Pi, added optionID clauses in initial query to exclude Canvas and Custom Market Centers in addition to QCM optionIDs, jf.
04/03/18		Killed SN logic with fire, jf.
06/28/18		JF, added updates to tblProducts.fastTrak_productType sections to account for processType lookups vs. tblProduct lookups.
08/10/18		JF, added <1 price to fullCard spec near LN 1000.
08/17/18		JF, updated fullCard queries so that envelope default white image gets updated regardless of price change made on on 8/10
08/22/18		JF, added this back into fullCard section (in two places): SUBSTRING(a.productCode, 1, 12)  (the substring was missing).
11/12/19		JF, added [AND op.processType = 'fasTrak'] to primary query. Pulled out [AND (p.productType = 'Custom' OR p.productType = 'fasTrak')] from the primary query. this should help with the Furnished Art gate.
11/14/19		JF, added readyForSwitch check.
11/19/19		JF, killed  MC code with hellfire (near ln 1242)
01/27/19		JF, added Credit Due up top.
02/11/20		CT, Added Select Date Constraints to keep old orders from flowing through (LN 139)
08/04/20		JF, Added stripper to init query.
09/09/20		JF, Added fileExists fix to init query.
10/13/20		JF, Added resubmission section that modifies ShipsWith value if OPID is resubbed.
11/23/20		JF, LEN(orderNo) IN (9,10)
01/07/21		BS, iframe Conversion, limit to non-canvas cards
04/21/21		CKB, modified file check #5
07/22/21		CKB, added validate file
11/10/21		CKB, added processstatus
12/17/21		CKB, fix stock count to match QC logic - clickup #1wv1ntt 
02/11/22		CKB, modified sports gate logic to be data driven group gates - clickup #1x7bmfc
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

DECLARE @flowName AS VARCHAR(20) = 'NC'

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'NC Switch SP', @lastRunDate;

BEGIN TRY
	--First, validate image files
	EXEC usp_OPPO_validateFile 'NC'

	TRUNCATE TABLE tblSwitch_NC
	INSERT INTO tblSwitch_NC (orderID, orderNo, orderDate, customerID, 
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
	-- all subsequent fields in tblSwitch_NC are updated below.
	FROM tblOrders a
	INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
	INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
	INNER JOIN tblProducts p ON op.productID = p.productID
	LEFT JOIN tblSkuGroup sg ON p.productCode LIKE sg.skuPattern
	LEFT JOIN tblSkuGroupGate g ON sg.skuGroup = g.skuGroup
	WHERE a.orderDate > CONVERT(DATETIME, '09/01/2019')
	AND DATEDIFF(MI, a.created_on, GETDATE()) > 10
	AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
	AND a.orderStatus NOT LIKE '%Waiting%'
	AND a.displayPaymentStatus IN ('Good', 'Credit Due')
	AND SUBSTRING(a.orderNo, 1, 3) <> 'NCC'
	AND op.deleteX <> 'yes'
	AND op.processType = 'fasTrak'
	AND SUBSTRING(p.productCode, 1, 2) = 'NC'
	AND SUBSTRING(p.productCode, 3, 2) <> 'EV'
	AND p.productCode NOT IN ('NCFAH6-00001', 'NCFAV6-00001')
	AND op.[ID] NOT IN 
		(SELECT DISTINCT ordersProductsID 
		FROM tblSwitch_NC 
		WHERE ordersProductsID IS NOT NULL)
	AND op.switch_create = 0

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

	AND NOT EXISTS  --1/7/21 BJS iframe conversion work here
		(SELECT TOP 1 ordersProductsID
		FROM tblOrdersProducts_productOptions opex
		WHERE opex.ordersProductsID = op.ID
		AND deleteX <> 'yes'
		AND (optionID = 518 --QuickCard Mailer optionID
				 OR optionID = 535 --Canvas optionID --1/7/21 BJS This isn't always added
				 OR optionID = 541 --1/7/21 BJS CC State ID should always be added to canvas products during iframe conversion
				 OR optionCaption LIKE 'CanvasHiRes%' --1/7/21 BJS Just to be extra sure canvas cards don't flow this way
				 OR optionID = 562 --Custom Market Center optionID
			)
		)
	--Image Check ----------------------------------
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

	--Sampler request text
	UPDATE tblSwitch_NC
	SET samplerRequest = 'NCC Sampler Pack'
	WHERE samplerRequest = 'yes'

	UPDATE tblSwitch_NC
	SET samplerRequest = NULL
	WHERE samplerRequest = 'no'

	--// fix productQuantity if fasTrak_newQTY value exists
	UPDATE tblSwitch_NC
	SET productQuantity = b.fastTrak_newQTY
	FROM tblSwitch_NC a
	INNER JOIN tblOrders_Products b
		ON a.ordersProductsID = b.ID
	WHERE (b.fastTrak_newQTY IS NOT NULL 
		  AND b.fastTrak_newQTY <> 0 )
	AND a.productQuantity <> b.fastTrak_newQTY

	--// get OPTION data.
	--option_cause	
	--// update custom option fields per line item
	-- bring in new cause
	UPDATE tblSwitch_NC
	SET option_cause = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_cause IS NULL
	AND b.optionCaption = 'Cause'
	AND b.deleteX <> 'yes'

	-- update cause if changed
	UPDATE tblSwitch_NC
	SET option_cause = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_cause IS NOT NULL
	AND a.option_cause <> CONVERT(VARCHAR(MAX), b.textValue)
	AND b.optionCaption = 'Cause'
	AND b.deleteX <> 'yes'

	-- option_cause
	UPDATE tblSwitch_NC
	SET option_cause = 'No Cause Selected'
	WHERE option_cause IS NULL

	-- option_bak
	UPDATE tblSwitch_NC SET option_bak = 'GC_AutismBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'The Autism Society of San Diego' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_AutismBack.V.pdf' WHERE option_bak IS NULL AND option_cause = 'The Autism Society of San Diego' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BloodWaterBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Blood:Water Mission' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BloodWaterBack.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Blood:Water Mission' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BootBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Boot Campaign' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BootBack.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Boot Campaign' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_EducationBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Education' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_EducationBack.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Education' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_erasepovertyBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Erase Poverty' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_ErasePoverty.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Erase Poverty' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_Love146Back.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Love146' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_Love146Back.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Love146' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_MosquitoNetsBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Mosquito Nets' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_MosquitoNetsBack.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Mosquito Nets' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_PlantPurposeBack.H.pdf' WHERE option_bak IS NULL AND option_cause = 'Plant With Purpose' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_PlantPurposeBack.V.pdf' WHERE option_bak IS NULL AND option_cause = 'Plant With Purpose' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_RedCrossBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'American Red Cross' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_RedCrossBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'American Red Cross' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'NCC_Back.H.pdf' WHERE option_bak IS NULL AND option_cause = 'No Cause Selected' AND SUBSTRING(productCode, 5,1) = 'H' 
	UPDATE tblSwitch_NC SET option_bak = 'NCC_Back.H.pdf' WHERE option_bak IS NULL AND option_cause IS NULL AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'NCC_Back.V.pdf' WHERE option_bak IS NULL AND option_cause = 'No Cause Selected' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'NCC_Back.V.pdf' WHERE option_bak IS NULL AND option_cause IS NULL AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_CCFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'ccfoodbank' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_CCFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'ccfoodbank' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_CCFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'Clark County Food Bank' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_CCFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'Clark County Food Bank' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BideaweeBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%bideawee%' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BideaweeBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%bideawee%' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_LRMFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%lewis%' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_LRMFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%lewis%' AND SUBSTRING(productCode, 5,1) = 'V'

	UPDATE tblSwitch_NC SET option_bak = 'GC_BBBSBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'Big Brothers Big Sisters of San Diego County' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BBBSBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'Big Brothers Big Sisters of San Diego County' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_BBBSBack.X.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'Big Brothers Big Sisters of San Diego County 2' AND SUBSTRING(productCode, 5,1) = 'X'

	UPDATE tblSwitch_NC SET option_bak = 'GC_JanusBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%Janus%' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_JanusBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%Janus%' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_MarthasPantryBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%martha%' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_MarthasPantryBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%martha%' AND SUBSTRING(productCode, 5,1) = 'V'
	UPDATE tblSwitch_NC SET option_bak = 'GC_NCCFoodBankBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'North County Community Food Bank' AND SUBSTRING(productCode, 5,1) = 'H'
	UPDATE tblSwitch_NC SET option_bak = 'GC_NCCFoodBankBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) = 'North County Community Food Bank' AND SUBSTRING(productCode, 5,1) = 'V'

	--option_customInside	
	UPDATE tblSwitch_NC
	SET option_customInside = b.textValue + '.pdf'
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionGroupCaption = 'Uploaded Files'
	AND (a.option_customInside IS NULL 
		 OR a.option_customInside = 'Blank_inside.pdf')
	AND (b.textValue LIKE '%-INSIDE-%' 
		 OR b.textValue LIKE '%.inside%' 
		 OR b.textValue LIKE '%GRT%')
	AND b.deleteX <> 'yes'
	AND a.option_customInside IS NULL

	--option_customInside: update customInside if changed (part 1)
	UPDATE tblSwitch_NC
	SET option_customInside = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_customInside IS NOT NULL
	AND REPLACE(a.option_customInside, '.pdf','') <> CONVERT(VARCHAR(MAX), b.textValue)
	AND (b.textValue LIKE '%-INSIDE-%' 
		 OR b.textValue LIKE '%.inside%'
		 OR b.textValue LIKE '%GRT%')
	AND b.deleteX <> 'yes'

	-- option_customInside: update customeInside if changed (part 2)
	UPDATE tblSwitch_NC
	SET option_customInside = REPLACE(b.textValue, '/InProduction/NoteCards/Greetings/', '')
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_customInside IS NOT NULL
	AND REPLACE(a.option_customInside, '.pdf','') <> CONVERT(VARCHAR(MAX), b.textValue)
	AND (b.textValue LIKE '%GRT%' 
		 OR b.textValue LIKE '%inside%')
	AND (b.optionCaption = 'File Name 3' 
		 OR b.optionCaption = 'File Name 4')
	AND b.textValue NOT LIKE '%.jpg'
	AND b.deleteX <> 'yes'

	UPDATE tblSwitch_NC
	SET option_customInside = REPLACE(option_customInside, '.pdf.pdf', '.pdf')

	UPDATE tblSwitch_NC
	SET option_customInside = 'Blank_inside.pdf'
	WHERE option_customInside IS NULL

	--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	--// ENVELOPES BEGIN:
	-- bring in related envelope product information
	UPDATE tblSwitch_NC
	SET env_productCode = b.productCode, 
	env_productName = b.productName, 
	env_productQuantity = b.productQuantity
	FROM tblSwitch_NC a
	INNER JOIN tblOrders_Products b
		ON a.orderID = b.orderID
	WHERE SUBSTRING(b.productCode, 3, 2) = 'EV'
	AND a.groupID = b.groupID
	AND b.deleteX <> 'yes'
	AND a.env_productCode IS NULL
	AND a.env_productName IS NULL
	AND a.env_productQuantity IS NULL
	   
	 --1. bring in new envelope custom info (edit, JF 11/26/13)
	UPDATE tblSwitch_NC
	SET option_envelope = b.textValue
	FROM tblSwitch_NC a 
	INNER JOIN tblOrdersProducts_productOptions b
		ON SUBSTRING(a.option_customInside, 1, 12) = SUBSTRING(b.textValue, 1, 12)
	INNER JOIN tblOrders_Products x
		ON a.ordersProductsID = x.[ID]
	WHERE (b.textValue LIKE '%NCEV%' 
			OR b.textValue LIKE '%.env')
	AND b.deleteX <> 'yes'

	--2. update envelope custom info if changed
	UPDATE tblSwitch_NC
	SET option_envelope = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON SUBSTRING(a.option_envelope, 1, 12) = SUBSTRING(b.textValue, 1, 12)
	WHERE a.option_envelope IS NOT NULL
	AND REPLACE(a.option_envelope, '.pdf', '') <> CONVERT(VARCHAR(MAX), b.textValue)
	AND (b.textValue LIKE '%NCEV%' 
		 OR b.textValue LIKE '%.env')
	AND b.deleteX <> 'yes'

	-- Section that accounts for orders that have no custom product, but still have custom envelope(s)
	UPDATE tblSwitch_NC
	SET option_envelope = b.textValue
	FROM tblSwitch_NC a 
	INNER JOIN tblOrders o
		ON a.orderNo = o.orderNo
	INNER JOIN tblOrders_Products p
		ON o.orderID = p.orderID
	INNER JOIN tblOrdersProducts_productOptions b
		ON p.[ID] = b.ordersProductsID
	WHERE (a.option_customInside IS NULL 
			OR a.option_customInside LIKE '%Blank_inside%')
	AND ((a.option_envelope NOT LIKE '%NCEV%' 
			AND a.option_envelope NOT LIKE '%NCENV%' 
			AND a.option_envelope NOT LIKE '%.env') 
		 OR a.option_envelope IS NULL)
	AND (b.textValue LIKE '%NCEV%' 
		 OR b.textValue LIKE '%.env')
	AND b.deleteX <> 'yes'
	AND a.env_productName = p.productName

	--option_envelope: populate final data
	UPDATE tblSwitch_NC
	SET option_envelope = b.textValue + '.pdf'
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	INNER JOIN tblOrders_Products p
		ON a.groupID = p.groupID
	WHERE SUBSTRING(p.productCode, 3, 2) = 'EV'
	AND b.optionGroupCaption = 'Uploaded Files'
	AND b.textValue LIKE '%env%'
	AND b.deleteX <> 'yes'

	UPDATE tblSwitch_NC
	SET option_envelope = REPLACE(option_envelope, '.pdf.pdf', '.pdf')

	-- update default "no image" value if option_envelope is still blank
	UPDATE tblSwitch_NC
	SET option_envelope = 'no.env.image.env.pdf'
	WHERE option_envelope IS NULL
	OR option_envelope = ''

	-- 4. option_customEnvelope: get image name for the custom envelope image, added 10/21/16; jf.
	UPDATE tblSwitch_NC
	SET option_customEnvelope = REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.pdf', '.jpg')
	FROM tblOrdersProducts_productOptions x
	INNER JOIN tblOrders_Products b
		ON x.ordersProductsID = b.ID
	INNER JOIN tblSwitch_NC a
		ON b.orderID = a.orderID
	INNER JOIN tblProducts p
		ON b.productID = p.productID
	WHERE SUBSTRING(b.productCode, 3, 2) = 'EV'
	AND a.groupID = b.groupID
	AND b.deleteX <> 'yes'
	AND x.optionCaption = 'File Name 2'
	AND (p.productType = 'Custom' OR p.productType = 'fasTrak')

	--This code replaces the color specific iterations below.
	UPDATE tblSwitch_NC
	SET option_envelope = env_productCode + '.Front.pdf'
	WHERE (option_envelope IS NULL OR option_envelope = 'no.env.image.env.pdf' )
	AND env_productCode IS NOT NULL
	AND env_productCode <> ''

	--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	--option_cov	
	UPDATE tblSwitch_NC
	SET option_cov = b.textValue + '.pdf'
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionGroupCaption = 'Uploaded Files'
	AND b.textValue LIKE '%-cov-%'
	AND b.deleteX <> 'yes'
	AND a.option_cov IS NULL

	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov, '.pdf.pdf', '.pdf')

	--option_cov: update .cov if changed
	UPDATE tblSwitch_NC
	SET option_cov = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_cov IS NOT NULL
	AND a.option_cov <> CONVERT(VARCHAR(MAX), b.textValue)
	AND b.textValue LIKE '%.cov'
	AND b.deleteX <> 'yes'

	--option_cov: Update option_cov with a custom Cov, if applicable
	UPDATE tblSwitch_NC
	SET option_cov = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_cov IS NULL
	AND b.textValue LIKE '%.pdf%'
	AND b.optionCaption = 'File Name 2'
	AND b.deleteX <> 'yes'
	AND (SUBSTRING(a.productCode, 1, 4) = 'NCPC'
		OR SUBSTRING(a.productCode, 1, 4) = 'NCLC')

	--option_cov: accomodate productCode length change.
	UPDATE tblSwitch_NC
	SET option_cov = SUBSTRING(productCode, 1, 18) + '.pdf'
	WHERE option_cov IS NULL

	--option_cov: extensions
	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'.jpg','.pdf')
	WHERE option_cov LIKE '%.jpg%'

	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'.jpg.pdf','.pdf')
	WHERE option_cov LIKE '%.jpg.pdf%'

	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'.pdf.pdf','.pdf')
	WHERE option_cov LIKE '%.pdf.pdf%'

	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'/InProduction/NoteCards/Covers/','')
	WHERE option_cov LIKE '%/InProduction/NoteCards/Covers/%'

	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'/OpcPreview/NoteCards/Covers/','')
	WHERE option_cov LIKE '%/OpcPreview/NoteCards/Covers/%'

	--Fix CUGC issues.
	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'CUGC.','.')
	WHERE option_cov LIKE '%CUGC.%'

	UPDATE tblSwitch_NC
	SET option_envelope = REPLACE(option_envelope,'CUGC.','.')
	WHERE option_envelope LIKE '%CUGC.%'

	--Fix CU issues.
	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'CU.','.')
	WHERE option_cov LIKE '%CU.%'

	UPDATE tblSwitch_NC
	SET option_envelope = REPLACE(option_envelope,'CU.','.')
	WHERE option_envelope LIKE '%CU.%'

	--Fix GC issues.
	UPDATE tblSwitch_NC
	SET option_cov = REPLACE(option_cov,'GC.','.')
	WHERE option_cov LIKE '%GC.%'

	UPDATE tblSwitch_NC
	SET option_envelope = REPLACE(option_envelope,'GC.','.')
	WHERE option_envelope LIKE '%GC.%'

	--option_bak (will be modified below)
	UPDATE tblSwitch_NC
	SET option_bak = b.textValue
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Cause'
	AND b.deleteX <> 'yes'
	AND a.option_bak IS NULL

	-- option_bak
	UPDATE tblSwitch_NC SET option_bak='GC_AutismBack.H.pdf' WHERE option_bak ='The Autism Society of San Diego' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_AutismBack.V.pdf' WHERE option_bak ='The Autism Society of San Diego' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_BloodWaterBack.H.pdf' WHERE option_bak ='Blood:Water Mission' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_BloodWaterBack.V.pdf' WHERE option_bak ='Blood:Water Mission' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_BootBack.H.pdf' WHERE option_bak ='Boot Campaign' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_BootBack.V.pdf' WHERE option_bak ='Boot Campaign' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_EducationBack.H.pdf' WHERE option_bak ='Education' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_EducationBack.V.pdf' WHERE option_bak ='Education' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_erasepovertyBack.H.pdf' WHERE option_bak ='Erase Poverty' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_ErasePoverty.V.pdf' WHERE option_bak ='Erase Poverty' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_Love146Back.H.pdf' WHERE option_bak ='Love146' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_Love146Back.V.pdf' WHERE option_bak ='Love146' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_MosquitoNetsBack.H.pdf' WHERE option_bak ='Mosquito Nets' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_MosquitoNetsBack.V.pdf' WHERE option_bak ='Mosquito Nets' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_PlantPurposeBack.H.pdf' WHERE option_bak ='Plant With Purpose' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_PlantPurposeBack.V.pdf' WHERE option_bak ='Plant With Purpose' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_RedCrossBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='American Red Cross' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_RedCrossBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='American Red Cross' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='NCC_Back.H.pdf' WHERE option_bak ='No Cause Selected' AND SUBSTRING(productCode,5,1)='H' 
	UPDATE tblSwitch_NC SET option_bak='NCC_Back.H.pdf' WHERE option_bak  IS NULL AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='NCC_Back.V.pdf' WHERE option_bak ='No Cause Selected' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='NCC_Back.V.pdf' WHERE option_bak  IS NULL AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_CCFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='ccfoodbank' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_CCFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='ccfoodbank' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_CCFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='Clark County Food Bank' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_CCFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='Clark County Food Bank' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_BideaweeBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%bideawee%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_BideaweeBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%bideawee%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_LRMFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%lewis%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_LRMFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%lewis%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_BBBSBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='Big Brothers Big Sisters of San Diego County' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_BBBSBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='Big Brothers Big Sisters of San Diego County' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_BBBSBack.X.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='Big Brothers Big Sisters of San Diego County 2' AND SUBSTRING(productCode,5,1)='X'
	UPDATE tblSwitch_NC SET option_bak='GC_JanusBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%Janus%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_JanusBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%Janus%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_MarthasPantryBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%martha%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_MarthasPantryBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak) LIKE '%martha%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblSwitch_NC SET option_bak='GC_NCCFoodBankBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='North County Community Food Bank' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblSwitch_NC SET option_bak='GC_NCCFoodBankBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_bak)='North County Community Food Bank' AND SUBSTRING(productCode,5,1)='V'

	--// Populate shortName column where NULL (added: 11/04/2013, JF)
	UPDATE tblSwitch_NC
	SET shortName = RTRIM(SUBSTRING(productName, 1, (SELECT CHARINDEX('(', productName)-1)))
	WHERE shortName IS NULL
	OR shortName = ''

	UPDATE tblSwitch_NC
	SET shortName = REPLACE(shortName, (SUBSTRING(shortName, 1, (SELECT CHARINDEX('-', productName)+1))), '')
	WHERE shortName LIKE '%-%'
	AND shortName IS NOT NULL

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
SET @json = (SELECT orderid,@flowName as switchflow from tblSwitch_NC FOR JSON PATH);
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
FROM tblSwitch_NC s
LEFT JOIN #tmpShip t on s.orderID = t.orderID;

UPDATE s
SET shipsWith = 'Local Pickup'
FROM tblSwitch_NC s
INNER JOIN tblOrders o ON s.orderid = o.orderid
	WHERE (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')


	-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
	UPDATE x
	SET resubmit = 1
	FROM tblSwitch_NC x
	WHERE EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products op
		WHERE op.deleteX <> 'yes'
		AND op.fastTrak_resubmit = 1
		AND op.ID = x.ordersProductsID)

	-- For any OPID that has been resubbed, update ShipsWith accordingly
	IF OBJECT_ID('tempdb..#tempResubChoice_NC') IS NOT NULL 
	DROP TABLE #tempResubChoice_NC

	CREATE TABLE #tempResubChoice_NC (
	RowID INT IDENTITY(1, 1), 
	OPID INT)

	DECLARE @NumberRecords_rs INT, 
					 @RowCount_rs INT,
					 @OPID_rs INT,
					 @MostRecent_ResubChoice_rs INT

	INSERT INTO #tempResubChoice_NC (OPID)
	SELECT DISTINCT ordersProductsID
	FROM tblSwitch_NC
	WHERE resubmit = 1

	SET @NumberRecords_rs = @@RowCount
	SET @RowCount_rs = 1

	WHILE @RowCount_rs <= @NumberRecords_rs
	BEGIN
		 SELECT @OPID_rs = OPID
		 FROM #tempResubChoice_NC
		 WHERE RowID = @RowCount_rs

		 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
																FROM tblSwitch_resubOption
																WHERE OPID = @OPID_rs
																ORDER BY resubmitDate DESC)
	
		UPDATE tblSwitch_NC
		SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
		WHERE ordersProductsID = @OPID_rs	 

		SET @RowCount_rs = @RowCount_rs + 1
	END
	-- RESUBMISSION SECTION -------------------------------------------------------------------------------END
	
	--// shipType Update
	--// default
	UPDATE tblSwitch_NC
	SET shipType = 'Ship'
	WHERE shipType IS NULL

	--// 3 day
	UPDATE tblSwitch_NC
	SET shipType = '3 Day'
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblOrders
		WHERE LEN(orderNo) IN (9,10)
		AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

	--// 2 day
	UPDATE tblSwitch_NC
	SET shipType = '2 Day'
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblOrders
		WHERE LEN(orderNo) IN (9,10)
		AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

	--// Next day
	UPDATE tblSwitch_NC
	SET shipType = 'Next Day'
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblOrders
		WHERE LEN(orderNo) IN (9,10)
		AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

	--// Local pickup, will call
	UPDATE tblSwitch_NC
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
	TRUNCATE TABLE tblSwitch_NC_distinctIDCount
	INSERT INTO tblSwitch_NC_distinctIDCount (orderID, ordersProductsID)
	SELECT DISTINCT orderID, ordersProductsID
	FROM tblSwitch_NC

	TRUNCATE TABLE tblSwitch_NC_distinctIDCount2
	INSERT INTO tblSwitch_NC_distinctIDCount2 (orderID, countOrderID)
	SELECT orderID, COUNT(orderID) AS 'countOrderID'
	FROM tblSwitch_NC_distinctIDCount
	GROUP BY orderID
	ORDER BY orderID

	UPDATE tblSwitch_NC
	SET totalCount = b.countOrderID
	FROM tblSwitch_NC a 
	INNER JOIN tblSwitch_NC_distinctIDCount2 b
		ON a.orderID = b.orderID


	UPDATE tblSwitch_NC
	SET displayCount = NULL,
	multiCount = totalCount

	--// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin PCU
	--// Counts (multiCount and totalCount)
	IF OBJECT_ID(N'tblSwitch_NC_displayCount', N'U') IS NOT NULL
	DROP TABLE tblSwitch_NC_displayCount

	CREATE TABLE tblSwitch_NC_displayCount 
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
	TRUNCATE TABLE tblSwitch_NC_displayCount
	INSERT INTO tblSwitch_NC_displayCount (orderID, ordersProductsID, totalCount)
	SELECT DISTINCT orderID, ordersProductsID, totalCount
	FROM tblSwitch_NC
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
		FROM tblSwitch_NC_displayCount
		WHERE RowID = @RowCount
	
		UPDATE tblSwitch_NC
		SET @topMultiCount = (SELECT TOP 1 multiCount
							 FROM tblSwitch_NC
							 WHERE orderID = @orderID
							 ORDER BY multiCount ASC)
	
		UPDATE tblSwitch_NC
		SET multiCount = @topMultiCount - 1
		WHERE orderID = @orderID
		AND ordersProductsID = @ordersProductsID
		AND @topMultiCount - 1 <> 0	
	
		SET @RowCount = @RowCount + 1
	END

	UPDATE tblSwitch_NC
	SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

	--// update packetValue with sortable multi-digit numbers
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
	UPDATE tblSwitch_NC SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ displayCount calculation
	--// Set flags
	UPDATE tblSwitch_NC SET switch_approve = 0
	UPDATE tblSwitch_NC SET switch_print = 0
	UPDATE tblSwitch_NC SET switch_approveDate = GETDATE()
	UPDATE tblSwitch_NC SET switch_printDate = GETDATE()
	UPDATE tblSwitch_NC SET switch_createDate = GETDATE()

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
	FROM tblSwitch_NC s
INNER JOIN #tmpShip t on s.orderID = t.orderID

	--// update customBackground value; new, 12/29/16 jf.
	UPDATE tblSwitch_NC
	SET customBackground = b.optionCaption
	FROM tblSwitch_NC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionGroupCaption = 'Background'

					----// update fullCard specification (replaced with two queries shown below)
					--UPDATE tblSwitch_NC
					--SET fullCard = 1,
					--	  productQuantity = a.productQuantity * 50
					--FROM tblSwitch_NC a
					--INNER JOIN tblSwitch_NOP_NC_MarketCenterCodes b
					--	ON SUBSTRING(a.productCode, 3, 2) = b.code
					--INNER JOIN tblOrders_Products op
					--	ON a.productCode = op.productCode
					--WHERE SUBSTRING(a.productCode, 1, 12) NOT IN
					--	(SELECT productCode
					--	FROM tblSwitch_NOP_NC_MarketCenterExceptions)
					--AND op.productPrice < 1

	----// update fullCard specification
	--UPDATE a
	--SET productQuantity = a.productQuantity * 50,
	--	   fullCard = 1
	--FROM tblSwitch_NC a
	--INNER JOIN tblSwitch_NOP_NC_MarketCenterCodes b
	--	ON SUBSTRING(a.productCode, 3, 2) = b.code
	--INNER JOIN tblOrders_Products op
	--	ON a.productCode = op.productCode
	--WHERE SUBSTRING(a.productCode, 1, 12) NOT IN
	--	(SELECT productCode
	--	FROM tblSwitch_NOP_NC_MarketCenterExceptions)
	--AND op.productPrice > 1

	----// all marketCenter products (fullcard=1) have white envelopes (ignore market center NCs from HOM)
	--UPDATE a
	--SET env_color = 'White',
	--	   option_envelope = 'NCEVW6-001.Front.pdf',
	--	   fullCard = 1
 --   FROM tblSwitch_NC a
	--INNER JOIN tblSwitch_NOP_NC_MarketCenterCodes b
	--	ON SUBSTRING(a.productCode, 3, 2) = b.code
	--INNER JOIN tblOrders_Products op
	--	ON a.productCode = op.productCode
	--WHERE SUBSTRING(a.productCode, 1, 12) NOT IN
	--	(SELECT productCode
	--	FROM tblSwitch_NOP_NC_MarketCenterExceptions)

	TRUNCATE TABLE tblSwitch_NC_ForOutput
	INSERT INTO tblSwitch_NC_ForOutput (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, ordersProductsID, shipsWith, resubmit, shipType, displayCount, switch_create, switch_createDate, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, env_productCode, env_productName, env_productQuantity, env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, samplerRequest, displayedQuantity, option_customEnvelope, customBackground, fullCard)
	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, ordersProductsID, shipsWith, resubmit, shipType, displayCount, switch_create, switch_createDate, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, env_productCode, env_productName, env_productQuantity, env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, samplerRequest, displayedQuantity, option_customEnvelope, customBackground, fullCard
	FROM tblSwitch_NC 
	ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

	--INSERT INTO tblSwitch_NCLog (PKID, ordersProductsID, insertedOn)
	--SELECT DISTINCT PKID, ordersProductsID, GETDATE()
	--FROM tblSwitch_NC_ForOutput

	--Step to log current batch of OPID/Punits
	declare @CurrentDate datetime = getdate() --Get current date for batch
	insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
	select 
	flowName = 'NC'
	,a.PKID
	,a.ordersProductsID
	,batchTimestamp = @CurrentDate
	,jsonData = 
		   (select *
		   from tblSwitch_NC_ForOutput b
		   where a.PKID = b.PKID
		   for json path)
	from tblSwitch_NC_ForOutput a

	-- Update OPID status fields indicating successful submission to switch
	UPDATE tblOrders_Products
	SET switch_create = 1,
		fastTrak_status = 'In Production',
		fastTrak_status_lastModified = GETDATE(),
		fastTrak_resubmit = 0
	FROM tblOrders_Products op
	INNER JOIN tblSwitch_NC_ForOutput t ON op.ID = t.ordersProductsID

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, ordersProductsID, shipsWith, resubmit, shipType, displayCount, switch_create, switch_createDate, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, env_productCode, env_productName, env_productQuantity, env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, samplerRequest, displayedQuantity, option_customEnvelope, fullCard
	FROM tblSwitch_NC_ForOutput 
	ORDER BY PKID, orderID, displayCount, ordersProductsID --, packetValue 
	ASC

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH