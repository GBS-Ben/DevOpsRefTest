create proc [dbo].[usp_MIG_SyncProductionFiles] as
begin

UPDATE p
SET textValue = f.InfoBlock, 
	modified_on = GETDATE()
FROM tblOrdersProducts_ProductOptions p 
INNER JOIN dbo.tblNOPProductionFiles f 
	ON p.ordersProductsId = f.nopOrderItemID
WHERE optionId = 577 --DefaultLayout
	AND f.InfoBlock IS NOT NULL
	AND TextValue <> f.infoBlock
	AND f.CreateDate > '6/1/2019'

end