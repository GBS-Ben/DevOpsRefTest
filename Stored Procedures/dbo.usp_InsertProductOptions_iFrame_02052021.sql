CREATE proc [dbo].[usp_InsertProductOptions_iFrame_02052021] 
@ordersProductsId int
,@optionId int
,@optionPrice decimal(15,2)
as

--declare @ordersProductsId int = 556072354
--,@optionId int = 10198
--,@optionPrice decimal(15,2) = 10.0

insert into dbo.tblOrdersProducts_ProductOptions(ordersProductsID, optionID, optionCaption, optionPrice, optionGroupCaption, textValue, deletex, optionQty, created_on,modified_on) 
select @ordersProductsId as ordersProductsId
,pol.optionId
,pog.optionGroupCaption as optionCaption
,@optionPrice as optionPrice
,'' as optionGroupCaption
,po.optionCaption --case when @optionPrice > 0 then po.optionCaption + ' [+$' + rtrim(cast(@optionPrice as varchar(10))) + ']' else po.optionCaption end as textValue
,'0' as deletex
,case when pog.optionGroupCaption in ('Express Production','Custom Artwork','Change Fee','Custom Art Fee','Design Fee','Setup Charges',
							'Electronic Proof','Receive an Electronic Proof','Custom Artwork','Photo and Logo x 3','Photo and Logo x 5','Photo and Logo x 4')
							then 1
		when (left(op.productCode,2) = 'BP' or left(op.productCode,4) = 'GNNC' or left(op.productCode,2) = 'FANC') then op.productQuantity * 100
		else op.productQuantity end as optionQty
,getdate() as created_on
,getdate() as modified_on
from nopxref_tblProductOptions po
inner join nopxref_tblProductOptionGroups pog
	on po.optionGroupId = pog.optionGroupId
inner join dbo.tblOrders_Products op
	on op.id = @ordersProductsId
left join 
	(select optionCaption, max(optionId) optionId
	 from dbo.tblProductOptions
	 where optionID <> 252
	 group by optionCaption) pol
	on pog.optionGroupCaption = pol.optionCaption
where po.optionId = @optionId