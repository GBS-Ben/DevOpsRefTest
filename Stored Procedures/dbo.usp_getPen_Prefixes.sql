CREATE PROC usp_getPen_Prefixes
AS
SELECT DISTINCT 
SUBSTRING(productCode, 1, 6)
FROM tblProducts
WHERE productCode LIKE 'PN%'