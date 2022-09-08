
CREATE PROCEDURE [dbo].[usp_GetUSPSTrackingNumbers]

AS

SET NOCOUNT ON

BEGIN TRY


	SELECT DISTINCT trackingNo
	FROM tblOrders o
	INNER JOIN [tblEndiciaPostBack]  e 
		ON o.OrderNo = REPLACE(e.orderNo, 'ON', '')
	LEFT JOIN gbsAcquire.dbo.USPSShipTracking us 
		ON us.TrackID = e.trackingNo
			AND us.ProcessExecutionId IS NULL
	WHERE orderStatus NOT IN ('Cancelled','Delivered', 'Failed')
		AND (us.TrackID IS NULL 
			OR (us.AcquireInsertDateTime < DATEADD(d,-2,GETDATE())
				AND 
				us.ProcessExecutionId IS NULL)
				)-- Only tracking numbers not currently being processed


END TRY 
BEGIN CATCH

	EXECUTE  [dbo].[usp_StoredProcedureErrorLog]

END CATCH