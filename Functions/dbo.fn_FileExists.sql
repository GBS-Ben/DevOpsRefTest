CREATE FUNCTION [dbo].[fn_FileExists](@path VARCHAR(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN CAST(@result AS BIT)
END;