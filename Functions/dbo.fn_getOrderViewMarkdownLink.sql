CREATE FUNCTION "dbo"."fn_getOrderViewMarkdownLink" (
	@linkText VARCHAR(64),
	@orderNo VARCHAR(32)
	)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @url VARCHAR(128);
	SELECT @url = dbo.fn_getOrderViewLink(@orderNo);
	RETURN CONCAT('[', @linkText, '](', @url , ')' );
END