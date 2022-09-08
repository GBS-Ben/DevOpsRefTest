create PROCEDURE [dbo].[usp_popTrack_backup]
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		01/01/2008
-- Purpose		This proc populates tblJobTrack FROM Endicia, WorldShip and 
--					QuantumView, UPDATEs statuses, writes notes, etc.

-------------------------------------------------------------------------------
-- Modification History
--
-- 7/29/16		Some Syntax fixes.
-- 8/1/2017		Fix JobTrack Weight conversion error
--12/27/17		BS, Modifided Weight update section to prevent deadlocking
-------------------------------------------------------------------------------
SET NOCOUNT ON;

BEGIN TRY
	--PART A: ENDICIA POST BACK DATA - UPDATES ------------------------------------------------------------------------------------------------------------------------------------------------------
	--First, UPDATE tblEndiciaPostBack data to correctly present records that come in with the "attention" field shifted to the right.
	UPDATE tblEndiciaPostBack
	SET attention = address1, 
	address1 = address2, 
	address2 = ''
	WHERE attention = '' 
	AND address1 <> '' 
	AND address2 <> ''

	UPDATE tblEndiciaPostBack
	SET address2 = '' 
	WHERE address1 = address2

	--PART B: POPULATE tblJobTrack with Endicia Data , FIX tblOrders.shippingDESC ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--step 1, Endicia data goes in.
	INSERT INTO tblJobTrack 
	(trackingnumber, jobnumber, [pickup date], 
	[Delivery Street Name], [Delivery City], 
	[Delivery State/Province], [Delivery Postal Code], 
	[subscription file name], 
	trackSource, 
	mailClass, postageAmount, transactionDate, transactionID, [weight], author)
	SELECT 
	trackingNo, REPLACE(orderNo, 'ON', ''), postMarkDate, 
	address1, city, 
	[state], zip, 
	'051225_123456789', --Place Holder Data
	'USPS Endicia', 
	mailClass, 
	CONVERT(MONEY, postageAmount), transactionDate, transactionID, 
	ROUND((FLOOR(CASE  WHEN [weight] LIKE '+%' THEN NULL ELSE [weight] END)/16), 0),  
	RS10 
	FROM tblEndiciaPostBack 
	WHERE jobTrack_migStamp IS NULL
	AND transactionID IS NOT NULL 
	AND transactionID <> ''

	--step 2, stamp the tblEndiciaPostBack data, so that it will NOT be reimported again.
	UPDATE tblEndiciaPostBack
	SET jobTrack_migStamp = GETDATE()
	WHERE transactionID IS NOT NULL 
	AND transactionID <> ''
	AND transactionID IN
		(SELECT transactionID 
		FROM tblJobTrack 
		WHERE transactionID IS NOT NULL 
		AND transactionID <> '')
	AND (jobTrack_migStamp IS NULL OR jobTrack_migStamp = '')

	--step 3, Clean Jobtrack weights and SET default [weight] to "1" for Intranet display purposes
	;WITH weightCTE AS (SELECT * FROM tblJobTrack WHERE LEN([weight])> 6)
	UPDATE t
	SET [weight] = RIGHT(t.[weight], 4)
	FROM tblJobTrack t 
	INNER JOIN weightCTE c ON t.PKID = c.PKID 

	;WITH weightCTE AS (SELECT * FROM tblJobTrack WHERE [weight] LIKE '%.%')
	UPDATE t
	SET [weight] = ROUND((FLOOR(CASE  WHEN t.[weight] LIKE '+%' THEN NULL ELSE t.[weight] END)/16), 0)
	FROM tblJobTrack t 
	INNER JOIN weightCTE c ON t.PKID = c.PKID 

	;WITH weightCTE AS (SELECT * FROM tblJobTrack WHERE [weight] = 0)
	UPDATE t
	SET [weight] = 1 
	FROM tblJobTrack t 
	INNER JOIN weightCTE c ON t.PKID = c.PKID 

	--step 4.a, fix tblOrders.shippingDesc, when orders come in UPS, but we later decide to ship USPS, 
	--				we need to change the "method", which IS tblOrders.shippingDesc to USPS.
	--BJS 12/27/2017 Added CTE and INNER JOIN to prevent deadlocks
	;WITH cte 
	AS (SELECT DISTINCT jobnumber 
		FROM tblJobTrack
		WHERE trackSource LIKE '%USPS%'
		AND jobnumber IS NOT NULL
		AND jobnumber <> ''
		AND trackingNumber LIKE '9%')

	UPDATE o
	SET shippingDesc = 'USPS'
	FROM tblOrders o
	INNER JOIN cte ON cte.jobnumber = o.orderNo --this was a sub query before
	WHERE shippingDesc LIKE '%UPS%'
	AND shippingDesc IS NOT NULL

		
	--step 4.b, this updates shippingDesc on tblOrders with USPS with a USPS Tracking# IS scanned in tbl_barCode
	UPDATE tblOrders
	SET shippingDesc = 'USPS'
	WHERE orderNo IN
		(SELECT DISTINCT jobNo 
		FROM tbl_barCode 
		WHERE trackingNo LIKE '94%' 
		OR trackingNo LIKE '%USPS%')
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%UPS%'

	--step 5.a, fix tblOrders.shippingDesc, values that are USPS that should be 1 of 3 variants of UPS Services.
	UPDATE tblOrders
	SET shippingDesc = 'UPS Ground'
	WHERE shippingDesc LIKE '%USPS%'
	AND shippingDesc IS NOT NULL
	AND orderNo IN
		(SELECT DISTINCT jobnumber 
		FROM tblJobTrack
		WHERE jobnumber IS NOT NULL
		AND jobnumber <> ''
		AND trackingNumber LIKE '1Z%'
		AND trackingNumber NOT LIKE '%USPS%'
		AND [ups service] = '003')

	--step 5.b
	UPDATE tblOrders
	SET shippingDesc = 'UPS 3 Day Select'
	WHERE shippingDesc LIKE '%USPS%'
	AND shippingDesc IS NOT NULL
	AND orderNo IN
		(SELECT DISTINCT jobnumber 
		FROM tblJobTrack
		WHERE jobnumber IS NOT NULL
		AND jobnumber <> ''
		AND trackingNumber LIKE '1Z%'
		AND trackingNumber NOT LIKE '%USPS%'
		AND [ups service] = '012')

	--step 5.c
	UPDATE tblOrders
	SET shippingDesc = 'UPS 2nd Day Air'
	WHERE shippingDesc LIKE '%USPS%'
	AND shippingDesc IS NOT NULL
	AND orderNo IN
		(SELECT DISTINCT jobnumber 
		FROM tblJobTrack
		WHERE jobnumber IS NOT NULL
		AND jobnumber <> ''
		AND trackingNumber LIKE '1Z%'
		AND trackingNumber NOT LIKE '%USPS%'
		AND [ups service] = '002')

	--step 6: UPDATE mailClass
	UPDATE tblJobTrack SET mailClass = 'UPS Next Day Air' WHERE [ups service] = '001' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS 2nd Day Air' WHERE [ups service] = '002' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Ground' WHERE [ups service] = '003' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Worldwide Expedited' WHERE [ups service] = '007' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Worldwide Standard' WHERE [ups service] = '011' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS 3 Day Select' WHERE [ups service] = '012' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Next Day Air Saver' WHERE [ups service] = '013' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Next Day Air Early AM' WHERE [ups service] = '014' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Economy' WHERE [ups service] = '021' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Worldwide Express Plus' WHERE [ups service] = '054' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS 2nd Day AM' WHERE [ups service] = '059' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Express NA1' WHERE [ups service] = '064' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Express Saver' WHERE [ups service] = '065' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'Worldwide Express Freight' WHERE [ups service] = '066' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Today Standard' WHERE [ups service] = '082' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Today Dedicated Courier' WHERE [ups service] = '083' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Today Intercity' WHERE [ups service] = '084' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Today Express' WHERE [ups service] = '085' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS Today Express Saver' WHERE [ups service] = '086' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS - Unspecified' WHERE [ups service] IS NULL AND trackingNumber LIKE '1Z%' AND trackingNumber NOT LIKE '%stamp%' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS - Unspecified' WHERE [ups service] = '' AND trackingNumber LIKE '1Z%' AND trackingNumber NOT LIKE '%stamp%' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'UPS - Unspecified' WHERE trackingNumber LIKE '1Z%' AND trackingNumber NOT LIKE '%stamp%' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'USPS - Unspecified' WHERE [ups service] IS NULL AND trackingNumber NOT LIKE '1Z%' AND trackingNumber LIKE '9%' AND mailClass IS NULL
	UPDATE tblJobTrack SET mailClass = 'Unknown Carrier' WHERE mailClass IS NULL

	--step 7: when we decide to deal with Multitracks, or USPS/UPS multi's, deal with it here. It's massive.
	-- [...]

	--PART C: ON HOM DOCK ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--step 1, UPDATE
	UPDATE tblOrders
	SET orderStatus = 'ON HOM Dock'
	WHERE orderStatus NOT LIKE '%Transit%'
	AND orderStatus <> 'Delivered'
	AND orderStatus <> 'ON HOM Dock'
	AND orderNo IN
		(SELECT REPLACE(orderNo, 'ON', '') 
		FROM tblEndiciaPostBack
		WHERE orderNo IS NOT NULL
		AND orderNo <> ''
		AND DATEDIFF(dd, jobTrack_migStamp, GETDATE()) < 2)

		/*
	--PART D: In Transit USPS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--step 1, UPDATE, at night
	UPDATE tblOrders
	SET orderStatus = 'In Transit USPS'
	WHERE orderStatus = 'ON HOM Dock'
	AND orderNo IN
		(SELECT DISTINCT REPLACE(orderNo, 'ON', '') 
		FROM tblEndiciaPostBack
		WHERE orderNo IS NOT NULL
		AND DATEDIFF(hh, jobTrack_migStamp, GETDATE()) >= 4)
		AND DATEPART(hh, GETDATE()) >= 20
		AND DATEPART(hh, GETDATE()) <= 24

	--step 2, notes
	INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType)
	SELECT jobNumber, 'In Transit USPS', transactionDate, 
	CASE
		WHEN author IS NULL THEN 'Endicia - NULL'
		WHEN author = '' THEN 'Endicia - NULL'
		ELSE 'Endicia - ' + author 
	END AS 'author',
	'order' 
	FROM tblJobTrack
	WHERE trackSource = 'USPS Endicia'
	AND jobNumber NOT IN
		(SELECT DISTINCT jobNumber 
		FROM tbl_Notes 
		WHERE CONVERT(VARCHAR(255), notes) LIKE '%In Transit USPS%' 
		AND notes IS NOT NULL
		AND jobNumber IS NOT NULL
		AND jobNumber <> '')
	AND jobNumber IN
		(SELECT DISTINCT orderNo 
		FROM tblOrders 
		WHERE orderStatus = 'In Transit USPS')
	AND transactionID IS NOT NULL 
	AND transactionID <> ''

	*/
	--PART D: In Transit USPS (Stamped) ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--step 1, UPDATE, at night
	UPDATE tblOrders
	SET orderStatus = 'In Transit USPS (Stamped)'
	WHERE orderStatus = 'On HOM Dock'
	AND orderNo IN
		(SELECT DISTINCT jobNo 
		FROM tbl_barCode 
		WHERE trackingNo LIKE '%USPS%' 
		AND trackingNo IS NOT NULL
		AND jobNo IS NOT NULL)
	AND DATEPART(hh, GETDATE()) >= 20
	AND DATEPART(hh, GETDATE()) <= 24

	--step 2, notes
	INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType)
	SELECT jobNumber, 'In Transit USPS (Stamped)', transactionDate, 
	CASE
		WHEN author IS NULL THEN 'Endicia - NULL'
		WHEN author = '' THEN 'Endicia - NULL'
		ELSE 'Endicia - ' + author 
	END AS 'author', 
	'order' 
	FROM tblJobTrack
	WHERE trackSource = 'USPS Endicia'
	AND jobNumber NOT IN
		(SELECT DISTINCT jobNumber 
		FROM tbl_Notes 
		WHERE CONVERT(VARCHAR(255), notes) LIKE 'In Transit USPS (Stamped)' 
		AND notes IS NOT NULL
		AND jobNumber IS NOT NULL
		AND jobNumber <> '')
	AND jobNumber IN
		(SELECT DISTINCT orderNo 
		FROM tblOrders 
		WHERE orderStatus = 'In Transit USPS (Stamped)')
	AND transactionID IS NOT NULL 
	AND transactionID <> ''

	--PART E: Delivered, The 5 Day Drop Off
	 --This has moved to the nightly proc, usp_updateUSPS
	 --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [usp_StoredProcedureErrorLog]

END CATCH