CREATE VIEW [dbo].[v_AMZ_reference]
AS
SELECT * FROM tblAMZ_orderShip
WHERE orderStatus = 'In House'
AND orderDate >= CONVERT(DATETIME, '08/20/2016')