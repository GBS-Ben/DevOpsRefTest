
CREATE PROCEDURE usp_LogUPSTrackingData
@TrackingNumber varchar(100),
@TrackingRequest varchar(max)
AS
SET NOCOUNT ON;

INSERT  gbsAcquire.dbo.UPSTracking (
TrackingNumber, TrackingRequest)
VALUES (@trackingNumber, @TrackingRequest)