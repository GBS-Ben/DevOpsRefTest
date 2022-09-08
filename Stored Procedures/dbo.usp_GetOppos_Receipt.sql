CREATE proc [dbo].[usp_GetOppos_Receipt]
@ordersProductsId int
as

--declare @ordersProductsId int = 556075272

declare @productId int = (select top 1 productID from tblOrders_Products where ID = @ordersProductsId)

SELECT oppo.optionID
,optionCaption = coalesce(ppo.jobTicketDisplayText,po.jobTicketDisplayText,po.optionCaption,oppo.optionCaption)
,oppo.optionprice
,oppo.optionQty
,oppo.optionGroupCaption
,textValue = case when po.isHyperlink = 0 then oppo.textValue else 'View' end
,link = case when po.isHyperlink = 1 then oppo.textValue else null end
FROM tblOrdersProducts_ProductOptions oppo
left join tblProduct_ProductOptions ppo
	on ppo.productID = @productId
		and oppo.optionID = ppo.optionID
left join tblProductOptions po
	on oppo.optionCaption = po.optionCaption
WHERE oppo.ordersproductsID = @ordersProductsId 
	AND oppo.deletex <> 'yes' 
	and po.displayOnReceipt = 1
	--and ppo.displayOnReceipt = 1