








CREATE PROCEDURE [dbo].[usp_Switch_BC_LUX] 
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/3/17
Purpose     Business Card Threshold Work for Switch Automation - Duplex
-------------------------------------------------------------------------------
Modification History

10/04/17	    Created, jf.
10/05/17	    Math galore, jf.
11/07/17	    Removed JU references, jf.
11/07/17	    Fixed BC custom shipswith logic, jf.
12/15/17		added switch_create check to the "brute force" section of main prep area, jf.
12/15/17		added the "AND textValue <> '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF'" clause since the path changed, jf
12/18/17		Made same adjustment as above, near LN422, jf.
01/11/18		2016 changes,BS
01/16/18		updated paths for variableWholeName and backName to: \\Arc\Merge Central\Switch-Data\BC-Printfiles\, JF.
01/16/18		removed backName work; updated variableWholeName to new paths as per AC, JF.
01/18/18		added backName back in as per AC request, JF.
02/16/18		BS, removed pickup from local pickup on First name to fix shipping Pickup At GBS ShippingDesc orders
03/26/18		added "BLANK-VERT" clauses anywhere that "BLANK-HORZ" existed, jf.
03/26/18		modified initial query to allow canvas BC's into the mix, jf
03/26/18		modified backName section near LN388  to allow canvas BC's into the mix, jf
03/27/18		updated initial query with 3-part sub that determines various things (last part), jf.
03/28/18		updated shipsWith='Stock' to ">=3" near LN522, as per KH, jf.
04/03/18		Killed SN logic with fire, jf.
04/06/18		added #84 section that deals with BP qualification in initial query, jf.
04/06/18		added expressProduction code throughout latter half of procedure, jf.
04/12/18		changed all dates to 02/01/2018, jf
04/12/18		significant changes to all logic in first 2 inserts, annotated. jf.
04/18/18		update front and back logic with new file-only data, no paths, jf.
04/25/18		COMPLETE REWRITE, jf.
05/08/18		updated to account for optionID 564 which deals with "blank backs" in Canvas-gen'd biz cards, jf
05/10/18		added @AB section which puts front_UV/back_UV groupings into multiples of six, jf
06/13/18		Added SwitchSortOrder for sorting in switch
06/28/18		Pulled envelopes from being associated stock items; 2 updates located near LN879 and LN911, jf
06/28/18		TRON overhaul, jf.
07/02/18		Moved "submitted_to_switch" to Switch, jf.
07/02/18		Log data, jf.
07/02/18		Added sortOrder field section near LN1315, jf.
07/06/18		Added time threshhold code to the insert section, jf.
07/10/18		Added codes that strips extensions off image files and replaces them with ".pdf", near LN375, jf.
07/10/18		Update initial query with new OPID qualification section, jf.
07/10/18		Updated shipsWith='Stock' to ">3" near LN522, as per KH, jf.
07/10/18		Added packetValue column to the insert list for tblSwitch_pUnit_TRON, near LN 1126, jf
07/10/18		Updated @YY section to account for splits, jf
07/12/18		I give thee Tron.
07/13/18		Updated CYO section, jf.
07/16/18		added update to fastTrak_resubmit = 0 rest for OPID at the end of sproc, jf
07/17/18		moved "AND op.switch_create = 0 " in initial query, to the parenthetical section, jf
07/17/18		removed "'Delivered', 'In Transit', 'In Transit - USPS')" from initial query, jf
07/17/18		added CYO section to Duplex designation subq in initial query, jf
07/17/18		added section that adds ".pdf" to image data that has no extension, jf
07/18/18		pulled out 'waiting for payment' in initial query, jf
07/24/18		updated shipsWith section to look at processType rather than productType, jf.
07/25/18		removed stock counts beyond 3. added update section near LN 955 that wipes all stock fields when shipsWith = 'stock', jf.
07/30/18		added shipsWith = 'resubmit' section, jf.
08/01/18		added express production section near LN588, jf
08/10/18		Added IMAGE CHECK section, jf
08/17/18		Added runtime flag, jf.
08/20/18		Added this check to initial queries: "AND op.processType = 'fasTrak'", jf.
09/06/18		Added shipState Insert into pUnit table, it was missing, jf.
09/07/18		fPlex.
09/07/18		Moved final flag updates up one statement, jf.
09/07/18		added back image treatment near LN1966, jf.
09/10/18		Updated TOT, jf.
10/01/18		Pulled opids that have "lux" options; optionID IN (573, 574, 575), ('Double Thick 32 pt', 'Luxe ColorFill 42 pt', 'Sandwich Color' respectively) jf.
10/12/18		Added productQuantity division for orders where tblOrders.NOP=1, so that a NOP quantity of 500, for example, shows as "5" instead, jf.
10/19/18		Added: EXEC usp_OPPO_validateFile 'BP'
11/28/18		Added optionID 571 ('Rounded Corners') to the pull-list from 10/01/18 note, jf.
02/05/19		got rid of "=" in productQTY adj for BPFA, jf.
03/13/19		Removed "submitted_to_switch" update to tblOrders_Products; it was causing OPIDs to get stuck and not move through production, jf.
04/16/19		Added split expressProduction segment near LN1445 (If a split exists from a previous run, set expressProduction = 1 for that split so that it is brute-forced into production in the builds below), jf
05/23/19		Added addt'l logic in secondary initial query that checks for OPID fileexists values for duplex opids that have multiple files, jf.
11/14/19		JF, added readyForSwitch check. Removed a bunch of stuff at the front of the stored proc that revolved around fileExists. There is a back up of this sproc before these changes here: [usp_Switch_BC_Duplex_TRON_JFBAK111419_01] in case things go fubar.
11/20/19		JF, modified step 4.a in initial query. for more info on what this is about, see stored proc: [popArtGate].
01/27/19		JF, Added Credit Due here: AND a.displayPaymentStatus IN ('Good', 'Credit Due')
08/04/20		JF, Added stripper to init query.
09/09/20		JF, Added fileExists fix to init query.
10/13/20		JF, Added resubmission section that modifies ShipsWith value if OPID is resubbed.
11/23/20		JF, LEN(orderNo) IN (9,10)
12/02/20		CKB, iFrame conversion changes
02/08/21		JF, killed the flagging system with hellfire and brimstone.
02/10/21		CKB, changed 32%pt%Double% to %32%pt%
02/17/21		CKB, added oppo check to main query
03/4/21			BS, added reorder to the oppo main query check.
03/19/21		BS, changed 5 - Check for all records of an opid where ReadyForSwitch = 0
03/31/21		CKB, added product quantity condition in prep for BC100
04/21/21		JF, added the following block to each "Custom Count" section that counts Rounded Corner Business Cards since they are on a different flow:
									AND (SUBSTRING(b.productCode, 1, 2) <> 'BP'
												OR 
													SUBSTRING(b.productCode, 1, 2) = 'BP'
													AND EXISTS
														(SELECT TOP 1 1
														FROM tblOrdersProducts_productOptions oppx
														WHERE oppx.deleteX <> 'yes'
														AND (oppx.optionID = 571 -- Rounded
																 OR (oppx.optionCaption='Corners' AND oppx.textValue like 'Round%'))	--added for iFrame conversion
														AND oppx.ordersProductsID = b.ID))
11/10/21		CKB, added processStatus
12/17/21		CKB, fix stock count to match QC logic - clickup #1wv1ntt 
02/11/22		CKB, modified sports gate logic to be data driven group gates - clickup #1x7bmfc
06/28/22        JSB, Furnished Art BC-LUX now need the GTG.
-----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// IMAGE CHECK //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

BEGIN TRY
DECLARE @flowName AS VARCHAR(20) = 'BC-LUX'
----Flags
--DECLARE @Flag BIT

--SET @Flag = (SELECT FlagStatus 
--			FROM Flags
--			WHERE FlagName = 'Switch_BC_Duplex_TRON')
					   
--IF @Flag = 0
--BEGIN

--UPDATE Flags
--SET FlagStatus = 1
--WHERE FlagName = 'Switch_BC_Duplex_TRON'

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'BCL Switch SP', @lastRunDate;


DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// INITIALIZE OPID //////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--First, validate image files
EXEC usp_OPPO_validateFile 'BP'

DROP TABLE IF EXISTS #tblSwitch_OPID
-- Initialize data set
CREATE TABLE [dbo].[#tblSwitch_OPID](
	[ID] [int] IDENTITY(1000,1) NOT NULL,
	[OPID] [int] NOT NULL,
	[ReadyForSwitch] [datetime] NOT NULL,
	[ThresholdOfTime] [datetime] NULL
) ON [PRIMARY]

INSERT INTO #tblSwitch_OPID (OPID, ReadyForSwitch)
SELECT DISTINCT op.ID, GETDATE()
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
INNER JOIN tblOrdersProducts_productOptions oppo ON op.ID = oppo.ordersProductsID
LEFT JOIN tblSkuGroup sg ON p.productCode LIKE sg.skuPattern
LEFT JOIN tblSkuGroupGate g ON sg.skuGroup = g.skuGroup
INNER JOIN OPIDSwitchFlow osf on op.id = osf.opid
WHERE 

--1. Duplex Designation ----------------------------------
op.ID IN
	--This subquery shows DUPLEX OPIDs
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
				--Regular Duplex BCs
				optionCaption IN ('Product Back', 'Back Intranet PDF','CanvasHiResBack')  -- added CanvasHiResBack for iFrame conversion
			OR
				-- CYO Duplex BCs
				optionCaption IN ('File Name 1', 'File Name 2')
				AND textValue NOT LIKE '%/%'
				AND textValue LIKE '%-BACK-%'
			)
	AND textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', 
		 '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', 
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 
		 'BLANK')
	AND ordersProductsID NOT IN
		--Blank Backs
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 564)	--not used since 2/2019  no iFrame conversion needed
	)

--2. Order Qualification ----------------------------------
AND DATEDIFF(MI, a.created_on, GETDATE()) > 60
AND a.orderDate > CONVERT(DATETIME, '07/01/2019')
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus IN ('Good', 'Credit Due')


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

--3. Product Qualification ----------------------------------
AND osf.SwitchFlow = 'BC-LUX'

--4. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType IN ('fasTrak','Custom')
AND (
		--4.a
		(op.fastTrak_status = 'In House' and op.productCode NOT LIKE '__FA%')
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
				AND RIGHT(textValue, 2) = '_J' --default layout - same before/after  no iFrame conversion needed
				AND opp2.ordersProductsID = op.ID)
		--4.b
		OR op.fastTrak_status = 'Good to Go'
		--4.c
		OR op.fastTrak_resubmit = 1
		)

--5. Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS				
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.id)

--6. Oppo Check ---- Must have BC oppos --------------------------------
AND EXISTS				
	(SELECT TOP 1 1
		FROM tblOrdersProducts_ProductOptions oppo
		WHERE op.ID = oppo.ordersProductsID and (optionID in (674,650,640) OR optionCaption = 'Reorder')
	)
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// BEGIN INSERT //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DROP TABLE IF EXISTS #tblSwitch_BC_LUX
CREATE TABLE [dbo].[#tblSwitch_BC_LUX]([PKID][INT] IDENTITY(1,1) NOT NULL,
	[orderID] [int] NULL, [orderNo] [nvarchar](255) NULL, [orderDate] [datetime] NULL, [customerID] [int] NULL, [shippingAddressID] [int] NULL, [shipCompany] [nvarchar](255) NULL, [shipFirstName] [nvarchar](255) NULL,
	[shipLastName] [nvarchar](255) NULL, [shipAddress1] [nvarchar](255) NULL, [shipAddress2] [nvarchar](255) NULL, [shipCity] [nvarchar](255) NULL, [shipState] [nvarchar](255) NULL, [shipZip] [nvarchar](255) NULL,
	[shipCountry] [nvarchar](255) NULL, [shipPhone] [nvarchar](255) NULL, [productCode] [nvarchar](50) NULL, [productName] [nvarchar](255) NULL, [shortName] [nvarchar](255) NULL, [productQuantity] [int] NULL,
	[packetValue] [nvarchar](50) NULL, [variableTopName] [nvarchar](255) NULL, [variableBottomName] [nvarchar](255) NULL, [variableWholeName] [nvarchar](255) NULL, [backName] [nvarchar](255) NULL, [numUnits] [int] NULL,
	[displayedQuantity] [int] NULL, [ordersProductsID] [int] NULL, [shipsWith] [nvarchar](255) NULL, [resubmit] [bit] NULL, [shipType] [nvarchar](50) NULL, [samplerRequest] [nvarchar](50) NULL, [multiCount] [int] NULL,
	[totalCount] [int] NULL, [displayCount] [nvarchar](50) NULL, [background] [nvarchar](255) NULL, [templateFile] [nvarchar](255) NULL, [team1FileName] [nvarchar](255) NULL, [team2FileName] [nvarchar](255) NULL,
	[team3FileName] [nvarchar](255) NULL, [team4FileName] [nvarchar](255) NULL, [team5FileName] [nvarchar](255) NULL, [team6FileName] [nvarchar](255) NULL, [groupID] [int] NULL, [productID] [int] NULL,
	[parentProductID] [int] NULL, [switch_create] [bit] NULL, [switch_createDate] [datetime] NULL, [switch_approve] [bit] NULL, [switch_approveDate] [datetime] NULL, [switch_print] [bit] NULL, [switch_printDate] [datetime] NULL,
	[switch_import] [bit] NULL, [mo_orders_Products] [datetime] NULL, [mo_orders] [datetime] NULL, [mo_customers] [datetime] NULL, [mo_customers_ShippingAddress] [datetime] NULL, [mo_oppo] [datetime] NULL,
	[customProductCount] [int] NULL, [customProductCode1] [nvarchar](50) NULL, [customProductCode2] [nvarchar](50) NULL, [customProductCode3] [nvarchar](50) NULL, [customProductCode4] [nvarchar](50) NULL,
	[fasTrakProductCount] [int] NULL, [fasTrakProductCode1] [nvarchar](50) NULL, [fasTrakProductCode2] [nvarchar](50) NULL, [fasTrakProductCode3] [nvarchar](50) NULL, [fasTrakProductCode4] [nvarchar](50) NULL,
	[stockProductCount] [int] NULL, [stockProductQuantity1] [int] NULL, [stockProductCode1] [nvarchar](50) NULL, [stockProductDescription1] [nvarchar](255) NULL, [stockProductQuantity2] [int] NULL, [stockProductCode2] [nvarchar](50) NULL,
	[stockProductDescription2] [nvarchar](255) NULL, [stockProductQuantity3] [int] NULL, [stockProductCode3] [nvarchar](50) NULL, [stockProductDescription3] [nvarchar](255) NULL, [stockProductQuantity4] [int] NULL,
	[stockProductCode4] [nvarchar](50) NULL, [stockProductDescription4] [nvarchar](255) NULL, [stockProductQuantity5] [int] NULL, [stockProductCode5] [nvarchar](50) NULL, [stockProductDescription5] [nvarchar](255) NULL,
	[stockProductQuantity6] [int] NULL, [stockProductCode6] [nvarchar](50) NULL, [stockProductDescription6] [nvarchar](255) NULL, [front_UV] [bit] NULL, [back_UV] [bit] NULL, [env_productCode] [nvarchar](50) NULL,
	[env_productName] [nvarchar](255) NULL, [env_productQuantity] [int] NULL, [env_color] [nvarchar](255) NULL, [option_cause] [nvarchar](255) NULL, [option_customInside] [nvarchar](255) NULL, [option_envelope] [nvarchar](255) NULL,
	[option_cov] [nvarchar](255) NULL, [option_bak] [nvarchar](255) NULL, [option_customEnvelope] [nvarchar](255) NULL, [customBackground] [nvarchar](255) NULL, [expressProduction] [bit] NOT NULL, [finishType] [nvarchar](50) DEFAULT (0) NULL,
	[duplex] [bit]  DEFAULT (0) NOT NULL, [fPlex] [bit]  DEFAULT (0) NOT NULL, [isFlipped] [int]  DEFAULT (0) NOT NULL, [simplex] [bit]  DEFAULT (0) NOT NULL, [uv_class] [nchar](2) NULL, [uv_sort] [int] NULL,
	[frontCoating] [nvarchar](255)  NULL, [backCoating] [nvarchar](255)  NULL, [cardType] [nvarchar](255)  NULL, [sandwichColor] [nvarchar](255)  NULL, [Corner] [nvarchar](255)  NULL
) 

INSERT INTO #tblSwitch_BC_LUX (orderID, orderNo, orderDate, customerID, 
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
expressProduction)

SELECT DISTINCT
a.orderID, a.orderNo, a.orderDate, a.customerID, 
--s.shippingAddressID, s.shipping_Company, s.shipping_Firstname, s.shipping_surName, 
--s.shipping_Street, s.shipping_Street2, s.shipping_Suburb, s.shipping_State, s.shipping_PostCode, s.shipping_Country, s.shipping_Phone, 
[dbo].[fn_BadCharacterStripper_noLower](s.shippingAddressID) AS shippingAddressID, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Company) AS shipping_Company, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Firstname) AS shipping_Firstname, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_surName) AS shipping_surName, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Street) AS shipping_Street, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Street2) AS shipping_Street2, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Suburb) AS shipping_Suburb, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_State) AS shipping_State, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_PostCode) AS shipping_PostCode, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Country) AS shipping_Country, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Phone) AS shipping_Phone, 
op.productCode, op.productName, 
'' AS 'shortName',
op.productQuantity, 
'01 of 01' AS 'packetValue',
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
0 AS 'stockProductQuantity6', '' AS 'stockProductCode6', '' AS 'stockProductDescription6',
0
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
INNER JOIN #tblSwitch_OPID q ON op.ID = q.OPID
WHERE op.[ID] NOT IN 
	(SELECT ordersProductsID 
	FROM #tblSwitch_BC_LUX
	WHERE ordersProductsID IS NOT NULL)
	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////// QUANTITY WORK /////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// First, fix productQuantity if fasTrak_newQTY value exists
UPDATE #tblSwitch_BC_LUX
SET productQuantity = b.fastTrak_newQTY
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrders_Products b
	ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY

--// Next, fix productQuantity if order is from NOP HOM, which typically has values like 500 instead of 5; 1000 instead of 10, etc. We want to change 500 to 5, 1000 to 10.
UPDATE a
SET productQuantity = productQuantity/100
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
WHERE o.NOP = 1
AND a.productQuantity > 100

DROP TABLE IF EXISTS #tblSwitch_BC_LUX_Splits
select 
orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, 
shortName, 5 as productQuantity, 
REPLICATE('0',2-LEN(CONVERT(VARCHAR(255), i.i+2))) + CONVERT(VARCHAR(255), i.i+2) + ' of ' + REPLICATE('0',2-LEN(CONVERT(VARCHAR(255), (bl.productQuantity/5)))) + CONVERT(VARCHAR(255), (bl.productQuantity/5)) AS 'packetValue', 
variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, 
displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, 
switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, 
customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, 
fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, 
stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, 
stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction
into #tblSwitch_BC_LUX_Splits
from #tblSwitch_BC_LUX bl
inner join integers i on i.i < ((bl.productQuantity-1)/5)
where bl.productquantity > 5

UPDATE bl set packetValue = '01 of ' + REPLICATE('0',2-LEN(cast(((bl.productQuantity-1)/5) as varchar(2)))) + cast(((bl.productQuantity)/5) as varchar(2)),productQuantity = 5
FROM #tblSwitch_BC_LUX bl
INNER JOIN #tblSwitch_BC_LUX_Splits bls on bl.ordersProductsID = bls.ordersProductsID
WHERE  bl.productquantity > 5

INSERT INTO #tblSwitch_BC_LUX (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction
FROM #tblSwitch_BC_LUX_Splits
ORDER BY ordersProductsID, packetValue


--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// UV SECTION //////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Front Coating
UPDATE #tblSwitch_BC_LUX
SET front_UV = 1
WHERE (front_UV = 0 or front_UV IS NULL)
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
			(optionGroupCaption = 'Front Coating' AND optionCaption = 'UV')	-- pre-iFrame
		 OR (optionCaption = 'Finish Options' and textvalue in ('Glossy Front/Matte Back','Glossy')) --added for iFrame conversion
		)
	 )

UPDATE #tblSwitch_BC_LUX
SET front_UV = 0
WHERE front_UV = 1
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
			(optionGroupCaption = 'Front Coating' AND optionCaption = 'Matte (No UV)') --pre-iFrame
		 or (optionCaption = 'Finish Options' and textValue in ('Matte','Matte Front/Glossy Back')) --added for iFrame conversion
		)
	)

--Back Coating
UPDATE #tblSwitch_BC_LUX
SET back_UV = 1
WHERE (back_UV = 0 OR back_UV IS NULL)
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
			(optionGroupCaption = 'Back Coating' AND optionCaption = 'UV') --pre-iFrame
		 OR (optionCaption = 'Finish Options' AND textValue in ('Matte Front/Glossy Back','Glossy')) --added for iFrame conversion
		)
	)
	
UPDATE #tblSwitch_BC_LUX
SET back_UV = 0
WHERE back_UV = 1
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
			(optionGroupCaption = 'Back Coating' AND optionCaption = 'Matte (No UV)')  --pre-iFrame
		 OR (optionCaption = 'Finish Options' AND textValue in ('Glossy Front/Matte Back','Matte'))  --added for iFrame conversion
		)
	)
  
-- deNULL
UPDATE #tblSwitch_BC_LUX
SET front_UV = 0
WHERE front_UV IS NULL

UPDATE #tblSwitch_BC_LUX
SET back_UV = 0
WHERE back_UV IS NULL

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// FINISH TYPE /////////////////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

UPDATE #tblSwitch_BC_LUX
SET finishType = 'UV'
WHERE front_UV = 1
OR back_UV = 1

UPDATE a
SET finishType = 'MT'
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions oppo
	ON a.ordersProductsID = oppo.ordersProductsID
WHERE a.front_UV = 0
AND a.back_UV = 0
AND oppo.optionID NOT IN (568, 569) --pre-iFrame
AND NOT EXISTS (SELECT TOP 1 1										--added for iFrame conversion
				FROM tblOrdersProducts_ProductOptions oppo2 
				WHERE oppo.PKID = oppo2.PKID 
				  AND oppo2.optionCaption = 'Finish Options' 
				  AND oppo2.textValue LIKE 'Soft%Touch%') 
AND oppo.deleteX <> 'yes'

UPDATE a
SET finishType = 'ST'
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions oppo
	ON a.ordersProductsID = oppo.ordersProductsID
WHERE a.front_UV = 0
AND a.back_UV = 0
AND (oppo.optionID IN (568, 569)	--pre-iFrame
     OR EXISTS (SELECT TOP 1 1										--added for iFrame conversion
				FROM tblOrdersProducts_ProductOptions oppo2 
				WHERE oppo.PKID = oppo2.PKID 
				  AND oppo2.optionCaption = 'Finish Options' 
				  AND oppo2.textValue LIKE 'Soft%Touch%') 
	) 
AND oppo.deleteX <> 'yes'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// FRONTS AND BACKS //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--(1/4) variableWholeName - CLASSIC
UPDATE #tblSwitch_BC_LUX
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND b.textValue LIKE '%/%'

--(2/4) variableWholeName - CANVAS
UPDATE #tblSwitch_BC_LUX
SET variableWholeName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Intranet PDF'

--(3/4) variableWholeName - CYO
UPDATE #tblSwitch_BC_LUX
SET variableWholeName = @UncBasePath + SUBSTRING(b.textValue, 1, LEN(b.textValue) - CHARINDEX('.', REVERSE(b.textValue))) + '.pdf'
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('File Name 1', 'File Name 2')
AND b.textValue NOT LIKE '%/%'
AND b.textValue LIKE '%-FRONT-%'

--(4/4) variableWholeName - added for iFrame conversion
UPDATE #tblSwitch_BC_LUX
SET variableWholeName = @UncBasePath + b.textValue
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption ='CanvasHiResFront File Name'
							   

--// (1/4) backName - CLASSIC
UPDATE #tblSwitch_BC_LUX
SET backName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Product Back'
AND b.textValue LIKE '%/%'
AND b.textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 'BLANK')

--// (2/4) backName - CANVAS
UPDATE #tblSwitch_BC_LUX
SET backName = @UncBasePath + REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM #tblSwitch_BC_LUX a 
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.deleteX <> 'yes'
AND b.optionCaption = 'Back Intranet PDF'
AND b.textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 'BLANK')
AND b.ordersProductsID NOT IN
		(SELECT ordersProductsID --this subquery accounts for optionID 564 that is the Canvas BCD "blank back" set up on 4/8/18 by RB, because Canvas generates a "false" textValue that is simple a blank image, but is randomly named.
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 564)

--// (3/4) backName - CYO
UPDATE #tblSwitch_BC_LUX
SET backName = @UncBasePath + SUBSTRING(b.textValue, 1, LEN(b.textValue) - CHARINDEX('.', REVERSE(b.textValue))) + '.pdf'
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('File Name 1', 'File Name 2')
AND b.textValue NOT LIKE '%/%'
AND b.textValue LIKE '%-BACK-%'
AND b.textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 'BLANK')

--// (4/4) backName - added for iFrame conversion
UPDATE #tblSwitch_BC_LUX
SET backName = @UncBasePath + b.textValue
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption ='CanvasHiResBack File Name'

--// update customBackground value; new, 12/29/16 jf.
UPDATE #tblSwitch_BC_LUX
SET customBackground = b.optionCaption
FROM #tblSwitch_BC_LUX a
INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'

--// Strip extension and replace with '.pdf'
UPDATE #tblSwitch_BC_LUX
SET variableWholeName = SUBSTRING(variableWholeName, 1, LEN(variableWholeName) - CHARINDEX('.', REVERSE(variableWholeName))) + '.pdf'
WHERE variableWholeName IS NOT NULL

UPDATE #tblSwitch_BC_LUX
SET backName = SUBSTRING(backName, 1, LEN(backName) - CHARINDEX('.', REVERSE(backName))) + '.pdf'
WHERE backName IS NOT NULL

UPDATE #tblSwitch_BC_LUX
SET customBackground = SUBSTRING(customBackground, 1, LEN(customBackground) - CHARINDEX('.', REVERSE(customBackground))) + '.pdf'
WHERE customBackground IS NOT NULL

--And if the extension is missing entirely.
UPDATE #tblSwitch_BC_LUX
SET variableWholeName = variableWholeName + '.pdf'
WHERE variableWholeName NOT LIKE '%.pdf'
AND variableWholeName <> ''
AND variableWholeName IS NOT NULL

UPDATE #tblSwitch_BC_LUX
SET backName = backName + '.pdf'
WHERE backName NOT LIKE '%.pdf'
AND backName <> ''
AND backName IS NOT NULL

UPDATE #tblSwitch_BC_LUX
SET customBackground = customBackground + '.pdf'
WHERE customBackground NOT LIKE '%.pdf'
AND customBackground <> ''
AND customBackground IS NOT NULL

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
SET @json = (SELECT orderid,@flowName as switchflow from #tblSwitch_BC_LUX FOR JSON PATH);
EXECUTE @RC = [dbo].[GetShipsWith] 
   @json
  ,@retJson OUTPUT

DROP TABLE IF EXISTS #tmpShip
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
FROM #tblSwitch_BC_LUX s
LEFT JOIN #tmpShip t on s.orderID = t.orderID;

UPDATE s
SET shipsWith = 'Local Pickup'
FROM #tblSwitch_BC_LUX s
INNER JOIN tblOrders o ON s.orderid = o.orderid
	WHERE (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIP TYPE //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// default
UPDATE #tblSwitch_BC_LUX
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE #tblSwitch_BC_LUX
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE #tblSwitch_BC_LUX
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE #tblSwitch_BC_LUX
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE #tblSwitch_BC_LUX
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

-- Update shipType to express production phrase when opid has been expedited.
UPDATE t
SET shipType =  LEFT(shipType + ' | Arrive by ' + CONVERT(NVARCHAR(50), DATEPART(MM, a.arrivalDate)) + '/' + CONVERT(NVARCHAR(50), DATEPART(DD, a.arrivalDate)), 50)
FROM  #tblSwitch_BC_LUX t
INNER JOIN tblOrders a
	ON t.orderNo = a.orderNo
INNER JOIN tblOrdersProducts_productOptions oppo
	ON t.ordersProductsID = oppo.ordersProductsID
WHERE a.arrivalDate IS NOT NULL
AND oppo.deleteX <> 'yes'
AND (optionCaption = 'Express Production' AND (textValue LIKE 'Yes%' OR textValue LIKE 'Express%' OR ISNULL(textValue,'') = ''))	-- added textValue qualifier for iFrame conversion
																				   

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////// DISPLAY COUNT DATA //////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// Run counts to populate totalCount column, which grabs the number of distinct ordersProductIDs per orderID.
DROP TABLE IF EXISTS [#tblSwitch_BCLux_distinctIDCount]
CREATE TABLE [dbo].[#tblSwitch_BCLux_distinctIDCount](
	[orderID] [int] NULL,
	[ordersProductsID] [int] NULL
)

INSERT INTO #tblSwitch_BCLux_distinctIDCount (orderID, ordersProductsID)
SELECT DISTINCT orderID, ordersProductsID
FROM #tblSwitch_BC_LUX

DROP TABLE IF EXISTS [#tblSwitch_BC_LUX_distinctIDCount2]
CREATE TABLE [dbo].[#tblSwitch_BC_LUX_distinctIDCount2](
	[orderID] [int] NULL,
	[countOrderID] [int] NULL
) 

INSERT INTO #tblSwitch_BC_LUX_distinctIDCount2 (orderID, countOrderID)
SELECT orderID, COUNT(orderID) AS 'countOrderID'
FROM #tblSwitch_BCLux_distinctIDCount
GROUP BY orderID
ORDER BY OrderId

UPDATE #tblSwitch_BC_LUX
SET totalCount = b.countOrderID
FROM #tblSwitch_BC_LUX a 
INNER JOIN #tblSwitch_BC_LUX_distinctIDCount2 b
ON a.orderID = b.orderID

UPDATE #tblSwitch_BC_LUX
SET displayCount = NULL,
multiCount = totalCount

DROP TABLE IF EXISTS #tblSwitch_BC_Lux_displayCount
--// PCU
--// Counts (multiCount and totalCount)
CREATE TABLE #tblSwitch_BC_Lux_displayCount
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
INSERT INTO #tblSwitch_BC_Lux_displayCount (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM #tblSwitch_BC_LUX
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
	FROM #tblSwitch_BC_Lux_displayCount
	WHERE RowID = @RowCount
	
	UPDATE #tblSwitch_BC_LUX
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM #tblSwitch_BC_LUX
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE #tblSwitch_BC_LUX
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE #tblSwitch_BC_LUX
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE #tblSwitch_BC_LUX SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

UPDATE #tblSwitch_BC_LUX SET switch_approve = 0
UPDATE #tblSwitch_BC_LUX SET switch_print = 0
UPDATE #tblSwitch_BC_LUX SET switch_approveDate = GETDATE()
UPDATE #tblSwitch_BC_LUX SET switch_printDate = GETDATE()
UPDATE #tblSwitch_BC_LUX SET switch_createDate = GETDATE()

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
	FROM #tblSwitch_BC_LUX s
INNER JOIN #tmpShip t on s.orderID = t.orderID

INSERT INTO BC_LOG (lognote) SELECT '5'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// OPID SORT QUALIFIERS //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
UPDATE x
SET resubmit = 1
FROM #tblSwitch_BC_LUX x
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND op.fastTrak_resubmit = 1
	AND op.ID = x.ordersProductsID)

-- For any OPID that has been resubbed, update ShipsWith accordingly
DROP TABLE IF EXISTS #tempResubChoice_BCD_TRON

CREATE TABLE #tempResubChoice_BCD_TRON (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @NumberRecords_rs INT, 
				 @RowCount_rs INT,
				 @OPID_rs INT,
				 @MostRecent_ResubChoice_rs INT

INSERT INTO #tempResubChoice_BCD_TRON (OPID)
SELECT DISTINCT ordersProductsID
FROM #tblSwitch_BC_LUX
WHERE resubmit = 1

SET @NumberRecords_rs = @@RowCount
SET @RowCount_rs = 1

WHILE @RowCount_rs <= @NumberRecords_rs
BEGIN
	 SELECT @OPID_rs = OPID
	 FROM #tempResubChoice_BCD_TRON
	 WHERE RowID = @RowCount_rs

	 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
															FROM tblSwitch_resubOption
															WHERE OPID = @OPID_rs
															ORDER BY resubmitDate DESC)
	
	UPDATE #tblSwitch_BC_LUX
	SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
	WHERE ordersProductsID = @OPID_rs	 

	SET @RowCount_rs = @RowCount_rs + 1
END

UPDATE #tblSwitch_BC_LUX
SET resubmit = 0
WHERE resubmit IS NULL
-- RESUBMISSION SECTION -------------------------------------------------------------------------------END


-- update expressProduction to reflect the current value in tblOrders_Products for the OPID; new, 04/06/18 jf.
UPDATE #tblSwitch_BC_LUX
SET expressProduction = 1
WHERE ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (optionCaption = 'Express Production' AND (textValue LIKE 'Yes%' OR textValue LIKE 'Express%' OR ISNULL(textValue,'') = ''))	-- added textValue qualifier for iFrame conversion
	)																						   

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// BEHOLD! THE THRESHOLD OF TIME //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Heh. 
-- If an OPID isn't getting pulled in because it is rare and the QTY threshold is not being met each successive imposition, then
-- we want to brute force it into the imposition, even if it messes up the "count of six" effort. This next section looks to see if an OPID
-- has been stagnate for a given period of time, and if so, flags it so that it is forced into the imposition later below.
-- the flag really is just setting ThresholdOfTime = GETDATE(), which doesn't mean anything, just a flag.
--// TOT

DROP TABLE IF EXISTS #tblSwitch_TOT
CREATE TABLE #tblSwitch_TOT
	(RowID INT IDENTITY(1, 1), 
	OPID INT, 
	orderDate DATETIME,
	dateCount INT)

DECLARE @NumRec INT, @RWCT INT
DECLARE @OPID INT
DECLARE @orderDate DATETIME
DECLARE @dateCount INT

--// Create table
INSERT INTO #tblSwitch_TOT (OPID, orderDate)
SELECT DISTINCT a.OPID, o.orderDate
FROM #tblSwitch_OPID a
INNER JOIN tblOrders_Products op ON a.OPID = op.ID
INNER JOIN tblOrders o ON op.orderID = o.orderID
 
-- Get the number of records in the temporary table
SET @NumRec = @@ROWCOUNT
SET @RWCT = 1

--// Begin iterative update on multiCount on all orderIDs that have more than 1 DISTINCT ordersProductsID in them.
WHILE @RWCT < = @NumRec
BEGIN
	SELECT @OPID = OPID,
				  @orderDate = orderDate
	FROM #tblSwitch_TOT
	WHERE RowID = @RWCT
	
	SET @dateCount = (SELECT COUNT(DateKey)
										FROM dateDimension
										WHERE isWeekend = 0
										AND isHoliday = 0
										AND [Date] > @orderDate
										AND [Date] < CONVERT(DATE,GETDATE()))

	UPDATE #tblSwitch_TOT
	SET dateCount = @dateCount
	WHERE OPID = @OPID

	UPDATE a
	SET a.ThresholdOfTime = GETDATE()
	FROM #tblSwitch_OPID a
	INNER JOIN #tblSwitch_TOT t ON a.OPID = t.OPID
	WHERE t.dateCount >= 2

	SET @RWCT = @RWCT + 1
END


--- Populate UV fields ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This is a fresh update (overwrite) in case UV values have changed for a given OPID (pUnit) since the last time this proc ran.
UPDATE #tblSwitch_BC_LUX
SET uv_class = 'YY',
	   uv_sort = 1
WHERE front_UV = 1
AND back_UV = 1
AND duplex = 1
AND finishType <> 'ST'

UPDATE #tblSwitch_BC_LUX
SET uv_class = 'YN',
	   uv_sort = 2
WHERE front_UV = 1
AND back_UV = 0
AND duplex = 1
AND finishType <> 'ST'

UPDATE #tblSwitch_BC_LUX
SET uv_class = 'NY',
	   uv_sort = 3
WHERE front_UV = 0
AND back_UV = 1
AND duplex = 1
AND finishType <> 'ST'

UPDATE #tblSwitch_BC_LUX
SET uv_class = 'NN',
	   uv_sort = 4
WHERE front_UV = 0
AND back_UV = 0
AND duplex = 1
AND finishType <> 'ST'

--ST
UPDATE #tblSwitch_BC_LUX
SET uv_class = 'NN',
	   uv_sort = 5
WHERE front_UV = 0
AND back_UV = 0
AND duplex = 1
AND finishType = 'ST'

UPDATE #tblSwitch_BC_LUX SET frontCoating = CASE WHEN finishType = 'ST' then 'Soft Touch' WHEN front_UV = 1 THEN 'UV' ELSE 'Matte' END
UPDATE #tblSwitch_BC_LUX SET backCoating  = CASE WHEN finishType = 'ST' then 'Soft Touch' WHEN back_UV = 1  THEN 'UV' ELSE 'Matte' END

UPDATE l
SET Corner = CASE WHEN textvalue = 'Round Corners' THEN 'Round' ELSE 'Square' END
FROM #tblSwitch_BC_LUX l
INNER JOIN tblOrdersProducts_ProductOptions oppo on l.ordersProductsID = oppo.ordersProductsID
WHERE oppo.deletex <> 'yes' AND (optionCaption='Corners' or oppo.optionid in (571))

UPDATE l
SET cardType = CASE WHEN textvalue LIKE '%52%pt%' or oppo.optionid in (574,575) THEN 'Sandwich' ELSE 'Double' END
FROM #tblSwitch_BC_LUX l
INNER JOIN tblOrdersProducts_ProductOptions oppo on l.ordersProductsID = oppo.ordersProductsID
WHERE deletex <> 'yes' AND ((optionCaption='Paper Stock' AND (textValue like '%32%pt%' or textValue like '%52%pt%')) OR oppo.optionID in (573,574,575))

UPDATE l
SET sandwichColor = oppo.textValue
FROM #tblSwitch_BC_LUX l
INNER JOIN tblOrdersProducts_ProductOptions oppo on l.ordersProductsID = oppo.ordersProductsID
WHERE oppo.deletex <> 'yes' AND (optionCaption like '%sandwich%' or oppo.optionid in (575))

UPDATE #tblSwitch_BC_LUX
SET expressProduction = 1
FROM #tblSwitch_BC_LUX b
INNER JOIN tblOrders o
	ON o.orderID = b.orderID
WHERE b.expressProduction = 0
AND b.duplex = 1
AND o.shippingDesc IN ('3 Day Ground Shipping', '2 Day Air Shipping', 'Next Day Shipping', 'UPS Next Day Air Saver', 'UPS 2nd Day Air', 
										'3 Day Select', 'UPS Next Day Air', 'UPS 3 Day Select', 'FedEx', ' 2nd Day Air', ' Next Day Air', 'UPS Next Day Air Sat Delivery')


--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// OUTPUT //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

---- Update OPID status fields indicating successful submission to switch
UPDATE tblOrders_Products
SET switch_create = 1,
	   fastTrak_status = 'In Production',
	   fastTrak_status_lastModified = GETDATE(),
	   fastTrak_resubmit = 0
FROM tblOrders_Products op
INNER JOIN #tblSwitch_BC_LUX t ON op.ID = t.ordersProductsID


------ Log data that is being presented to Switch, which we can reference in case of issues.
----INSERT tblSwitch_BC_LOG_TRON (PKID, orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit01, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, sortOrder, resubmit, split, expressProduction, pUnitID, dataVersion, logDate, ThresholdOfTime, simplex, duplex, fplex, isFlipped)
----SELECT a.PKID, a.orderID, a.orderNo, a.orderDate, a.customerID, a.shippingAddressID, a.shipCompany, a.shipFirstName, a.shipLastName, a.shipAddress1, a.shipAddress2, a.shipCity, a.shipState, a.shipZip, a.shipCountry, a.shipPhone, a.productCode, a.productName, a.shortName, a.productQuantity, a.packetValue, a.variableTopName, a.variableBottomName, a.variableWholeName, a.backName, a.numUnits, a.displayedQuantity, a.ordersProductsID, a.shipsWith, a.resubmit, a.shipType, a.samplerRequest, a.multiCount, a.totalCount, a.displayCount, a.background, a.templateFile, a.team1FileName, a.team2FileName, a.team3FileName, a.team4FileName, a.team5FileName, a.team6FileName, a.groupID, a.productID, a.parentProductID, a.switch_create, a.switch_createDate, a.switch_approve, a.switch_approveDate, a.switch_print, a.switch_printDate, a.switch_import, a.mo_orders_Products, a.mo_orders, a.mo_customers, a.mo_customers_ShippingAddress, a.mo_oppo, a.customProductCount, a.customProductCode1, a.customProductCode2, a.customProductCode3, a.customProductCode4, a.fasTrakProductCount, a.fasTrakProductCode1, a.fasTrakProductCode2, a.fasTrakProductCode3, a.fasTrakProductCode4, a.stockProductCount, a.stockProductQuantity1, a.stockProductCode1, a.stockProductDescription1, a.stockProductQuantity2, a.stockProductCode2, a.stockProductDescription2, a.stockProductQuantity3, a.stockProductCode3, a.stockProductDescription3, a.stockProductQuantity4, a.stockProductCode4, a.stockProductDescription4, a.stockProductQuantity5, a.stockProductCode5, a.stockProductDescription5, a.stockProductQuantity6, a.stockProductCode6, a.stockProductDescription6, a.front_UV, a.back_UV, a.customBackground, a.sortOrder, a.resubmit, a.split, a.expressProduction, a.pUnitID, 'Duplex - TRON', GETDATE(), a.ThresholdOfTime, a.simplex, a.duplex, a.fplex, a.isFlipped
----FROM tblSwitch_BCD_ThresholdDiff_TRON a
----ORDER BY PKID

----Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch to log each job
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'BC_Lux'
,a.PKID
,a.ordersProductsID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from #tblSwitch_BC_LUX b
       where a.PKID = b.PKID
       for json path)
from #tblSwitch_BC_LUX a





-- Output duplex data for Switch use.
SELECT distinct a.PKID, a.orderID, a.orderNo, a.orderDate, a.customerID, a.shippingAddressID, a.shipCompany, a.shipFirstName, a.shipLastName, a.shipAddress1, a.shipAddress2, a.shipCity, a.shipState, a.shipZip, a.shipCountry, a.shipPhone, a.productCode, a.productName, a.shortName, a.productQuantity, a.packetValue, a.variableTopName, a.variableBottomName, a.variableWholeName, a.backName, a.numUnits, a.displayedQuantity, a.ordersProductsID, a.shipsWith, a.resubmit, a.shipType, a.samplerRequest, a.multiCount, a.totalCount, a.displayCount, a.background, a.templateFile, a.team1FileName, a.team2FileName, a.team3FileName, a.team4FileName, a.team5FileName, a.team6FileName, a.groupID, a.productID, a.parentProductID, a.switch_create, a.switch_createDate, a.switch_approve, a.switch_approveDate, a.switch_print, a.switch_printDate, a.switch_import, a.mo_orders_Products, a.mo_orders, a.mo_customers, a.mo_customers_ShippingAddress, a.mo_oppo, a.customProductCount, a.customProductCode1, a.customProductCode2, a.customProductCode3, a.customProductCode4, a.fasTrakProductCount, a.fasTrakProductCode1, a.fasTrakProductCode2, a.fasTrakProductCode3, a.fasTrakProductCode4, a.stockProductCount, a.stockProductQuantity1, a.stockProductCode1, a.stockProductDescription1, a.stockProductQuantity2, a.stockProductCode2, a.stockProductDescription2, a.stockProductQuantity3, a.stockProductCode3, a.stockProductDescription3, a.stockProductQuantity4, a.stockProductCode4, a.stockProductDescription4, a.stockProductQuantity5, a.stockProductCode5, a.stockProductDescription5, a.stockProductQuantity6, a.stockProductCode6, a.stockProductDescription6, a.front_UV, a.back_UV, a.customBackground, a.resubmit, a.expressProduction,  a.simplex, a.duplex, a.fplex, a.isFlipped,a.finishType,frontCoating,backCoating,Corner,cardType,sandwichColor
FROM #tblSwitch_BC_LUX a
ORDER BY PKID


--END
  

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH