CREATE FUNCTION [dbo].[ParseTimeFromString](@TimeString nvarchar(20))
RETURNS TIME
AS 
BEGIN

    DECLARE @CleanTime time

	IF LEN(@TimeString) = 6
	BEGIN
		SELECT @CleanTime = CONVERT(time,(SUBSTRING(@TimeString, 1, 2) + ':' + SUBSTRING(@TimeString, 3, 2)+ ':' + SUBSTRING(@TimeString, 5, 2)))
	END
	IF LEN(@TimeString) = 5
	BEGIN
		SELECT @CleanTime = CONVERT(time,('0' + SUBSTRING(@TimeString, 1, 2) + ':' + SUBSTRING(@TimeString, 3, 2)+ ':' + SUBSTRING(@TimeString, 5, 2)))
	END
		IF LEN(@TimeString) = 4
	BEGIN
		SELECT @CleanTime = CONVERT(time,(SUBSTRING(@TimeString, 1, 2) + ':' + SUBSTRING(@TimeString, 3, 2)+ ':00'))
	END
		IF LEN(@TimeString) = 3
	BEGIN
		SELECT @CleanTime = CONVERT(time,(SUBSTRING(@TimeString, 1, 1) + ':' + SUBSTRING(@TimeString, 2, 2)+ ':00'))
	END


    RETURN @CleanTime

END