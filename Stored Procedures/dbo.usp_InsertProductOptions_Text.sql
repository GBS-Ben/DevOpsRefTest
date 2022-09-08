CREATE proc [dbo].[usp_InsertProductOptions_Text] 
@ordersProductsId int
,@optionId int
,@optionPrice decimal(15,2)
,@optionQty int
,@textValue varchar(4000)
,@ordersProductsGUID uniqueidentifier
as

--declare @ordersProductsId int = 556067876
--,@optionId int = 10049
--,@optionPrice decimal(15,2) = 0.0
--,@optionQty int = 0
--,@textValue varchar(4000) = 'This is some text'

declare @tpoOptionId int
,@optionGroupId int
,@optionCaption varchar(255)

--Get legacy option Id
select top 1 @tpoOptionId = pol.optionId
	,@optionCaption = po.optionCaption
from nopxref_tblProductOptions po
inner join nopxref_tblProductOptionGroups pog
	on po.optionGroupId = pog.optionGroupId
left join 
	(select optionCaption, max(optionId) optionId
	 from dbo.tblProductOptions
	 where optionID <> 252
	 group by optionCaption) pol
	on pog.optionGroupCaption = pol.optionCaption
where po.optionId = @optionId

--soft delete the old record
update oppo set deletex = 'yes'
from dbo.tblOrdersProducts_ProductOptions oppo
where oppo.ordersProductsID = @ordersProductsId
	and oppo.optionID = @tpoOptionId

--insert into new text value into dbo.tblOrdersProducts_ProductOptions
insert into dbo.tblOrdersProducts_ProductOptions(ordersProductsID, optionID, optionCaption, optionPrice, optionGroupCaption, textValue, deletex, optionQty, ordersProductsGUID, created_on,modified_on) 
select @ordersProductsId as ordersProductsId
,@tpoOptionId as optionId
,@optionCaption as optionCaption
,@optionPrice as optionPrice
,'' as optionGroupCaption
,@textValue as textValue
,'0' as deletex
,@optionQty as optionQty
,@ordersProductsGUID
,getdate() as created_on
,getdate() as modified_on