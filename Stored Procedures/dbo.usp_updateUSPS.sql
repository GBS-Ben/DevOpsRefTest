CREATE PROCEDURE [dbo].[usp_updateUSPS]
AS
/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		01/01/2008
Purpose		This proc runs nightly to update jobs that use USPS
-------------------------------------------------------------------------------
Modification History

01/01/18	Created, jf
06/26/18	Updated for 5-day drop off, previously commented out, jf.
12/06/18	Updated "TOP (1) 1" statements, jf.
12/07/18	Added 5-day drop off WHILE loop section, jf.
04/27/21	CKB, Markful
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;
BEGIN TRY 

--This section ensures that no USPS "ON DOCKS" were left behind from failure of endiciaPostBack (ie, machine is down). This is merely a back-up part, and should NOT normally return results.
UPDATE tblOrders
SET orderStatus = 'In Transit'
WHERE orderStatus IN ('ON HOM Dock','ON MRK Dock')
AND (DATEPART (HH, GETDATE()) > = 23 OR DATEPART (HH, GETDATE()) < = 2)
AND (DATENAME(DW,GETDATE()) <> 'Saturday' AND DATENAME(DW,GETDATE()) <> 'Sunday')

-- BARCODE NOTES --------------------------------------------------------------------------------------------------------------------------------------------------------
-- Run as a back up to the Endicia system until we have proven that we no longer need BARCODE for USPS (minus stamps).

-- (1) USPS (NON STAMPED)
INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType)
SELECT CONVERT(VARCHAR(255), b.jobno), 'In Transit USPS', time_stamp, workcenter, 'order' 
FROM tbl_barcode AS b
WHERE EXISTS 
				(SELECT TOP (1) 1
				FROM tbl_barcode AS b1 
				WHERE b.jobno = b1.jobno 
				AND time_Stamp > CONVERT(DATETIME, '09/01/2014'))
AND NOT EXISTS 
				(SELECT TOP (1) 1
				FROM tbl_Notes AS n1 
				WHERE CONVERT(VARCHAR(255), b.jobno) = n1.jobnumber
				AND notes LIKE '%In Transit USPS%')
AND EXISTS 
			(SELECT TOP (1) 1 
			FROM tblOrders AS o 
			WHERE b.jobno = o.orderNo
			AND orderStatus = 'In Transit USPS')

-- (2) USPS (STAMPED) - 1ZUSPSSTAMPS
INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
SELECT CONVERT(VARCHAR(255), b.jobno), 'In Transit USPS (Stamped)', time_stamp, workcenter, 'order' 
FROM tbl_barcode AS b 
WHERE EXISTS 
				(SELECT TOP (1) 1 
				FROM tbl_barcode AS b1
				WHERE b.jobno = b1.jobno 
				AND time_Stamp > CONVERT(DATETIME, '12/01/2013'))
AND NOT EXISTS (SELECT TOP (1) 1 
				FROM tbl_Notes AS n
				WHERE CONVERT(VARCHAR(255), b.jobno) = n.jobnumber 
					AND notes LIKE 'In Transit USPS%')
AND EXISTS (SELECT TOP (1) 1 
			FROM tblOrders AS o 
			WHERE b.jobno = o.orderNo 
				AND orderStatus = 'In Transit USPS (Stamped)')

-- (3) UPS
INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
SELECT CONVERT(VARCHAR(255), o.orderNo), 'In Transit', GETDATE(), 'SQL', 'order'
FROM tblOrders AS o
WHERE orderStatus = 'In Transit'
AND NOT EXISTS 
				(SELECT TOP (1) 1
				FROM tbl_Notes AS n 
				WHERE CONVERT(VARCHAR(255), o.orderNo) = n.jobnumber 
				AND notes LIKE '%Transit%')

-- DELIVERY 5 DAY DROP OFF CODE.  --------------------------------------------------------------------------------------------------------------------------------------------------------
--This updates orderStatus = 'Delivered' WHERE a USPS order has been in Transit 5 or more days.
IF OBJECT_ID(N'tempdb..#DeliveryOverride', N'U') IS NOT NULL
DROP TABLE #DeliveryOverride

CREATE TABLE #DeliveryOverride
	(RowID INT IDENTITY(1, 1), 
	OrderNo VARCHAR(50), 
	OrderStatus VARCHAR(50),
	LastStatusUpdate DATETIME,
	DateCount INT)

DECLARE @NumRec INT
	,@RWCT INT
	,@OrderNo VARCHAR(50)
	,@OrderStatus VARCHAR(50)
	,@LastStatusUpdate DATETIME
	,@DateCount INT

--// Create table
TRUNCATE TABLE #DeliveryOverride
INSERT INTO #DeliveryOverride (OrderNo, OrderStatus, LastStatusUpdate)
SELECT DISTINCT o.orderNo, o.orderStatus, o.LastStatusUpdate
FROM tblOrders o
WHERE orderStatus IN ('In Transit', 'In Transit USPS')

-- Get the number of records in the temporary table
SET @NumRec = @@ROWCOUNT
SET @RWCT = 1

--// Begin iterative update on multiCount on all orderIDs that have more than 1 DISTINCT ordersProductsID in them.
WHILE @RWCT < = @NumRec
BEGIN
	SELECT @OrderNo = OrderNo,
		   @OrderStatus = OrderStatus,
		   @LastStatusUpdate = LastStatusUpdate
	FROM #DeliveryOverride
	WHERE RowID = @RWCT
	
	SET @DateCount = (SELECT COUNT(DateKey)
						FROM dateDimension
						WHERE isWeekend = 0
						AND isHoliday = 0
						AND [Date] > @LastStatusUpdate
						AND [Date] < CONVERT(DATE,GETDATE()))


	IF @DateCount > 5 AND @OrderStatus = 'In Transit' -- UPS
	BEGIN
		UPDATE o
		SET orderStatus = 'Delivered'
		FROM tblOrders o
		WHERE orderNo = @OrderNo

		INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
		SELECT @OrderNo, 'Order status automatically updated to "Delivered" after five or more business days at: "' + @OrderStatus + '".', GETDATE(), 'SQL', 'order' 				
	END

	IF @DateCount > 5 AND @OrderStatus = 'In Transit USPS' -- USPS
	BEGIN
		UPDATE o
		SET orderStatus = 'Delivered'
		FROM tblOrders o
		WHERE o.orderNo = @OrderNo

		INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
		SELECT @OrderNo, 'Order status automatically updated to "Delivered" after five or more business days at: "' + @OrderStatus + '".', GETDATE(), 'SQL', 'order'	
	END

	SET @RWCT = @RWCT + 1
END

/*
		----these 2 statements were replaced with the loop above, 12/7, jf.
		----USPS (Endicia Post Back)
		--UPDATE o
		--SET orderStatus = 'Delivered'
		--FROM tblOrders AS o
		--WHERE orderStatus = 'In Transit USPS' 
		--AND EXISTS (SELECT TOP (1) 1
		--			FROM tblEndiciaPostBack AS EPB	
		--			WHERE o.orderNo = REPLACE(EPB.orderNo, 'ON', '')
		--			AND DATEDIFF(dd, jobTrack_migStamp, GETDATE()) > 5
		--			AND DATEDIFF(dd, jobTrack_migStamp, GETDATE()) < 105)

		---- UPS (Manual Override in case of lack of delivery data from UPS QV)
		--UPDATE tblOrders
		--SET orderStatus = 'Delivered'
		--WHERE orderStatus = 'In Transit'
		--AND DATEDIFF(DD, lastStatusUpdate, GETDATE()) > 5
*/

-- WRITE DELIVERY NOTES --------------------------------------------------------------------------------------------------------------------------------------------------------
--Step 1, ENDICIA
INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
SELECT jobNumber, 'Delivered', CONVERT(DATETIME, transactionDate), trackSource, 'order' 
FROM tblJobTrack AS jt
WHERE
jobNumber <> '' 
AND trackSource = 'USPS Endicia'
AND NOT EXISTS 
	(SELECT TOP (1) 1
	FROM tbl_Notes AS N 
	WHERE CONVERT(VARCHAR(50), jt.jobnumber) = n.jobnumber 
	AND notes LIKE '%Delivered%' 
	AND jobNumber <> '')
AND EXISTS 
	(SELECT TOP (1) 1
	FROM tblOrders AS o 
	WHERE jt.jobnumber = CONVERT(VARCHAR(255), o.orderNo)
	AND o.orderStatus = 'Delivered'
	AND DATEDIFF(DD, o.orderDate, GETDATE()) < 366)

--Step 3, UPS Notes
INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
SELECT CONVERT(VARCHAR(255), orderNo), 'Delivered', GETDATE(), 'SQL', 'order'
FROM tblOrders AS o
WHERE orderStatus = 'Delivered'
AND NOT EXISTS
	(SELECT TOP (1) 1
	FROM tblJobTrack xt
	WHERE CONVERT(VARCHAR(255), o.orderNo) = xt.jobNumber
	AND trackSource = 'USPS Endicia') 
AND NOT EXISTS 
	(SELECT TOP (1) 1
	FROM tbl_Notes AS N 
	WHERE CONVERT(VARCHAR(255), o.orderNo) = n.jobnumber 
	AND notes LIKE '%Delivered%')
AND DATEDIFF(DD, lastStatusUpdate, GETDATE()) < 30

END TRY
BEGIN CATCH
	--Capture errors if they happen
			EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH