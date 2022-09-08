
CREATE PROC usp_getProductsByCode @productCode VARCHAR(100)
AS
SELECT * FROM tblProducts
WHERE productCode LIKE @productCode