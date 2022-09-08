CREATE PROCEDURE [dbo].[usp_popTrack]
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		01/01/2008
-- Purpose		This proc populates tblJobTrack FROM Endicia, WorldShip and 
--					QuantumView, UPDATEs statuses, writes notes, etc.

-------------------------------------------------------------------------------
-- Modification History
--
--07/29/16			Some Syntax fixes.
--08/01/17			Fix JobTrack Weight conversion error
--12/27/17			BS, Modifided Weight update section to prevent deadlocking
--09/15/18			BS, Still trying to fix deadlocking.  
--09/18/18			JF, updates throughout including pulling of barcode related updates, which are ancient.
--10/01/18			JF, updated LN135 CTE to limit logical reads as per Query Store findings.
--10/02/18			BS, More deadlock fix attempts on section 5
--07/07/20			JF, killed references to transactionID throughout procedure. We think that transactionID has be deprecated.
--04/27/21			CKB, Markful
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

--PART B: POPULATE tblJobTrack with Endicia Data , FIX tblOrders.shippingDESC ----------------------------------------------------------------------------------------------------------------------
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

--step 2, stamp the tblEndiciaPostBack data, so that it will NOT be reimported again.
UPDATE tblEndiciaPostBack
SET jobTrack_migStamp = GETDATE()
WHERE 
jobTrack_migStamp IS NULL 
OR jobTrack_migStamp = ''

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
;WITH cte 
AS (SELECT jobnumber 
	FROM tblJobTrack
	WHERE DATEDIFF(DD, CreatedOn, GETDATE()) < 60
	AND CHARINDEX('USPS',trackSource) > 0
	AND jobnumber IS NOT NULL
	AND jobnumber <> ''
	AND trackingNumber LIKE '9%')

UPDATE o
SET shippingDesc = 'USPS'
FROM tblOrders o
INNER JOIN cte ON cte.jobnumber = o.orderNo
WHERE CHARINDEX('UPS',shippingDesc) > 0
AND shippingDesc IS NOT NULL
AND shippingDesc <> 'USPS'
		
--step 4.b, this updates shippingDesc on tblOrders with USPS with a USPS Tracking# IS scanned in tbl_barCode (NOT USED 9/18/18)
--;WITH cte 
--AS 		(SELECT jobNo 
--	FROM tbl_barCode 
--	WHERE DATEDIFF(DD, Time_Stamp, GETDATE()) < 60
--	AND (trackingNo LIKE '94%' 
--	OR CHARINDEX('USPS',trackingNo) > 0))

--UPDATE tblOrders
--SET shippingDesc = 'USPS'
--FROM tblOrders o 
--INNER JOIN cte c ON c.JobNo = o.orderNo
--WHERE CHARINDEX('USPS',shippingDesc) > 0
--AND shippingDesc <> 'USPS'
;WITH cte
AS (SELECT jobnumber, [ups service] 
	FROM tblJobTrack x WITH (NOLOCK)
	INNER JOIN tblOrders o WITH (NOLOCK) ON x.jobNumber = o.orderNo
	WHERE x.jobnumber IS NOT NULL
		AND x.jobnumber <> ''
		AND x.trackingNumber LIKE '1Z%'
		AND CHARINDEX('USPS',x.trackingNumber) = 0
		AND NULLIF(x.[ups service],'') IS NOT NULL --IN ('012','002','003')
		AND o.OrderDate < DATEADD(DD, -365, GETDATE()) 
		AND o.orderStatus NOT IN ('Delivered', 'Failed', 'Cancelled')
	)
--step 5.b
UPDATE tblOrders
SET shippingDesc = CASE [ups service] WHEN '012' THEN 'UPS 3 Day Select'
	WHEN '002' THEN 'UPS 2nd Day Air'
	WHEN '003' THEN 'UPS Ground'
	END
FROM tblOrders o WITH (NOLOCK)
INNER JOIN cte ON cte.jobnumber = o.orderNo
WHERE CHARINDEX('USPS',shippingDesc) > 0

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
UPDATE tblJobTrack SET mailClass = 'UPS - Unspecified' WHERE	trackingNumber LIKE '1Z%' AND trackingNumber NOT LIKE '%stamp%' AND mailClass IS NULL
UPDATE tblJobTrack SET mailClass = 'USPS - Unspecified' WHERE [ups service] IS NULL AND trackingNumber NOT LIKE '1Z%' AND trackingNumber LIKE '9%' AND mailClass IS NULL
UPDATE tblJobTrack SET mailClass = 'Unknown Carrier' WHERE mailClass IS NULL

--PART C: ON HOM DOCK ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--step 1, UPDATE
UPDATE tblOrders
SET orderStatus = 'ON MRK Dock'
WHERE orderStatus NOT LIKE '%Transit%'
AND orderStatus <> 'Delivered'
AND orderStatus NOT IN ('ON HOM Dock','ON MRK Dock')
AND orderNo IN
	(SELECT REPLACE(orderNo, 'ON', '') 
	FROM tblEndiciaPostBack
	WHERE orderNo IS NOT NULL
	AND orderNo <> ''
	AND DATEDIFF(dd, jobTrack_migStamp, GETDATE()) < 2)

--PART D: In Transit USPS (Stamped) ---------------------------------------------------------------------------------------------------------------------------------------------------------------- NOT USED 9/18/18
--step 1, UPDATE, at night
--;WITH cte AS	(SELECT jobNo 
--	FROM tbl_barCode 
--	WHERE CHARINDEX('USPS',trackingNo) > 0
--	AND trackingNo IS NOT NULL
--	AND jobNo IS NOT NULL)

--UPDATE tblOrders
--SET orderStatus = 'In Transit USPS (Stamped)'
--FROM tblOrders o 
--INNER JOIN cte ON cte.JobNo = o.orderNo
--WHERE orderStatus = 'On HOM Dock'	
--AND DATEPART(hh, GETDATE()) >= 20
--AND DATEPART(hh, GETDATE()) <= 24

--step 2, notes
INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType)
SELECT j.jobNumber, 'In Transit USPS (Stamped)', j.transactionDate, 
CASE
	WHEN j.author IS NULL THEN 'Endicia - System'
	WHEN j.author = '' THEN 'Endicia - System'
	ELSE 'Endicia - ' + j.author 
END AS 'author', 
'order' 
FROM tblJobTrack j WITH (NOLOCK)
INNER JOIN tblOrders o WITH (NOLOCK) ON j.jobNumber = o.orderNo
WHERE j.trackSource = 'USPS Endicia'
AND o.orderStatus = 'In Transit USPS (Stamped)'
AND jobNumber NOT IN
	(SELECT jobNumber 
	FROM tbl_Notes WITH (NOLOCK)
	WHERE CONVERT(VARCHAR(255), notes) LIKE 'In Transit USPS (Stamped)' 
	AND notes IS NOT NULL
	AND jobNumber IS NOT NULL
	AND jobNumber <> '')

END TRY
BEGIN CATCH

--Capture errors if they happen
EXEC [usp_StoredProcedureErrorLog]

END CATCH