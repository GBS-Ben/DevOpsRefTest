CREATE FUNCTION [dbo].[fnParseEmailAddress](@TextValue varchar(max))  
RETURNS varchar(500)   
AS   
-- Returns a valid email address.  This function only handles 1 email address in the text.
BEGIN  
	DECLARE @ValidEmail varchar(500), @RightText varchar(1000), @LeftText varchar(1000), @ReverseLeft varchar(1000)


	--Clean the text feild passed in
	SET @TextValue = REPLACE(REPLACE(REPLACE(@TextValue, CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ')   --replace tabs and line feeds with spaces


	--Split the email into Left, Right, and Left Reverse
	SET @RightText = LTRIM(RTRIM(CASE WHEN LEN(rtrim(ltrim(@TextValue))) - (CHARINDEX('@', LTRIM(RTRIM(@TextValue)), 0) - 1) > 0 THEN RIGHT(LTRIM(RTRIM(@TextValue)), LEN(RTRIM(LTRIM(@TextValue))) - (CHARINDEX('@', LTRIM(RTRIM(@TextValue)), 0) - 1)) ELSE NULL END))
	SET @LeftText =  LTRIM(RTRIM(LEFT(LTRIM(RTRIM(@TextValue)), CHARINDEX('@', LTRIM(RTRIM(@TextValue)), 0)-1))) 
	SET @ReverseLeft = LTRIM(RTRIM(REVERSE(LEFT(LTRIM(RTRIM(@TextValue)), CHARINDEX('@', LTRIM(RTRIM(@TextValue)), 0) - 1))))

	SELECT @ValidEmail =	COALESCE(CASE WHEN (PATINDEX('%[,:* \\]%', @ReverseLeft)-1) > 0  THEN LTRIM(RTRIM(RIGHT(@LeftText, PATINDEX('%[,:* \\]%', @ReverseLeft)-1))) ELSE NULL END, @LeftText) + 
			(CASE WHEN (PATINDEX('%[,:* \\]%', @RightText)-1) > 0 THEN LEFT(@RightText, PATINDEX('%[,:* \\]%', @RightText)-1) ELSE @RightText END)

	---Remove other cases the above code doesnt handle
	SELECT @ValidEmail = CASE WHEN @ValidEmail LIKE '%@' THEN NULL   
			WHEN @ValidEmail NOT LIKE '%@%.%' THEN NULL
		ELSE @ValidEmail
		END 

	 RETURN @ValidEmail

END;