CREATE PROCEDURE [dbo].[usp_PushNopOrderStatus]
AS
/*---------------------------------------------------------------------------
-- Author:		Shreck
-- Create date: 08/04/2017
-- Description:	Updates nop orders with intranet status and shipping changes

	--04/27/21		CKB, Markful


These are the statuses for NOP
    --   ShippingNotRequired = 10,
    --	NotYetShipped = 20,
    --PartiallyShipped = 25,
    --Shipped = 30,
    --Delivered = 40,
	--	    public enum OrderStatus
    --{
    --    Pending = 10,
    --    Processing = 20,
    --    Complete = 30,
    --    Cancelled = 40
	--04/27/21		CKB, Markful

	--------------------------------------------------------------------------------------------------------------*/
	SET NOCOUNT ON;
	
	DECLARE @StatusMessage varchar(100)
	, @Start datetime = DATEADD(DAY,-10,GETDATE())
	, @EventName varchar(100) = 'Prop NOP Order Status'
	, @ExecutionId int

	SET @Start = ISNULL((SELECT MAX(ExecutionEndDate)  FROM [dbo].[ProcessExecutionLog] WHERE EventName = @EventName  AND ExecutionEndDate IS NOT NULL), '1/1/1900')

	--log the execution of the process
	INSERT [dbo].[ProcessExecutionLog] (EventName, ExecutionStartDate, StatusMessage) VALUES (@EventName, @Start, 'Started Processing')

	BEGIN TRY

		SELECT @ExecutionID =  @@IDENTITY

	   DECLARE  @nopOrders TABLE
	   (rownum int identity(1,1) Primary Key, 
		OrderNo varchar(100),
		OrderGuid uniqueidentifier, 
		NopOrderID int, 
		OrderStatus varchar(100),
		ShippingStatus int,
		TrackingNumber varchar(100), 
		DateShipped Datetime,
		DateDelivered Datetime,
		TotalWeight int 
		)
	
		--GET all ncc orders
		INSERT @nopOrders (OrderNo, OrderStatus, DateShipped, DateDelivered)
		SELECT OrderNo,
			 OrderStatus,
			 shipDate,
			 CASE WHEN OrderStatus = 'Delivered' THEN statusDate ELSE NULL END
		FROM  tblorders o
		WHERE (OrderNO LIKE 'ADH%' OR
			OrderNO LIKE 'ATM%' OR 
			OrderNo LIKE 'NCC%' OR
			OrderNo LIKE 'HOM%' OR
			OrderNo LIKE 'MRK%') 
			AND Nop =1
			AND LastStatusUpdate >= @Start   -- Get data since the last time we ran this Event
		
		 
		IF (SELECT COUNT(*) FROM @nopOrders) > 0   -- make sure we have work to do before we do it.
		BEGIN

			--Get the nop id for our order.  We will change this to the guid when we modify the nop migration
			UPDATE n
			SET NopOrderID = nopID
			FROM @nopOrders n
			INNER JOIN dbo.nopcommerce_tblNopOrder nop  ON nop.gbsOrderID = n.OrderNo

			UPDATE n
			SET TrackingNumber = CASE WHEN t.TrackingNumber LIKE '%UP%' THEN NULL WHEN t.TrackingNumber LIKE '%USP%' THEN NULL ELSE t.TrackingNumber END, 
				DateShipped = ISNULL( t.[pickup date],DateShipped),  --job track is sometimes wrong for old orders so we use the order table information when it is available!
				DateDelivered = ISNULL(t.DeliveredOn, n.DateDelivered) 
		   FROM tblJobTrack t
		   INNER JOIN @nopOrders n ON n.OrderNo = t.JobNumber
   
		   UPDATE n
		   SET ShippingStatus = CASE WHEN OrderStatus = 'Delivered' THEN  40 
												WHEN OrderStatus LIKE 'In Transit%' THEN  30 
												WHEN OrderStatus IN ('On HOM Dock','On MRK Dock') THEN  30 
											ELSE NULL
											END,
				 OrderStatus = CASE WHEN OrderStatus = 'In House' THEN  20 
												WHEN OrderStatus LIKE 'In Production' THEN  20 
												WHEN OrderStatus IN ('On HOM Dock','On MRK Dock') THEN  30
												WHEN OrderStatus = 'Cancelled' THEN  40		
												WHEN OrderStatus = 'Delivered' THEN  30	
												WHEN OrderStatus  LIKE 'In Transit%' THEN  30			
											 --  WHEN OrderStatus = 'Back Ordered' THEN  10
												--WHEN OrderStatus = 'Waiting For Payment' THEN  10										 
											ELSE NULL END
		FROM @nopOrders n

		--Add new shipping records
		  INSERT dbo.[nopcommerce_Shipment] (OrderId, TrackingNumber, ShippedDateUtc, DeliveryDateUtc, CreatedOnUtc)
		  SELECT d.id, o.TrackingNumber, o.DateShipped, o.DateDelivered, GETUTCDATE()
		  FROM @nopOrders o
		  INNER JOIN dbo.nopcommerce_Order d 
			ON o.NopOrderID = d.id
		  LEFT JOIN  dbo.[nopcommerce_Shipment] s 
			ON s.OrderId = d.Id
		  WHERE o.TrackingNumber IS NOT NULL
			AND s.OrderId IS NULL  -- insert the new records

			--update existing shipping records
		 UPDATE s 
		 SET [ShippedDateUtc] = ISNULL(s.[ShippedDateUtc], o.DateShipped),   --Update the shipping date if it is null
			[DeliveryDateUtc] = ISNULL(s.[DeliveryDateUtc], o.DateDelivered)
		  FROM @nopOrders o
		  INNER JOIN dbo.nopcommerce_Order d 
			ON o.NopOrderID = d.id
		  INNER JOIN  dbo.[nopcommerce_Shipment] s 
			ON s.OrderId = d.Id
		  WHERE o.TrackingNumber IS NOT NULL

			UPDATE  d
			SET [OrderStatusId] = ISNULL(OrderStatus, d.[OrderStatusId]) , -- use the existing if the status is not new
				[ShippingStatusId] = ISNULL(ShippingStatus,d.[ShippingStatusId]) -- use the existing if the status is not new
			FROM @nopOrders o
		  INNER JOIN dbo.nopcommerce_Order d 
			ON o.NopOrderID = d.id
	 END

	 UPDATE [dbo].[ProcessExecutionLog]
	 SET ExecutionEndDate = GETDATE(), 
		StatusMessage = 'Success'
	WHERE ExecutionLogID = @ExecutionId

END TRY
BEGIN CATCH

	UPDATE [dbo].[ProcessExecutionLog]
	 SET  StatusMessage = 'Failure - See Stored Procedure Execution Log'
	WHERE ExecutionLogID = @ExecutionId

	--Capture errors if they happen
	EXEC [usp_StoredProcedureErrorLog]

END CATCH