



CREATE PROCEDURE [dbo].[usp_barcodeADD]
AS
SET NOCOUNT ON;
/*
-----------------------------------------------------------------------------
Author Craig Price
Created		07/19/2016
Purpose		Pulls barcode scans into DB. Dependent on SSIS package, i_Barcode.

-----------------------------------------------------------------------------
Modification History
08/02/16		Added Multifeeder and Namebadge notes to the mix; jf.
09/12/17		Modified to eliminate deadlocking
10/01/18		Updated some of the WHERE clauses, jf.
10/2/18			BJS - Updated DEADLOCK_PRIORITY and added NOLOCK
11/07/18		added embroidery code, jf.
11/13/18		added fastTrak_status = 'Completed' section at bottom of sproc, jf.
12/30/20		JF, updated the envelope production section with the correct diff notes value.
1/4/21			JF, updated print room to include the new "BLDG 1 PRINT ROOM" station.
04/27/21		CKB, Markful
-----------------------------------------------------------------------------
// Run updates on wipLOG, prior to import.
*/
BEGIN TRY

SET DEADLOCK_PRIORITY LOW;  --this procedure should die first

DECLARE @Notes TABLE (
	rownum INT IDENTITY(1,1), 
	jobnumber [varchar](50) NULL,
	notes [varchar](MAX) NULL, 
	notedate [datetime] NULL,
	author [varchar](50) NULL,
	notesType [varchar](255) NULL
	)

DECLARE @StartDate DATETIME2 --date we use to limit records
SET @StartDate = DATEADD(MM,-6, GETDATE())
--Received Ticket

SELECT [RecNo]
      ,[Time_Stamp]
      ,[JobNo]
      ,[Operation]
      ,[Workcenter]
      ,[TrackingNo]
      ,[importedSuccessfully]
      ,[OPID]
INTO #OrderScans
FROM [dbo].[WIPLog]
WHERE ISNULL(OPID,0) = 0

drop table if exists #opidscans
SELECT IDENTITY(int) as ID
	  ,[RecNo]
      ,[Time_Stamp]
      ,[JobNo]
      ,[Operation]
      ,[Workcenter]
      ,[TrackingNo]
      ,[importedSuccessfully]
      ,wl.[OPID]
	  ,a.wpid AS WPID
	  ,CASE WHEN r.isActive = 0 THEN r.RunNumber + 1 
		    WHEN a.StepNumber < r.stepNumber then r.RunNumber + 1 ELSE r.RunNumber END as RunNumber
INTO #OPIDScans
FROM [dbo].[WIPLog] wl
INNER JOIN tblOrders_Products op on wl.opid = op.id
CROSS APPLY (select * from gbsController_vwWorkflowProcess wp WHERE wl.Operation = wp.CompleteScanStatus AND op.workflowid= wp.workflowid) a
LEFT JOIN vwOPIDRunNumber r on wl.opid = r.opid
WHERE ISNULL(wl.OPID,0) <> 0
ORDER BY a.StepNumber

IF (SELECT TOP 1 1 FROM #OrderScans) IS NOT NULL
	BEGIN
		UPDATE #OrderScans
		SET OPERATION = 'Received Ticket'
		WHERE workcenter = 'Apparel Dept'

			--In Production
			UPDATE #OrderScans
			SET OPERATION = 'In Production'
			WHERE workcenter IN ('Print Room', 'BLDG 1 PRINT ROOM')

			UPDATE #OrderScans
			SET OPERATION = 'In Production'
			WHERE workCenter = 'Art Department'

			--Production Complete
			UPDATE #OrderScans
			SET OPERATION = 'Production Complete'
			WHERE workcenter = 'Multifeeder'

			UPDATE #OrderScans
			SET OPERATION = 'Production Complete'
			WHERE workcenter = 'Namebadge'

			UPDATE #OrderScans
			SET OPERATION = 'Production Complete'
			WHERE workcenter = 'Embroidery'

			UPDATE #OrderScans
			SET OPERATION = 'Envelopes Complete'
			WHERE workcenter = 'Envelopes'

			--ON HOM Dock
			UPDATE #OrderScans
			SET OPERATION = 'On MRK Dock'
			WHERE workcenter = 'Warehouse'


			UPDATE #OrderScans
			SET OPERATION = 'On MRK Dock'
			WHERE OPERATION IS NULL

			UPDATE #OrderScans
			SET jobNo = REPLACE(jobNo, 'ON', '')
			WHERE jobNo LIKE 'ON%'

			UPDATE #OrderScans
			SET trackingNo = RIGHT(trackingNo, 22) 
			WHERE LEN(trackingNo) = 31

			--// Run insert
			INSERT INTO dbo.tbl_barcode (recno
				, time_stamp
				, jobno
				, OPERATION
				, workcenter
				, trackingNo)
			SELECT DISTINCT recno + 1000000
				, time_stamp
				, jobno
				, [operation]
				, workcenter
				, trackingNo 
			FROM #OrderScans

			--// Run additional updates that rely on possible changes made elsewhere.
			UPDATE dbo.tbl_barcode
			SET OPERATION = 'On MRK Dock'
			WHERE trackingNo IS NOT NULL
				AND OPERATION NOT IN ('DELIVERED'
										,'On HOM Dock'
										,'On MRK Dock'
										, 'In Production'
										, 'Production Complete'
										, 'Envelopes Complete'  )

			--Art Department ----------------------------------------	
			INSERT @Notes (jobnumber
						, notes
						, notedate
						, author
						, notesType)
			SELECT b.jobNo
				, 'In Production'
				, b.time_stamp
				, b.workcenter
				, 'order' 
			FROM dbo.tbl_Barcode AS b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders AS a WITH (NOLOCK) ON b.JobNo = a.orderNo
						AND b.Workcenter = 'Art Department'
			WHERE b.time_Stamp > @StartDate
			AND a.orderStatus NOT IN  ('cancelled'
											,'failed'
											,'ON HOM Dock'
											,'ON MRK Dock'
											,'delivered'
											,'In Transit'
											,'In Transit USPS')
			AND NOT EXISTS (SELECT TOP 1 1
											FROM dbo.tbl_notes tn WITH (NOLOCK)
											WHERE TN.jobNumber = b.JobNo 
											AND notes LIKE 'In Production%'
											AND noteDate > @StartDate)

			--Print Room ----------------------------------------
			INSERT @Notes (jobnumber
						, notes
						, notedate
						, author
						, notesType)
			SELECT b.jobNo
				, 'Printed - In Production'
				, b.time_stamp
				, b.workcenter
				, 'order' 
			FROM dbo.tbl_Barcode AS b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders AS a WITH (NOLOCK) ON b.JobNo = a.orderNo
						AND b.Workcenter IN ('Print Room', 'BLDG 1 PRINT ROOM')
			WHERE b.time_Stamp > @StartDate
			AND NOT EXISTS (SELECT TOP 1 1
											FROM dbo.tbl_notes AS TN WITH (NOLOCK)
											WHERE notes LIKE 'Printed - In Production%'
											AND noteDate > @StartDate)
			AND a.orderStatus NOT IN  ('cancelled'
										,'failed'
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'delivered'
										,'In Transit'
										,'In Transit USPS')

			--Multifeeder / Namebadge ----------------------------------------
			INSERT @Notes (jobnumber
						, notes
						, notedate
						, author
						, notesType)
			SELECT b.jobNo
				, 'Production Complete'
				, b.time_stamp
				, b.workcenter
				, 'order' 
			FROM dbo.tbl_Barcode AS b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders AS a WITH (NOLOCK) ON b.JobNo = a.orderNo
						AND (b.Workcenter = 'Multifeeder' 
								OR b.Workcenter = 'Namebadge')
			WHERE b.time_Stamp > @StartDate
			AND NOT EXISTS (SELECT TOP 1 1
											FROM dbo.tbl_notes AS TN WITH (NOLOCK)
											WHERE b.JobNo = TN.jobNumber 
											AND notes LIKE 'Production Complete%' 
											AND noteDate > @StartDate)
			AND a.orderStatus NOT IN  ('cancelled'
										,'failed'
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'delivered'
										,'In Transit'
										,'In Transit USPS')

			--Embroidery ----------------------------------------
			INSERT @Notes (jobnumber
						, notes
						, notedate
						, author
						, notesType)
			SELECT b.jobNo
				, 'Production Complete'
				, b.time_stamp
				, b.workcenter
				, 'order' 
			FROM dbo.tbl_Barcode AS b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders AS a WITH (NOLOCK) ON b.JobNo = a.orderNo
					AND b.Workcenter = 'Embroidery'
			WHERE b.time_Stamp > @StartDate
			AND NOT EXISTS (SELECT TOP 1 1
							FROM dbo.tbl_notes AS TN WITH (NOLOCK)
							WHERE b.JobNo = TN.jobNumber
							AND notes LIKE '%Production Complete%' 
							AND noteDate > @StartDate)
			AND a.orderStatus NOT IN  ('cancelled'
										,'failed'
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'delivered'
										,'In Transit'
										,'In Transit USPS')

			--Envelopes ----------------------------------------
			INSERT @Notes (jobnumber
						, notes
						, notedate
						, author
						, notesType)
			SELECT b.jobNo
				, b.Operation
				, b.time_stamp
				, b.workcenter
				, 'order' 
			FROM dbo.tbl_Barcode AS b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders AS a WITH (NOLOCK) ON b.JobNo = a.orderNo
					AND b.Workcenter = 'Envelopes'
			WHERE b.time_Stamp > @StartDate
			AND NOT EXISTS (SELECT TOP 1 1
							FROM dbo.tbl_notes AS TN WITH (NOLOCK)
							WHERE b.JobNo = TN.jobNumber
							AND notes = 'Envelopes Complete'
							AND noteDate > @StartDate)
			AND a.orderStatus NOT IN  ('cancelled'
										,'failed'
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'delivered'
										,'In Transit'
										,'In Transit USPS')
							
			--All Else ----------------------------------------
			INSERT @Notes (jobnumber
						, notes
						, notedate
						, author
						, notesType)
			SELECT b.jobNo
				, 'On MRK Dock'
				, b.time_stamp
				, b.workcenter
				, 'order'
			FROM dbo.tbl_Barcode AS b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders AS a WITH (NOLOCK) ON b.JobNo = a.orderNo
						AND b.Workcenter NOT IN ('Print Room', 'BLDG 1 PRINT ROOM', 'Art Department', 'Multifeeder', 'Namebadge', 'Embroidery','Envelopes')
			WHERE b.time_Stamp > @StartDate
			AND NOT EXISTS (SELECT TOP 1 1
							FROM dbo.tbl_notes AS TN WITH (NOLOCK)
							WHERE b.JobNo = TN.jobNumber 
							AND notes IN ( 'ON HOM Dock', 'ON MRK Dock')
							AND noteDate > @StartDate)
			AND a.orderStatus NOT IN  ('cancelled'
										,'failed'
										,'delivered'
										,'In Transit'
										,'In Transit USPS')

			--Update the notes table
			INSERT INTO dbo.tbl_notes (jobnumber
										, notes
										, notedate
										, author
										, notesType) 
			SELECT jobnumber
					, notes
					, notedate
					, author
					, notesType
			FROM @Notes

			--part 4, tbl_Notes UPDATES ----------------------------------------
			UPDATE dbo.tbl_notes 
			SET notes = 'On MRK Dock'
				,notesType = 'order'
			WHERE author = 'UPS Admin'
			AND notes IS NULL

			UPDATE dbo.tbl_notes 
			SET notes = 'On MRK Dock'
				,notesType = 'order'
			WHERE author = 'UPS-2'
			AND notes IS NULL

			UPDATE dbo.tbl_notes 
			SET notes = 'On MRK Dock'
				,notesType = 'order'
			WHERE author = 'UPS-3'
			AND notes IS NULL

			UPDATE dbo.tbl_notes 
			SET notes = 'In Production'
				,notesType = 'order'
			WHERE author = 'Art Department'
			AND notes IS NULL

			UPDATE dbo.tbl_notes 
			SET notes = 'Received Ticket'
				,notesType = 'order'
			WHERE author = 'Apparel Dept'
			AND notes IS NULL

			DELETE FROM dbo.tbl_notes WHERE notes = ''

			UPDATE dbo.tbl_notes 
			SET notes = 'On MRK Dock'
			WHERE author = 'Warehouse'
			AND notes IS NULL

			--part 5, Get Orders we need to update so we can update order status ----------------------------------------

			--1----------------------------------------------------------------------------------------
			;WITH UpdateOrders
			AS
			(SELECT a.orderID, b.OPERATION
			FROM dbo.tbl_Barcode b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders a WITH (NOLOCK) ON b.JobNo = a.orderNo
			WHERE b.OPERATION IS NOT NULL
			AND a.orderStatus <> b.OPERATION
			AND b.time_Stamp > a.lastStatusUpdate
			AND a.orderStatus NOT IN ('Delivered'
										,'Exception'
										,'Failed'
										,'Cancelled' 
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'In Transit'
										,'In Transit USPS')
			AND a.tabStatus NOT IN ('Failed', 'Exception'))

			--Update orderStatus
			UPDATE o
			SET orderStatus = u.OPERATION
			FROM UpdateOrders u 
			INNER JOIN dbo.tblOrders o ON o.orderID = u.orderID		
			WHERE u.Operation IN ('In Production')
			AND o.orderStatus NOT IN ('Delivered'
										,'Exception'
										,'Failed'
										,'Cancelled' 
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'In Transit'
										,'In Transit USPS'
										,'In Production')

			--2----------------------------------------------------------------------------------------
			;WITH UpdateOrders
			AS
			(SELECT a.orderID, b.OPERATION
			FROM dbo.tbl_Barcode b WITH (NOLOCK)
			INNER JOIN dbo.tblOrders a WITH (NOLOCK) ON b.JobNo = a.orderNo
			WHERE b.OPERATION IS NOT NULL
			AND a.orderStatus <> b.OPERATION
			AND b.time_Stamp > a.lastStatusUpdate
			AND a.orderStatus NOT IN ('Delivered'
										,'Exception'
										,'Failed'
										,'Cancelled' 
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'In Transit'
										,'In Transit USPS')
			AND a.tabStatus NOT IN ('Failed', 'Exception'))


			UPDATE o
			SET orderStatus = 'In Production'
			FROM UpdateOrders u 
			INNER JOIN dbo.tblOrders o ON o.orderID = u.orderID		
			WHERE u.Operation IN ('Production Complete')
			AND o.orderStatus NOT IN ('Delivered'
										,'Exception'
										,'Failed'
										,'Cancelled' 
										,'ON HOM Dock'
										,'ON MRK Dock'
										,'In Transit'
										,'In Transit USPS'
										,'In Production')

			--3----------------------------------------------------------------------------------------
			/* This CTE wasn't working so I pulled it, jf.
					;WITH UpdateOrders
					AS
					(SELECT a.orderID, b.OPERATION
					FROM dbo.tbl_Barcode b WITH (NOLOCK)
					INNER JOIN dbo.tblOrders a WITH (NOLOCK) ON b.JobNo = a.orderNo
					WHERE b.OPERATION IS NOT NULL
					AND a.orderStatus <> b.OPERATION
					AND b.time_Stamp > a.lastStatusUpdate
					AND a.orderStatus NOT IN ('Delivered'
												,'Exception'
												,'Failed'
												,'Cancelled' 
												,'ON HOM Dock'
												,'In Transit'
												,'In Transit USPS')
					AND a.tabStatus NOT IN ('Failed', 'Exception'))

					UPDATE op
					SET fastTrak_status = 'Completed'
					FROM tblOrders_Products op 
					INNER JOIN dbo.tblOrders o ON o.orderID = op.orderID
					INNER JOIN UpdateOrders	u ON o.orderID = u.orderID
					WHERE u.Operation IN ('In Production', 'Production Complete')
					AND SUBSTRING(op.productCode, 1, 2) = 'AP'
					AND ISNULL(op.fastTrak_status, '') <> 'Completed'
			*/

			--Apparel OPID status update
			UPDATE op
			SET fastTrak_status = 'Completed'
			FROM tblOrders_Products op 
			INNER JOIN tblOrders o ON o.orderID = op.orderID
			INNER JOIN tbl_Barcode b ON o.orderNo = b.JobNo
				AND DATEDIFF(HH, b.Time_Stamp, GETDATE()) < 1 --looks at last hour's worth of barcode submissions to avoid resetting status to complete on resubmitted opids. (not ideal)
			WHERE b.Operation = 'Production Complete'
			AND SUBSTRING(op.productCode, 1, 2) = 'AP'
			AND ISNULL(op.fastTrak_status, '') <> 'Completed'
	END
IF (SELECT TOP 1 1 FROM #OPIDScans) IS NOT NULL
	BEGIN
		
		--// Run insert
		INSERT INTO dbo.tbl_barcode (recno
			, time_stamp
			, OPERATION
			, workcenter
			,OPID)
		SELECT DISTINCT recno + 1000000
			, time_stamp
			, [operation]
			, workcenter
			, opid
		FROM #OPIDScans
	
		INSERT INTO tbl_notes (jobnumber, author, notedate, notes, notestype,ordersProductsID) 
		SELECT o.orderNo,os.workcenter,getdate(),cast(os.opid as varchar(15)) + ' - ' + os.Operation + ' was scanned.','product',os.opid
		FROM #OPIDScans os
		INNER JOIN tblOrders_Products op on os.opid = op.id
		INNER JOIN tblOrders o on op.orderID = o.orderID

		
		DECLARE @OPIDCount INT = 0;
		DECLARE @CurrItem INT = 1;
		DECLARE @CurrOPID INT = 1;
		DECLARE @CurrWPID INT;
		DECLARE @CurrRunNumber INT;
		DECLARE @SQL NVARCHAR(2000);

		SET @OPIDCount = (SELECT count(*) FROM #OPIDScans);

		WHILE @CurrItem <= @OPIDCount  
		BEGIN
			
			SELECT @CurrOPID = OPID, @CurrWPID  = WPID, @CurrRunNumber = RunNumber FROM #OPIDSCans WHERE ID =  @CurrItem 

			SET @SQL = 'EXEC Workflow_CompleteItem @Status=''Success'',@OPID=' + cast(@CurrOPID as varchar(10)) + ',@WPID=' + cast(@CurrWPID as varchar(10))+ ',@runNumber=' + cast(@CurrRunNumber as varchar(10));
			print @sql
			EXEC (@SQL);

			SET @SQL ='';
			SET @CurrItem = @CurrItem+ 1;
		END
	END
END TRY
BEGIN CATCH
	--Capture errors if they happen
	EXECUTE [usp_StoredProcedureErrorLog]
END CATCH