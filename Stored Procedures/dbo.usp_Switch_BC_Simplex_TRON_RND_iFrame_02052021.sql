﻿
CREATE PROCEDURE [dbo].[usp_Switch_BC_Simplex_TRON_RND_iFrame_02052021] 
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/3/17
Purpose     Business Card Threshold Work for Switch Automation - Simplex LUX
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
07/10/18		Added packetValue column to the insert list for tblSwitch_pUnit_TRON_RND, near LN 1126, jf
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
05/23/19		Added addt'l logic in secondary initial query that checks for OPID fileexists values for Duplex opids that have multiple files, jf.
07/25/19		BJS Fix BC from being sent to the switch
11/14/19		JF, added readyForSwitch check.
11/20/19		JF, modified step 4.a in initial query. for more info on what this is about, see stored proc: [popArtGate].
08/04/20		JF, Added stripper to init query.
09/09/20		JF, Added fileExists fix to init query.
11/23/20		JF, LEN(orderNo) IN (9,10)

LUX -------------------------------------------------------------------------

optionID	optionGroupID	optionCaption
-----------------------------------------------------------------------------
571			57				Round
573			58				Double Thick 32 pt
574			58				Luxe ColorFill 42 pt
575			19				Sandwich Color
568			36				Soft Touch Front Coating
569			36				Soft Touch Back Coating
-----------------------------------------------------------------------------

Business Card Flows:

1. Regular Business Cards (16pt) - Simplex - Square Corners - 0 - [usp_Switch_BC_Simplex_TRON]
2. Regular Business Cards (16pt) - Duplex - Square Corners - 0 - [usp_Switch_BC_Duplex_TRON]
3. Regular Business Cards (16pt) - Simplex - Rounded Corners - 571 - []
4. Regular Business Cards (16pt) - Duplex - Rounded Corners - 571 - []
5. Double Thick Business Cards (32pt) - Simplex - Square Corners - 573 - []
6. Double Thick Business Cards (32pt) - Duplex - Rounded Corners - 573/571 - []
7. Sandwich Business Cards (42pt) - Simplex - Square Corners - 574 - []
8. Sandwich Business Cards (42pt) - Duplex - Rounded Corners - 574/571 - []


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// IMAGE CHECK //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

--Flags
DECLARE @Flag BIT

SET @Flag = (SELECT FlagStatus 
			FROM Flags
			WHERE FlagName = 'Switch_BC_Simplex_TRON_RND')
					   
--IF @Flag = 0
--BEGIN

UPDATE Flags
SET FlagStatus = 1
WHERE FlagName = 'Switch_BC_Simplex_TRON_RND'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// INITIALIZE OPID //////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Remove any pUnit values from tblSwitch_pUnit_TRON_RND that have not made it to switch AND are not split. We want to keep the unsubmitted split's data the same as their previously submitted siblings. 
-- This will ensure that we get the most up-to-date data per OPID, unless it is a split, in which case, we are looking for consistency.
-- We do not want to refresh Simplex values as they are about to come in as fPlex.
DELETE FROM tblSwitch_pUnit_TRON_RND
WHERE submitted_to_switch = 0
AND split = 0
AND Simplex = 1

-- Initialize data set
TRUNCATE TABLE tblSwitch_OPID_TRON_RND
INSERT INTO tblSwitch_OPID_TRON_RND (OPID, ReadyForSwitch)

SELECT DISTINCT op.ID, GETDATE()
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
INNER JOIN tblOrdersProducts_productOptions oppo ON op.ID = oppo.ordersProductsID
WHERE

--1. Duplex Designation ----------------------------------
op.ID NOT IN
	--This subquery shows Duplex OPIDs
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND (
				--Regular Duplex BCs
				optionCaption IN ('Product Back', 'Back Intranet PDF')
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
	AND NOT EXISTS
		--Blank Backs
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions opp1
		WHERE deleteX <> 'yes'
		AND optionID = 564
		AND op.ID = opp1.ordersProductsID)
	)

--2. Order Qualification ----------------------------------
AND DATEDIFF(MI, a.created_on, GETDATE()) > 60
AND a.orderDate > CONVERT(DATETIME, '02/01/2018')
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus = 'Good'

--3. Product Qualification ----------------------------------
AND SUBSTRING(p.productCode, 1, 2) = 'BP' 

--4. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType IN ('fasTrak', 'custom')
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
				AND RIGHT(textValue, 2) = '_J'
				AND opp2.ordersProductsID = op.ID)
		--4.b
		OR op.fastTrak_status = 'Good to Go'
		--4.c
		OR op.fastTrak_resubmit = 1
		)
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions opp1
	WHERE deleteX <> 'yes'
	AND optionID = 571 -- Rounded
	AND opp1.ordersProductsID = op.ID) 

--5. Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS				
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.ID
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOPPO_fileExists ee
		WHERE ee.readyForSwitch = 1
		AND e.OPID = ee.OPID))



--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// BEGIN INSERT //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

TRUNCATE TABLE tblSwitch_BCS_TRON
INSERT INTO tblSwitch_BCS_TRON (orderID, orderNo, orderDate, customerID, 
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

SELECT
a.orderID, a.orderNo, a.orderDate, a.customerID, 
--s.shippingAddressID, s.shipping_Company, s.shipping_Firstname, s.shipping_surName, 
--s.shipping_Street, s.shipping_Street2, s.shipping_Suburb, s.shipping_State, s.shipping_PostCode, s.shipping_Country, s.shipping_Phone, 
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
0 AS 'stockProductQuantity6', '' AS 'stockProductCode6', '' AS 'stockProductDescription6',
0
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
INNER JOIN tblSwitch_OPID_TRON_RND q ON op.ID = q.OPID
WHERE NOT EXISTS
	(SELECT ordersProductsID 
	FROM tblSwitch_BCS_TRON x
	WHERE ordersProductsID IS NOT NULL
	AND op.ID = x.ordersProductsID)


--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////// QUANTITY WORK /////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// First, fix productQuantity if fasTrak_newQTY value exists
UPDATE tblSwitch_BCS_TRON
SET productQuantity = b.fastTrak_newQTY
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b ON a.ordersProductsID = b.ID
WHERE (b.fastTrak_newQTY IS NOT NULL 
	  AND b.fastTrak_newQTY <> 0 )
AND a.productQuantity <> b.fastTrak_newQTY

--// Next, fix productQuantity if order is from NOP HOM, which typically has values like 500 instead of 5; 1000 instead of 10, etc. We want to change 500 to 5, 1000 to 10.
UPDATE a
SET productQuantity = productQuantity/100
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
WHERE o.NOP = 1
AND a.productQuantity > 100

--// Next, duplicate line items based on productQuantity for given ordersProductsID; use integers table for iterations. 
-- A 5-quantity product has 1 row, 10 has 2 rows, etc. So, we iterate on QTY. If QTY is 10, then this code would produce a "1 of 2" and "2 of 2".
TRUNCATE TABLE tblSwitch_BCS_Bounce_TRON_Rnd_Simplex
INSERT INTO tblSwitch_BCS_Bounce_TRON_Rnd_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, 
shortName, productQuantity, 
CONVERT(VARCHAR(255), i.i) + ' of ' + CONVERT(VARCHAR(255), a.productQuantity/5) AS 'packetValue', 
variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, 
displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, 
switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, 
customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, 
fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, 
stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, 
stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction
FROM tblSwitch_BCS_TRON a 
INNER JOIN integers i 
	ON i.i <= a.productQuantity/5
WHERE i.i <> 0

--// Repopulate tblSwitch_BCS_TRON with accurate data to begin more edits.
TRUNCATE TABLE tblSwitch_BCS_TRON
INSERT INTO tblSwitch_BCS_TRON (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction)
SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction
FROM tblSwitch_BCS_Bounce_TRON_Rnd_Simplex
ORDER BY ordersProductsID, packetValue

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '1 of', '01 of') WHERE packetValue LIKE '1 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '2 of', '02 of') WHERE packetValue LIKE '2 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '3 of', '03 of') WHERE packetValue LIKE '3 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '4 of', '04 of') WHERE packetValue LIKE '4 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '5 of', '05 of') WHERE packetValue LIKE '5 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '6 of', '06 of') WHERE packetValue LIKE '6 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '7 of', '07 of') WHERE packetValue LIKE '7 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '8 of', '08 of') WHERE packetValue LIKE '8 of%'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, '9 of', '09 of') WHERE packetValue LIKE '9 of%'

UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 1', 'of 01') WHERE packetValue LIKE '%of 1'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 2', 'of 02') WHERE packetValue LIKE '%of 2'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 3', 'of 03') WHERE packetValue LIKE '%of 3'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 4', 'of 04') WHERE packetValue LIKE '%of 4'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 5', 'of 05') WHERE packetValue LIKE '%of 5'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 6', 'of 06') WHERE packetValue LIKE '%of 6'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 7', 'of 07') WHERE packetValue LIKE '%of 7'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 8', 'of 08') WHERE packetValue LIKE '%of 8'
UPDATE tblSwitch_BCS_TRON SET packetValue = REPLACE(packetValue, 'of 9', 'of 09') WHERE packetValue LIKE '%of 9'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// UV SECTION //////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Front Coating
UPDATE tblSwitch_BCS_TRON
SET front_UV = 1
WHERE (front_UV = 0 or front_UV IS NULL)
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Front Coating'
	AND optionCaption = 'UV')

UPDATE tblSwitch_BCS_TRON
SET front_UV = 0
WHERE front_UV = 1
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Front Coating'
	AND optionCaption = 'Matte (No UV)')

--Back Coating
UPDATE tblSwitch_BCS_TRON
SET back_UV = 1
WHERE (back_UV = 0 OR back_UV IS NULL)
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Back Coating'
	AND optionCaption = 'UV')

UPDATE tblSwitch_BCS_TRON
SET back_UV = 0
WHERE back_UV = 1
AND ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionGroupCaption = 'Back Coating'
	AND optionCaption = 'Matte (No UV)')

-- deNULL
UPDATE tblSwitch_BCS_TRON
SET front_UV = 0
WHERE front_UV IS NULL

UPDATE tblSwitch_BCS_TRON
SET back_UV = 0
WHERE back_UV IS NULL

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// FINISH TYPE /////////////////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

UPDATE tblSwitch_BCS_TRON
SET finishType = 'UV'
WHERE front_UV = 1
OR back_UV = 1

UPDATE a
SET finishType = 'MT'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions oppo ON a.ordersProductsID = oppo.ordersProductsID
WHERE a.front_UV = 0
AND a.back_UV = 0
AND oppo.optionID NOT IN (568, 569)
AND oppo.deleteX <> 'yes'

UPDATE a
SET finishType = 'ST'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions oppo ON a.ordersProductsID = oppo.ordersProductsID
WHERE a.front_UV = 0
AND a.back_UV = 0
AND oppo.optionID IN (568, 569)
AND oppo.deleteX <> 'yes'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// FRONTS AND BACKS //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--(1/3) variableWholeName - CLASSIC
UPDATE tblSwitch_BCS_TRON
SET variableWholeName = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'File Name 2'
AND b.textValue LIKE '%/%'

--(2/3) variableWholeName - CANVAS
UPDATE tblSwitch_BCS_TRON
SET variableWholeName = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Intranet PDF'

--(3/3) variableWholeName - CYO
UPDATE tblSwitch_BCS_TRON
SET variableWholeName = SUBSTRING(b.textValue, 1, LEN(b.textValue) - CHARINDEX('.', REVERSE(b.textValue))) + '.pdf'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('File Name 1', 'File Name 2')
AND b.textValue NOT LIKE '%/%'
AND b.textValue LIKE '%-FRONT-%'

--// (1/3) backName - CLASSIC
UPDATE tblSwitch_BCS_TRON
SET backName = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption = 'Product Back'
AND b.textValue LIKE '%/%'
AND b.textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 'BLANK')

--// (2/3) backName - CANVAS
UPDATE tblSwitch_BCS_TRON
SET backName = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
FROM tblSwitch_BCS_TRON a 
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
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

--// (3/3) backName - CYO
UPDATE tblSwitch_BCS_TRON
SET backName = SUBSTRING(b.textValue, 1, LEN(b.textValue) - CHARINDEX('.', REVERSE(b.textValue))) + '.pdf'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
AND b.deleteX <> 'yes'
AND b.optionCaption IN ('File Name 1', 'File Name 2')
AND b.textValue NOT LIKE '%/%'
AND b.textValue LIKE '%-BACK-%'
AND b.textValue NOT IN
		('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
		 '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 'BLANK')

--// update customBackground value; new, 12/29/16 jf.
UPDATE tblSwitch_BCS_TRON
SET customBackground = b.optionCaption
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Background'

--// Strip extension and replace with '.pdf'
UPDATE tblSwitch_BCS_TRON
SET variableWholeName = SUBSTRING(variableWholeName, 1, LEN(variableWholeName) - CHARINDEX('.', REVERSE(variableWholeName))) + '.pdf'
WHERE variableWholeName IS NOT NULL

UPDATE tblSwitch_BCS_TRON
SET backName = SUBSTRING(backName, 1, LEN(backName) - CHARINDEX('.', REVERSE(backName))) + '.pdf'
WHERE backName IS NOT NULL

UPDATE tblSwitch_BCS_TRON
SET customBackground = SUBSTRING(customBackground, 1, LEN(customBackground) - CHARINDEX('.', REVERSE(customBackground))) + '.pdf'
WHERE customBackground IS NOT NULL

--And if the extension is missing entirely.
UPDATE tblSwitch_BCS_TRON
SET variableWholeName = variableWholeName + '.pdf'
WHERE variableWholeName NOT LIKE '%.pdf'
AND variableWholeName <> ''
AND variableWholeName IS NOT NULL

UPDATE tblSwitch_BCS_TRON
SET backName = backName + '.pdf'
WHERE backName NOT LIKE '%.pdf'
AND backName <> ''
AND backName IS NOT NULL

UPDATE tblSwitch_BCS_TRON
SET customBackground = customBackground + '.pdf'
WHERE customBackground NOT LIKE '%.pdf'
AND customBackground <> ''
AND customBackground IS NOT NULL

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIPS WITH //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Custom. If an OPID from this flow ships with another OPID that is not a pen and has processType = 'Custom', then set shipsWith = 'custom' for current OPID.
UPDATE tblSwitch_BCS_TRON
SET shipsWith = 'Custom'
WHERE orderID IN
		(SELECT orderID 
		FROM tblOrders_Products 
		WHERE deleteX <> 'yes'
		AND ID NOT IN
			(SELECT ordersProductsID
			FROM tblSwitch_BCS_TRON)
		AND processType = 'Custom'
		AND SUBSTRING(productCode, 1, 2) <> 'PN')

-- fasTrak. If another fasTrak OPID ships with current OPID from this flow, and that other OPID is not a part of this current flow, then set shipsWith = 'fasTrak' for current OPID.
UPDATE tblSwitch_BCS_TRON
SET shipsWith = 'fasTrak'
WHERE shipsWith <> 'Custom'
AND orderID IN
	(SELECT DISTINCT orderID 
	FROM tblOrders_Products 
	WHERE deleteX <> 'yes'
	AND ID NOT IN
			(SELECT ordersProductsID
			FROM tblSwitch_BCS_TRON)
	AND processType = 'fasTrak')	 

-- Local Pickup / Will Call. If current OPID is on an order that is a local pickup (or will call) order, then set shipsWith = 'Local Pickup' for current OPID.
UPDATE tblSwitch_BCS_TRON
SET shipsWith = 'Local Pickup'
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders
	WHERE CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will call%'
			OR CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')

-- Stock. If more than 3 stock line items are on the same order as the current OPID, then count 'em up. (this excludes NameBadge accessories)
TRUNCATE TABLE tblSwitch_BCS_stockCount_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_stockCount_TRON_RND_Simplex (orderID, stockCount)
SELECT DISTINCT a.orderID, b.[ID]
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND SUBSTRING(b.productCode, 1, 2) <> 'FM'
AND b.processType = 'Stock'

UPDATE tblSwitch_BCS_TRON
SET shipsWith = 'Stock'
WHERE orderID IN
	(SELECT orderID 
	FROM tblSwitch_BCS_stockCount_TRON_RND_Simplex
	GROUP BY orderID
	HAVING COUNT(orderID) > 3)

---- Resubmit values can override shipsWith when @resubmitChoice = 1 (see [usp_resubmitOPID] for details) (removed 10/13/20; jf)
--UPDATE t
--SET shipsWith = 'Resubmit'
--FROM tblSwitch_BCS_TRON t
--INNER JOIN tblOrders_Products op ON t.ordersProductsID = op.ID
--WHERE op.fastTrak_shippingLabelOption1 = 1

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// SHIP TYPE //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// default
UPDATE tblSwitch_BCS_TRON
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE tblSwitch_BCS_TRON
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE tblSwitch_BCS_TRON
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE tblSwitch_BCS_TRON
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE tblSwitch_BCS_TRON
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
FROM  tblSwitch_BCS_TRON t
INNER JOIN tblOrders a ON t.orderNo = a.orderNo
INNER JOIN tblOrdersProducts_productOptions oppo ON t.ordersProductsID = oppo.ordersProductsID
WHERE a.arrivalDate IS NOT NULL
AND oppo.deleteX <> 'yes'
AND oppo.optionCaption = 'Express Production'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////// DISPLAY COUNT DATA //////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// Run counts to populate totalCount column, which grabs the number of distinct ordersProductIDs per orderID.
TRUNCATE TABLE tblSwitch_BCS_distinctIDCount_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_distinctIDCount_TRON_RND_Simplex (orderID, ordersProductsID)
SELECT DISTINCT orderID, ordersProductsID
FROM tblSwitch_BCS_TRON

TRUNCATE TABLE tblSwitch_BCS_distinctIDCount2_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_distinctIDCount2_TRON_RND_Simplex (orderID, countOrderID)
SELECT orderID, COUNT(orderID) AS 'countOrderID'
FROM tblSwitch_BCS_distinctIDCount_TRON_RND_Simplex
GROUP BY orderID
ORDER BY OrderId

UPDATE tblSwitch_BCS_TRON
SET totalCount = b.countOrderID
FROM tblSwitch_BCS_TRON a 
INNER JOIN tblSwitch_BCS_distinctIDCount2_TRON_RND_Simplex b
ON a.orderID = b.orderID

UPDATE tblSwitch_BCS_TRON
SET displayCount = NULL,
multiCount = totalCount

--// PCU
--// Counts (multiCount and totalCount)
IF OBJECT_ID(N'tblSwitch_BCS_displayCount_TRON_RND_Simplex', N'U') IS NOT NULL
DROP TABLE tblSwitch_BCS_displayCount_TRON_RND_Simplex

CREATE TABLE tblSwitch_BCS_displayCount_TRON_RND_Simplex
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
TRUNCATE TABLE tblSwitch_BCS_displayCount_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_displayCount_TRON_RND_Simplex (orderID, ordersProductsID, totalCount)
SELECT DISTINCT orderID, ordersProductsID, totalCount
FROM tblSwitch_BCS_TRON
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
	FROM tblSwitch_BCS_displayCount_TRON_RND_Simplex
	WHERE RowID = @RowCount
	
	UPDATE tblSwitch_BCS_TRON
	SET @topMultiCount = (SELECT TOP 1 multiCount
						 FROM tblSwitch_BCS_TRON
						 WHERE orderID = @orderID
						 ORDER BY multiCount ASC)
	
	UPDATE tblSwitch_BCS_TRON
	SET multiCount = @topMultiCount - 1
	WHERE orderID = @orderID
	AND ordersProductsID = @ordersProductsID
	AND @topMultiCount - 1 <> 0	
	
	SET @RowCount = @RowCount + 1
END

UPDATE tblSwitch_BCS_TRON
SET displayCount = CONVERT(VARCHAR(255), multiCount) + ' of ' + CONVERT(VARCHAR(255), totalCount)

--// update packetValue with sortable multi-digit numbers
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '1 of', '01 of') WHERE displayCount LIKE '1 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '2 of', '02 of') WHERE displayCount LIKE '2 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '3 of', '03 of') WHERE displayCount LIKE '3 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '4 of', '04 of') WHERE displayCount LIKE '4 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '5 of', '05 of') WHERE displayCount LIKE '5 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '6 of', '06 of') WHERE displayCount LIKE '6 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '7 of', '07 of') WHERE displayCount LIKE '7 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '8 of', '08 of') WHERE displayCount LIKE '8 of%'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, '9 of', '09 of') WHERE displayCount LIKE '9 of%'

UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 1', 'of 01') WHERE displayCount LIKE '%of 1'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 2', 'of 02') WHERE displayCount LIKE '%of 2'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 3', 'of 03') WHERE displayCount LIKE '%of 3'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 4', 'of 04') WHERE displayCount LIKE '%of 4'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 5', 'of 05') WHERE displayCount LIKE '%of 5'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 6', 'of 06') WHERE displayCount LIKE '%of 6'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 7', 'of 07') WHERE displayCount LIKE '%of 7'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 8', 'of 08') WHERE displayCount LIKE '%of 8'
UPDATE tblSwitch_BCS_TRON SET displayCount = REPLACE(displayCount, 'of 9', 'of 09') WHERE displayCount LIKE '%of 9'

UPDATE tblSwitch_BCS_TRON SET switch_approve = 0
UPDATE tblSwitch_BCS_TRON SET switch_print = 0
UPDATE tblSwitch_BCS_TRON SET switch_approveDate = GETDATE()
UPDATE tblSwitch_BCS_TRON SET switch_printDate = GETDATE()
UPDATE tblSwitch_BCS_TRON SET switch_createDate = GETDATE()

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////// CUSTOM COUNTS //////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// customProductCount
TRUNCATE TABLE tblSwitch_BCS_countCustom_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_countCustom_TRON_RND_Simplex (orderID, countCustom)
SELECT a.orderID, COUNT(DISTINCT(SUBSTRING(b.productCode, 1, 4))) AS 'countCustom'
FROM tblSwitch_BCS_TRON a 
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Custom' 
	AND productID IS NOT NULL
	AND SUBSTRING(productCode, 1, 2) <> 'PN')
AND SUBSTRING(b.productCode, 1, 2) <> 'BP'
GROUP BY a.orderID

UPDATE tblSwitch_BCS_TRON
SET customProductCount = b.countCustom
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_countCustom_TRON_RND_Simplex b ON a.orderID = b.orderID

--// Populate customProductCode fields
TRUNCATE TABLE tblSwitch_BCS_listCustom_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_listCustom_TRON_RND_Simplex (orderID, productCodePrefix)
SELECT DISTINCT a.orderID, SUBSTRING(b.productCode, 1 ,4) AS 'productCodePrefix'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	 WHERE productType = 'Custom' 
	 AND productID IS NOT NULL
	 AND SUBSTRING(productCode, 1, 2) <> 'PN')
AND SUBSTRING(b.productCode, 1, 2) <> 'BP'

UPDATE tblSwitch_BCS_TRON
SET customProductCode1 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listCustom_TRON_RND_Simplex b ON a.orderID = b.orderID

UPDATE tblSwitch_BCS_TRON
SET customProductCode2 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listCustom_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix

UPDATE tblSwitch_BCS_TRON
SET customProductCode3 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listCustom_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix
AND customProductCode2 <> ''
AND customProductCode2 <> b.productCodePrefix

UPDATE tblSwitch_BCS_TRON
SET customProductCode4 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listCustom_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE customProductCode1 <> ''
AND customProductCode1 <> b.productCodePrefix
AND customProductCode2 <> ''
AND customProductCode2 <> b.productCodePrefix
AND customProductCode3 <> ''
AND customProductCode3 <> b.productCodePrefix

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////// FASTRAK COUNTS //////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// FTProductCount
TRUNCATE TABLE tblSwitch_BCS_countFT_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_countFT_TRON_RND_Simplex (orderID, countFT)
SELECT a.orderID, COUNT(DISTINCT(SUBSTRING(b.productCode, 1, 4))) AS 'countFT'
FROM tblSwitch_BCS_TRON a 
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND SUBSTRING(b.productCode, 1, 2) <> 'BP'
GROUP BY a.orderID

UPDATE tblSwitch_BCS_TRON
SET fasTrakProductCount = b.countFT
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_countFT_TRON_RND_Simplex b ON a.orderID = b.orderID

--// Populate fasTrakProductCode fields
TRUNCATE TABLE tblSwitch_BCS_listFT_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_listFT_TRON_RND_Simplex (orderID, productCodePrefix)
SELECT DISTINCT a.orderID, SUBSTRING(b.productCode, 1 ,4) AS 'productCodePrefix'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND SUBSTRING(b.productCode, 1, 2) <> 'BP'

UPDATE tblSwitch_BCS_TRON
SET fasTrakProductCode1 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listFT_TRON_RND_Simplex b ON a.orderID = b.orderID

UPDATE tblSwitch_BCS_TRON
SET fasTrakProductCode2 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listFT_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix

UPDATE tblSwitch_BCS_TRON
SET fasTrakProductCode3 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listFT_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix
AND fasTrakProductCode2 <> ''
AND fasTrakProductCode2 <> b.productCodePrefix

UPDATE tblSwitch_BCS_TRON
SET fasTrakProductCode4 = b.productCodePrefix
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listFT_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE fasTrakProductCode1 <> ''
AND fasTrakProductCode1 <> b.productCodePrefix
AND fasTrakProductCode2 <> ''
AND fasTrakProductCode2 <> b.productCodePrefix
AND fasTrakProductCode3 <> ''
AND fasTrakProductCode3 <> b.productCodePrefix

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////// STOCK COUNTS //////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--// stockProductCount
TRUNCATE TABLE tblSwitch_BCS_countStock_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_countStock_TRON_RND_Simplex (orderID, countStock)
SELECT a.orderID, COUNT(DISTINCT(b.productCode)) AS 'countStock'
FROM tblSwitch_BCS_TRON a 
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Stock'
	AND SUBSTRING(productCode, 1, 2) <> 'NB'
	AND SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productCode <> 'AM-16')
AND SUBSTRING(b.productCode, 1, 2) <> 'BP'
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.ID NOT IN --this pulls out envelopes grouped with non-bizcard products, b/c bizcards never have envelopes grouped with them.
	(SELECT ID
	FROM tblOrders_Products
	WHERE SUBSTRING(productCode, 3, 2) = 'EV'
	AND deleteX <> 'yes'
	AND groupID <> 0)
GROUP BY a.orderID

UPDATE tblSwitch_BCS_TRON
SET stockProductCount = b.countStock
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_countStock_TRON_RND_Simplex b ON a.orderID = b.orderID

--// Populate stockProductCode fields (up to 3 slots because if >3, then we blank them all out anyways)
TRUNCATE TABLE tblSwitch_BCS_listStock_TRON_RND_Simplex
INSERT INTO tblSwitch_BCS_listStock_TRON_RND_Simplex (orderID, productCode)
SELECT DISTINCT a.orderID, b.productCode AS 'productCode'
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE productType = 'Stock'
	AND SUBSTRING(productCode, 1, 2) <> 'NB'
	AND SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productCode <> 'AM-16')
AND SUBSTRING(b.productCode, 1, 2) <> 'BP'
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.ID NOT IN --this pulls out envelopes grouped with non-bizcard products, b/c bizcards never have envelopes grouped with them.
	(SELECT ID
	FROM tblOrders_Products
	WHERE SUBSTRING(productCode, 3, 2) = 'EV'
	AND deleteX <> 'yes'
	AND groupID <> 0)
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_BCS_TRON
SET stockProductCode1 = b.productCode
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listStock_TRON_RND_Simplex b ON a.orderID = b.orderID

UPDATE tblSwitch_BCS_TRON
SET stockProductCode2 = b.productCode
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listStock_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode

UPDATE tblSwitch_BCS_TRON
SET stockProductCode3 = b.productCode
FROM tblSwitch_BCS_TRON a
INNER JOIN tblSwitch_BCS_listStock_TRON_RND_Simplex b ON a.orderID = b.orderID
WHERE stockProductCode1 <> ''
AND stockProductCode1 <> b.productCode
AND stockProductCode2 <> ''
AND stockProductCode2 <> b.productCode

UPDATE tblSwitch_BCS_TRON
SET stockProductQuantity1 = b.productQuantity,
	stockProductDescription1 = b.productName
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode1 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_BCS_TRON
SET stockProductQuantity2 = b.productQuantity,
	stockProductDescription2 = b.productName
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b	ON a.orderID = b.orderID
WHERE a.stockProductCode2 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

UPDATE tblSwitch_BCS_TRON
SET stockProductQuantity3 = b.productQuantity,
	stockProductDescription3 = b.productName
FROM tblSwitch_BCS_TRON a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE a.stockProductCode3 = b.productCode
AND b.productCode <> ''
AND b.productCode IS NOT NULL
AND b.productName NOT LIKE '%Mail%'

-- If shipsWith = 'Stock', that means there are >3 stock w/ current OPID. In this scenario, wipe all stock fields.
UPDATE tblSwitch_BCS_TRON
SET stockProductCode1 = '',
	   stockProductCode2 = '',	
	   stockProductCode3 = '',	
	   stockProductQuantity1 = 0,
	   stockProductQuantity2 = 0,
	   stockProductQuantity3 = 0
WHERE shipsWith = 'Stock'

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////// OPID SORT QUALIFIERS //////////////////////////////////	
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- RESUBMISSION SECTION -------------------------------------------------------------------------------BEGIN
UPDATE x
SET resubmit = 1
FROM tblSwitch_BCS_TRON x
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND op.fastTrak_resubmit = 1
	AND op.ID = x.ordersProductsID)

-- For any OPID that has been resubbed, update ShipsWith accordingly
IF OBJECT_ID('tempdb..#tempResubChoice_BCS_TRON') IS NOT NULL 
DROP TABLE #tempResubChoice_BCS_TRON

CREATE TABLE #tempResubChoice_BCS_TRON (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @NumberRecords_rs INT, 
				 @RowCount_rs INT,
				 @OPID_rs INT,
				 @MostRecent_ResubChoice_rs INT

INSERT INTO #tempResubChoice_BCS_TRON (OPID)
SELECT DISTINCT ordersProductsID
FROM tblSwitch_BCS_TRON
WHERE resubmit = 1

SET @NumberRecords_rs = @@RowCount
SET @RowCount_rs = 1

WHILE @RowCount_rs <= @NumberRecords_rs
BEGIN
	 SELECT @OPID_rs = OPID
	 FROM #tempResubChoice_BCS_TRON
	 WHERE RowID = @RowCount_rs

	 SET @MostRecent_ResubChoice_rs = (SELECT TOP 1 resubmitChoice
															FROM tblSwitch_resubOption
															WHERE OPID = @OPID_rs
															ORDER BY resubmitDate DESC)
	
	UPDATE tblSwitch_BCS_TRON
	SET shipsWith = 'RESUB ' + CONVERT(VARCHAR(50), ISNULL(@MostRecent_ResubChoice_rs, 1))
	WHERE ordersProductsID = @OPID_rs	 

	SET @RowCount_rs = @RowCount_rs + 1
END

UPDATE tblSwitch_BCS_TRON
SET resubmit = 0
WHERE resubmit IS NULL
-- RESUBMISSION SECTION -------------------------------------------------------------------------------END

-- update expressProduction to reflect the current value in tblOrders_Products for the OPID; new, 04/06/18 jf.
UPDATE tblSwitch_BCS_TRON
SET expressProduction = 1
WHERE ordersProductsID IN
	(SELECT ordersProductsID
	FROM tblOrdersProducts_productOptions
	WHERE deleteX <> 'yes'
	AND optionCaption = 'Express Production')

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// BEHOLD! THE THRESHOLD OF TIME //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Heh. 
-- If an OPID isn't getting pulled in because it is rare and the QTY threshold is not being met each successive imposition, then
-- we want to brute force it into the imposition, even if it messes up the "count of six" effort. This next section looks to see if an OPID
-- has been stagnate for a given period of time, and if so, flags it so that it is forced into the imposition later below.
-- the flag really is just setting ThresholdOfTime = GETDATE(), which doesn't mean anything, just a flag.
--// TOT

IF OBJECT_ID(N'tblSwitch_TOT_RND', N'U') IS NOT NULL
DROP TABLE tblSwitch_TOT_RND

CREATE TABLE tblSwitch_TOT_RND
	(RowID INT IDENTITY(1, 1), 
	OPID INT, 
	orderDate DATETIME,
	dateCount INT)

DECLARE @NumRec INT, @RWCT INT
DECLARE @OPID INT
DECLARE @orderDate DATETIME
DECLARE @dateCount INT

--// Create table
TRUNCATE TABLE tblSwitch_TOT_RND
INSERT INTO tblSwitch_TOT_RND (OPID, orderDate)
SELECT DISTINCT a.OPID, o.orderDate
FROM tblSwitch_OPID_TRON_RND a
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
	FROM tblSwitch_TOT_RND
	WHERE RowID = @RWCT
	
	SET @dateCount = (SELECT COUNT(DateKey)
										FROM dateDimension
										WHERE isWeekend = 0
										AND isHoliday = 0
										AND [Date] > @orderDate
										AND [Date] < CONVERT(DATE,GETDATE()))

	UPDATE tblSwitch_TOT_RND
	SET dateCount = @dateCount
	WHERE OPID = @OPID

	UPDATE a
	SET a.ThresholdOfTime = GETDATE()
	FROM tblSwitch_OPID_TRON_RND a
	INNER JOIN tblSwitch_TOT_RND t ON a.OPID = t.OPID
	WHERE t.dateCount >= 0 --We are overriding TOT in RND, this normally is set to "2" not "0".

	SET @RWCT = @RWCT + 1
END

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// THY NAME IS pUNIT //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- All the work so far in this sproc is massage, iteration, and prep work; now we move to the production and output segment of work.
-- The pUnit table controls the "production units" of a given OPID, since below there is the possibility of an OPID being "split" into multiple runs 
-- because a portion of the "production units" will go this run, and a portion will fall on the subsequent run(s).

-- pUnit - Remove resubs ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- First, reset pUnit work table by pulling out any OPID that has been resubmitted which negates any previous activity on said OPID. So, if an OPID was split from before, we ignore this and the resub values take precedent.
DELETE FROM tblSwitch_pUnit_TRON_RND
WHERE OPID IN
	(SELECT ordersProductsID
	FROM tblSwitch_BCS_TRON
	WHERE resubmit = 1)

-- pUnit - Insert new records ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Next, insert unique pUnit value and new (and resubbed) OPIDs, which will be added to the work table. Now that we have a table to bounce against, we can use the unique pUnitID field to prioritize "remainders" in the code below.
-- We will work exclusively from tblSwitch_pUnit_TRON_RND from here on out for all of our UV groupings, splits, etc.
INSERT INTO tblSwitch_pUnit_TRON_RND (pUnitID, OPID, Simplex, orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState,
shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName,
backName, numUnits, displayedQuantity, shipsWith, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, 
team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate,
switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_products, mo_orders, mo_customers, mo_customers_ShippingAddress, 
mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount,
fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, 
stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, 
stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, 
stockProductDescription6, front_UV, back_UV, env_productCode, env_productName, env_productQuantity,
env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, option_customEnvelope, customBackground, inserted_on)

SELECT 
CONVERT(NVARCHAR(10), ordersProductsID) + '.'  + CONVERT(NVARCHAR(5), productQuantity) + '.'  + REPLACE(packetValue, ' of ', '.'), 
ordersProductsID, 1,
orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, 
shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName,
backName, numUnits, displayedQuantity, shipsWith, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, 
team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate,
switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_products, mo_orders, mo_customers, mo_customers_ShippingAddress, 
mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount,
fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, 
stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3,
stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, 
stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, env_productCode, env_productName, env_productQuantity,
env_color, option_cause, option_customInside, option_envelope, option_cov, option_bak, option_customEnvelope, customBackground, GETDATE()
FROM tblSwitch_BCS_TRON
WHERE ordersProductsID NOT IN
	(SELECT OPID
	FROM tblSwitch_pUnit_TRON_RND)

-- update any missing packetValue data; this is legacy, we might decide to remove this if it is not doing anything, jf.
UPDATE tblSwitch_pUnit_TRON_RND
SET packetValue = CONVERT(NVARCHAR(10), SUBSTRING(pUnitID, LEN(pUnitID) - CHARINDEX('.', REVERSE(pUnitID))-1, 2)) + ' of ' + CONVERT(NVARCHAR(10), SUBSTRING(pUnitID, LEN(pUnitID) - CHARINDEX('.', REVERSE(pUnitID))+2, 2))
WHERE packetValue IS NULL

-- pUnit - Populate UV fields ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This is a fresh update (overwrite) in case UV values have changed for a given OPID (pUnit) since the last time this proc ran.
UPDATE tblSwitch_pUnit_TRON_RND
SET uv_class = 'YY',
	   uv_sort = 1
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE b.front_UV = 1
AND b.back_UV = 1
AND a.Simplex = 1
AND b.finishType <> 'ST'

UPDATE tblSwitch_pUnit_TRON_RND
SET uv_class = 'YN',
	   uv_sort = 2
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE b.front_UV = 1
AND b.back_UV = 0
AND a.Simplex = 1
AND b.finishType <> 'ST'

UPDATE tblSwitch_pUnit_TRON_RND
SET uv_class = 'NY',
	   uv_sort = 3
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE b.front_UV = 0
AND b.back_UV = 1
AND a.Simplex = 1
AND b.finishType <> 'ST'

UPDATE tblSwitch_pUnit_TRON_RND
SET uv_class = 'NN',
	   uv_sort = 4
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE b.front_UV = 0
AND b.back_UV = 0
AND a.Simplex = 1
AND b.finishType <> 'ST'

--ST
UPDATE tblSwitch_pUnit_TRON_RND
SET uv_class = 'NN',
	   uv_sort = 5
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE b.front_UV = 0
AND b.back_UV = 0
AND a.Simplex = 1
AND b.finishType = 'ST'

-- pUnit - Populate misc sort fields ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Resubmit
UPDATE tblSwitch_pUnit_TRON_RND
SET resubmit = 1
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE b.resubmit = 1
AND a.Simplex = 1

--expressProduction
UPDATE tblSwitch_pUnit_TRON_RND
SET expressProduction = 1
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
WHERE a.expressProduction = 0
AND b.expressProduction = 1
AND a.Simplex = 1

UPDATE tblSwitch_pUnit_TRON_RND
SET expressProduction = 1
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_TRON b ON a.OPID = b.ordersProductsID
INNER JOIN tblOrders o ON o.orderID = b.orderID
WHERE a.expressProduction = 0
AND a.Simplex = 1
AND o.shippingDesc IN ('3 Day Ground Shipping', '2 Day Air Shipping', 'Next Day Shipping', 'UPS Next Day Air Saver', 'UPS 2nd Day Air', 
										'3 Day Select', 'UPS Next Day Air', 'UPS 3 Day Select', 'FedEx', ' 2nd Day Air', ' Next Day Air', 'UPS Next Day Air Sat Delivery')

--if pUnit siblings exist, in which NEITHER OPID (sibling or self) has succesfully been submitted to switch =1, then reset split to "0" for all of those siblings involved. otherwise, the sort will go fubar.
UPDATE tblSwitch_pUnit_TRON_RND
SET split = 0
WHERE OPID IN
	(SELECT OPID 
	FROM tblSwitch_pUnit_TRON_RND
	WHERE split = 1
	AND submitted_to_switch = 0)
AND OPID IN
	(SELECT OPID 
	FROM tblSwitch_pUnit_TRON_RND
	WHERE split = 0
	AND submitted_to_switch = 0)

--If a split exists from a previous run, set expressProduction = 1 for that split so that it is brute-forced into production in the builds below
UPDATE tblSwitch_pUnit_TRON_RND
SET expressProduction = 1
WHERE split =1
AND submitted_to_switch = 0

-- UV ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Prep variables that calculate highest number of records per UV group that is divisible by six, because we want each grouping to be in multiples of six.
--@AB, where the "A" position = front_UV and the "B" position = back_UV. "Y" = yes; "N" = no.
-- Splits are included in the calculation now since we are pulling exclusively from tblSwitch_pUnit_TRON_RND rather than joining on BCD.

DECLARE @YY INT,
			    @YN INT,
				@NN INT,
				@ST INT,
				@SQLStatement NVARCHAR(MAX),
				@TOT INT = 0,
				@EXP INT = 0

--@YY ------------------------------------------------------------------------------------------
SET @YY = (SELECT COUNT(a.pUnitID) 
					  FROM tblSwitch_pUnit_TRON_RND a
					  WHERE a.uv_sort = 1
					  AND a.submitted_to_switch = 0)

IF @YY IS NULL
BEGIN
	SET @YY = 0
END

--07252019 BJS No need to stop these from flowing on through to the other side

--SET @YY = FLOOR(@YY/6)
--SET @YY = @YY * 6

IF @YY IS NULL
BEGIN
	SET @YY = 0
END

--@YN ------------------------------------------------------------------------------------------
-- in the case of @YN, we are now flipping the rare @NY to @YN, so this particular calculation looks at uv_sort = 2 or 3.
SET @YN = (SELECT COUNT(a.pUnitID) 
					  FROM tblSwitch_pUnit_TRON_RND a
					  WHERE a.uv_sort IN (2, 3)
					  AND a.submitted_to_switch = 0)

IF @YN IS NULL
BEGIN
	SET @YN = 0
END

--07252019 BJS No need to stop these from flowing on through to the other side

--SET @YN = FLOOR(@YN/6)
--SET @YN = @YN * 6

IF @YN IS NULL
BEGIN
	SET @YN = 0
END

--@NN ------------------------------------------------------------------------------------------
SET @NN = (SELECT COUNT(a.pUnitID) 
					  FROM tblSwitch_pUnit_TRON_RND a
					  WHERE a.uv_sort = 4
					  AND a.submitted_to_switch = 0)

IF @NN IS NULL
BEGIN
	SET @NN = 0
END

--07252019 BJS No need to stop these from flowing on through to the other side

--SET @NN = FLOOR(@NN/6)
--SET @NN = @NN * 6

IF @NN IS NULL
BEGIN
	SET @NN = 0
END

--@ST ------------------------------------------------------------------------------------------
SET @ST = (SELECT COUNT(a.pUnitID) 
					  FROM tblSwitch_pUnit_TRON_RND a
					  WHERE a.uv_sort = 5
					  AND a.submitted_to_switch = 0)

IF @ST IS NULL
BEGIN
	SET @ST = 0
END

--07252019 BJS No need to stop these from flowing on through to the other side

--SET @ST = FLOOR(@ST/6)
--SET @ST = @ST * 6

IF @ST IS NULL
BEGIN
	SET @ST = 0
END

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// INSERT FOR IMPO //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Now, insert valid pUNITs into table that we will work from to do counts; do this per UV grouping that are in multiples of six; defined above.
-- Each section below has multiple parts: (1) the regular import of six/group and (2) the additional splits that have yet to make their way into production and (3) the TOTs that are brute-forced in because time has elapsed beyond the threshold.

TRUNCATE TABLE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex

--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-
-- YY ++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-

IF @YY <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, 1
	FROM tblSwitch_pUnit_TRON_RND
	WHERE uv_sort = 1
	AND simplex = 1
	AND submitted_to_switch = 0
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, OPID, orderID, displayCount, packetValue'
	
	EXEC(@SQLStatement);
END

/*

								@TOT SECTION IS SKIPPED IN RND
								@EXP SECTION IS SKIPPED IN RND
															
									

-- Now, any OPIDs that do not exist in the output data (tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex), but surpass the time threshold, must be inserted despite any havoc it creates on the six/group work.
-- IF @TOT >= 1, then grab all.
SET @TOT = 0
SET @TOT = (SELECT COUNT(ID)
					FROM tblSwitch_OPID_TRON_RND a
					INNER JOIN tblSwitch_pUnit_TRON_RND b
						ON a.OPID = b.OPID
					WHERE b.uv_sort = 1
					AND b.submitted_to_switch = 0
					AND a.ThresholdOfTime IS NOT NULL
					AND b.pUnitID NOT IN
						(SELECT pUnitID
						FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @TOT IS NULL
BEGIN
	SET @TOT = 0
END

IF @TOT <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''TOT'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 1, 1
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort = 1
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END


--Exception Threshold: Brute force any pUnit that has been resubmitted or has been marked for expressProduction and still has not made it into tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex
--This still may happen despite @TOT bringing in all leftovers in a Threshold of Time event. If there is no @TOT, there still may be exceptions which need to come in.
--In this case, if there are exceptions that were not already prioritized in the first INSERT via ORDER BY (e.g., there are 7 exceptions and only 6 made it), bring in everything.
--Summing up: if @EXP >= 1, then grab all.

SET @EXP = 0
SET @EXP = (SELECT COUNT(ID)
						FROM tblSwitch_OPID_TRON_RND a
						INNER JOIN tblSwitch_pUnit_TRON_RND b
							ON a.OPID = b.OPID
						WHERE uv_sort = 1
						AND submitted_to_switch = 0
						AND (resubmit = 1 OR expressProduction = 1)
						AND pUnitID NOT IN
							(SELECT pUnitID
							FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @EXP IS NULL
BEGIN
	SET @EXP = 0
END

IF @EXP <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''Resub_ExpressProd'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 0, 1
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort = 1
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
*/

--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-
-- YN (and flipped NY) +-++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-

IF @YN <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, 2
	FROM tblSwitch_pUnit_TRON_RND
	WHERE uv_sort IN (2, 3)
	AND submitted_to_switch = 0
	AND simplex = 1
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
/*

								@TOT SECTION IS SKIPPED IN RND
								@EXP SECTION IS SKIPPED IN RND
															
									

-- Now, any OPIDs that do not exist in the output data (tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex), but surpass the time threshold, must be inserted despite any havoc it creates on the six/group work.
-- IF @TOT >= 1, then grab all.
SET @TOT = 0
SET @TOT = (SELECT COUNT(ID)
					FROM tblSwitch_OPID_TRON_RND a
					INNER JOIN tblSwitch_pUnit_TRON_RND b
						ON a.OPID = b.OPID
					WHERE b.uv_sort IN (2, 3)
					AND b.submitted_to_switch = 0
					AND a.ThresholdOfTime IS NOT NULL
					AND b.pUnitID NOT IN
						(SELECT pUnitID
						FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @TOT IS NULL
BEGIN
	SET @TOT = 0
END

IF @TOT <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''TOT'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 1, 2
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort IN (2, 3)
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END

--Exception Threshold: Brute force any pUnit that has been resubmitted or has been marked for expressProduction and still has not made it into tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex
--This still may happen despite @TOT bringing in all leftovers in a Threshold of Time event. If there is no @TOT, there still may be exceptions which need to come in.
--In this case, if there are exceptions that were not already prioritized in the first INSERT via ORDER BY (e.g., there are 7 exceptions and only 6 made it), bring in everything.
--Summing up: if @EXP >= 1, then grab all.

SET @EXP = 0
SET @EXP = (SELECT COUNT(ID)
						FROM tblSwitch_OPID_TRON_RND a
						INNER JOIN tblSwitch_pUnit_TRON_RND b
							ON a.OPID = b.OPID
						WHERE uv_sort IN (2, 3)
						AND submitted_to_switch = 0
						AND (resubmit = 1 OR expressProduction = 1)
						AND pUnitID NOT IN
							(SELECT pUnitID
							FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @EXP IS NULL
BEGIN
	SET @EXP = 0
END

IF @EXP <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''Resub_ExpressProd'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 0, 2
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort IN (2, 3)
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
*/
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-
-- NN ++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-

IF @NN <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, 4
	FROM tblSwitch_pUnit_TRON_RND
	WHERE uv_sort = 4
	AND submitted_to_switch = 0
	AND simplex = 1
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
/*

								@TOT SECTION IS SKIPPED IN RND
								@EXP SECTION IS SKIPPED IN RND
															
									

-- Now, any OPIDs that do not exist in the output data (tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex), but surpass the time threshold, must be inserted despite any havoc it creates on the six/group work.
SET @TOT = 0
SET @TOT = (SELECT COUNT(ID)
					FROM tblSwitch_OPID_TRON_RND a
					INNER JOIN tblSwitch_pUnit_TRON_RND b
						ON a.OPID = b.OPID
					WHERE b.uv_sort = 4
					AND b.submitted_to_switch = 0
					AND a.ThresholdOfTime IS NOT NULL
					AND b.pUnitID NOT IN
						(SELECT pUnitID
						FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @TOT IS NULL
BEGIN
	SET @TOT = 0
END

IF @TOT <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)
	
	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''TOT'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 1, 4
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort = 4
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END

--Exception Threshold: Brute force any pUnit that has been resubmitted or has been marked for expressProduction and still has not made it into tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex
--This still may happen despite @TOT bringing in all leftovers in a Threshold of Time event. If there is no @TOT, there still may be exceptions which need to come in.
--In this case, if there are exceptions that were not already prioritized in the first INSERT via ORDER BY (e.g., there are 7 exceptions and only 6 made it), bring in everything.
--Summing up: if @EXP >= 1, then grab all.

SET @EXP = 0
SET @EXP = (SELECT COUNT(ID)
						FROM tblSwitch_OPID_TRON_RND a
						INNER JOIN tblSwitch_pUnit_TRON_RND b
							ON a.OPID = b.OPID
						WHERE uv_sort = 4
						AND submitted_to_switch = 0
						AND (resubmit = 1 OR expressProduction = 1)
						AND pUnitID NOT IN
							(SELECT pUnitID
							FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @EXP IS NULL
BEGIN
	SET @EXP = 0
END

IF @EXP <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''Resub_ExpressProd'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 0, 4
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort = 4
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
*/
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-
-- ST ++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++-

IF @ST <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, split, 5
	FROM tblSwitch_pUnit_TRON_RND
	WHERE uv_sort = 5
	AND submitted_to_switch = 0
	AND simplex = 1
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
/*

								@TOT SECTION IS SKIPPED IN RND
								@EXP SECTION IS SKIPPED IN RND
															
									

-- Now, any OPIDs that do not exist in the output data (tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex), but surpass the time threshold, must be inserted despite any havoc it creates on the six/group work.
SET @TOT = 0
SET @TOT = (SELECT COUNT(ID)
					FROM tblSwitch_OPID_TRON_RND a
					INNER JOIN tblSwitch_pUnit_TRON_RND b
						ON a.OPID = b.OPID
					WHERE b.uv_sort = 5
					AND b.submitted_to_switch = 0
					AND a.ThresholdOfTime IS NOT NULL
					AND b.pUnitID NOT IN
						(SELECT pUnitID
						FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @TOT IS NULL
BEGIN
	SET @TOT = 0
END

IF @TOT <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''TOT'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 1, 5
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort = 5
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END

--Exception Threshold: Brute force any pUnit that has been resubmitted or has been marked for expressProduction and still has not made it into tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex
--This still may happen despite @TOT bringing in all leftovers in a Threshold of Time event. If there is no @TOT, there still may be exceptions which need to come in.
--In this case, if there are exceptions that were not already prioritized in the first INSERT via ORDER BY (e.g., there are 7 exceptions and only 6 made it), bring in everything.
--Summing up: if @EXP >= 1, then grab all.

SET @EXP = 0
SET @EXP = (SELECT COUNT(ID)
						FROM tblSwitch_OPID_TRON_RND a
						INNER JOIN tblSwitch_pUnit_TRON_RND b
							ON a.OPID = b.OPID
						WHERE uv_sort = 5
						AND submitted_to_switch = 0
						AND (resubmit = 1 OR expressProduction = 1)
						AND pUnitID NOT IN
							(SELECT pUnitID
							FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex))

IF @EXP IS NULL
BEGIN
	SET @EXP = 0
END

IF @EXP <> 0
BEGIN
	SET @SQLStatement = N'
	INSERT INTO tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex (orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, ThresholdOfTime, sortOrder)

	SELECT orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, t.OPID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, ''Resub_ExpressProd'' AS team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, expressProduction, pUnitID, 0, 5
	FROM tblSwitch_pUnit_TRON_RND t
	WHERE uv_sort = 5
	AND submitted_to_switch = 0
	AND pUnitID NOT IN
		(SELECT pUnitID
		FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
	ORDER BY split DESC, resubmit DESC, expressProduction DESC, t.OPID, orderID, displayCount, packetValue'

	EXEC(@SQLStatement);
END
*/
/* There is no FPLEX IN SIMPLEX
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// ID & FLIP FPLEX IMAGES //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- First, update simplex/Simplex in ThresholdDiff.
UPDATE a
SET simplex = 1
FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a
INNER JOIN tblSwitch_pUnit_TRON_RND b ON a.pUnitID = b.pUnitID
WHERE b.simplex = 1

UPDATE a
SET Simplex = 1
FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a
INNER JOIN tblSwitch_pUnit_TRON_RND b ON a.pUnitID = b.pUnitID
WHERE b.Simplex = 1

-- Next, ID the fPlex values.
UPDATE a
SET fPlex = 1
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex b ON a.pUnitID = b.pUnitID
WHERE a.simplex = 1
AND a.fPlex = 0

UPDATE a
SET fplex = 1
FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a
INNER JOIN tblSwitch_pUnit_TRON_RND b ON a.pUnitID = b.pUnitID
WHERE b.fplex = 1

--In regards to @NY, which has been rolled into the @YN portion of the flow, flip the image because we are going to run the @NY backwards, so that when looking at @NY, the back is now the front. 
--first, flip it and put into tblSwitch_pUnit_TRON_RND and then set isFlipped = 1
UPDATE tblSwitch_pUnit_TRON_RND
SET isFlipped = 1,
		variableWholeName = b.backName,
		backName = b.variableWholeName
FROM tblSwitch_pUnit_TRON_RND a
INNER JOIN tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex b ON a.pUnitID = b.pUnitID
WHERE a.uv_sort = 3

--now, the images in tblSwitch_pUnit_TRON_RND are correctly flipped for @NYs.
--next, update tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex with the correctly flipped values from tblSwitch_pUnit_TRON_RND and then set isFlipped = 1
UPDATE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex
SET isFlipped = 1,
		variableWholeName = b.variableWholeName,
		backName = b.backName
FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a
INNER JOIN tblSwitch_pUnit_TRON_RND b ON a.pUnitID = b.pUnitID
WHERE b.uv_sort = 3

--set blank backs to correct value 'blank.pdf'
UPDATE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex SET backName = 'blank.pdf' WHERE backName = '' AND fPlex = 1
UPDATE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex SET backName = 'blank.pdf' WHERE backName = '.pdf' AND fPlex = 1
UPDATE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex SET variableWholeName = 'blank.pdf' WHERE variableWholeName = '.pdf' AND fPlex = 1
UPDATE tblSwitch_pUnit_TRON_RND SET backName = 'blank.pdf' WHERE backName = '.pdf' AND fPlex = 1
UPDATE tblSwitch_pUnit_TRON_RND SET variableWholeName = 'blank.pdf' WHERE variableWholeName = '.pdf' AND fPlex = 1

UPDATE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex SET backName = '' WHERE backName = '.pdf' AND fPlex = 0
UPDATE tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex SET variableWholeName = '' WHERE variableWholeName = '.pdf' AND fPlex = 0
UPDATE tblSwitch_pUnit_TRON_RND SET backName = '' WHERE backName = '.pdf' AND fPlex = 0
UPDATE tblSwitch_pUnit_TRON_RND SET variableWholeName = '' WHERE variableWholeName = '.pdf' AND fPlex = 0
*/
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////// OUTPUT //////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Mark splits in tblSwitch_OPID_TRON_RND for next run. This is determined by the presence of an OPID in Threshold, but its pUnitID counterpart not being there. Its sibling made it, but it didn't, therefore, it's a split.
UPDATE tblSwitch_pUnit_TRON_RND
SET split = 1
WHERE split = 0
AND OPID IN
	(SELECT ordersProductsID
	FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)
AND pUnitID NOT IN
	(SELECT pUnitID
	FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex)

-- Update OPID status fields indicating successful submission to switch
UPDATE tblOrders_Products
SET switch_create = 1,
	   fastTrak_status = 'In Production',
	   fastTrak_status_lastModified = GETDATE(),
	   fastTrak_resubmit = 0
FROM tblOrders_Products op
INNER JOIN tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex t ON op.ID = t.ordersProductsID

-- Update pUNIT status indicating successful submission to switch
UPDATE tblSwitch_pUnit_TRON_RND
SET submitted_to_switch = 1,
	   submitted_to_switch_on = GETDATE()
FROM tblSwitch_pUnit_TRON_RND p
INNER JOIN tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex t ON p.pUnitID = t.pUnitID

---- Log data that is being presented to Switch, which we can reference in case of issues.
--INSERT tblSwitch_BC_LOG_TRON (PKID, orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit01, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, front_UV, back_UV, customBackground, sortOrder, resubmit, split, expressProduction, pUnitID, dataVersion, logDate, ThresholdOfTime)
--SELECT a.PKID, a.orderID, a.orderNo, a.orderDate, a.customerID, a.shippingAddressID, a.shipCompany, a.shipFirstName, a.shipLastName, a.shipAddress1, a.shipAddress2, a.shipCity, a.shipState, a.shipZip, a.shipCountry, a.shipPhone, a.productCode, a.productName, a.shortName, a.productQuantity, a.packetValue, a.variableTopName, a.variableBottomName, a.variableWholeName, a.backName, a.numUnits, a.displayedQuantity, a.ordersProductsID, a.shipsWith, a.resubmit, a.shipType, a.samplerRequest, a.multiCount, a.totalCount, a.displayCount, a.background, a.templateFile, a.team1FileName, a.team2FileName, a.team3FileName, a.team4FileName, a.team5FileName, a.team6FileName, a.groupID, a.productID, a.parentProductID, a.switch_create, a.switch_createDate, a.switch_approve, a.switch_approveDate, a.switch_print, a.switch_printDate, a.switch_import, a.mo_orders_Products, a.mo_orders, a.mo_customers, a.mo_customers_ShippingAddress, a.mo_oppo, a.customProductCount, a.customProductCode1, a.customProductCode2, a.customProductCode3, a.customProductCode4, a.fasTrakProductCount, a.fasTrakProductCode1, a.fasTrakProductCode2, a.fasTrakProductCode3, a.fasTrakProductCode4, a.stockProductCount, a.stockProductQuantity1, a.stockProductCode1, a.stockProductDescription1, a.stockProductQuantity2, a.stockProductCode2, a.stockProductDescription2, a.stockProductQuantity3, a.stockProductCode3, a.stockProductDescription3, a.stockProductQuantity4, a.stockProductCode4, a.stockProductDescription4, a.stockProductQuantity5, a.stockProductCode5, a.stockProductDescription5, a.stockProductQuantity6, a.stockProductCode6, a.stockProductDescription6, a.front_UV, a.back_UV, a.customBackground, a.sortOrder, a.resubmit, a.split, a.expressProduction, a.pUnitID, 'Simplex - TRON - RND', GETDATE(), a.ThresholdOfTime
--FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a
--ORDER BY PKID

--Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'BC_Simplex_TRON_RND'
,a.PKID
,a.ordersProductsID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex b
       where a.PKID = b.PKID
       for json path)
from tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a

--Set flag back to '0'.
UPDATE Flags
SET FlagStatus = 0
WHERE FlagName = 'Switch_BC_Simplex_TRON'

--Set switch flag to "1", which will get reset at the end of the flow by [usp_Switch_updateToProduction]
UPDATE Flags
SET FlagStatus = 1
WHERE FlagName = 'Switch_BC_TRON_RND'

-- Output Simplex data for Switch use.
SELECT a.PKID, a.orderID, a.orderNo, a.orderDate, a.customerID, a.shippingAddressID, a.shipCompany, a.shipFirstName, a.shipLastName, a.shipAddress1, a.shipAddress2, a.shipCity, a.shipState, a.shipZip, a.shipCountry, a.shipPhone, a.productCode, a.productName, a.shortName, a.productQuantity, a.packetValue, a.variableTopName, a.variableBottomName, a.variableWholeName, a.backName, a.numUnits, a.displayedQuantity, a.ordersProductsID, a.shipsWith, a.resubmit, a.shipType, a.samplerRequest, a.multiCount, a.totalCount, a.displayCount, a.background, a.templateFile, a.team1FileName, a.team2FileName, a.team3FileName, a.team4FileName, a.team5FileName, a.team6FileName, a.groupID, a.productID, a.parentProductID, a.switch_create, a.switch_createDate, a.switch_approve, a.switch_approveDate, a.switch_print, a.switch_printDate, a.switch_import, a.mo_orders_Products, a.mo_orders, a.mo_customers, a.mo_customers_ShippingAddress, a.mo_oppo, a.customProductCount, a.customProductCode1, a.customProductCode2, a.customProductCode3, a.customProductCode4, a.fasTrakProductCount, a.fasTrakProductCode1, a.fasTrakProductCode2, a.fasTrakProductCode3, a.fasTrakProductCode4, a.stockProductCount, a.stockProductQuantity1, a.stockProductCode1, a.stockProductDescription1, a.stockProductQuantity2, a.stockProductCode2, a.stockProductDescription2, a.stockProductQuantity3, a.stockProductCode3, a.stockProductDescription3, a.stockProductQuantity4, a.stockProductCode4, a.stockProductDescription4, a.stockProductQuantity5, a.stockProductCode5, a.stockProductDescription5, a.stockProductQuantity6, a.stockProductCode6, a.stockProductDescription6, a.front_UV, a.back_UV, a.customBackground, a.sortOrder, a.resubmit, a.split, a.expressProduction, a.pUnitID, 'TRON', a.ThresholdOfTime, a.simplex, a.Simplex, a.fplex, a.isFlipped
FROM tblSwitch_BCS_ThresholdDiff_TRON_RND_Simplex a
ORDER BY PKID

--Run BCD_RND now, regardless of what happened with BCS_RND. This preserves the order of BCS > BCD.
UPDATE tblSwitchControl
SET controlStatus = 1
WHERE controlName = 'IMPO_BCD_RND'

--END