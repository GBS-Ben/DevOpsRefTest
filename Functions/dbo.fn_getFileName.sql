CREATE FUNCTION "dbo"."fn_getFileName"
(
	@path nvarchar(260)
)
RETURNS nvarchar(260)
AS
BEGIN
	IF(CHARINDEX('/', @path) > 0)
		 SELECT @path = RIGHT(@path, CHARINDEX('/', REVERSE(@path)) -1)
		 RETURN @path;
END