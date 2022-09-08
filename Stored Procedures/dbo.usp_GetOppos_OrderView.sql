create proc [dbo].[usp_GetOppos_OrderView]
@ordersProductsId int
as

--Get file oppos first
SELECT oppo.optionID
,oppo.optionCaption
,oppo.optionprice
,oppo.optionQty
,oppo.optionGroupCaption
,textValue = case when po.isHyperlink = 0 then oppo.textValue else 'View' end
,link = case when po.isHyperlink = 1 then oppo.textValue else null end
FROM tblOrdersProducts_ProductOptions oppo
left join tblProductOptions po
	on oppo.optionID = po.optionID
WHERE oppo.ordersproductsID = @ordersProductsId 
	AND oppo.deletex <> 'yes' 
	and po.displayOnOrderView = 1

order by oppo.optionPrice desc, oppo.optionGroupCaption, oppo.optionCaption, oppo.pkid asc