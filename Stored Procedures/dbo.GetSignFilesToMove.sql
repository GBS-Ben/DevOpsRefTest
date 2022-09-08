CREATE PROCEDURE GetSignFilesToMove

AS 

select distinct
opcFileName = textValue
,signSingleFileName = jobnumber + right(oppo.textValue,7)
from SN_ImposerExport sie
inner join dbo.tblOrdersProducts_ProductOptions oppo
	on sie.opid = oppo.ordersProductsID
inner join dbo.tblOrders_Products op
	on oppo.ordersProductsID = op.ID
inner join dbo.tblOrders o
	on op.orderID = o.orderID
where oppo.optionCaption in ('CanvasHiResFront UNC File', 'CanvasHiResBack UNC File')
	AND datediff(MINUTE,o.orderdate,getdate()) > 30