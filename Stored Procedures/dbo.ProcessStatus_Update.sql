CREATE PROC [dbo].[ProcessStatus_Update]
@processName varchar(255),@lastRunDateTime datetime
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE processStatus SET lastRunDateTime = @lastRunDateTime WHERE processName = @processName
	
END