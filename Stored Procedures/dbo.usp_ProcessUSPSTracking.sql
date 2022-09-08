CREATE PROCEDURE [dbo].[usp_ProcessUSPSTracking]
AS
SET NOCOUNT ON;


-------------------------------------------------------------------------------
-- Author		Bobby Shreck
-- Created		07/28/2017
-- Purpose		This procedure processes records acquired from the USPS API


-------------------------------------------------------------------------------
-- Modification History
--
-- 7/31/17		Modified to mark bogus errors as processed.
--02/01/21		Y2k strikes again
--04/27/21		CKB, Markful
-------------------------------------------------------------------------------

BEGIN TRY

		DECLARE @ProcessExecutionId uniqueidentifier, @StartTime datetime

		SET @ProcessExecutionId = newid()
		SET @StartTime = GETDATE()

		DECLARE @USPSTracking TABLE (
		rownum int IDENTITY(1, 1), 
		ShipTrackId int, 
		TrackingNumber varchar(500), 
		OrderNo varchar(20),
		TrackEvent varchar(500), 
		EventTime TIME, 
		EventDate varchar(20), 
		EventCity varchar(500), 
		EventState varchar(500), 
		EventZipCode varchar(500), 
		EventCountry varchar(500),
		FirmName varchar(500), 
		[Name] varchar(500), 
		AuthorizedAgent varchar(500), 
		DeliveryAttributeCode varchar(500), 
		JobTrackDate datetime,
		OrderNoMissing bit DEFAULT (0), --If we cant find the OrderNo to link this Tracking ID to
		OrderStatus varchar(100), 
		Note varchar(255),
		[ActualDelivery] varchar(20),
		[Location] varchar(100)  --Place at address
		)
	
		INSERT @USPSTracking (ShipTrackId, TrackingNumber	,TrackEvent	,EventTime,	EventDate,	EventCity	,EventState,	EventZipCode,	EventCountry,	FirmName,	[Name]	,AuthorizedAgent	,DeliveryAttributeCode)
		SELECT  ShiptrackID, 
		p.value('(./TrackInfo[1]/@ID)', 'varchar(500)') AS TrackingNumber,
		--p.value('(./TrackInfo)[1]', 'varchar(500)') AS TrackSummary,
		p.value('(./TrackInfo/TrackSummary/Event)[1]', 'varchar(500)') AS [Event],
		p.value('(./TrackInfo/TrackSummary/EventTime)[1]', 'varchar(500)') AS EventTime,
		p.value('(./TrackInfo/TrackSummary/EventDate)[1]', 'varchar(500)') AS [EventDate],
		p.value('(./TrackInfo/TrackSummary/EventCity)[1]', 'varchar(500)') AS EventCity,
		p.value('(./TrackInfo/TrackSummary/EventState)[1]', 'varchar(500)') AS EventState,
		p.value('(./TrackInfo/TrackSummary/EventZIPCode)[1]', 'varchar(500)') AS EventZIPCode,
		p.value('(./TrackInfo/TrackSummary/EventCountry)[1]', 'varchar(500)') AS EventCountry,
		p.value('(./TrackInfo/TrackSummary/FirmName)[1]', 'varchar(500)') AS FirmName,
		p.value('(./TrackInfo/TrackSummary/Name)[1]', 'varchar(500)') AS [Name],
		p.value('(./TrackInfo/TrackSummary/AuthorizedAgent)[1]', 'varchar(500)') AS AuthorizedAgent,
		p.value('(./TrackInfo/TrackSummary/DeliveryAttributeCode)[1]', 'varchar(500)') AS DeliveryAttributeCode 
		FROM [gbsAcquire].[dbo].[USPSShipTracking] as s
			CROSS APPLY TrackRequest.nodes('TrackResponse') t(p)
		WHERE p.value('(./TrackInfo/TrackSummary/Event)[1]', 'varchar(500)') is not null
			AND ProcessExecutionId IS NULL

		;WITH cteOrders
		AS
		(
		SELECT Orderno, trackingNo
		FROM tblEndiciaPostBack tep 
		WHERE CONVERT(datetime, tep.transactionDate) > GETDATE() - 30
			AND NULLIF(Orderno, '') IS NOT NULL
		)
		UPDATE us
		SET OrderNo = RIGHT(tep.orderNo,10)
		FROM @USPSTracking us
		INNER JOIN cteOrders  tep ON us.TrackingNumber = tep.trackingNo
		
		UPDATE @USPSTracking SET OrderNoMissing =  1 WHERE OrderNo IS NULL

		UPDATE @USPSTracking
		SET OrderStatus = 'ON MRK Dock',
			Note = 'ON MRK Dock -  ' + CONVERT(varchar(100), TrackingNumber), 
			JobTrackDate = CONVERT(varchar(20),CONVERT(datetime,EventDate), 1)
		WHERE TrackEvent  LIKE 'Shipping Label%'

		UPDATE @USPSTracking
		SET OrderStatus = 'Delivered',
			Note = REPLACE(TrackEvent, '/', ' or ') , 
			JobTrackDate = EventDate, 
			ActualDelivery = CONVERT(varchar(20),CONVERT(datetime,EventDate), 1),
			[Location] = REPLACE(REPLACE(TrackEvent, '/', ' or ') ,'Delivered,','') 
		WHERE TrackEvent LIKE 'Delivered%'

		UPDATE @USPSTracking
		SET OrderStatus = 'In Transit USPS',
			Note = 'In Transit USPS', 
			JobTrackDate = CONVERT(varchar(20),CONVERT(datetime,EventDate), 1)
		WHERE TrackEvent NOT LIKE 'Shipping Label%'
			AND TrackEvent NOT LIKE 'Delivered%' 

	--UPDATE JOB TRACK 

		--Update Picked up and in Transit Orders where the date is null
		UPDATE x
		SET
			[pickup date] = CONVERT(varchar(20),CONVERT(datetime,EventDate), 1),
			[subscription file name] = 'USPS API-' + CONVERT(varchar(20), @StartTime, 112),
			UpdatedOn = @StartTime
		FROM tblJobTrack x
		INNER JOIN @USPSTracking t ON t.trackingnumber = x.trackingnumber
			AND  t.OrderNo =  x.jobnumber
		WHERE t.OrderStatus = 'In Transit USPS'
			AND x.[pickup date] IS NULL

		UPDATE x
		SET
			[delivery city] = ISNULL(t.EventCity, x.[delivery city]),
			[delivery state/province] = ISNULL(t.EventState, x.[delivery state/province]),
			[delivery postal code] = ISNULL(t.EventZipCode,x.[delivery postal code]),
			[deliveredOn] = ISNULL(t.EventDate,x.deliveredOn),
			[subscription file name] = 'USPS API-' + CONVERT(varchar(20), @StartTime, 112),
			[location] = ISNULL(t.[location], x.[location]),
			UpdatedOn = @StartTime
		FROM tblJobTrack x
		INNER JOIN @USPSTracking t ON t.trackingnumber = x.trackingnumber
			AND  t.OrderNo =  x.jobnumber
		WHERE t.OrderStatus = 'Delivered'

	--UPDATE ORDERS
			UPDATE t
			SET ShipDate = ISNULL(t.ShipDate, us.EventDate), --Keep the original value if the new value is null
				OrderStatus = ISNULL(us.OrderStatus, t.OrderStatus),
				lastStatusUpdate = @StartTime
			FROM @USPSTracking us
			INNER JOIN tblOrders t ON t.OrderNo = us.OrderNo
			WHERE us.OrderStatus = 'In Transit USPS'
			AND NULLIF(t.ShipDate,'') IS NULL

			UPDATE t
			SET OrderStatus = ISNULL(us.OrderStatus, t.OrderStatus),
				lastStatusUpdate = @StartTime
			FROM @USPSTracking us
			INNER JOIN tblOrders t ON t.OrderNo = us.OrderNo
			WHERE us.OrderStatus = 'Delivered'

	--Add Notes
			INSERT INTO tbl_Notes (jobNumber, notes, noteDate, author, systemNote, notesType)
			SELECT DISTINCT OrderNo, 
				'Marked as "Delivered" by carrier on: ' +  ActualDelivery + '.', 
				GETDATE(), 
				'SQL', 
				'Delivery Confirmation', 
				'order'
			FROM @USPSTracking us
			WHERE  us.OrderStatus = 'Delivered'
				AND NOT EXISTS (SELECT TOP 1 jobNumber FROM tbl_Notes WHERE Notes LIKE 'Marked as "Delivered"%' AND jobNumber = us.OrderNo)
		UNION
		--// TRANSIT UPDATES ----------------------------------------------------------------------
		-- write in transit notes.
			SELECT DISTINCT OrderNo, 'Marked as "In Transit" by carrier on: ' + EventDate+ '.', GETDATE(), 
			'SQL', 'In Transit Confirmation', 'order'
			FROM @USPSTracking us 
			WHERE us.OrderStatus = 'In Transit USPS'
				AND NOT EXISTS (SELECT TOP 1 jobNumber FROM tbl_Notes WHERE (Notes LIKE 'Marked as "In Transit"%' OR Notes = 'In Transit') AND jobNumber = us.OrderNo)

	--Mark tracking event as processed
	UPDATE  s
	SET ProcessExecutionId = @ProcessExecutionId, 
		ProcessStartDateTime = @StartTime,
		ProcessEndDateTime = GETDATE()
	FROM [gbsAcquire].[dbo].[USPSShipTracking] as s
	INNER JOIN @USPSTracking us ON us.ShipTrackId = s.ShipTrackID
	WHERE OrderNoMissing	 = 0

	--Mark tracking numbers errors processed for errors that mean the shipment isnt in picked up yet
	UPDATE s
	SET ProcessExecutionId = @ProcessExecutionId, 
		ProcessStartDateTime = @StartTime,
		ProcessEndDateTime = '1/1/1900'
	FROM [gbsAcquire].[dbo].[USPSShipTracking] as s
	INNER JOIN (
		SELECT  ShiptrackID, 
			p.value('(./TrackInfo[1]/@ID)', 'varchar(500)') AS TrackingNumber,
			--p.value('(./TrackInfo)[1]', 'varchar(500)') AS TrackSummary,
			p.value('(./TrackInfo/Error/Description)[1]', 'varchar(500)') AS ERROR
			FROM [gbsAcquire].[dbo].[USPSShipTracking] as s
				CROSS APPLY TrackRequest.nodes('TrackResponse') t(p)
			WHERE p.value('(./TrackInfo/Error/Description)[1]', 'varchar(500)') LIKE '%The tracking number may be incorrect or the status update is not yet availabl%'
				AND ProcessExecutionId IS NULL
	) e ON e.TrackingNumber = s.TrackID
	WHERE s.ProcessExecutionId IS NULL

END TRY
BEGIN CATCH
    --log errors
	EXEC usp_StoredProcedureErrorLog

END CATCH