CREATE PROCEDURE [dbo].[usp_pushBackQV]
AS

SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		01/01/2008
-- Purpose		Polls UPS QuantumView Data for insert into DB.
--					Updates order statuses and writes notes for new shipping info.

-------------------------------------------------------------------------------
-- Modification History
--
-- 7/18/16		Updated frequency of operation in JOB from 30m to 30s. Syntax.
-- 7/27/16		Updated Syntax.
-- 7/21/17		Added tracking number to the On HOM Dock note
-- 2/20/18		Updated initial query and subsequent areas relating to referencenumber, jf.
-- 2/20/18		Updated initial query to look at subquery of trackingnumbers, not jobnumber, thus bringing in ALL unique trackingnumbers per orderno, jf.
-- 3/14/18			BJS Added Prefix for reference to grab WEB
-- 5/14/20		JF, Y2K, fixing substring operations.
--04/27/21		CKB, Markful
--07/09/21		JF, quick fix for MRK
--02/03/22		CKB, refactored to reduce blocking
-------------------------------------------------------------------------------

--// Insert QV data into tblJobTrack
INSERT INTO tblJobTrack (trackingnumber, jobNumber, [pickup date], [package count], [weight], mailclass, trackSource, author)
SELECT x.trackingnumber, 
x.jobnumber, 
SUBSTRING(x.createdate, 5, 2) + '/' + SUBSTRING(x.createdate, 7, 2) + '/' + SUBSTRING(x.createdate, 1, 4) AS 'createDate', 
x.numberpackages, 
ROUND(x.actualweight, 0), 
'UPS ' + x.servicetype AS 'serviceType', 
'UPS WorldShip - Pending',
x.reference5
FROM vwTbl_upsx x
LEFT JOIN tbljobtrack jt
	on x.trackingnumber = jt.trackingnumber
		and x.jobnumber = jt.jobnumber
		and (trackSource = 'UPS Quantum View' OR trackSource = 'UPS WorldShip')
WHERE 1=1
AND createdate > convert(varchar(8),getdate()-30,112)
AND SUBSTRING(x.jobnumber, 1 ,3) IN ('HOM','MRK', 'NCC', 'WEB', 'ATM', 'ADH')
AND x.trackingnumber IS NOT NULL
AND jt.trackingnumber IS NULL

select orderid
into #updates
from tblOrders o
WHERE orderNo IN
		(SELECT jobNumber 
		FROM tblJobTrack 
		WHERE trackSource IN ('UPS WorldShip - Pending' ,'USPS Endicia')
		AND jobNumber IS NOT NULL 
		AND trackSource IS NOT NULL)
AND orderStatus NOT IN ('On HOM Dock','On MRK Dock', 'Delivered', 'Failed', 'Cancelled')
AND orderStatus NOT LIKE '%In Transit%'

--// update orderStatus for UPS
IF (SELECT COUNT(*) FROM #UPDATES) > 0 
BEGIN
	UPDATE o
	SET orderStatus = 'On MRK Dock'
	from tblOrders o
	inner join #updates u on o.orderid = u.orderid
END

DROP TABLE #updates

--// update Fast Trak Badge products to tblOrders_Products.fastTrak_completed = 1 (which means, 'Completed')
-- update 6/10/15
SELECT id
INTO #updateOP
FROM tblOrders_Products 
WHERE 
orderID IN
		(SELECT orderID 
		FROM tblOrders
		WHERE orderStatus LIKE '%Dock%' 
		OR orderStatus LIKE '%Transit%' 
		OR orderStatus LIKE '%Delivered%')
AND fastTrak_completed = 0
AND fastTrak = 1
AND fastTrak_productType = 'Badge'

IF (SELECT COUNT(*) FROM #updateOP) > 0 
BEGIN
	UPDATE op
	SET fastTrak_completed = 1, 
	fastTrak_Status = 'Completed'
	FROM tblOrders_Products op
	INNER JOIN #updateOP u on op.ID = u.ID
END
DROP TABLE #updateOP


--// write to tbl_Notes, "ON HOM Dock" FOR USPS
INSERT INTO tbl_notes (jobNumber, notes, noteDate, author, notesType)
SELECT DISTINCT a.orderNo, 'On MRK Dock' + ISNULL(' -  '  + b.trackingnumber, ''),GETDATE(),
CASE
	WHEN author IS NULL THEN 'Endicia - NULL'
	WHEN author = '' THEN 'Endicia - NULL'
	ELSE 'Endicia - ' + author 
END AS 'author', 
'order'
FROM tblJobTrack b
INNER JOIN tblOrders a
	ON b.jobNumber = a.orderNo
WHERE b.jobNumber NOT IN
		(SELECT jobNumber 
		FROM tbl_notes 
		WHERE jobNumber IS NOT NULL 
		AND LEFT(notes,11) IN ('ON HOM Dock','On MRK Dock')
		AND noteDate > '10/01/2017')
AND orderStatus NOT IN ('Delivered', 'Failed', 'Cancelled', 'In Transit', 'In Transit USPS')
AND a.orderdate > '05/01/2020'
AND b.trackSource = 'USPS Endicia'

--// write to tbl_Notes, "ON HOM Dock" FOR UPS
INSERT INTO tbl_notes (jobNumber, notes, noteDate, author, notesType)
SELECT DISTINCT  
b.jobnumber, 
'On MRK Dock' + ISNULL(' - ' + b.trackingnumber, ''), GETDATE(), 
CASE
	WHEN reference5 IS NULL THEN 'UPS WorldShip - NULL'
	ELSE 'UPS WorldShip - ' + reference5 
END AS 'author',
'order'
FROM vwtbl_UPSx b
INNER JOIN tblOrders a
	ON b.jobnumber = a.orderNo
WHERE b.jobnumber  NOT IN
		(SELECT jobNumber 
		FROM tbl_notes 
		WHERE jobNumber IS NOT NULL 
		AND LEFT(notes,11) IN ('ON HOM Dock','On MRK Dock')
		AND noteDate > '05/01/2020')
AND a.orderStatus <> 'cancelled'
AND a.orderStatus <> 'failed'
AND a.orderStatus NOT LIKE '%in transit%'
AND a.orderStatus <> 'delivered'
AND a.orderdate > '05/01/2020'

--// set pending status to legit status
UPDATE tblJobTrack
SET trackSource = 'UPS WorldShip'
WHERE trackSource = 'UPS WorldShip - Pending'