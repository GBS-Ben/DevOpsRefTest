CREATE FUNCTION [dbo].[fn_BadCharacterStripper_noLower] 
(
    @Inputstring nvarchar(255)
)
RETURNS nvarchar(255)
AS
BEGIN
--declare @InputString nvarchar(255) = 'This 51354¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ßàáâãäåæçshould èéêëìíîïðñòóôõöøùúûüýþÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ appear'
 
    DECLARE @returnString nvarchar(255)
    SET @returnString = ''
 
    DECLARE @nchar nvarchar(1)
    DECLARE @position int
 
    SET @position = 1
    WHILE @position <= LEN(@InputString)
    BEGIN
        SET @nchar = SUBSTRING(@InputString, @position, 1)
        --Unicode & ASCII are the same from 1 to 255.
        --Only Unicode goes beyond 255
        --0 to 31 are non-printable characters
        IF (UNICODE(@nchar) between 192 and 198) or (UNICODE(@nchar) between 225 and 230) 
            SET @nchar = 'a'
        IF (UNICODE(@nchar) between 200 and 203) or (UNICODE(@nchar) between 232 and 235) 
            SET @nchar = 'e'
        IF (UNICODE(@nchar) between 204 and 207) or (UNICODE(@nchar) between 236 and 239) 
            SET @nchar = 'i'
        IF (UNICODE(@nchar) between 210 and 214) or (UNICODE(@nchar) between 242 and 246) or (UNICODE(@nchar)=240) 
            SET @nchar = 'o'
        IF (UNICODE(@nchar) between 217 and 220) or (UNICODE(@nchar) between 249 and 252)  
            SET @nchar = 'u'
        IF (UNICODE(@nchar)=199)  or (UNICODE(@nchar)=231)  -- letter Ç or ç 
            SET @nchar = 'c'
        IF (UNICODE(@nchar)=209)  or (UNICODE(@nchar)=241)  -- letter Ñ or ñ 
            SET @nchar = 'n'
        IF (UNICODE(@nchar) between 45 and 46) or (UNICODE(@nchar) between 48 and 57) or (UNICODE(@nchar)  between 64 and 90) or (UNICODE(@nchar) = 95) or (UNICODE(@nchar)  between 97 and 122) or (UNICODE(@nchar) = 32)
            SET @returnString = @returnString + @nchar
        SET @position = @position + 1
    END
    --SET @returnString = lower(@returnString) -- emails in lower case

	--select @returnString
    RETURN @returnString
 
END