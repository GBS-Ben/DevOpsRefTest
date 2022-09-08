CREATE PROCEDURE [dbo].[usp_QVImport]
AS
SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/01/2008
-- Purpose     Brings new UPS Quantum View Data into the DB.
--					Data comes in from UPS QV Autoload app on dbserver.
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/11/16		JF
--					Overall clean.
--7/20/17 Shreck Improving performance
--7/27/17 No Deletes, updates only
--11/1/19	Update ShipDate on <> Delivered and Delivered'
--05/14/20	JF, Y2K substrings.
-------------------------------------------------------------------------------
BEGIN TRY

	IF (SELECT COUNT(*) FROM tbl_UPSQuantumViewCapture_Acquire) > 0
	BEGIN

		DECLARE @currentDate  datetime
		SET @currentDate = GETDATE()
		-----------------------------------------------------------------------------------------
		--  Create Temp Tables
		-----------------------------------------------------------------------------------------

		IF OBJECT_ID('tempdb..#Orders') IS NOT NULL
			DROP TABLE #Orders

		CREATE TABLE  #Orders(
						rownum int IDENTITY(1,1),
						OrderNo varchar(100) NOT NULL,
						OrderStatus varchar(100) NULL, 
						StatusDate datetime,
						ShipDate datetime
						)

		IF OBJECT_ID('tempdb..#tbljobtrack') IS NOT NULL
			DROP TABLE #tbljobtrack

		CREATE TABLE  #tbljobtrack(
		[rownum] [int] IDENTITY(1,1) NOT NULL,	
		[trackingnumber] [varchar](255) NOT NULL,
			[jobnumber] [varchar](255) NULL,
			[ups service] [varchar](255) NULL,
			[pickup date] [varchar](255) NULL,
			[scheduled delivery date] [varchar](255) NULL,
			[package count] [varchar](255) NULL,
			[addtrack] [varchar](255) NULL,
			[Delivery Street Number] [varchar](255) NULL,
			[Delivery Street Prefix] [varchar](255) NULL,
			[Delivery Street Name] [varchar](255) NULL,
			[Delivery Street Type] [varchar](255) NULL,
			[Delivery Street Suffix] [varchar](255) NULL,
			[Delivery Building Name] [varchar](255) NULL,
			[Delivery Room/Suite/Floor] [varchar](255) NULL,
			[Delivery City] [varchar](255) NULL,
			[Delivery State/Province] [varchar](255) NULL,
			[Delivery Postal Code] [varchar](255) NULL,
			[deliveredOn] [varchar](255) NULL,
			[location] [varchar](255) NULL,
			[signedForBy] [varchar](255) NULL,
			[addressType_DisplayOnIntranet] [varchar](255) NULL,
			[addressType] [varchar](255) NULL,
			[subscription file name] [varchar](255) NULL,
			[trackSource] [varchar](255) NULL,
			[transactionID] [varchar](255) NULL,
			[transactionDate] [varchar](255) NULL,
			[mailClass] [varchar](255) NULL,
			[postageAmount] [varchar](255) NULL,
			[postMarkDate] [varchar](255) NULL,
			[weight] [varchar](255) NULL,
			[author] [varchar](255) NULL
			)



		--Clean Import table
			TRUNCATE TABLE tbl_UPSQuantumViewCapture_ImportHoldingBay 

			--// CLEAN DATA ---------------------------------------------------------------------
			DELETE  dbo.tbl_UPSQuantumViewCapture_Acquire  WHERE [subscriber ID] <> 'gogbs'

			INSERT tbl_UPSQuantumViewCapture_ImportHoldingBay (
			  [Subscriber ID]
			  ,[Subscription Name]
			  ,[Subscription Number]
			  ,[Query Begin Date]
			  ,[Query End Date]
			  ,[Subscription File Name]
			  ,[File Status]
			  ,[Record Type]
			  ,[Shipper Number]
			  ,[Shipper Name]
			  ,[Shipper Address Line 1]
			  ,[Shipper Address Line 2]
			  ,[Shipper Address Line 3]
			  ,[Shipper City]
			  ,[Shipper State/Province]
			  ,[Shipper Postal Code]
			  ,[Shipper Country]
			  ,[Ship To Attention]
			  ,[Ship To Phone]
			  ,[Ship To Name]
			  ,[Ship To Address Line 1]
			  ,[Ship To Address Line 2]
			  ,[Ship To Address Line 3]
			  ,[Ship To City]
			  ,[Ship To State/Province]
			  ,[Ship To Postal Code]
			  ,[Ship To Country]
			  ,[Ship To Location ID]
			  ,[Shipment Reference Number Type 1]
			  ,[Shipment Reference Number Value 1]
			  ,[Shipment Reference Number Type 2]
			  ,[Shipment Reference Number Value 2]
			  ,[UPS Service]
			  ,[Pickup Date]
			  ,[Scheduled Delivery Date]
			  ,[Scheduled Delivery Time]
			  ,[Document Type]
			  ,[Package Activity Date]
			  ,[Package Activity Time]
			  ,[Package Description]
			  ,[Package Count]
			  ,[Package Dimensions Unit of Measurement]
			  ,[Length]
			  ,[Width]
			  ,[Height]
			  ,[Package Dimensional Weight]
			  ,[Package Weight]
			  ,[Oversize Package Type]
			  ,[Tracking Number]
			  ,[Package Reference Number Type 1]
			  ,[Package Reference Number Value 1]
			  ,[Package Reference Number Type 2]
			  ,[Package Reference Number Value 2]
			  ,[Package Reference Number Type 3]
			  ,[Package Reference Number Value 3]
			  ,[Package Reference Number Type 4]
			  ,[Package Reference Number Value 4]
			  ,[Package Reference Number Type 5]
			  ,[Package Reference Number Value 5]
			  ,[COD Currency Type]
			  ,[COD Amount Due]
			  ,[Declared Value]
			  ,[Earliest Delivery Time]
			  ,[Hazardous Materials Type]
			  ,[Hold For Pickup]
			  ,[Saturday Delivery Indicator]
			  ,[Call Tag ARS Type]
			  ,[Manufacture Country]
			  ,[Harmonized Type]
			  ,[Customs Monetary Value]
			  ,[Special Instructions]
			  ,[Shipment Charge Type]
			  ,[Bill Ship To]
			  ,[Collect Bill]
			  ,[UPS Location]
			  ,[UPS Location State/Province]
			  ,[UPS Location Country]
			  ,[Updated Ship To Name]
			  ,[Updated Ship To Street Number]
			  ,[Updated Ship To Street Prefix]
			  ,[Updated Ship To Street Name]
			  ,[Updated Ship To Street Type]
			  ,[Updated Ship To Street Suffix]
			  ,[Updated Ship To Building Name]
			  ,[Updated Ship To Room/Suite/Floor]
			  ,[Updated Ship To Political Division 3]
			  ,[Updated Ship To City]
			  ,[Updated Ship To State/Province]
			  ,[Updated Ship To Country]
			  ,[Updated Ship To Postal Code]
			  ,[Exception Status Description]
			  ,[Exception Reason Description]
			  ,[Exception Resolution Type]
			  ,[Exception Resolution Description]
			  ,[Rescheduled Delivery Date]
			  ,[Rescheduled Delivery Time]
			  ,[Driver Release]
			  ,[Delivery Location]
			  ,[Delivery Name]
			  ,[Delivery Street Number]
			  ,[Delivery Street Prefix]
			  ,[Delivery Street Name]
			  ,[Delivery Street Type]
			  ,[Delivery Street Suffix]
			  ,[Delivery Building Name]
			  ,[Delivery Room/Suite/Floor]
			  ,[Delivery Political Division 3]
			  ,[Delivery City]
			  ,[Delivery State/Province]
			  ,[Delivery Country]
			  ,[Delivery Postal Code]
			  ,[Residential Address]
			  ,[Signed For By]
			  ,[COD Collected Currency Type]
			  ,[COD Amount Collected]
			  ,[COD Amount Decimal]
			  ,[Bill To Account Number]
			  ,[Bill Option]
			  ,[Exception Reason Code]
			  ,[Exception Status Code]
			  ,[Receiving Address Name"]
			  ,[Activity Type])
			SELECT DISTINCT [Subscriber ID]
			  ,[Subscription Name]
			  ,[Subscription Number]
			  ,[Query Begin Date]
			  ,[Query End Date]
			  ,[Subscription File Name]
			  ,[File Status]
			  ,[Record Type]
			  ,[Shipper Number]
			  ,[Shipper Name]
			  ,[Shipper Address Line 1]
			  ,[Shipper Address Line 2]
			  ,[Shipper Address Line 3]
			  ,[Shipper City]
			  ,[Shipper State/Province]
			  ,[Shipper Postal Code]
			  ,[Shipper Country]
			  ,[Ship To Attention]
			  ,[Ship To Phone]
			  ,[Ship To Name]
			  ,[Ship To Address Line 1]
			  ,[Ship To Address Line 2]
			  ,[Ship To Address Line 3]
			  ,[Ship To City]
			  ,[Ship To State/Province]
			  ,[Ship To Postal Code]
			  ,[Ship To Country]
			  ,[Ship To Location ID]
			  ,[Shipment Reference Number Type 1]
			  ,[Shipment Reference Number Value 1]
			  ,[Shipment Reference Number Type 2]
			  ,[Shipment Reference Number Value 2]
			  ,[UPS Service]
			  ,[Pickup Date]
			  ,[Scheduled Delivery Date]
			  ,[Scheduled Delivery Time]
			  ,[Document Type]
			  ,[Package Activity Date]
			  ,[Package Activity Time]
			  ,[Package Description]
			  ,[Package Count]
			  ,[Package Dimensions Unit of Measurement]
			  ,[Length]
			  ,[Width]
			  ,[Height]
			  ,[Package Dimensional Weight]
			  ,[Package Weight]
			  ,[Oversize Package Type]
			  ,[Tracking Number]
			  ,[Package Reference Number Type 1]
			  ,[Package Reference Number Value 1]
			  ,[Package Reference Number Type 2]
			  ,[Package Reference Number Value 2]
			  ,[Package Reference Number Type 3]
			  ,[Package Reference Number Value 3]
			  ,[Package Reference Number Type 4]
			  ,[Package Reference Number Value 4]
			  ,[Package Reference Number Type 5]
			  ,[Package Reference Number Value 5]
			  ,[COD Currency Type]
			  ,[COD Amount Due]
			  ,[Declared Value]
			  ,[Earliest Delivery Time]
			  ,[Hazardous Materials Type]
			  ,[Hold For Pickup]
			  ,[Saturday Delivery Indicator]
			  ,[Call Tag ARS Type]
			  ,[Manufacture Country]
			  ,[Harmonized Type]
			  ,[Customs Monetary Value]
			  ,[Special Instructions]
			  ,[Shipment Charge Type]
			  ,[Bill Ship To]
			  ,[Collect Bill]
			  ,[UPS Location]
			  ,[UPS Location State/Province]
			  ,[UPS Location Country]
			  ,[Updated Ship To Name]
			  ,[Updated Ship To Street Number]
			  ,[Updated Ship To Street Prefix]
			  ,[Updated Ship To Street Name]
			  ,[Updated Ship To Street Type]
			  ,[Updated Ship To Street Suffix]
			  ,[Updated Ship To Building Name]
			  ,[Updated Ship To Room/Suite/Floor]
			  ,[Updated Ship To Political Division 3]
			  ,[Updated Ship To City]
			  ,[Updated Ship To State/Province]
			  ,[Updated Ship To Country]
			  ,[Updated Ship To Postal Code]
			  ,[Exception Status Description]
			  ,[Exception Reason Description]
			  ,[Exception Resolution Type]
			  ,[Exception Resolution Description]
			  ,[Rescheduled Delivery Date]
			  ,[Rescheduled Delivery Time]
			  ,[Driver Release]
			  ,[Delivery Location]
			  ,[Delivery Name]
			  ,[Delivery Street Number]
			  ,[Delivery Street Prefix]
			  ,[Delivery Street Name]
			  ,[Delivery Street Type]
			  ,[Delivery Street Suffix]
			  ,[Delivery Building Name]
			  ,[Delivery Room/Suite/Floor]
			  ,[Delivery Political Division 3]
			  ,[Delivery City]
			  ,[Delivery State/Province]
			  ,[Delivery Country]
			  ,[Delivery Postal Code]
			  ,[Residential Address]
			  ,[Signed For By]
			  ,[COD Collected Currency Type]
			  ,[COD Amount Collected]
			  ,[COD Amount Decimal]
			  ,[Bill To Account Number]
			  ,[Bill Option]
			  ,[Exception Reason Code]
			  ,[Exception Status Code]
			  ,[Receiving Address Name"]
			  ,[Activity Type]
			FROM tbl_UPSQuantumViewCapture_Acquire

			--// INSERT NEW DATA ----------------------------------------------------------------------
				-- update [package reference number value 3] by removing trailing "r" where applicable.
			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package reference number value 3] = REPLACE([package reference number value 3], 'r', '')
			WHERE [package reference number value 3] LIKE '%r'

			-- update empty/null [package activity date] to substring of [subscription filen name] where applicable.
			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package activity date] = ((CONVERT(VARCHAR(255), SUBSTRING([subscription file name], 3, 2)) + '/' + 
										CONVERT(VARCHAR(255), SUBSTRING([subscription file name], 5, 2)) + '/20' + 
										CONVERT(VARCHAR(255), SUBSTRING([subscription file name], 1, 2))))
			WHERE [package activity date] IS NULL 
			OR [package activity date] = ''

			-- clean regular package activity date formats.
			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package activity date] = SUBSTRING([package activity date], 5, 2) + '/' + SUBSTRING([package activity date], 7, 2) + '/' + SUBSTRING([package activity date], 1, 4) 
			WHERE [package activity date] <> ''
			AND [package activity date] NOT LIKE '%/%'

			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [pickup date] = SUBSTRING([pickup date], 5, 2) + '/' + SUBSTRING([pickup date], 7, 2) + '/' + SUBSTRING([pickup date], 1, 4) 
			WHERE [pickup date] <> ''
			AND [pickup date] NOT LIKE '%/%'

			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [scheduled delivery date] = SUBSTRING([scheduled delivery date], 5, 2) + '/' + SUBSTRING([scheduled delivery date], 7, 2) + '/' + SUBSTRING([scheduled delivery date], 1, 4)
			WHERE [scheduled delivery date] <> ''
			AND [scheduled delivery date] NOT LIKE '%/%'

			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package activity time] = SUBSTRING([package activity time], 1, 2) + ':' + SUBSTRING([package activity time], 3, 2)
			WHERE [package activity time] NOT LIKE '%:%'

			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package activity time] = '0' + [package activity time]
			WHERE LEN([package activity time]) = 7 
			AND [package activity time] LIKE '0%'

			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package activity time] = '12' + SUBSTRING([package activity time], 3, 6) 
			WHERE [package activity time] LIKE '00%'

			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package activity time] = SUBSTRING([package activity time], 2, 7) 
			WHERE [package activity time] LIKE '0%'

			-- update [package reference number value 3] when empty.
			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package reference number value 3] = SUBSTRING([package reference number value 1], 3, 10)
			WHERE [package reference number value 1] LIKE 'ON%'
			AND [package reference number value 1] NOT LIKE '% %'
			AND LEN([package reference number value 1]) = 12 
			AND [package reference number value 3] = ''

			-- update [package reference number value 3] when 3 is like ON.
			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET [package reference number value 3] = SUBSTRING([package reference number value 3], 3, 10)
			WHERE [package reference number value 3] LIKE 'ON%'
			AND LEN([package reference number value 1]) = 12 

			--Create the OrderNo from the package reference value so we can use this indexed column to join.
			UPDATE dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
			SET OrderNo = SUBSTRING([package reference number value 3], 1, 10)

		-----------------------------------------------------------------------------------------
		--  Add new records to the capture table for history
		-----------------------------------------------------------------------------------------

			-- store new records based off of [Subscription File Name]....this is used for long term storage. We could eliminate this?.
			INSERT INTO dbo.tbl_UPSQuantumViewCapture
				([Subscriber ID], [Subscription Name], [Subscription Number], [Query Begin Date], [Query End Date], [Subscription File Name], [File Status], 
				[Record Type], [Shipper Number], [Shipper Name], [Shipper Address Line 1], [Shipper Address Line 2], [Shipper Address Line 3], [Shipper City], 
				[Shipper State/Province], [Shipper Postal Code], [Shipper Country], [Ship To Attention], [Ship To Phone], [Ship To Name], [Ship To Address Line 1], 
				[Ship To Address Line 2], [Ship To Address Line 3], [Ship To City], [Ship To State/Province], [Ship To Postal Code], [Ship To Country], [Ship To Location ID], 
				[Shipment Reference Number Type 1], [Shipment Reference Number Value 1], [Shipment Reference Number Type 2], [Shipment Reference Number Value 2], [UPS Service], 
				[Pickup Date], [Scheduled Delivery Date], [Scheduled Delivery Time], [Document Type], [Package Activity Date], [Package Activity Time], [Package Description], 
				[Package Count], [Package Dimensions Unit of Measurement], [Length], [Width], [Height], [Package Dimensional Weight], [Package Weight], [Oversize Package Type], 
				[Tracking Number], [Package Reference Number Type 1], [Package Reference Number Value 1], [Package Reference Number Type 2], [Package Reference Number Value 2], 
				[Package Reference Number Type 3], [Package Reference Number Value 3], [Package Reference Number Type 4], [Package Reference Number Value 4], 
				[Package Reference Number Type 5], [Package Reference Number Value 5], [COD Currency Type], [COD Amount Due], [Declared Value], [Earliest Delivery Time], 
				[Hazardous Materials Type], [Hold For Pickup], [Saturday Delivery Indicator], [Call Tag ARS Type], [Manufacture Country], [Harmonized Type], 
				[Customs Monetary Value], [Special Instructions], [Shipment Charge Type], [Bill Ship To], [Collect Bill], [UPS Location], [UPS Location State/Province], 
				[UPS Location Country], [Updated Ship To Name], [Updated Ship To Street Number], [Updated Ship To Street Prefix], [Updated Ship To Street Name], 
				[Updated Ship To Street Type], [Updated Ship To Street Suffix], [Updated Ship To Building Name], [Updated Ship To Room/Suite/Floor], 
				[Updated Ship To Political Division 3], [Updated Ship To City], [Updated Ship To State/Province], [Updated Ship To Country], [Updated Ship To Postal Code], 
				[Exception Status Description], [Exception Reason Description], [Exception Resolution Type], [Exception Resolution Description], [Rescheduled Delivery Date], 
				[Rescheduled Delivery Time], [Driver Release], [Delivery Location], [Delivery Name], [Delivery Street Number], [Delivery Street Prefix], [Delivery Street Name], 
				[Delivery Street Type], [Delivery Street Suffix], [Delivery Building Name], [Delivery Room/Suite/Floor], [Delivery Political Division 3], [Delivery City], 
				[Delivery State/Province], [Delivery Country], [Delivery Postal Code], [Residential Address], [Signed For By], [COD Collected Currency Type], [COD Amount Collected], 
				[COD Amount Decimal], [Bill To Account Number], [Bill Option], [Exception Reason Code], [Exception Status Code], [Receiving Address Name"], [Activity Type])
			SELECT DISTINCT
				[Subscriber ID], [Subscription Name], [Subscription Number], [Query Begin Date], [Query End Date], [Subscription File Name], [File Status], [Record Type], [Shipper Number], 
				[Shipper Name], [Shipper Address Line 1], [Shipper Address Line 2], [Shipper Address Line 3], [Shipper City], [Shipper State/Province], [Shipper Postal Code], [Shipper Country], 
				[Ship To Attention], [Ship To Phone], [Ship To Name], [Ship To Address Line 1], [Ship To Address Line 2], [Ship To Address Line 3], [Ship To City], [Ship To State/Province], 
				[Ship To Postal Code], [Ship To Country], [Ship To Location ID], [Shipment Reference Number Type 1], [Shipment Reference Number Value 1], [Shipment Reference Number Type 2], 
				[Shipment Reference Number Value 2], [UPS Service], [Pickup Date], [Scheduled Delivery Date], [Scheduled Delivery Time], [Document Type], [Package Activity Date], 
				[Package Activity Time], [Package Description], [Package Count], [Package Dimensions Unit of Measurement], [Length], [Width], [Height], [Package Dimensional Weight], 
				[Package Weight], [Oversize Package Type], [Tracking Number], [Package Reference Number Type 1], [Package Reference Number Value 1], [Package Reference Number Type 2], 
				[Package Reference Number Value 2], [Package Reference Number Type 3], [Package Reference Number Value 3], [Package Reference Number Type 4], [Package Reference Number Value 4], 
				[Package Reference Number Type 5], [Package Reference Number Value 5], [COD Currency Type], [COD Amount Due], [Declared Value], [Earliest Delivery Time], [Hazardous Materials Type],
				[Hold For Pickup], [Saturday Delivery Indicator], [Call Tag ARS Type], [Manufacture Country], [Harmonized Type], [Customs Monetary Value], [Special Instructions], 
				[Shipment Charge Type], [Bill Ship To], [Collect Bill], [UPS Location], [UPS Location State/Province], [UPS Location Country], [Updated Ship To Name], [Updated Ship To Street Number], 
				[Updated Ship To Street Prefix], [Updated Ship To Street Name], [Updated Ship To Street Type], [Updated Ship To Street Suffix], [Updated Ship To Building Name], 
				[Updated Ship To Room/Suite/Floor], [Updated Ship To Political Division 3], [Updated Ship To City], [Updated Ship To State/Province], [Updated Ship To Country], 
				[Updated Ship To Postal Code], [Exception Status Description], [Exception Reason Description], [Exception Resolution Type], [Exception Resolution Description], 
				[Rescheduled Delivery Date], [Rescheduled Delivery Time], [Driver Release], [Delivery Location], [Delivery Name], [Delivery Street Number], [Delivery Street Prefix], 
				[Delivery Street Name], [Delivery Street Type], [Delivery Street Suffix], [Delivery Building Name], [Delivery Room/Suite/Floor], [Delivery Political Division 3], 
				[Delivery City], [Delivery State/Province], [Delivery Country], [Delivery Postal Code], [Residential Address], [Signed For By], [COD Collected Currency Type], 
				[COD Amount Collected], [COD Amount Decimal], [Bill To Account Number], [Bill Option], [Exception Reason Code], [Exception Status Code], [Receiving Address Name"], [Activity Type]
			FROM dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
		-----------------------------------------------------------------------------------------
		--  Write Notes:
		-----------------------------------------------------------------------------------------
			--// DELIVERY UPDATES ----------------------------------------------------------------------
			-- write delivery notes.
			INSERT INTO tbl_Notes (jobNumber, notes, noteDate, author, systemNote, notesType)
				SELECT DISTINCT SUBSTRING([package reference number value 3], 1, 10), 
					'Marked as "Delivered" by carrier on: ' +  [Package Activity Date] + '.', 
					GETDATE(), 
					'SQL', 
					'Delivery Confirmation', 
					'order'
				FROM dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay i
				WHERE [Record Type] IN ('D1', 'D2') --These are delivery records
					AND [Shipment Reference Number Value 1] LIKE 'ON%'
					AND EXISTS (SELECT TOP 1 orderNo  FROM tblOrders  WHERE OrderNo = i.OrderNo AND orderStatus <> 'Failed' AND orderStatus <> 'Cancelled')
					AND NOT EXISTS (SELECT TOP 1 1 FROM tbl_Notes WHERE systemNote = 'Delivery Confirmation' AND ISNULL(jobNumber,'') = i.OrderNo)
			UNION
			--// TRANSIT UPDATES ----------------------------------------------------------------------
			-- write in transit notes.
				SELECT DISTINCT SUBSTRING([package reference number value 3], 1, 10), 'Marked as "In Transit" by carrier on: ' + [Package Activity Date] + '.', GETDATE(), 
				'SQL', 'In Transit Confirmation', 'order'
				FROM dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay i 
				WHERE [Shipment Reference Number Value 1] LIKE 'ON%'
					AND DATEDIFF(DAY, [Package Activity Date], GETDATE()) < 30
					AND EXISTS
						(SELECT TOP 1 orderNo 
						FROM tblOrders 
						WHERE OrderNo = i.OrderNo
						AND orderStatus <> 'Failed'
						AND orderStatus <> 'Cancelled'
						AND orderStatus <> 'Delivered'
						AND orderNo IS NOT NULL
					)
				AND NOT EXISTS
					(
					SELECT TOP 1 jobNumber 
					FROM tbl_Notes
					WHERE jobnumber = i.OrderNo
						AND jobNumber IS NOT NULL
						AND systemNote = 'In Transit Confirmation'
						)
		-----------------------------------------------------------------------------------------------------------------
		--  Update #Orders with order information for imported data; we will write orders later
		------------------------------------------------------------------------------------------------------------------

				INSERT #Orders (OrderNo, OrderStatus, StatusDate, ShipDate)
				SELECT DISTINCT OrderNo, 'Delivered', [Package Activity Date], NULL
				FROM dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay
				WHERE OrderNo IS NOT NULL
				AND [Record Type] IN ('D1','D2')  --these are delivery records
				

			INSERT #Orders (OrderNo, OrderStatus, StatusDate, ShipDate)
			SELECT DISTINCT o.OrderNo,  'In Transit' , [Package Activity Date], NULL 
			FROM tblOrders o
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b
				ON o.orderNo = ISNULL(b.OrderNo,'')
			LEFT JOIN #Orders t ON t.OrderNo = b.OrderNo
			WHERE t.OrderNo IS NULL -- This means the order is not delivered in the table above
			AND o.orderStatus <> 'Failed'
			AND o.orderStatus <> 'Cancelled'
			AND o.orderStatus <> 'In Transit'
			AND o.orderStatus <> 'Delivered'
	
		-----------------------------------------------------------------------------------------
		--  JobTrack Processing
		-----------------------------------------------------------------------------------------

			--load temp job track table with disctinct tracking and order no
			--there could be many tracking numbers per each order
			INSERT INTO #tbljobtrack(trackingnumber, jobnumber)
			SELECT DISTINCT b.[tracking number],  orderno
			FROM dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b 
			WHERE NULLIF(OrderNo,'') IS NOT NULL
			/*
			UNION
			SELECT DISTINCT b.[tracking number],  '' AS orderno 
			FROM dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b 
			LEFT JOIN #tbljobtrack jt ON jt.trackingnumber = b.[Tracking Number] 
			WHERE jt.trackingnumber IS NULL
				AND NULLIF(OrderNo,'') IS  NULL
				*/

			--Set Manifest information
			UPDATE x
			SET	[ups service] = a.[ups service], 
				[pickup date] = a.[pickup date], 
				[scheduled delivery date] = a.[scheduled delivery date], 
				[package count] = a.[package count], 
				[weight] = a.[Package Weight] ,
				[subscription file name] = a.[subscription file name]
			FROM  #tbljobtrack x 
			INNER JOIN  dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay a 
				ON x.trackingnumber = a.[Tracking Number]
				AND  x.jobnumber = ISNULL(a.OrderNo,'')
			WHERE [Record Type] IN ('M1', 'M2') 

			/*TO DO   This gives us the actual in transit date time
			--Update Origin Scan Details
			UPDATE x 
			SET 
			FROM #tbljobtrack x 
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay a 
				ON  x.trackingnumber = a.[Tracking Number]
			WHERE [Record Type] IN ('D1', 'D2')
			AND  'UPS Quantum View'

			*/

			--UPDATE Delivery Details
			UPDATE x
			SET [delivery street number] = a.[delivery street number], 
				[delivery street prefix] = a.[delivery street prefix], 
				[delivery street name] = a.[delivery street name], 
				[delivery street type] = a.[delivery street type], 
				[delivery street suffix] = a.[delivery street suffix], 
				[delivery building name] = a.[delivery building name], 
				[delivery room/suite/floor] = a.[delivery room/suite/floor], 
				[delivery city] = a.[delivery city], 
				[delivery state/province] = a.[delivery state/province], 
				[delivery postal code] = a.[delivery postal code], 
				[signedforby] = [Signed for by] , 
				[deliveredon] = [Package Activity Date],
				[location] = [Delivery Location] ,
				[subscription file name] = a.[subscription file name]
			FROM #tbljobtrack x 
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay a 
				ON  x.trackingnumber = a.[Tracking Number]
					AND  x.jobnumber = ISNULL(a.OrderNo,'')
			WHERE [Record Type] IN ('D1', 'D2')

			/*TO DO   	--Update for exceptions - mostly update the scheduled delivery date
			*/
			--4  No more deleting from Job Track
			--DELETE FROM tbljobtrack 
			--WHERE [ups service] = '' 
			--AND jobnumber IN 
			--	(SELECT jobnumber 
			--	FROM tbljobtrack 
			--	GROUP BY jobnumber 
			--	HAVING count(jobnumber) > 1)
			--AND trackSource = 'UPS Quantum View'

			--// SHIPMENT DATES ----------------------------------------------------------------------
			-- shipments from UPS quantum view.
			UPDATE a
			SET shipDate = b.[pickup date]
			FROM #Orders a
			INNER JOIN  #tbljobtrack b
				ON a.orderNo = b.jobNumber
			WHERE a.shipDate IS NULL
				AND b.[pickup date] IS NOT NULL

			-- shipments from USPS
			UPDATE a
			SET shipDate = CONVERT(datetime, 
						(CONVERT(VARCHAR(255), DATEPART(mm, b.noteDate)) + '/' + 
						CONVERT(VARCHAR(255), DATEPART(dd, b.noteDate)) + '/' + 
						CONVERT(VARCHAR(255), DATEPART(yy, b.noteDate)))) 
			FROM #Orders a 
			INNER JOIN tbl_Notes b
				ON a.orderNo = b.jobNumber
			WHERE a.shipDate IS NULL
				AND b.notes LIKE 'In Transit USPS%'

			-- null shipment dates
			UPDATE #Orders
			SET shipDate = NULL
			WHERE shipDate = '1900-01-01 00:00:00.000'

			--// DELIVERY UPDATES ----------------------------------------------------------------------
			---- Location update...likely not needed but be safe
			UPDATE a
			SET [location] =  b.[delivery location]
			FROM #tblJobTrack a
			INNER JOIN  dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b
				ON a.jobNumber = b.OrderNo
				AND a.trackingNumber = b.[Tracking Number]
			WHERE b.[delivery location] <> '' 
			AND b.[delivery location] IS NOT NULL
			AND a.location IS NULL

			-- address Type
			-- "Residential Address = 1" means it was residential AND signed for by.
			UPDATE a
			SET addressType = CONVERT(VARCHAR(255), b.[residential address])
			FROM #tblJobTrack a
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b
			ON   a.trackingNumber = b.[Tracking Number]
				AND  a.jobnumber = ISNULL(b.OrderNo,'')
			WHERE b.[residential address] = '1'
			AND a.addressType IS NULL
			AND a.trackSource = 'UPS Quantum View'

			-- "Residential Address = 2" means it was residential BUT NOT signed for by. 
			UPDATE a
			SET addressType = CONVERT(VARCHAR(255), b.[residential address])
			FROM #tblJobTrack a
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b
			ON   a.trackingNumber = b.[Tracking Number] 
				AND  a.jobnumber = ISNULL(b.OrderNo,'')
			WHERE b.[residential address] = '2'
				AND a.addressType IS NULL


			---- Signed For By Likely not needed but be safe
			UPDATE a
				SET signedForBy = CONVERT(VARCHAR(255), b.[signed for by])
			FROM #tblJobTrack a
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b
			ON  a.jobNumber = OrderNo
				AND a.trackingNumber = b.[Tracking Number]
			WHERE b.[signed for by] <> '' 
				AND b.[signed for by] IS NOT NULL
				AND a.signedForBy IS NULL

			--When there is no signature
			UPDATE #tblJobTrack
			SET signedForBy = 'Driver Released'
			WHERE addressType = '2'
				AND trackSource = 'UPS Quantum View'
				AND signedForBy <> 'Driver Released'
				AND NULLIF(signedForBy, '') IS NULL

			--Delivery Date
			UPDATE a
			SET deliveredOn = b.[Package Activity Date]	 ,
				[subscription file name] = b.[subscription file name]
			FROM #tblJobTrack a
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b
			ON a.trackingNumber = b.[Tracking Number] 
				AND  a.jobnumber = ISNULL(b.OrderNo,'')
			WHERE b.[Record Type] = 'D2'
				AND b.[Package Activity Date] <> ''
				AND b.[Package Activity Date] IS NOT NULL
				AND a.deliveredOn IS NULL
				AND a.trackSource = 'UPS Quantum View'

			--addressType_DisplayOnIntranet
			UPDATE #tblJobTrack
			SET addressType_DisplayOnIntranet = 'Residential'
			WHERE addressType = '1' 
				OR  addressType = '2' 
				AND addressType_DisplayOnIntranet <> 'Residential'

			UPDATE #tblJobTrack
			SET addressType_DisplayOnIntranet = 'Commercial'
			WHERE (addressType <> '1'
					AND addressType <> '2'
					AND addressType_DisplayOnIntranet <> 'Commercial')
			OR 
				  (addressType IS NULL 
					AND addressType_DisplayOnIntranet <> 'Commercial')

			--Just being safe again			
			UPDATE t
			SET  [UPS Service] =  b.[UPS Service] ,
				[subscription file name] = b.[subscription file name]
			FROM #tbljobtrack t 
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b 
				ON b.[Tracking Number] = t.trackingnumber
				 AND  t.jobnumber = ISNULL(b.OrderNo,'')
			WHERE b.[UPS Service] IS NOT NULL
				AND t.[ups service] IS NULL

			--Rescheduled Delivery Dates for when a delivery exception happens
		UPDATE t
			SET  [scheduled delivery date] =  b.[Rescheduled Delivery Date]
			FROM #tbljobtrack t 
			INNER JOIN dbo.tbl_UPSQuantumViewCapture_ImportHoldingBay b 
				ON b.[Tracking Number] = t.trackingnumber
				 AND  t.jobnumber = ISNULL(b.OrderNo,'')
			WHERE [Rescheduled Delivery Date] IS NOT NULL

		------------------------------------------------------------------------
		--MERGE JOBTRACK	
		------------------------------------------------------------------------ 
	
	INSERT INTO [tbljobtrack]
			   ([trackingnumber]
			   ,[jobnumber]
			   ,[ups service]
			   ,[pickup date]
			   ,[scheduled delivery date]
			   ,[package count]
			   ,[addtrack]
			   ,[Delivery Street Number]
			   ,[Delivery Street Prefix]
			   ,[Delivery Street Name]
			   ,[Delivery Street Type]
			   ,[Delivery Street Suffix]
			   ,[Delivery Building Name]
			   ,[Delivery Room/Suite/Floor]
			   ,[Delivery City]
			   ,[Delivery State/Province]
			   ,[Delivery Postal Code]
			   ,[deliveredOn]
			   ,[location]
			   ,[signedForBy]
			   ,[addressType_DisplayOnIntranet]
			   ,[addressType]
			   ,[subscription file name]
			   ,[trackSource]
			   ,[transactionID]
			   ,[transactionDate]
			   ,[mailClass]
			   ,[postageAmount]
			   ,[postMarkDate]
			   ,[weight]
			   ,[author]
			   ,[CreatedOn]
			   ,[UpdatedOn])
		 SELECT t.[trackingnumber]
			   ,t.[jobnumber]
			   ,t.[ups service]
			   ,t.[pickup date]
			   ,t.[scheduled delivery date]
			   ,t.[package count]
			   ,t.[addtrack]
			   ,t.[Delivery Street Number]
			   ,t.[Delivery Street Prefix]
			   ,t.[Delivery Street Name]
			   ,t.[Delivery Street Type]
			   ,t.[Delivery Street Suffix]
			   ,t.[Delivery Building Name]
			   ,t.[Delivery Room/Suite/Floor]
			   ,t.[Delivery City]
			   ,t.[Delivery State/Province]
			   ,t.[Delivery Postal Code]
			   ,t.[deliveredOn]
			   ,t.[location]
			   ,t.[signedForBy]
			   ,t.[addressType_DisplayOnIntranet]
			   ,t.[addressType]
			   ,t.[subscription file name]
			   ,t.[trackSource]
			   ,t.[transactionID]
			   ,t.[transactionDate]
			   ,t.[mailClass]
			   ,t.[postageAmount]
			   ,t.[postMarkDate]
			   ,t.[weight]
			   ,t.[author]
			   ,@currentDate
			   ,@currentDate
		 FROM   #tbljobtrack t
		 LEFT JOIN tblJobTrack x 
			ON t.trackingnumber = x.trackingnumber
			AND t.jobnumber = x.jobnumber
		 WHERE x.trackingnumber IS NULL

		UPDATE x
			SET [delivery street number] = ISNULL(t.[delivery street number], x.[delivery street number]),
			[delivery street prefix] = ISNULL(t.[delivery street prefix],  x.[delivery street prefix]),
			[delivery street name] = ISNULL(t.[delivery street name], x.[delivery street name]),
			[delivery street type] = ISNULL(t.[delivery street type], x.[delivery street type]),
			[delivery street suffix] = ISNULL(t.[delivery street suffix], x.[delivery street suffix]),
			[delivery building name] = ISNULL(t.[delivery building name], x.[delivery building name]),
			[delivery room/suite/floor] = ISNULL(t.[delivery room/suite/floor], x.[delivery room/suite/floor]),
			[delivery city] = ISNULL(t.[delivery city], x.[delivery city]),
			[delivery state/province] = ISNULL(t.[delivery state/province], x.[delivery state/province]),
			[delivery postal code] = ISNULL(t.[delivery postal code],x.[delivery postal code]),
			[deliveredOn] = ISNULL(t.deliveredOn,x.deliveredOn),
			[signedForBy] = ISNULL(t.signedForBy,x.signedForBy),
			[addressType] =ISNULL(t.addressType,x.addressType),
			[addressType_DisplayOnIntranet]= ISNULL(t.addressType_DisplayOnIntranet,x.addressType_DisplayOnIntranet),
			[ups service] = ISNULL(t.[UPS Service], x.[ups service]),
			[subscription file name] = ISNULL(t.[subscription file name],x.[subscription file name]),
			[scheduled delivery date] = ISNULL(t.[scheduled delivery date], x.[scheduled delivery date]),
			[location] = ISNULL(t.[location], x.[location]),
			UpdatedOn = @currentDate
		FROM tblJobTrack x
		INNER JOIN #tbljobtrack t ON t.trackingnumber = x.trackingnumber
		  AND  t.jobnumber =  x.jobnumber

			--UPDATE ORDERS
			UPDATE t
			SET ShipDate = ISNULL(t.ShipDate, ISNULL(o.shipdate,GETDATE())), --Keep the original value if the new value is null
				OrderStatus = ISNULL(o.OrderStatus, t.OrderStatus),
				lastStatusUpdate = @currentDate
			FROM #Orders o
			INNER JOIN tblOrders t ON t.OrderNo = o.OrderNo
			WHERE o.OrderStatus <> 'Delivered'

			UPDATE t
			SET ShipDate = ISNULL(t.ShipDate, ISNULL(o.shipdate,GETDATE())), --Keep the original value if the new value is null
				OrderStatus = ISNULL(o.OrderStatus, t.OrderStatus),
				lastStatusUpdate = @currentDate
			FROM #Orders o
			INNER JOIN tblOrders t ON t.OrderNo = o.OrderNo
			WHERE o.OrderStatus = 'Delivered'

		/*  CLEAN UP  */

		IF OBJECT_ID('tempdb..#tbljobtrack') IS NOT NULL
			DROP TABLE #tbljobtrack
	END	
END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [usp_StoredProcedureErrorLog]

END CATCH