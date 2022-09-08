CREATE PROCEDURE [dbo].[usp_GetUPSTrackingNumbers]

AS

SET NOCOUNT ON

BEGIN TRY


	SELECT DISTINCT e.trackingnumber 
	FROM tblOrders o
	INNER JOIN tbljobtrack  e 
		ON o.OrderNo = REPLACE(e.jobnumber, 'ON', '')
	LEFT JOIN gbsAcquire.dbo.UPSTracking us 
		ON us.TrackingNumber = e.trackingnumber
			AND us.ProcessExecutionId IS NULL 
	 WHERE orderStatus NOT IN ('Cancelled','Delivered', 'Failed')
		--IN ('On HOM Dock', 'In Transit')
		AND us.trackingId IS NULL 
		AND e.trackingnumber like '1z%' 
		AND [pickup date] > dateadd(dd,-30,getdate() )
		AND e.deliveredOn IS NULL
		AND NOT EXISTS(    --only check every 4 hours
			SELECT TOP 1 1 
						FROM gbsAcquire.dbo.UPSTracking x 
						WHERE x.TrackingNumber = e.trackingnumber
							AND AcquireInsertDateTime > dateadd(HH, -4, GETDATE()
							)
							)
																

								
END TRY 
BEGIN CATCH

	EXECUTE  [dbo].[usp_StoredProcedureErrorLog]

END CATCH