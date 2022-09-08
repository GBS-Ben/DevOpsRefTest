---------------------------------------
CREATE PROCEDURE [dbo].[ImposerNC] @PLEX INT
AS
/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		08/22/18
Purpose		Creates data for Imposer, Notecards.
					@PLEX: 1 = simplex; 2 = duplex
					with notecards, "duplex" refers to presence of greeting image.
					
					EXEC ImposerNC 1
					EXEC ImposerNC 2
-------------------------------------------------------------------------------
Modification History

08/22/18	Created, jf.
10/17/18	Updated throughout, added @Plex 1 and 2 factors in inline notes, jf.'
10/17/18	Added x.ignoreCheck = 0 to x.fileExists = 0 check, jf.
10/19/18	Added: EXEC usp_OPPO_validateFile 'NC'; jf.
10/25/18	Added Logging, ImpositionID work, jf.
11/12/18	Added Reporting, jf.
11/26/18	Under Development on multijag, jf.
11/28/18	Finished Jag, jf.
04/27/21	CKB, Markful
********************************** RELEASE NOTES **********************************

11/26/18	this is the latest build but is awaiting the multijag work to be completed. details of the build are below and the two sections that are under development are noted within the code below by (#UNDER DEVELOPMENT) tags

--TERMINOLOGY-------

EXPOSUB - opid that has been expedited or resubbed
STANDARD - everything else
BatchID - this id groups together a set of opid(s) that comprise a batch within the imposition. Once defined, the batch will be jagged.
Jag - this is the process of splitting a batch in half and interpolating rows (e.g., a batch of 50 would look like [1, 26, 2, 27, ..., 24, 49, 25, 50])

--SHEET LIMIT-------

TEST	150
LIVE	3000

--CAVITY GROUPS-----

UNDER -- BETWEEN 0 and 74 (0 and 999 in live)
SOLO - BETWEEN 75 and 150 cavities (1000 and 1300 in live)
OVER - GREATER THAN 150 cavities or more (1300 or more in live)

--TEST ENVIRO-------		--LIVE ENVIRO-------		
UNDER	0		74			UNDER	0		999
SOLO	75		150			SOLO	1000	1300
OVER	151		...			OVER	1301	...

--POSSIBLE BATCH TYPES-------
(based on above logic)

sort, priority asc:

01. EXPOSUB UNDER
02. EXPOSUB SOLO
03. STANDARD UNDER
04. STANDARD SOLO
05. EXPOSUB OVER
06. STANDARD OVER

--BATCHES -------------

01. EXPOSUB UNDER | add cavities for "unders" that are exposubs.

	- a1. retrieve top 1 exposub opid that is an "under" with smallest JagQTY where BatchID is NULL
	- b1. if this is the first opid, set @BatchID=1 and add the cavities (the first opid will not exceed batch limit since it is an "under")
	- b2. if this is not the first "under" exposub opid added then:
			- b.2a first check to see if by adding this opid, current batch doesn't go over batch limit. 
					- b.2a1 If it doesn't go over batch limit, add opid.
					- b.2a2 If it does go over batch limit, set @BatchID = @BatchID + 1, add this opid to the new batch
	- c1. are there more "under" exposubs that have not been added to a batch yet?
		- if yes; return to a1.
		- if no; move to step 2.

02. EXPOSUB SOLO | add cavities for "solos" that are exposubs, if they can fit on existing batch.

	- d1. retrieve top 1 exposub opid that is a "solo" with smallest JagQTY where BatchID is NULL
	- e1. if this is the first opid, set @BatchID=1 and add the cavities (unlikely event, since it would mean that there were zero "unders")
	- e2. if this is not the first "solo" exposub opid added then:
			- e.2a first check to see if by adding this opid, current batch doesn't go over batch limit. 
					- e.2a1 If it doesn't go over batch limit, add opid.
					- e.2a2 If it does go over batch limit, set @BatchID = @BatchID + 1, add this opid to the new batch
	- f1. are there more "solo" exposubs that have not been added to a batch yet?
		- if yes; return to d1.
		- if no; move to step 3.

03. STANDARD UNDER | add cavities for standard "unders"
	- g1. retrieve standard "under" opid with smallest JagQTY where BatchID is NULL
	- h1. if this is the first opid, set @BatchID=1 and add the cavities (the first opid will not exceed batch limit since it is an "under")
	- h2. if this is not the first "under" added then:
			- h.2a first check to see if by adding this opid, current batch doesn't go over batch limit. 
					- h.2a1 If it doesn't go over batch limit, add opid.
					- h.2a2 If it does go over batch limit, set @BatchID = @BatchID + 1, add this opid to the new batch
	- I1. are there more "unders" that have not been added to a batch yet?
		- if yes; return to a1.
		- if no; move to step 2.

04. STANDARD SOLO | add cavities for "solos" that are "standards", if they can fit on existing batch.

	- d1. retrieve top 1 exposub opid that is a "solo" with smallest JagQTY where BatchID is NULL
	- e1. if this is the first opid, set @BatchID=1 and add the cavities (unlikely event, since it would mean that there were zero "unders")
	- e2. if this is not the first "solo" exposub opid added then:
			- e.2a first check to see if by adding this opid, current batch doesn't go over batch limit. 
					- e.2a1 If it doesn't go over batch limit, add opid.
					- e.2a2 If it does go over batch limit, set @BatchID = @BatchID + 1, add this opid to the new batch
	- f1. are there more "solo" exposubs that have not been added to a batch yet?
		- if yes; return to d1.
		- if no; move to step 3.

05. EXPOSUB OVER | add cavities for "overs" that are exposubs.
06. STANDARD OVER | add cavities for "overs" that are standards.

****************************** RELEASE NOTES END *******************************

-------------------------------------------------------------------------------
*/
BEGIN TRY 
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ESTABLISH TEST DATA
DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

--DECLARE @PLEX INT = 1 -- uncomment for testing
IF OBJECT_ID('tempdb..#ImposerNCTestOPIDs') IS NOT NULL DROP TABLE #ImposerNCTestOPIDs
CREATE TABLE #ImposerNCTestOPIDs(
	OPID INT NOT NULL)

INSERT INTO #ImposerNCTestOPIDs (OPID)
VALUES 

--SIMPLEX (18)
(555474521),(555474532),(555474533),(555474536),(555474537),(555474538),(555474539),
(555474542),(555474544),(555474553),(555474554),(555474556),(555474559),(555474560),
(555474561),(555474562),(555474564),(555474565)

--DUPLEX (31)
,(555478126), (555478158), (555478146), (555478129), (555478135), (555478155), (555478124), 
(666560265), (555478130), (555478144), (555478127), (666560268), (555478141), (555478147), 
(555478145), (555478128), (555478162), (666560271), (555478148), (555478125), (555478119), 
(555478120), (555478134), (555478154), (666560269), (555478123), (555478157), (666560266), 
(666560272), (555478131), (555478137)

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CREATE MAIN QUERY

IF OBJECT_ID('tempdb..#tempImposerNCMain') IS NOT NULL 
DROP TABLE #tempImposerNCMain

CREATE TABLE #tempImposerNCMain (
			 OrderNo NVARCHAR(50)
			,OrderID INT
			,OPID INT
			,OutputName NVARCHAR(100)
			,Barcode NVARCHAR(50)
			,Quantity NVARCHAR(100)
			,ShipColor NVARCHAR(100)
			,ShipsWith NVARCHAR(100)
			,ShipsWithAlt NVARCHAR(100)
			,Resubmit BIT DEFAULT ((0))
			,Expedite BIT DEFAULT ((0))
			,GroupID INT
			,ShipLine1 NVARCHAR(255)
			,ShipLine2 NVARCHAR(255)
			,ShipLine3 NVARCHAR(255)
			,ShipLine4 NVARCHAR(255)
			,ShipLine5 NVARCHAR(255)
			,ShipType NVARCHAR(50)
			,StoreLogo NVARCHAR(50)
			,UV INT
			,ShipZone NCHAR(9))

INSERT INTO #tempImposerNCMain (OrderNo, OrderID, OPID, OutputName, BarCode, Quantity, ShipColor, ShipsWith, ShipsWithAlt, Resubmit, GroupID, ShipLine1, ShipLine2, ShipLine3, ShipLine4, ShipLine5, ShipType, StoreLogo, UV, ShipZone)
SELECT o.orderNo, o.orderID, op.ID, 
CONVERT(NVARCHAR(50), op.ID) + '-tkt.pdf' AS outputName,
'*ON' + CONVERT(NVARCHAR(50), o.orderNo) + '*' AS barcode, 
CASE 
		  WHEN op.fastTrak_resubmit = 1 THEN 'Quantity: ' + CONVERT(NVARCHAR(50), ISNULL(op.fastTrak_newQTY, op.productQuantity))
		  ELSE 'Quantity: ' + CONVERT(NVARCHAR(50), op.productQuantity)
END AS quantity,
'' AS shipColor, 'Ship' AS shipsWith, '' AS shipsWithAlt, op.fastTrak_resubmit, op.groupID,
RTRIM(REPLACE(ISNULL(s.shipping_Firstname, '') + ' ' + ISNULL(s.shipping_surName, ''), '  ', ' ')) AS shipLine1,
RTRIM(ISNULL(s.shipping_Street, '') + ' ' + ISNULL(s.shipping_Street2, '')) AS shipLine2,
RTRIM(ISNULL(s.shipping_Suburb, '') + ', ' + ISNULL(s.shipping_State, '') + ' ' + ISNULL(s.shipping_PostCode, '')) AS shipLine3,
s.shipping_Country AS shipLine4, s.shipping_Phone AS shipLine5, 
CASE WHEN CONVERT(NVARCHAR(255), o.shippingDesc) LIKE '%3 Day%' THEN '3 Day'
						WHEN CONVERT(NVARCHAR(255), o.shippingDesc) LIKE '%2%Day%' THEN '2 Day'
						WHEN CONVERT(NVARCHAR(255), o.shippingDesc) LIKE '%Next%' THEN 'Next Day'
						ELSE ''
			END AS shipType,
CASE WHEN SUBSTRING(o.orderNo, 1, 3) IN ('HOM','MRK') THEN 'MRKLogo.pdf'
						WHEN SUBSTRING(o.orderNo, 1, 3) = 'NCC' THEN 'NCCLogo.pdf'
						ELSE 'MRKLogo.pdf'
			END AS storeLogo,
2 AS UV, 
'zone' + CONVERT(NCHAR(1), ISNULL(o.shipZone, 0)) + '.pdf' AS shipZone
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblCustomers_ShippingAddress s ON o.orderNo = s.orderNo
WHERE

--A. Order Qualification

DATEDIFF(MI, o.created_on, GETDATE()) > 10
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Waiting For Payment', 'Waiting On Customer', 'Waiting For New Art', 'GTG-Waiting For Payment')
AND o.displayPaymentStatus = 'Good'

--B. Product Qualification

AND SUBSTRING(op.productCode, 1, 2) = 'NC'
AND SUBSTRING(op.productCode, 3, 2) <> 'EV'

--C. OPID Qualification

AND op.processType = 'fasTrak'
AND op.deleteX <> 'yes'															
AND (
		--C1
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		--C2
		OR op.fastTrak_status = 'Good to Go'
		--C3
		OR op.fastTrak_resubmit = 1
		--C4
		OR op.ID IN (SELECT OPID FROM #ImposerNCTestOPIDs) -- REMOVE WHEN DONE TESTING **********************TESTING*********************	 
		)

--D. Canvas Qualification

AND (op.ID IN
				(SELECT ordersProductsID
				FROM tblOrdersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionID = 535)
			OR op.ID IN (SELECT OPID FROM #ImposerNCTestOPIDs) -- REMOVE WHEN DONE TESTING **********************TESTING*********************		
				)

--E. Source Qualification (NCC or Market Center?)

AND (SUBSTRING(o.orderNo, 1, 3) = 'NCC'
		OR
		SUBSTRING(o.orderNo, 1, 3) IN ('HOM' ,'MRK')
		AND
		op.ID IN
				(SELECT ordersProductsID
				FROM tblordersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionID = 562)
		OR op.ID IN (SELECT OPID FROM #ImposerNCTestOPIDs) -- REMOVE WHEN DONE TESTING **********************TESTING************************		
				)

--F. Testing Section -------------------------------

AND op.ID IN (SELECT OPID FROM #ImposerNCTestOPIDs) -- REMOVE WHEN DONE TESTING **********************TESTING****************************		
ORDER BY o.OrderID, op.ID

--EXPEDITE ----------------------

UPDATE a
SET Expedite =  1
FROM #tempImposerNCMain a
INNER JOIN tblOrders o ON a.orderID = o.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE o.shippingDesc IN ('3 Day Ground Shipping', '2 Day Air Shipping', 'Next Day Shipping', 'UPS Next Day Air Saver', 'UPS 2nd Day Air', 
											   '3 Day Select', 'UPS Next Day Air', 'UPS 3 Day Select', 'FedEx', ' 2nd Day Air', ' Next Day Air', 'UPS Next Day Air Sat Delivery')
OR
(oppo.deleteX <> 'yes' AND optionCaption = 'Express Production') 

--SELECT  '#ImposerNCTestOPIDs', * FROM    #ImposerNCTestOPIDs
--SELECT  '#tempImposerNCMain', * FROM    #tempImposerNCMain

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FLAG

-- Flags
DECLARE @Flag BIT
SET @Flag = (SELECT FlagStatus FROM Flags WHERE FlagName = 'ImposerNCTickets')
					   
--IF @Flag = 0
--BEGIN

UPDATE Flags
SET FlagStatus = 1
WHERE FlagName = 'ImposerNCTickets'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FILE EXISTS

--First, validate image files
EXEC usp_OPPO_validateFile 'NC'

-- For any OPID that is missing an image, send an email
IF OBJECT_ID('tempdb..#tempPSUFileCheckImposerNC') IS NOT NULL 
DROP TABLE #tempPSUFileCheckImposerNC

CREATE TABLE #tempPSUFileCheckImposerNC (
RowID INT IDENTITY(1, 1), 
FILE_EXISTS_ROWID INT, 
OPID INT)

DECLARE @FILE_EXISTS_ROWID INT,
				 @OPIDX INT,
				 @NumberRecords_x INT, 
				 @RowCount_x INT

INSERT INTO #tempPSUFileCheckImposerNC (FILE_EXISTS_ROWID, OPID)
SELECT x.rowID, t.OPID
FROM tblOPPO_fileExists x 
INNER JOIN #tempImposerNCMain t ON x.OPID = t.OPID
WHERE x.fileExists = 0
AND x.ignoreCheck = 0
ORDER BY x.rowID, t.OPID

--send email
SET @NumberRecords_x = @@ROWCOUNT
SET @RowCount_x = 1

WHILE @RowCount_x <= @NumberRecords_x
BEGIN
	 SELECT @FILE_EXISTS_ROWID = FILE_EXISTS_ROWID,
				   @OPIDX = OPID
	 FROM #tempPSUFileCheckImposerNC
	 WHERE RowID = @RowCount_x

	 EXEC usp_OPPO_fileExist_sendEmail_TestOnly @FILE_EXISTS_ROWID, @OPIDX --CHANGE SPROC NAME WHEN DONE TESTING*********************

SET @RowCount_x = @RowCount_x + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// TICKETS

TRUNCATE TABLE ImposerNCTickets

IF @PLEX IS NULL OR @PLEX <> 2
BEGIN
	SET @PLEX = 1
END

--currently, simplex notecards are defined by two factors: (1) the ABSENCE of a greeting or "inside intranet pdf" which goes into Surface2 and (2) the PRESENCE of the "Add Greeting" optionCaption with textValue of "No".
IF @PLEX = 1
BEGIN
		INSERT INTO ImposerNCTickets (OrderNo, OrderID, OPID, OutputName, BarCode, Quantity, ShipColor, ShipsWith, ShipsWithAlt, Resubmit, Expedite, GroupID, ShipLine1, ShipLine2, ShipLine3, ShipLine4, ShipLine5, ShipType, StoreLogo, UV, ShipZone)
		SELECT DISTINCT t.OrderNo, t.OrderID, t.OPID, t.OutputName, t.BarCode, t.Quantity, t.ShipColor, t.ShipsWith, t.ShipsWithAlt, t.Resubmit, t.Expedite, t.GroupID, t.ShipLine1, t.ShipLine2, t.ShipLine3, t.ShipLine4, t.ShipLine5, t.ShipType, t.StoreLogo, t.UV, t.ShipZone
		FROM tblOPPO_fileExists x 
		INNER JOIN #tempImposerNCMain t ON t.OPID = x.OPID
		WHERE x.fileExists = 1
		AND x.ignoreCheck = 0
		AND t.OPID NOT IN
			(SELECT ordersProductsID
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.optionCaption IN ('Greeting', 'Inside Intranet PDF'))
		AND t.OPID IN
			(SELECT ordersProductsID
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.optionCaption = 'Add Greeting'
			AND oppo.textValue = 'No')
		ORDER BY t.resubmit DESC, t.expedite DESC, t.OrderID, t.OPID
END

--currently, duplex notecards are defined by one factor: (1) the PRESENCE of a greeting or "inside intranet pdf" which goes into Surface 2.
IF @PLEX = 2
BEGIN
		INSERT INTO ImposerNCTickets (OrderNo, OrderID, OPID, OutputName, BarCode, Quantity, ShipColor, ShipsWith, ShipsWithAlt, Resubmit, Expedite, GroupID, ShipLine1, ShipLine2, ShipLine3, ShipLine4, ShipLine5, ShipType, StoreLogo, UV, ShipZone)
		SELECT DISTINCT t.OrderNo, t.OrderID, t.OPID, t.OutputName, t.BarCode, t.Quantity, t.ShipColor, t.ShipsWith, t.ShipsWithAlt, t.Resubmit, t.Expedite, t.GroupID, t.ShipLine1, t.ShipLine2, t.ShipLine3, t.ShipLine4, t.ShipLine5, t.ShipType, t.StoreLogo, t.UV, t.ShipZone
		FROM tblOPPO_fileExists x 
		INNER JOIN #tempImposerNCMain t ON t.OPID = x.OPID
		WHERE x.fileExists = 1
		AND x.ignoreCheck = 0
		AND t.OPID IN
			(SELECT ordersProductsID
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.optionCaption IN ('Greeting', 'Inside Intranet PDF'))
		ORDER BY t.resubmit DESC, t.expedite DESC, t.OrderID, t.OPID
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// IMAGERY

--SURFACE 1 ----------------------------------------------------------------------------------------------------

UPDATE a
SET Surface1 = CASE WHEN oppo.TextValue LIKE '%/%' THEN REPLACE((RIGHT(REPLACE(oppo.textValue, @UncBasePath, ''), CHARINDEX('/', REVERSE(REPLACE(oppo.textValue, @UncBasePath, ''))))), '/', '')
								ELSE REPLACE(oppo.textValue, @UncBasePath, '')
							END
FROM ImposerNCTickets a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.optionCaption IN ('Card Front', 'Intranet PDF')
AND oppo.deleteX <> 'yes'

--SURFACE 2 ----------------------------------------------------------------------------------------------------

UPDATE a
SET Surface2 = CASE WHEN oppo.TextValue LIKE '%/%' THEN REPLACE((RIGHT(REPLACE(oppo.textValue, @UncBasePath, ''), CHARINDEX('/', REVERSE(REPLACE(oppo.textValue, @UncBasePath, ''))))), '/', '')
								ELSE REPLACE(oppo.textValue, @UncBasePath, '')
							END
FROM ImposerNCTickets a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.optionCaption IN ('Greeting', 'Inside Intranet PDF')
AND oppo.deleteX <> 'yes'

--SURFACE 3 ----------------------------------------------------------------------------------------------------

UPDATE a
SET Surface3 = CASE WHEN oppo.TextValue LIKE '%/%' THEN REPLACE((RIGHT(REPLACE(oppo.textValue, @UncBasePath, ''), CHARINDEX('/', REVERSE(REPLACE(oppo.textValue, @UncBasePath, ''))))), '/', '')
								ELSE REPLACE(oppo.textValue, @UncBasePath, '')
							END
FROM ImposerNCTickets a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.optionCaption IN ('Card Back', 'Back Intranet PDF')
AND oppo.deleteX <> 'yes'

--AUXILIARY ----------------------------------------------------------------------------------------------------

UPDATE a
SET AuxiliaryText = op.productName,
Surface3 = REPLACE(obbo.textValue, @UncBasePath, ''),
Surface2 = REPLACE(op.productCode, 'CU', '') + CASE 
													WHEN obbo.OptionCaption = 'Envelope Front' THEN '.Front.pdf' 
													WHEN obbo.OptionCaption = 'Envelope Back' THEN '.Back.pdf'
													ELSE '.Front.pdf' 
												END
FROM ImposerNCTickets a
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON a.OPID = CONVERT(INT, oppo.textValue)
LEFT JOIN tblOrdersProducts_productOptions obbo ON op.ID = CONVERT(INT, obbo.ordersProductsID) AND obbo.optionCaption IN ('Envelope Front', 'Envelope Back')
WHERE oppo.ordersProductsID <> a.OPID
AND op.ID <> a.OPID
AND oppo.optionID = 514
AND op.ID = oppo.ordersProductsID

UPDATE a
SET Surface2 = REPLACE(op.productCode, 'CU', '') + '.Front.pdf',
AuxiliaryText = op.productName
FROM ImposerNCTickets a
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON a.OPID = CONVERT(INT, oppo.textValue)
LEFT JOIN tblOrdersProducts_productOptions obbo ON op.ID = CONVERT(INT, obbo.ordersProductsID) AND obbo.optionCaption IN ('Envelope Front', 'Envelope Back')
WHERE oppo.ordersProductsID <> a.OPID
AND op.ID <> a.OPID
AND oppo.optionID = 514
AND op.ID = oppo.ordersProductsID

UPDATE a
SET Surface2 = REPLACE(op.productCode, 'CU', '') + '.Front.pdf',
AuxiliaryText = op.productName
FROM ImposerNCTickets a
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
WHERE SUBSTRING(op.productCode, 3, 2) = 'EV'
AND a.groupID = op.groupID 
AND op.deleteX <> 'yes'
AND SUBSTRING(a.orderNo, 1, 3) IN ('HOM' ,'MRK')
AND a.groupID <> 0

UPDATE ImposerNCTickets
SET Surface2 = 'NCEVW6-001.Front.pdf',
AuxiliaryText = 'White A6 Envelopes (NCEVW6-001)'
WHERE Surface2 IS NULL
AND SUBSTRING(orderNo, 1, 3) IN ('HOM' ,'MRK') 

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  OPID COUNTS

--pUNIT COUNT ----------------------

UPDATE a
SET pUnitCount = b.pUnitCount
FROM ImposerNCTickets a 
INNER JOIN (SELECT PKID, 'Packet ' + CONVERT(NVARCHAR(10), ROW_NUMBER() OVER(PARTITION BY OPID ORDER BY PKID)) + ' of ' + CONVERT(NVARCHAR(10), COUNT(OPID) OVER(PARTITION BY OPID)) AS pUnitCount 
					  FROM ImposerNCTickets) b 
ON a.PKID = b.PKID 

--PRODUCT COUNT ----------------------

UPDATE a
SET ProductCount = b.ProductCount
FROM ImposerNCTickets a 
INNER JOIN (SELECT PKID, 'Product ' + CONVERT(NVARCHAR(10), ROW_NUMBER() OVER(PARTITION BY orderID ORDER BY OPID)) + ' of ' + CONVERT(NVARCHAR(10), COUNT(orderID) OVER(PARTITION BY orderID)) AS ProductCount
					  FROM ImposerNCTickets) b 
ON a.PKID = b.PKID 

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  SHIPPING

--CUSTOM ----------------------

UPDATE a
SET ShipsWith = 'Custom'
FROM ImposerNCTickets a
INNER JOIN tblOrders_Products op ON a.OrderID = op.orderID
WHERE a.OPID <> op.ID	
AND op.processType = 'Custom'
AND SUBSTRING(op.productCode, 1, 2) <> 'PN' 
AND op.deleteX <> 'yes'

--FASTRAK ----------------------

UPDATE a
SET ShipsWith = 'fasTrak'
FROM ImposerNCTickets a
INNER JOIN tblOrders_Products op ON a.OrderID = op.orderID
WHERE a.OPID <> op.ID	
AND op.processType = 'fasTrak'
AND op.deleteX <> 'yes'
AND a.ShipsWith <> 'Custom'

--STOCK ----------------------

UPDATE a
SET ShipsWith = 'Stock' 
FROM ImposerNCTickets a
INNER JOIN (SELECT op.orderID, COUNT(op.ID) OVER(PARTITION BY op.orderID) AS StockCount
			FROM tblOrders_Products op
			INNER JOIN ImposerNCTickets a ON op.orderID = a.OrderID
			WHERE op.processType = 'Stock'
			AND op.ID <> a.OPID
			AND op.deleteX <> 'yes') b 
ON a.OrderID = b.orderID
WHERE b.StockCount > 6

--RESUBMIT

UPDATE a
SET ShipsWith = 'Resubmit'
FROM ImposerNCTickets a
INNER JOIN tblOrders_Products op ON a.OPID = op.ID
WHERE op.fastTrak_shippingLabelOption1 = 1

--SHIPTYPE ----------------------

UPDATE a
SET ShipType = 'Local Pickup'
FROM ImposerNCTickets a
INNER JOIN tblOrders o ON a.orderID = o.orderID
WHERE o.shippingDesc IN ('Local Pickup', 'WillCall')
OR o.shipping_firstName IN ('Local Pickup', 'Local')

UPDATE t
SET shipType =  LEFT(shipType + ' | Arrive by ' + CONVERT(NVARCHAR(50), DATEPART(MM, a.arrivalDate)) + '/' + CONVERT(NVARCHAR(50), DATEPART(DD, a.arrivalDate)), 50)
FROM  ImposerNCTickets t
INNER JOIN tblOrders a ON t.OrderNo = a.orderNo
INNER JOIN tblOrdersProducts_productOptions oppo ON t.OPID = oppo.ordersProductsID
WHERE a.arrivalDate IS NOT NULL
AND oppo.deleteX <> 'yes'
AND oppo.optionCaption = 'Express Production'

--SHIPSWITHALT ----------------------

UPDATE ImposerNCTickets
SET ShipsWithAlt = ShipsWith,
	   ShipsWith = ''
WHERE ShipType <> ''

--SHIPCOLOR ----------------------

UPDATE ImposerNCTickets SET ShipColor = 'green' WHERE ShipsWith = 'Ship' OR ShipsWithAlt = 'Ship'
UPDATE ImposerNCTickets SET ShipColor = 'orange' WHERE ShipsWith = 'Custom' OR ShipsWithAlt = 'Custom'
UPDATE ImposerNCTickets SET ShipColor = 'purple' WHERE ShipsWith = 'fasTrak' OR ShipsWithAlt = 'fasTrak'
UPDATE ImposerNCTickets SET ShipColor = 'blue' WHERE ShipsWith = 'Stock' OR ShipsWithAlt = 'Stock'
UPDATE ImposerNCTickets SET ShipColor = 'yellow' WHERE ShipsWith = 'Local Pickup' OR ShipsWithAlt = 'Local Pickup'
UPDATE ImposerNCTickets SET ShipColor = 'red' WHERE ShipsWith = 'Resubmit' OR ShipsWithAlt = 'Resubmit'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  ASSOCIATED PRODUCT COUNTS - CUSTOM

--declare variables to be used in all sections below
DECLARE @NumRec INT, 
				 @RWCT INT, 
				 @OPID INT,
				 @OrderID INT,
				 @ProductCode NVARCHAR(50),
				 @ProductName NVARCHAR(255)

--three tables needed for operation
IF OBJECT_ID('tempdb..#ImposerAssociatedCustomProductsJoiner') IS NOT NULL DROP TABLE #ImposerAssociatedCustomProductsJoiner
CREATE TABLE #ImposerAssociatedCustomProductsJoiner (
				ImposerOPID INT,
				AssociatedOPID INT,
				ProductCodePrefix NVARCHAR(20),
				ComboOPID NVARCHAR(50))

IF OBJECT_ID('tempdb..#ImposerAssociatedCustomProducts') IS NOT NULL DROP TABLE #ImposerAssociatedCustomProducts				
CREATE TABLE #ImposerAssociatedCustomProducts (
				RowID INT IDENTITY(1, 1), 
				OrderID INT, 
				AssociatedOPID INT,
				ProductCodePrefix NVARCHAR(20))

IF OBJECT_ID('tempdb..#ImposerAssociatedCustomProductCounts') IS NOT NULL DROP TABLE #ImposerAssociatedCustomProductCounts
CREATE TABLE #ImposerAssociatedCustomProductCounts (
				OrderID INT,
				CountOPID INT)	

--run loops
INSERT INTO #ImposerAssociatedCustomProducts (OrderID, AssociatedOPID, ProductCodePrefix)
SELECT DISTINCT op.orderID, op.ID, SUBSTRING(op.productCode, 1 ,4) 
FROM tblOrders_Products op
INNER JOIN ImposerNCTickets a ON a.OrderID = op.orderID
WHERE op.deletex <> 'yes'
AND op.processType = 'Custom'
AND op.ID NOT IN
	(SELECT OPID 
	FROM ImposerNCTickets)

SET @NumRec = @@ROWCOUNT
SET @RWCT = 1

WHILE @RWCT <= @NumRec
BEGIN
	SELECT @OPID = AssociatedOPID,
				  @OrderID = OrderID
	FROM #ImposerAssociatedCustomProducts
	WHERE RowID = @RWCT

	INSERT INTO #ImposerAssociatedCustomProductsJoiner (ImposerOPID, AssociatedOPID, ComboOPID, ProductCodePrefix)
	SELECT DISTINCT a.OPID, x.AssociatedOPID, 
	CONVERT(NVARCHAR(50), a.OPID) + '.' + CONVERT(NVARCHAR(50), x.AssociatedOPID),
	CONVERT(NVARCHAR(50), x.ProductCodePrefix)
	FROM ImposerNCTickets a
	INNER JOIN #ImposerAssociatedCustomProducts x ON a.orderID = x.OrderID
	WHERE a.OrderID = @OrderID
	AND x.AssociatedOPID = @OPID
	AND CONVERT(NVARCHAR(50), a.OPID) + '.' + CONVERT(NVARCHAR(50), x.AssociatedOPID) NOT IN
		(SELECT ISNULL(ComboOPID, 0)
		FROM #ImposerAssociatedCustomProductsJoiner)

	UPDATE a
	SET CustomProducts = ISNULL(a.CustomProducts, ' ') + CONVERT(NVARCHAR(50), j.ProductCodePrefix) + ' '
	FROM ImposerNCTickets a
	INNER JOIN #ImposerAssociatedCustomProductsJoiner j ON a.OPID = j.ImposerOPID
	WHERE @OPID = j.AssociatedOPID

	--get numerical count value
	INSERT INTO #ImposerAssociatedCustomProductCounts (OrderID, CountOPID)
	SELECT x.OrderID, COUNT(x.OrderID)
	FROM #ImposerAssociatedCustomProducts x
	WHERE x.OrderID = @OrderID
	GROUP BY x.OrderID

	SET @RWCT = @RWCT + 1
END

UPDATE a
SET CustomProducts = CONVERT(NVARCHAR(20), x.CountOPID) + ' Custom: ' + CONVERT(NVARCHAR(255), a.CustomProducts)
FROM ImposerNCTickets a
INNER JOIN #ImposerAssociatedCustomProductCounts x ON a.OrderID = x.OrderID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  ASSOCIATED PRODUCT COUNTS - FASTRAK

--three tables needed for operation
IF OBJECT_ID('tempdb..#ImposerAssociatedFasTrakProductsJoiner') IS NOT NULL DROP TABLE #ImposerAssociatedFasTrakProductsJoiner
CREATE TABLE #ImposerAssociatedFasTrakProductsJoiner (
				ImposerOPID INT,
				AssociatedOPID INT,
				ProductCodePrefix NVARCHAR(20),
				ComboOPID NVARCHAR(50))

IF OBJECT_ID('tempdb..#ImposerAssociatedFasTrakProducts') IS NOT NULL DROP TABLE #ImposerAssociatedFasTrakProducts				
CREATE TABLE #ImposerAssociatedFasTrakProducts (
				RowID INT IDENTITY(1, 1), 
				OrderID INT, 
				AssociatedOPID INT,
				ProductCodePrefix NVARCHAR(20))

IF OBJECT_ID('tempdb..#ImposerAssociatedFasTrakProductCounts') IS NOT NULL DROP TABLE #ImposerAssociatedFasTrakProductCounts		
CREATE TABLE #ImposerAssociatedFasTrakProductCounts (
				OrderID INT,
				CountOPID INT)	

--run loops
INSERT INTO #ImposerAssociatedFasTrakProducts (OrderID, AssociatedOPID, ProductCodePrefix)
SELECT DISTINCT op.orderID, op.ID, SUBSTRING(op.productCode, 1 ,4) 
FROM tblOrders_Products op
INNER JOIN ImposerNCTickets a ON a.OrderID = op.orderID
WHERE op.deletex <> 'yes'
AND op.processType = 'fasTrak'
AND op.ID NOT IN
	(SELECT OPID 
	FROM ImposerNCTickets)

SET @NumRec = @@ROWCOUNT
SET @RWCT = 1

WHILE @RWCT <= @NumRec
BEGIN
	SELECT @OPID = AssociatedOPID,
				  @OrderID = OrderID
	FROM #ImposerAssociatedFasTrakProducts
	WHERE RowID = @RWCT

	INSERT INTO #ImposerAssociatedFasTrakProductsJoiner (ImposerOPID, AssociatedOPID, ComboOPID, ProductCodePrefix)
	SELECT DISTINCT a.OPID, x.AssociatedOPID, 
	CONVERT(NVARCHAR(50), a.OPID) + '.' + CONVERT(NVARCHAR(50), x.AssociatedOPID),
	CONVERT(NVARCHAR(50), x.ProductCodePrefix)
	FROM ImposerNCTickets a
	INNER JOIN #ImposerAssociatedFasTrakProducts x ON a.orderID = x.OrderID
	WHERE a.OrderID = @OrderID
	AND x.AssociatedOPID = @OPID
	AND CONVERT(NVARCHAR(50), a.OPID) + '.' + CONVERT(NVARCHAR(50), x.AssociatedOPID) NOT IN
		(SELECT ISNULL(ComboOPID, 0)
		FROM #ImposerAssociatedFasTrakProductsJoiner)

	UPDATE a
	SET fasTrakProducts = ISNULL(a.fasTrakProducts, ' ') + CONVERT(NVARCHAR(50), j.ProductCodePrefix) + ' '
	FROM ImposerNCTickets a
	INNER JOIN #ImposerAssociatedFasTrakProductsJoiner j ON a.OPID = j.ImposerOPID
	WHERE @OPID = j.AssociatedOPID

	--get numerical count value
	INSERT INTO #ImposerAssociatedFasTrakProductCounts (OrderID, CountOPID)
	SELECT x.OrderID, COUNT(x.OrderID)
	FROM #ImposerAssociatedFasTrakProducts x
	WHERE x.OrderID = @OrderID
	GROUP BY x.OrderID

	SET @RWCT = @RWCT + 1
END

UPDATE a
SET fasTrakProducts = CONVERT(NVARCHAR(20), x.CountOPID) + ' fasTrak: ' + CONVERT(NVARCHAR(255), a.fasTrakProducts)
FROM ImposerNCTickets a
INNER JOIN #ImposerAssociatedFasTrakProductCounts x ON a.OrderID = x.OrderID

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////  ASSOCIATED PRODUCT COUNTS - STOCK

--create table that lists associated stock products for Imposed OPID
IF OBJECT_ID('tempdb..#ImposerAssociatedStockProducts') IS NOT NULL DROP TABLE #ImposerAssociatedStockProducts		
CREATE TABLE #ImposerAssociatedStockProducts (
				RowID INT IDENTITY(1, 1), 
				OrderID INT,
				AssociatedOPID INT,
				AssociatedProductQuantity INT,
				AssociatedProductPriceQuantity INT,
				AssociatedProductName NVARCHAR(255),
				AssociatedProductCode NVARCHAR(50))

INSERT INTO #ImposerAssociatedStockProducts  (OrderID, AssociatedOPID, AssociatedProductQuantity, AssociatedProductPriceQuantity, AssociatedProductName, AssociatedProductCode)
SELECT DISTINCT op.orderID, op.ID, op.productQuantity, op.productPrice * op.productQuantity AS APPQ, op.productName, op.productCode
FROM tblOrders_Products op
INNER JOIN ImposerNCTickets a ON a.OrderID = op.orderID
WHERE op.deletex <> 'yes'
AND op.ID NOT IN
	(SELECT ID
	FROM tblOrders_Products
	WHERE SUBSTRING(productCode, 1, 4) = 'NCEV' 
	AND groupID <> 0)
AND op.processType = 'Stock'
ORDER BY APPQ DESC, op.productName

SET @NumRec = @@ROWCOUNT
SET @RWCT = 1

WHILE @RWCT <= @NumRec
BEGIN
	SELECT @OrderID = OrderID,
				  @OPID = AssociatedOPID,
				  @ProductName = CONVERT(NVARCHAR(50), ISNULL(AssociatedProductQuantity, 0)) + '    ' + AssociatedProductCode + '    ' + AssociatedProductName				  
	FROM #ImposerAssociatedStockProducts
	WHERE RowID = @RWCT

	UPDATE ImposerNCTickets
	SET StockProduct1 = @ProductName
	WHERE StockProduct1 IS NULL
	AND OrderID = @OrderID

	UPDATE ImposerNCTickets
	SET StockProduct2 = @ProductName
	WHERE StockProduct2 IS NULL
	AND StockProduct1 <> @ProductName
	AND OrderID = @OrderID
	
	UPDATE ImposerNCTickets
	SET StockProduct3 = @ProductName
	WHERE StockProduct3 IS NULL
	AND StockProduct2 <> @ProductName
	AND StockProduct1 <> @ProductName
	AND OrderID = @OrderID

	UPDATE ImposerNCTickets
	SET StockProduct4 = @ProductName
	WHERE StockProduct4 IS NULL
	AND StockProduct3 <> @ProductName
	AND StockProduct2 <> @ProductName
	AND StockProduct1 <> @ProductName
	AND OrderID = @OrderID

	UPDATE ImposerNCTickets
	SET StockProduct5 = @ProductName
	WHERE StockProduct5 IS NULL
	AND StockProduct4 <> @ProductName
	AND StockProduct3 <> @ProductName
	AND StockProduct2 <> @ProductName
	AND StockProduct1 <> @ProductName
	AND OrderID = @OrderID

	UPDATE ImposerNCTickets
	SET StockProduct6 = @ProductName
	WHERE StockProduct6 IS NULL
	AND StockProduct5 <> @ProductName
	AND StockProduct4 <> @ProductName
	AND StockProduct3 <> @ProductName
	AND StockProduct2 <> @ProductName
	AND StockProduct1 <> @ProductName
	AND OrderID = @OrderID

	SET @RWCT = @RWCT + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// BUILD CAVITIES

TRUNCATE TABLE ImposerNCCavities
DECLARE @cvOrderNo NVARCHAR(50),
				@cvOPID INT,
				@cvSurface1 NVARCHAR(100),
				@cvSurface2 NVARCHAR(100),
				@cvSurface3 NVARCHAR(100),
				@cvOutputName NVARCHAR(100),
				@cvProductQuantity INT,
				@cvProductQuantityTop INT,
				@cvOutputNameChecker NVARCHAR(100),
				@cvResubmit BIT,
				@cvExpedite BIT,
				@NumRec2 INT, 
				@RWCT2 INT,
				@UV NVARCHAR(50),
				@UVColor NVARCHAR(50)

--create table that stores unique OPIDs for cavity iteration
IF OBJECT_ID('tempdb..#ImposerCavityIteration') IS NOT NULL DROP TABLE #ImposerCavityIteration	
CREATE TABLE #ImposerCavityIteration (
				RowID INT IDENTITY(1, 1), 
				OrderNo NVARCHAR(50),
				OPID INT,
				Surface1 NVARCHAR(100),
				Surface2 NVARCHAR(100),
				Surface3 NVARCHAR(100),
				OutputName NVARCHAR(100),
				ProductQuantity INT,
				Resubmit BIT,
				Expedite BIT,
				UV NVARCHAR(50),
				UVColor NVARCHAR(50))

INSERT INTO #ImposerCavityIteration (OrderNo, OPID, OutputName, ProductQuantity, Resubmit, Expedite, UV, UVColor)
SELECT DISTINCT a.OrderNo, a.OPID, a.OutputName, CONVERT(INT,REPLACE(a.Quantity, 'Quantity: ', '')) AS ProductQuantity, a.Resubmit, a.Expedite,
CASE 
	WHEN ISNULL(a.UV, 1) = 1 THEN 'UV/UV'
	WHEN ISNULL(a.UV, 2) = 2 THEN 'UV/Matte'
	WHEN ISNULL(a.UV, 3) = 3 THEN 'Matte/UV'
	WHEN ISNULL(a.UV, 4) = 4 THEN 'Matte/Matte'
	WHEN ISNULL(a.UV, 5) = 5 THEN 'SoftTouch'
	ELSE 'UV/UV'
END AS UV,
CASE 
	WHEN ISNULL(a.UV, 1) = 1 THEN 'blue'
	WHEN ISNULL(a.UV, 2) = 2 THEN 'green'
	WHEN ISNULL(a.UV, 3) = 3 THEN 'yellow'
	WHEN ISNULL(a.UV, 4) = 4 THEN 'red'
	WHEN ISNULL(a.UV, 5) = 5 THEN 'purple'
	ELSE 'blue'
END AS UVColor
FROM ImposerNCTickets a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.deleteX <> 'yes'
ORDER BY a.Resubmit DESC, a.Expedite DESC, a.OrderNo, a.OPID, a.OutputName, ProductQuantity

--set loop vars
SET @NumRec2 = @@ROWCOUNT
SET @RWCT2 = 1

--SURFACE 1 ----------------------------------------------------------------------------------------------------

UPDATE a
SET Surface1 = CASE WHEN oppo.TextValue LIKE '%/%' THEN REPLACE((RIGHT(REPLACE(oppo.textValue, @UncBasePath, ''), CHARINDEX('/', REVERSE(REPLACE(oppo.textValue, @UncBasePath, ''))))), '/', '')
								ELSE REPLACE(oppo.textValue, @UncBasePath, '')
							END
FROM #ImposerCavityIteration a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.optionCaption IN ('Card Front', 'Intranet PDF')
AND oppo.deleteX <> 'yes'

--SURFACE 2 ----------------------------------------------------------------------------------------------------

UPDATE a
SET Surface2 = CASE WHEN oppo.TextValue LIKE '%/%' THEN REPLACE((RIGHT(REPLACE(oppo.textValue, @UncBasePath, ''), CHARINDEX('/', REVERSE(REPLACE(oppo.textValue, @UncBasePath, ''))))), '/', '')
								ELSE REPLACE(oppo.textValue, @UncBasePath, '')
							END
FROM #ImposerCavityIteration a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.optionCaption IN ('Greeting', 'Inside Intranet PDF')
AND oppo.deleteX <> 'yes'

--SURFACE 3 ----------------------------------------------------------------------------------------------------

UPDATE a
SET Surface3 = CASE WHEN oppo.TextValue LIKE '%/%' THEN REPLACE((RIGHT(REPLACE(oppo.textValue, @UncBasePath, ''), CHARINDEX('/', REVERSE(REPLACE(oppo.textValue, @UncBasePath, ''))))), '/', '')
								ELSE REPLACE(oppo.textValue, @UncBasePath, '')
							END
FROM #ImposerCavityIteration a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPID = oppo.ordersProductsID
WHERE oppo.optionCaption IN ('Card Back', 'Back Intranet PDF')
AND oppo.deleteX <> 'yes'

UPDATE #ImposerCavityIteration
SET Surface1 = ISNULL(Surface1, ''),
		Surface2 = ISNULL(Surface2, ''),
		Surface3 = ISNULL(Surface3, '')

--INSERT TICKET ROW ----------------------------------------------------------------------------------------------------

WHILE @RWCT2 <= @NumRec2
BEGIN
	SELECT @cvOrderNo = OrderNo,
				 @cvOPID = OPID,
				 @cvSurface1 = Surface1,
				 @cvSurface2 = Surface2,
				 @cvSurface3 = Surface3,
				 @cvOutputName = OutputName,
				 @cvProductQuantity = ProductQuantity,
				 @cvProductQuantityTop = 0,
				 @cvResubmit = Resubmit,
				 @cvExpedite = Expedite,
				 @UV=  UV,
				 @UVColor = UVColor			  
	FROM #ImposerCavityIteration
	WHERE RowID = @RWCT2
	ORDER BY Resubmit DESC, Expedite DESC

	WHILE @cvProductQuantityTop <> @cvProductQuantity
			BEGIN
				--insert ticket row for given @cv output
				SET @cvOutputNameChecker = NULL
				SET @cvOutputNameChecker = (SELECT TOP 1 TicketName FROM ImposerNCCavities WHERE TicketName = @cvOutputName)
				IF @cvOutputNameChecker IS NULL
						BEGIN
							INSERT INTO ImposerNCCavities (OrderNo, OPID, TicketName, Resubmit, Expedite, UV, UVColor)
							SELECT @cvOrderNo, @cvOPID, @cvOutputName, @cvResubmit, @cvExpedite, @UV, @UVColor
						END

				--insert cavity row for give @cv output
				INSERT INTO ImposerNCCavities (OrderNo, OPID, Surface1, Surface2, Surface3, Resubmit, Expedite, UV, UVColor)
				SELECT @cvOrderNo, @cvOPID, @cvSurface1, @cvSurface2, @cvSurface3, @cvResubmit, @cvExpedite, @UV, @UVColor
	
				--increment @cvProductQuantityTop
				SET @cvProductQuantityTop = @cvProductQuantityTop + 1
			END

	--increment row count
	SET @RWCT2 = @RWCT2 + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// DO COUNTS

--COUNTS --------------------------------------------------------------------------------
--get the count for each opid within imposition run
IF OBJECT_ID('tempdb..#ImposerJagCount') IS NOT NULL DROP TABLE #ImposerJagCount	
CREATE TABLE #ImposerJagCount (
				RowID INT IDENTITY(1, 1), 
				OPID INT NOT NULL,
				CavityCount INT)

--populate count table used for subsequent updates			
INSERT INTO #ImposerJagCount (OPID, CavityCount)
SELECT OPID, COUNT(OPID) AS CavityCount
FROM ImposerNCCavities
GROUP BY OPID
ORDER BY CavityCount DESC

--update cavity counts
UPDATE a
SET JagQTY = b.CavityCount
FROM ImposerNCCavities a
INNER JOIN #ImposerJagCount b ON a.OPID = b.OPID

--IDENTITIES --------------------------------------------------------------------------------
--EXPOSUBS (e.g., which opids are expedited, resubmitted, or both)
UPDATE a
SET ExpoSub = 1
FROM ImposerNCCavities a
WHERE a.Resubmit = 1
OR a.Expedite = 1

--UNDERS (e.g., which opids are under the "solo" and "over" thresholds)
UPDATE a
SET JagUnder = 1
FROM ImposerNCCavities a
INNER JOIN #ImposerJagCount b ON a.OPID = b.OPID
WHERE b.CavityCount BETWEEN 0 AND 74 --[0;999]

--SOLOS (e.g., which opids are considered large orders and are to be run at the end of the imposition, but could possibly be joined with smaller batches)
UPDATE a
SET JagSolo = 1
FROM ImposerNCCavities a
INNER JOIN #ImposerJagCount b ON a.OPID = b.OPID
WHERE b.CavityCount BETWEEN 75 AND 150 --[1000;1300]

--OVERS (e.g., which opids have more than the threshold value and always will have their own "limitless" batch. If a JagOver is an ExpoSub=1, then it will still just run by itself at the end of the imposition.)
UPDATE a
SET JagOver = 1
FROM ImposerNCCavities a
INNER JOIN #ImposerJagCount b ON a.OPID = b.OPID
WHERE b.CavityCount > 150 --[1300]

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ASSIGN BATCHES

DECLARE @NumRec3 INT, 
		@RWCT3 INT,
		@BatchID INT,
		@BatchFlag BIT = 0,
		@TopAvailableBatchID INT = 0,
		@TopAvailableBatchID_WithRemainingSpace INT = 0,
		@CurrentCount INT,
		@JagQTY INT = 0,
		@JagUnder BIT = 0,
		@JagSolo BIT = 0,
		@JagOver BIT = 0,
		@SheetLimit INT = 150, --[TEST: 150; LIVE: 3000]
		@UnderValue INT = 74, --[TEST: 74; LIVE: 999]
		@SoloValue INT = 150  --[TEST: 150; LIVE: 1300]

TRUNCATE TABLE ImposerNCCCavities_BatchCount

-----------------------------------------------------------------------------------------------------------
--BATCH 01. EXPOSUB UNDER | add cavities for "unders" that are exposubs. ----------------------------------
-----------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Batch01') IS NOT NULL DROP TABLE #Batch01				
CREATE TABLE #Batch01 (
		RowID INT IDENTITY(1, 1), 
		PKID INT,
		OrderNo NVARCHAR(50),
		OPID INT,
		Surface1 NVARCHAR(100),
		Surface2 NVARCHAR(100),
		Surface3 NVARCHAR(100),
		TicketName NVARCHAR(100),
		Resubmit BIT,
		Expedite BIT,
		FirstInstance BIT,
		RowSort INT,
		UV NVARCHAR(50),
		UVColor NVARCHAR(50),
		ExpoSub BIT,
		JagQTY INT,
		JagUnder BIT,
		JagSolo BIT,
		JagOver BIT)

INSERT INTO #Batch01 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT DISTINCT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities
WHERE ExpoSub = 1
AND JagUnder = 1
ORDER BY PKID

SET @NumRec3 = @@ROWCOUNT
SET @RWCT3 = 1

--reset variables
SET @JagQTY = 0
SET @BatchID = 0
SET @TopAvailableBatchID = 0
SET @TopAvailableBatchID_WithRemainingSpace = 0

WHILE @RWCT3 <= @NumRec3
BEGIN

	--reset flag used to monitor batchID assignation
	SET @BatchFlag = 0

	--the QTY is the same per PKID within a given OPID group, so this just grabs the PKIDs JagQTY value
	SET @JagQTY = (SELECT JagQTY
					FROM #Batch01
					WHERE RowID = @RWCT3)

	--this captures a batchID assigned to this PKID's OPID, should it exist (if it does not exist, @BatchID = 0)
	SET @BatchID = (SELECT TOP 1 ISNULL(i.BatchID, 0)
					FROM #Batch01 a
					INNER JOIN ImposerNCCavities i ON a.OPID = i.OPID
					WHERE a.RowID = @RWCT3
					ORDER BY i.BatchID DESC)
	
	IF @BatchID IS NULL
	BEGIN
		SET @BatchID = 0
	END

	--this captures the next number available to use for a batchID, should it be needed (if zero, it will default to "1")
	SET @TopAvailableBatchID = (SELECT TOP 1 ISNULL(BatchID, 0) + 1
								FROM ImposerNCCavities
								ORDER BY BatchID DESC)

	--this captures the first available batchID that has available space for this particular OPID, if any (based on the QTY of this OPID being subtracted from the BatchID's current count, keeping w/in threshold)
	SET @TopAvailableBatchID_WithRemainingSpace = (SELECT TOP 1 ISNULL(BatchID, 0)
													FROM ImposerNCCCavities_BatchCount
													WHERE ISNULL(CurrentCount, 0) + @JagQTY <= @SheetLimit
													ORDER BY BatchID ASC)
	
	IF @TopAvailableBatchID_WithRemainingSpace IS NULL
	BEGIN
		SET @TopAvailableBatchID_WithRemainingSpace = 0
	END

	--Now, Assign BatchID -------------------------------------------------	
	--(1) If this OPID has no BatchID assigned yet, and there is no existing available BatchID that has room to fit this OPID, then use @TopAvailableBatchID. 
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace = 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID

		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch01 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount
		
		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(2) If at BatchID exists with enough room to accommodate this OPID, and this OPID has not been assigned a BatchID yet, then use @TopAvailableBatchID_WithRemainingSpace.
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace <> 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID_WithRemainingSpace
		
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch01 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(3) when this particular PKID's OPID has already been assigned a batchID, we need to simply update this PKID to match its fellow OPIDs
	ELSE IF @BatchID <> 0 AND @BatchFlag = 0
	BEGIN
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch01 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3
		AND ISNULL(i.BatchID, 0) <> @BatchID

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END
SET @RWCT3 = @RWCT3 + 1
END

-----------------------------------------------------------------------------------------------------------
--BATCH 02. EXPOSUB SOLO | add cavities for "solos" that are exposubs. ----------------------------------
-----------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Batch02') IS NOT NULL DROP TABLE #Batch02				
CREATE TABLE #Batch02 (
		RowID INT IDENTITY(1, 1), 
		PKID INT,
		OrderNo NVARCHAR(50),
		OPID INT,
		Surface1 NVARCHAR(100),
		Surface2 NVARCHAR(100),
		Surface3 NVARCHAR(100),
		TicketName NVARCHAR(100),
		Resubmit BIT,
		Expedite BIT,
		FirstInstance BIT,
		RowSort INT,
		UV NVARCHAR(50),
		UVColor NVARCHAR(50),
		ExpoSub BIT,
		JagQTY INT,
		JagUnder BIT,
		JagSolo BIT,
		JagOver BIT)

INSERT INTO #Batch02 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT DISTINCT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities
WHERE ExpoSub = 1
AND JagSolo = 1
ORDER BY PKID

SET @NumRec3 = @@ROWCOUNT
SET @RWCT3 = 1

--reset variables
SET @JagQTY = 0
SET @BatchID = 0
SET @TopAvailableBatchID = 0
SET @TopAvailableBatchID_WithRemainingSpace = 0

WHILE @RWCT3 <= @NumRec3
BEGIN

	--reset flag used to monitor batchID assignation
	SET @BatchFlag = 0

	--the QTY is the same per PKID within a given OPID group, so this just grabs the PKIDs JagQTY value
	SET @JagQTY = (SELECT JagQTY
					FROM #Batch02
					WHERE RowID = @RWCT3)

	--this captures a batchID assigned to this PKID's OPID, should it exist (if it does not exist, @BatchID = 0)
	SET @BatchID = (SELECT TOP 1 ISNULL(i.BatchID, 0)
					FROM #Batch02 a
					INNER JOIN ImposerNCCavities i ON a.OPID = i.OPID
					WHERE a.RowID = @RWCT3
					ORDER BY i.BatchID DESC)
	
	IF @BatchID IS NULL
	BEGIN
		SET @BatchID = 0
	END

	--this captures the next number available to use for a batchID, should it be needed (if zero, it will default to "1")
	SET @TopAvailableBatchID = (SELECT TOP 1 ISNULL(BatchID, 0) + 1
								FROM ImposerNCCavities
								ORDER BY BatchID DESC)

	--this captures the first available batchID that has available space for this particular OPID, if any (based on the QTY of this OPID being subtracted from the BatchID's current count, keeping w/in threshold)
	SET @TopAvailableBatchID_WithRemainingSpace = (SELECT TOP 1 ISNULL(BatchID, 0)
													FROM ImposerNCCCavities_BatchCount
													WHERE ISNULL(CurrentCount, 0) + @JagQTY <= @SheetLimit
													ORDER BY BatchID ASC)
	
	IF @TopAvailableBatchID_WithRemainingSpace IS NULL
	BEGIN
		SET @TopAvailableBatchID_WithRemainingSpace = 0
	END

	--Now, Assign BatchID -------------------------------------------------	
	--(1) If this OPID has no BatchID assigned yet, and there is no existing available BatchID that has room to fit this OPID, then use @TopAvailableBatchID. 
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace = 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID

		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch02 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount
		
		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(2) If at BatchID exists with enough room to accommodate this OPID, and this OPID has not been assigned a BatchID yet, then use @TopAvailableBatchID_WithRemainingSpace.
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace <> 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID_WithRemainingSpace
		
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch02 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(3) when this particular PKID's OPID has already been assigned a batchID, we need to simply update this PKID to match its fellow OPIDs
	ELSE IF @BatchID <> 0 AND @BatchFlag = 0
	BEGIN
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch02 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3
		AND ISNULL(i.BatchID, 0) <> @BatchID

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END
SET @RWCT3 = @RWCT3 + 1
END

-----------------------------------------------------------------------------------------------------------
--BATCH 03. STANDARD UNDER | add cavities for standard "unders" -------------------------------------------
-----------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Batch03') IS NOT NULL DROP TABLE #Batch03				
CREATE TABLE #Batch03 (
		RowID INT IDENTITY(1, 1), 
		PKID INT,
		OrderNo NVARCHAR(50),
		OPID INT,
		Surface1 NVARCHAR(100),
		Surface2 NVARCHAR(100),
		Surface3 NVARCHAR(100),
		TicketName NVARCHAR(100),
		Resubmit BIT,
		Expedite BIT,
		FirstInstance BIT,
		RowSort INT,
		UV NVARCHAR(50),
		UVColor NVARCHAR(50),
		ExpoSub BIT,
		JagQTY INT,
		JagUnder BIT,
		JagSolo BIT,
		JagOver BIT)

INSERT INTO #Batch03 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT DISTINCT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities
WHERE ExpoSub = 0
AND JagUnder = 1
ORDER BY PKID

SET @NumRec3 = @@ROWCOUNT
SET @RWCT3 = 1

--reset variables
SET @JagQTY = 0
SET @BatchID = 0
SET @TopAvailableBatchID = 0
SET @TopAvailableBatchID_WithRemainingSpace = 0

WHILE @RWCT3 <= @NumRec3
BEGIN

	--reset flag used to monitor batchID assignation
	SET @BatchFlag = 0

	--the QTY is the same per PKID within a given OPID group, so this just grabs the PKIDs JagQTY value
	SET @JagQTY = (SELECT JagQTY
					FROM #Batch03
					WHERE RowID = @RWCT3)

	--this captures a batchID assigned to this PKID's OPID, should it exist (if it does not exist, @BatchID = 0)
	SET @BatchID = (SELECT TOP 1 ISNULL(i.BatchID, 0)
					FROM #Batch03 a
					INNER JOIN ImposerNCCavities i ON a.OPID = i.OPID
					WHERE a.RowID = @RWCT3
					ORDER BY i.BatchID DESC)
	
	IF @BatchID IS NULL
	BEGIN
		SET @BatchID = 0
	END

	--this captures the next number available to use for a batchID, should it be needed (if zero, it will default to "1")
	SET @TopAvailableBatchID = (SELECT TOP 1 ISNULL(BatchID, 0) + 1
								FROM ImposerNCCavities
								ORDER BY BatchID DESC)

	--this captures the first available batchID that has available space for this particular OPID, if any (based on the QTY of this OPID being subtracted from the BatchID's current count, keeping w/in threshold)
	SET @TopAvailableBatchID_WithRemainingSpace = (SELECT TOP 1 ISNULL(BatchID, 0)
													FROM ImposerNCCCavities_BatchCount
													WHERE ISNULL(CurrentCount, 0) + @JagQTY <= @SheetLimit
													ORDER BY BatchID ASC)
	
	IF @TopAvailableBatchID_WithRemainingSpace IS NULL
	BEGIN
		SET @TopAvailableBatchID_WithRemainingSpace = 0
	END

	--Now, Assign BatchID -------------------------------------------------	
	--(1) If this OPID has no BatchID assigned yet, and there is no existing available BatchID that has room to fit this OPID, then use @TopAvailableBatchID. 
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace = 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID

		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch03 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount
		
		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(2) If at BatchID exists with enough room to accommodate this OPID, and this OPID has not been assigned a BatchID yet, then use @TopAvailableBatchID_WithRemainingSpace.
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace <> 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID_WithRemainingSpace
		
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch03 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(3) when this particular PKID's OPID has already been assigned a batchID, we need to simply update this PKID to match its fellow OPIDs
	ELSE IF @BatchID <> 0 AND @BatchFlag = 0
	BEGIN
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch03 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3
		AND ISNULL(i.BatchID, 0) <> @BatchID

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END
SET @RWCT3 = @RWCT3 + 1
END

-----------------------------------------------------------------------------------------------------------
--BATCH 04. STANDARD SOLO | add cavities for "solos" that are "standards" if they can fit on existing batch
-----------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Batch04') IS NOT NULL DROP TABLE #Batch04				
CREATE TABLE #Batch04 (
		RowID INT IDENTITY(1, 1), 
		PKID INT,
		OrderNo NVARCHAR(50),
		OPID INT,
		Surface1 NVARCHAR(100),
		Surface2 NVARCHAR(100),
		Surface3 NVARCHAR(100),
		TicketName NVARCHAR(100),
		Resubmit BIT,
		Expedite BIT,
		FirstInstance BIT,
		RowSort INT,
		UV NVARCHAR(50),
		UVColor NVARCHAR(50),
		ExpoSub BIT,
		JagQTY INT,
		JagUnder BIT,
		JagSolo BIT,
		JagOver BIT)

INSERT INTO #Batch04 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT DISTINCT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities
WHERE ExpoSub = 0
AND JagSolo = 1
ORDER BY PKID

SET @NumRec3 = @@ROWCOUNT
SET @RWCT3 = 1

--reset variables
SET @JagQTY = 0
SET @BatchID = 0
SET @TopAvailableBatchID = 0
SET @TopAvailableBatchID_WithRemainingSpace = 0

WHILE @RWCT3 <= @NumRec3
BEGIN

	--reset flag used to monitor batchID assignation
	SET @BatchFlag = 0

	--the QTY is the same per PKID within a given OPID group, so this just grabs the PKIDs JagQTY value
	SET @JagQTY = (SELECT JagQTY
					FROM #Batch04
					WHERE RowID = @RWCT3)

	--this captures a batchID assigned to this PKID's OPID, should it exist (if it does not exist, @BatchID = 0)
	SET @BatchID = (SELECT TOP 1 ISNULL(i.BatchID, 0)
					FROM #Batch04 a
					INNER JOIN ImposerNCCavities i ON a.OPID = i.OPID
					WHERE a.RowID = @RWCT3
					ORDER BY i.BatchID DESC)
	
	IF @BatchID IS NULL
	BEGIN
		SET @BatchID = 0
	END

	--this captures the next number available to use for a batchID, should it be needed (if zero, it will default to "1")
	SET @TopAvailableBatchID = (SELECT TOP 1 ISNULL(BatchID, 0) + 1
								FROM ImposerNCCavities
								ORDER BY BatchID DESC)

	--this captures the first available batchID that has available space for this particular OPID, if any (based on the QTY of this OPID being subtracted from the BatchID's current count, keeping w/in threshold)
	SET @TopAvailableBatchID_WithRemainingSpace = (SELECT TOP 1 ISNULL(BatchID, 0)
													FROM ImposerNCCCavities_BatchCount
													WHERE ISNULL(CurrentCount, 0) + @JagQTY <= @SheetLimit
													ORDER BY BatchID ASC)
	
	IF @TopAvailableBatchID_WithRemainingSpace IS NULL
	BEGIN
		SET @TopAvailableBatchID_WithRemainingSpace = 0
	END

	--Now, Assign BatchID -------------------------------------------------	
	--(1) If this OPID has no BatchID assigned yet, and there is no existing available BatchID that has room to fit this OPID, then use @TopAvailableBatchID. 
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace = 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID

		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch04 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount
		
		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(2) If at BatchID exists with enough room to accommodate this OPID, and this OPID has not been assigned a BatchID yet, then use @TopAvailableBatchID_WithRemainingSpace.
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace <> 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID_WithRemainingSpace
		
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch04 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(3) when this particular PKID's OPID has already been assigned a batchID, we need to simply update this PKID to match its fellow OPIDs
	ELSE IF @BatchID <> 0 AND @BatchFlag = 0
	BEGIN
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch04 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3
		AND ISNULL(i.BatchID, 0) <> @BatchID

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END
SET @RWCT3 = @RWCT3 + 1
END

-----------------------------------------------------------------------------------------------------------
--BATCH 05. EXPOSUB OVER | add cavities for "overs" that are exposubs.
-----------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Batch05') IS NOT NULL DROP TABLE #Batch05				
CREATE TABLE #Batch05 (
		RowID INT IDENTITY(1, 1), 
		PKID INT,
		OrderNo NVARCHAR(50),
		OPID INT,
		Surface1 NVARCHAR(100),
		Surface2 NVARCHAR(100),
		Surface3 NVARCHAR(100),
		TicketName NVARCHAR(100),
		Resubmit BIT,
		Expedite BIT,
		FirstInstance BIT,
		RowSort INT,
		UV NVARCHAR(50),
		UVColor NVARCHAR(50),
		ExpoSub BIT,
		JagQTY INT,
		JagUnder BIT,
		JagSolo BIT,
		JagOver BIT)

INSERT INTO #Batch05 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT DISTINCT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities
WHERE ExpoSub = 1
AND JagOver = 1
ORDER BY PKID

SET @NumRec3 = @@ROWCOUNT
SET @RWCT3 = 1

--reset variables
SET @JagQTY = 0
SET @BatchID = 0
SET @TopAvailableBatchID = 0
SET @TopAvailableBatchID_WithRemainingSpace = 0

WHILE @RWCT3 <= @NumRec3
BEGIN

	--reset flag used to monitor batchID assignation
	SET @BatchFlag = 0

	--the QTY is the same per PKID within a given OPID group, so this just grabs the PKIDs JagQTY value
	SET @JagQTY = (SELECT JagQTY
					FROM #Batch05
					WHERE RowID = @RWCT3)

	--this captures a batchID assigned to this PKID's OPID, should it exist (if it does not exist, @BatchID = 0)
	SET @BatchID = (SELECT TOP 1 ISNULL(i.BatchID, 0)
					FROM #Batch05 a
					INNER JOIN ImposerNCCavities i ON a.OPID = i.OPID
					WHERE a.RowID = @RWCT3
					ORDER BY i.BatchID DESC)
	
	IF @BatchID IS NULL
	BEGIN
		SET @BatchID = 0
	END

	--this captures the next number available to use for a batchID, should it be needed (if zero, it will default to "1")
	SET @TopAvailableBatchID = (SELECT TOP 1 ISNULL(BatchID, 0) + 1
								FROM ImposerNCCavities
								ORDER BY BatchID DESC)

	--this captures the first available batchID that has available space for this particular OPID, if any (based on the QTY of this OPID being subtracted from the BatchID's current count, keeping w/in threshold)
	SET @TopAvailableBatchID_WithRemainingSpace = (SELECT TOP 1 ISNULL(BatchID, 0)
													FROM ImposerNCCCavities_BatchCount
													WHERE ISNULL(CurrentCount, 0) + @JagQTY <= @SheetLimit
													ORDER BY BatchID ASC)
	
	IF @TopAvailableBatchID_WithRemainingSpace IS NULL
	BEGIN
		SET @TopAvailableBatchID_WithRemainingSpace = 0
	END

	--Now, Assign BatchID -------------------------------------------------	
	--(1) If this OPID has no BatchID assigned yet, and there is no existing available BatchID that has room to fit this OPID, then use @TopAvailableBatchID. 
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace = 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID

		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch05 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount
		
		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(2) If at BatchID exists with enough room to accommodate this OPID, and this OPID has not been assigned a BatchID yet, then use @TopAvailableBatchID_WithRemainingSpace.
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace <> 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID_WithRemainingSpace
		
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch05 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(3) when this particular PKID's OPID has already been assigned a batchID, we need to simply update this PKID to match its fellow OPIDs
	ELSE IF @BatchID <> 0 AND @BatchFlag = 0
	BEGIN
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch05 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3
		AND ISNULL(i.BatchID, 0) <> @BatchID

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END
SET @RWCT3 = @RWCT3 + 1
END

-----------------------------------------------------------------------------------------------------------
--BATCH 06. STANDARD OVER | add cavities for "overs" that are standards.
-----------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Batch06') IS NOT NULL DROP TABLE #Batch06				
CREATE TABLE #Batch06 (
		RowID INT IDENTITY(1, 1), 
		PKID INT,
		OrderNo NVARCHAR(50),
		OPID INT,
		Surface1 NVARCHAR(100),
		Surface2 NVARCHAR(100),
		Surface3 NVARCHAR(100),
		TicketName NVARCHAR(100),
		Resubmit BIT,
		Expedite BIT,
		FirstInstance BIT,
		RowSort INT,
		UV NVARCHAR(50),
		UVColor NVARCHAR(50),
		ExpoSub BIT,
		JagQTY INT,
		JagUnder BIT,
		JagSolo BIT,
		JagOver BIT)

INSERT INTO #Batch06 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT DISTINCT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities
WHERE ExpoSub = 0
AND JagOver = 1
ORDER BY PKID

SET @NumRec3 = @@ROWCOUNT
SET @RWCT3 = 1

--reset variables
SET @JagQTY = 0
SET @BatchID = 0
SET @TopAvailableBatchID = 0
SET @TopAvailableBatchID_WithRemainingSpace = 0

WHILE @RWCT3 <= @NumRec3
BEGIN

	--reset flag used to monitor batchID assignation
	SET @BatchFlag = 0

	--the QTY is the same per PKID within a given OPID group, so this just grabs the PKIDs JagQTY value
	SET @JagQTY = (SELECT JagQTY
					FROM #Batch06
					WHERE RowID = @RWCT3)

	--this captures a batchID assigned to this PKID's OPID, should it exist (if it does not exist, @BatchID = 0)
	SET @BatchID = (SELECT TOP 1 ISNULL(i.BatchID, 0)
					FROM #Batch06 a
					INNER JOIN ImposerNCCavities i ON a.OPID = i.OPID
					WHERE a.RowID = @RWCT3
					ORDER BY i.BatchID DESC)
	
	IF @BatchID IS NULL
	BEGIN
		SET @BatchID = 0
	END

	--this captures the next number available to use for a batchID, should it be needed (if zero, it will default to "1")
	SET @TopAvailableBatchID = (SELECT TOP 1 ISNULL(BatchID, 0) + 1
								FROM ImposerNCCavities
								ORDER BY BatchID DESC)

	--this captures the first available batchID that has available space for this particular OPID, if any (based on the QTY of this OPID being subtracted from the BatchID's current count, keeping w/in threshold)
	SET @TopAvailableBatchID_WithRemainingSpace = (SELECT TOP 1 ISNULL(BatchID, 0)
													FROM ImposerNCCCavities_BatchCount
													WHERE ISNULL(CurrentCount, 0) + @JagQTY <= @SheetLimit
													ORDER BY BatchID ASC)
	
	IF @TopAvailableBatchID_WithRemainingSpace IS NULL
	BEGIN
		SET @TopAvailableBatchID_WithRemainingSpace = 0
	END

	--Now, Assign BatchID -------------------------------------------------	
	--(1) If this OPID has no BatchID assigned yet, and there is no existing available BatchID that has room to fit this OPID, then use @TopAvailableBatchID. 
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace = 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID

		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch06 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount
		
		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(2) If at BatchID exists with enough room to accommodate this OPID, and this OPID has not been assigned a BatchID yet, then use @TopAvailableBatchID_WithRemainingSpace.
	IF @BatchID = 0 AND @TopAvailableBatchID_WithRemainingSpace <> 0 AND @BatchFlag = 0
	BEGIN
		--get batchID
		SET @BatchID = @TopAvailableBatchID_WithRemainingSpace
		
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch06 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END

	--(3) when this particular PKID's OPID has already been assigned a batchID, we need to simply update this PKID to match its fellow OPIDs
	ELSE IF @BatchID <> 0 AND @BatchFlag = 0
	BEGIN
		--update cavity data
		UPDATE i
		SET BatchID = @BatchID
		FROM ImposerNCCavities i
		INNER JOIN #Batch06 a ON a.OPID = i.OPID
		WHERE a.RowID = @RWCT3
		AND ISNULL(i.BatchID, 0) <> @BatchID

		--determine batchID counts for sheet-limit adherence
		SET @CurrentCount = (SELECT ISNULL(COUNT(PKID), 0)
							FROM ImposerNCCavities
							WHERE BatchID = @BatchID)

		--update BatchCount worktable with currentCount for given batchID; this is a wipe and refresh b/c table is small
		DELETE FROM ImposerNCCCavities_BatchCount
		WHERE BatchID = @BatchID

		INSERT INTO ImposerNCCCavities_BatchCount (BatchID, CurrentCount)
		SELECT @BatchID, @CurrentCount

		--set flag that indicates that this PKID has been batched
	SET @BatchFlag = 1
	END
SET @RWCT3 = @RWCT3 + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// JAG
--first, fix PKID/RowID entanglement
TRUNCATE TABLE ImposerNCCavitiesStaged

INSERT INTO ImposerNCCavitiesStaged (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver
FROM ImposerNCCavities ORDER BY BatchID, PKID

UPDATE ImposerNCCavitiesStaged
SET PKID_old = PKID,
	PKID = RowID
WHERE 1 = 1

--SELECT * FROM ImposerNCCavitiesStaged

--declare variables and tables
DECLARE @NumRec5 INT,
		@RWCT5 INT,
		@BatchID5 INT,
		@NumbRec5SubLoop INT, 
		@RWCT5SubLoop INT, 
		@PKID DECIMAL(10,2),
		@Count INT,
		@CountHalf INT,
		@MinValue INT,
		@MaxValue INT,
		@FirstPKIDInBatch INT,
		@Offset INT,
		@CalcPKID INT

IF OBJECT_ID('tempdb..#BatchJagger') IS NOT NULL DROP TABLE #BatchJagger	
CREATE TABLE #BatchJagger (
				RowID INT IDENTITY(1, 1), 
				BatchID INT)

IF OBJECT_ID('tempdb..#SubBatchJagger') IS NOT NULL DROP TABLE #SubBatchJagger	
CREATE TABLE #SubBatchJagger (
				RowID INT IDENTITY(1, 1), 
				BatchID INT,
				PKID INT NOT NULL)

IF OBJECT_ID('tempdb..#ImposerJag') IS NOT NULL DROP TABLE #ImposerJag 
CREATE TABLE #ImposerJag (
		   RowID INT IDENTITY(1, 1)
		  ,PKID INT NOT NULL
		  ,PKID_Old INT NOT NULL
		  ,OrderNo NVARCHAR(50)
		  ,OPID INT
		  ,Surface1 NVARCHAR(100)
		  ,Surface2 NVARCHAR(100)
		  ,Surface3 NVARCHAR(100)
		  ,TicketName NVARCHAR(100)
		  ,Resubmit BIT
		  ,Expedite BIT
		  ,FirstInstance BIT
		  ,RowSort INT
		  ,UV NVARCHAR(50)
		  ,UVColor NVARCHAR(50)
		  ,BatchID INT
		  ,ExpoSub BIT
		  ,JagQTY INT
		  ,JagUnder BIT
		  ,JagSolo BIT
		  ,JagOver BIT)

IF OBJECT_ID('tempdb..#ImposerJagPlaceholder') IS NOT NULL DROP TABLE #ImposerJagPlaceholder 
CREATE TABLE #ImposerJagPlaceholder (
		   RowID INT IDENTITY(1, 1)
		  ,PKID INT NOT NULL
		  ,PKID_Old INT NOT NULL
		  ,OrderNo NVARCHAR(50)
		  ,OPID INT
		  ,Surface1 NVARCHAR(100)
		  ,Surface2 NVARCHAR(100)
		  ,Surface3 NVARCHAR(100)
		  ,TicketName NVARCHAR(100)
		  ,Resubmit BIT
		  ,Expedite BIT
		  ,FirstInstance BIT
		  ,RowSort INT
		  ,UV NVARCHAR(50)
		  ,UVColor NVARCHAR(50)
		  ,BatchID INT
		  ,ExpoSub BIT
		  ,JagQTY INT
		  ,JagUnder BIT
		  ,JagSolo BIT
		  ,JagOver BIT)

INSERT INTO #BatchJagger (BatchID)
SELECT DISTINCT BatchID
FROM ImposerNCCavitiesStaged
ORDER BY BatchID

SET @NumRec5 = @@ROWCOUNT
SET @RWCT5 = 1

--main loop begin------------------------------------------------------
WHILE @RWCT5 <= @NumRec5
BEGIN
	SET @BatchID5 = (SELECT TOP (1) ISNULL(BatchID, 0)
					FROM #BatchJagger
					WHERE RowID = @RWCT5)

	TRUNCATE TABLE #SubBatchJagger
	INSERT INTO #SubBatchJagger (BatchID, PKID)
	SELECT DISTINCT x.BatchID, x.PKID
	FROM ImposerNCCavitiesStaged x
	WHERE x.BatchID = @BatchID5
	ORDER BY x.BatchID, x.PKID

	SET @NumbRec5SubLoop = @@ROWCOUNT
	SET @RWCT5SubLoop = 1

	--set batch level variables -----------------------------------------

	--determine the total number of records in the current batch
	SET @Count = 0
	SET @Count = (SELECT ISNULL(COUNT(PKID), 0) FROM ImposerNCCavitiesStaged WHERE BatchID = @BatchID5)

	--determine half (rounded down) of the total number of records in the current batch
	SET @CountHalf = 0
	SET @CountHalf = (SELECT ISNULL(COUNT(PKID)/2, 0) FROM ImposerNCCavitiesStaged WHERE BatchID = @BatchID5)

	--lowest value in batch
	SET @MinValue = 0
	SET @MinValue = (SELECT TOP (1) PKID FROM ImposerNCCavitiesStaged WHERE BatchID = @BatchID5 ORDER BY PKID)
	
	--highest value in batch
	SET @MaxValue = 0
	SET @MaxValue = (SELECT TOP (1) PKID FROM ImposerNCCavitiesStaged WHERE BatchID = @BatchID5 ORDER BY PKID DESC)

	--sub loop begin------------------------------------------------------
	--in this loop, each PKID for the given @BatchID5 is individually inserted into #ImposerJag in 1 of 3 ways listed below

	WHILE @RWCT5SubLoop <= @NumbRec5SubLoop
	BEGIN
			SET @PKID = (SELECT TOP (1) ISNULL(j.PKID, 0)
						FROM #SubBatchJagger j
						LEFT JOIN #ImposerJag i ON j.PKID = i.PKID
						WHERE j.RowID = @RWCT5SubLoop
						AND j.BatchID = @BatchID5
						AND i.PKID IS NULL)	

			--anchor @CalcPKID to "1" and proceed with 1 of 3 calculations below.
			SET @CalcPKID = @PKID - @MinValue + 1


			--| OPTION #1 | first row | if PKID actually equals "1" because it is the first row in the entire imposition, Option #1 occurs.
			IF @PKID = @MinValue
			BEGIN
				INSERT INTO #ImposerJag (PKID, PKID_Old, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
				SELECT @PKID, a.PKID_Old, a.OrderNo, a.OPID, a.Surface1, a.Surface2, a.Surface3, a.TicketName, a.Resubmit, a.Expedite, a.FirstInstance, a.RowSort, a.UV, a.UVColor, a.BatchID, a.ExpoSub, a.JagQTY, a.JagUnder, a.JagSolo, a.JagOver
				FROM ImposerNCCavitiesStaged a
				LEFT JOIN #ImposerJag j ON a.PKID_Old = j.PKID_Old
				WHERE a.PKID = @MinValue 
				AND a.ticketName IS NOT NULL
				AND j.PKID_Old IS NULL
			END

			--| OPTION #2 | even rows | 
			IF @CalcPKID % 2 = 0
			BEGIN
				INSERT INTO #ImposerJag (PKID, PKID_Old, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
				SELECT @PKID, a.PKID_Old, a.OrderNo, a.OPID, a.Surface1, a.Surface2, a.Surface3, a.TicketName, a.Resubmit, a.Expedite, a.FirstInstance, a.RowSort, a.UV, a.UVColor, a.BatchID, a.ExpoSub, a.JagQTY, a.JagUnder, a.JagSolo, a.JagOver
				FROM ImposerNCCavitiesStaged a
				LEFT JOIN #ImposerJag j ON a.PKID_Old = j.PKID_Old
				WHERE a.PKID = @CountHalf + CEILING(@CalcPKID/2) + @MinValue - 1
				AND @PKID <> @MaxValue
				AND j.PKID_Old IS NULL
			END

			---| OPTION #3 | odd rows | 
			IF @CalcPKID % 2 = 1
			BEGIN
				INSERT INTO #ImposerJag (PKID, PKID_Old, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
				SELECT @PKID, a.PKID_Old, a.OrderNo, a.OPID, a.Surface1, a.Surface2, a.Surface3, a.TicketName, a.Resubmit, a.Expedite, a.FirstInstance, a.RowSort, a.UV, a.UVColor, a.BatchID, a.ExpoSub, a.JagQTY, a.JagUnder, a.JagSolo, a.JagOver
				FROM ImposerNCCavitiesStaged a
				LEFT JOIN #ImposerJag j ON a.PKID_Old = j.PKID_Old
				WHERE a.PKID = CEILING(@CalcPKID/2) + @MinValue
				AND @CalcPKID <> 1
				AND @PKID <> 1
				AND @PKID <> @MaxValue
				AND j.PKID_Old IS NULL
			END

			--| OPTION #4 | last row | if PKID actually is the last row in the given batch, it is dealt with here.
			IF @PKID = @MaxValue
			BEGIN
				INSERT INTO #ImposerJag (PKID, PKID_Old, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
				SELECT @PKID, a.PKID_Old, a.OrderNo, a.OPID, a.Surface1, a.Surface2, a.Surface3, a.TicketName, a.Resubmit, a.Expedite, a.FirstInstance, a.RowSort, a.UV, a.UVColor, a.BatchID, a.ExpoSub, a.JagQTY, a.JagUnder, a.JagSolo, a.JagOver
				FROM ImposerNCCavitiesStaged a
				LEFT JOIN #ImposerJag j ON a.PKID_Old = j.PKID_Old
				WHERE a.PKID = @MaxValue 
				AND j.PKID_Old IS NULL
			END

	-- grab next available PKID in current batch
	SET @RWCT5SubLoop = @RWCT5SubLoop + 1
	END
	--sub loop end ------------------------------------------------------

--at the end of each main batch-centric loop, submit current data from #ImposerJag to #ImposerJagPlaceholder which will eventually import into ImposerNCCavities. Then truncate #ImposerJag.
INSERT INTO #ImposerJagPlaceholder (PKID, PKID_Old, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver)
SELECT a.PKID, a.PKID_Old, a.OrderNo, a.OPID, a.Surface1, a.Surface2, a.Surface3, a.TicketName, a.Resubmit, a.Expedite, a.FirstInstance, a.RowSort, a.UV, a.UVColor, a.BatchID, a.ExpoSub, a.JagQTY, a.JagUnder, a.JagSolo, a.JagOver
FROM #ImposerJag a
ORDER BY a.RowID

--Refresh Jag table for next BatchID jag
TRUNCATE TABLE #ImposerJag

SET @RWCT5 = @RWCT5 + 1
END
--main loop end ------------------------------------------------------

--now refresh this BatchID's PKIDs that have been jagged.
TRUNCATE TABLE ImposerNCCavities

SET IDENTITY_INSERT ImposerNCCavities ON
INSERT INTO ImposerNCCavities (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver, PKID_Old)
SELECT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowID AS RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver, PKID_Old
FROM #ImposerJagPlaceholder
ORDER BY BatchID, RowSort
SET IDENTITY_INSERT ImposerNCCavities OFF

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FIRST INSTANCE

IF OBJECT_ID('tempdb..#ImposerJag4') IS NOT NULL DROP TABLE #ImposerJag4 
CREATE TABLE #ImposerJag4 (
		   RowID INT IDENTITY(1, 1)
		  ,PKID INT NOT NULL
		  ,PKID_Old INT NOT NULL
		  ,OrderNo NVARCHAR(50)
		  ,OPID INT
		  ,Surface1 NVARCHAR(100)
		  ,Surface2 NVARCHAR(100)
		  ,Surface3 NVARCHAR(100)
		  ,TicketName NVARCHAR(100)
		  ,Resubmit BIT
		  ,Expedite BIT
		  ,FirstInstance BIT
		  ,RowSort INT
		  ,UV NVARCHAR(50)
		  ,UVColor NVARCHAR(50)
		  ,BatchID INT
		  ,ExpoSub BIT
		  ,JagQTY INT
		  ,JagUnder BIT
		  ,JagSolo BIT
		  ,JagOver BIT)

DECLARE @NumberRecords4 INT, 
		  @RWCT4 INT, 
		  @OPID4 INT

INSERT INTO #ImposerJag4 (PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver, PKID_Old)
SELECT PKID, OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, BatchID, ExpoSub, JagQTY, JagUnder, JagSolo, JagOver, PKID_Old
FROM ImposerNCCavities
ORDER BY RowSort

SET @NumberRecords4 = @@ROWCOUNT
SET @RWCT4 = 1

WHILE @RWCT4 <= @NumberRecords4
BEGIN
	 SELECT @OPID4 = OPID
	 FROM #ImposerJag4
	 WHERE RowID = @RWCT4

	 UPDATE x
	 SET FirstInstance = 1
	 FROM ImposerNCCavities x
	 WHERE x.opid = @OPID4
	 AND x.RowSort IN
		  (SELECT TOP 1 z.RowSort
		  FROM #ImposerJag4 z
		  WHERE z.opid = @OPID4
		  AND z.TicketName IS NULL
		  AND z.opid NOT IN
				(SELECT OPID
				FROM ImposerNCCavities
				WHERE FirstInstance = 1)
		  ORDER BY z.RowSort)

	 SET @RWCT4 = @RWCT4 + 1
END

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ImpositionID

--Generate next available ImpositionID
UPDATE ImposerExecutionLog
SET isApplied = 1
WHERE isApplied = 0

INSERT INTO ImposerExecutionLog (ImpositionName, ImpositionStartDate, StatusMessage)
SELECT 'ImposerNC', GETDATE(), 'Data Retrieved'

DECLARE @ImpositionID INT
SET @ImpositionID = (SELECT TOP 1 ISNULL(ImpositionID, 0)
				FROM ImposerExecutionLog
				WHERE isApplied = 0
				AND StatusMessage = 'Data Retrieved')

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// REPORT

TRUNCATE TABLE ImposerNCReport
INSERT INTO ImposerNCReport (ImpositionID, OrderNo, OPID, uvType, Quantity, ShipType)
SELECT @ImpositionID, t.OrderNo, t.OPID,
CASE WHEN t.UV = 1 THEN 'UV/UV'
	 WHEN t.UV = 2 THEN 'UV/Matte'
	 WHEN t.UV = 3 THEN 'Matte/UV'
	 WHEN t.UV = 4 THEN 'Matte/Matte'
	 ELSE 'UV/Matte'
END AS uvType,
RIGHT('000' + REPLACE(t.Quantity, 'Quantity: ', ''), 4) AS Quantity,
CASE WHEN t.ShipType = 'Next Day' THEN 'Expedite'
	 WHEN t.ShipType = '2 Day' THEN 'Expedite'
	 WHEN t.ShipType = '3 Day' THEN 'Expedite'
	 ELSE 'Ship'
END AS ShipType
FROM ImposerNCTickets t
ORDER BY t.resubmit DESC, t.expedite DESC, t.OPID, t.productCount

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// LOGS

--Ticket Log
INSERT INTO ImposerNCTicketsLog (OrderNo, OrderID, OppoPKID, OPID, OutputName, Surface1, Surface2, Surface3, Surface4, Barcode, AuxiliaryText, Quantity, pUnitCount, 
ProductCount, ShipColor, ShipsWith, ShipsWithAlt, ShipType, ShipZone, Resubmit, Expedite, ShipLine1, ShipLine2, ShipLine3, ShipLine4, ShipLine5, CustomProducts, fasTrakProducts,
StockProduct1, StockProduct2, StockProduct3, StockProduct4, StockProduct5, StockProduct6, GroupID, StoreLogo, UV, Aux1, Aux2, Aux3, Aux4, Aux5, Aux6, Aux7, Aux8, Aux9, Aux10,
Aux11, Aux12, Aux13, Aux14, Aux15, Aux16, Aux17, Aux18, Aux19, Aux20, ImpositionID)
SELECT OrderNo, OrderID, OppoPKID, OPID, OutputName, Surface1, Surface2, Surface3, Surface4, Barcode, AuxiliaryText, Quantity, pUnitCount, ProductCount, ShipColor,
ShipsWith, ShipsWithAlt, ShipType, ShipZone, Resubmit, Expedite, ShipLine1, ShipLine2, ShipLine3, ShipLine4, ShipLine5, CustomProducts, fasTrakProducts, StockProduct1,
StockProduct2, StockProduct3, StockProduct4, StockProduct5, StockProduct6, GroupID, StoreLogo, UV, Aux1, Aux2, Aux3, Aux4, Aux5, Aux6, Aux7, Aux8, Aux9, Aux10, Aux11, Aux12,
Aux13, Aux14, Aux15, Aux16, Aux17, Aux18, Aux19, Aux20, @ImpositionID
FROM ImposerNCTickets
ORDER BY resubmit DESC, expedite DESC, OPID, productCount

--Cavity Log
INSERT INTO ImposerNCCavitiesLog (OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, ImpositionID)
SELECT OrderNo, OPID, Surface1, Surface2, Surface3, TicketName, Resubmit, Expedite, FirstInstance, RowSort, UV, UVColor, @ImpositionID
FROM ImposerNCCavities
ORDER BY RowSort

--Report Log
INSERT INTO ImposerNCReportLog (ImpositionID, OrderNo, OPID, uvType, Quantity, ShipType, ReportDate)
SELECT ImpositionID, OrderNo, OPID, uvType, Quantity, ShipType, ReportDate
FROM ImposerNCReport
ORDER BY PKID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FLAGS

--Set flag back to '0'.
UPDATE Flags
SET FlagStatus = 0
WHERE FlagName = 'ImposerNCTickets'

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// (DESTRUCTIVE) OPID UPDATE - REMOVE AFTER [TEST]

--Update OPID status fields indicating successful submission to switch
--UPDATE op
--	fastTrak_status_lastModified = GETDATE(),
--	fastTrak_resubmit = 0	
--FROM tblOrders_Products op
--INNER JOIN ImposerNCTickets x ON op.ID = x.OPID

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// RETRIEVE DATA

--retrieve Imposition/Batch data --------

SELECT impositionID, 
CASE WHEN @PLEX = 1 THEN 'Simplex'
	 WHEN @PLEX = 2 THEN 'Duplex'
	 ELSE 'Simplex'
END AS impositionPlex,
impositionStartDate
FROM ImposerExecutionLog
WHERE isApplied = 0
AND ImpositionName = 'ImposerNC'

--retrieve ticket data --------

SELECT pkid, orderNo, opid, outputName, surface1, surface2, surface3, surface4, barcode, auxiliaryText, quantity, pUnitCount, productCount, shipColor, 
shipsWith, shipsWithAlt, shipType, shipZone, storeLogo, resubmit, expedite, shipLine1, shipLine2, shipLine3, shipLine4, shipLine5, customProducts, fasTrakProducts, 
stockProduct1, stockProduct2, stockProduct3, stockProduct4, stockProduct5, stockProduct6
FROM ImposerNCTickets
ORDER BY resubmit DESC, expedite DESC, opid, productCount

--retrieve cavity data --------

--Original Code, pre multi-jag.
--SELECT pkid, orderNo, opid, surface1, surface2, surface3, ticketName, resubmit, expedite, firstInstance, RowSort, uv, uvColor
--FROM ImposerNCCavities
--ORDER BY RowSort

SELECT PKID, orderNo, opid, surface1, surface2, surface3, ticketName, resubmit, expedite, firstInstance, rowSort, uv, uvColor, batchID
FROM ImposerNCCavities
ORDER BY BatchID, RowSort

--retrieve report data --------

SELECT orderNo, opid, uvType, quantity, shipType
FROM ImposerNCReport
ORDER BY PKID

--END
END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH