
CREATE FUNCTION dbo.GetWorkflowControl
(
	@OPID INT, @WPID INT, @RunNumber INT
)
RETURNS VARCHAR(255)
AS
BEGIN

	RETURN (select @opid as opid,@wpid as wpid, @runnumber as runnumber for json path)


END