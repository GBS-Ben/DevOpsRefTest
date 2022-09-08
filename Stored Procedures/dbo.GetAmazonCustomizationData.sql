
CREATE PROCEDURE GetAmazonCustomizationData @ProductType varchar(20) = 'AW'

AS
SET NOCOUNT ON;
BEGIN



SELECT j.[order-item-id] + '.json', j.[order-item-id], j.BuyerCustomizedInfoJSON 
FROM tblAMZ_CustomizedInfoJSON j
INNER JOIN tblAMZ_orderImporter i on i.[order-item-id] = j.[order-item-id]
WHERE CreatedOn > DATEADD(mi,-120,GETDATE()) 
--j.[order-item-id] = 12935713789650


END