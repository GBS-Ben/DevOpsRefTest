CREATE FUNCTION [dbo].[fn_Get10DigitCompanyCode]
(   
    @CompanyId int 
)
RETURNS varchar(100)
AS
BEGIN
	
	DECLARE @10DigitCode varchar(100) 


	SELECT @10DigitCode = 

		CASE WHEN ISNULL(CompanyShortCode,'00') = 'TH'  THEN  ISNULL(CompanyShortCode,'') + '-' +   ISNULL(CONVERT(varchar(100),CompanyOfficeCode),'000') + '-' + ISNULL(CompanyLongCode,'00000')
		ELSE  ISNULL(CompanyShortCode,'00') + '-' +   ISNULL(CONVERT(varchar(100),CompanyOfficeCode),'000') + '-' + CASE WHEN CompanyLongCode LIKE '[0-9][0-9][0-9][0-9][0-9]' THEN ISNULL(CompanyLongCode,'00000') ELSE '00000' END
		END
FROM HOMLive_CompanyList
WHERE CompanyId = @CompanyId
	RETURN @10DigitCode
END