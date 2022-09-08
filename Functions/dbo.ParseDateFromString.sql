CREATE FUNCTION [dbo].[ParseDateFromString](@DateString nvarchar(20))
RETURNS DATETIME
AS 
BEGIN

    DECLARE @CleanDate datetime

	SELECT @CleanDate = CONVERT(datetime2,(SUBSTRING(@DateString, 5, 2) + '/' 
		+ SUBSTRING(@DateString, 7, 2)  + '/' 
		+ SUBSTRING(@DateString, 1, 4)))

    RETURN @CleanDate

END