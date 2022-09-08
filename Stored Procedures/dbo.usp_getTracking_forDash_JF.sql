CREATE PROC [dbo].[usp_getTracking_forDash_JF]
@orderNo VARCHAR(100)
AS
SELECT * FROM tblJobTrack
WHERE jobNumber = @orderNo

SELECT * FROM tblDashboard_Prop_JobTrack
WHERE orderNo = @orderNo


SELECT * FROM SQL01.HOMLIVE.dbo.tblDashboard_JobTrack
WHERE orderNo = @orderNo