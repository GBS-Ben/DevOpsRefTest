-- =============================================
-- Author:		CBrowne
-- Create date: 12/07/2020
-- Description:	Modify the schedule of the PrintFileMover job
-- =============================================
CREATE PROCEDURE [dbo].[PrintFileMover_UpdateSchedule]
	@ScheduleDate datetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NewDatePart AS INT
	DECLARE @NewTimePart AS INT

	SET @NewDatePart = cast(convert(varchar(8),cast(@ScheduleDate as date),112) AS INT)
	SET @NewTimePart = replace(convert(varchar(8),cast(@ScheduleDate as time)),':','')

	exec msdb.dbo.sp_update_schedule 
		@name='PrintFileMover Schedule'
	  , @enabled = 1
	  , @active_start_date = @NewDatePart
	  , @active_start_time = @NewTimePart
END