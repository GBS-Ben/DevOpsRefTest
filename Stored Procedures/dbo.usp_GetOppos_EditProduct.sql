CREATE proc [dbo].[usp_GetOppos_EditProduct] 
@ordersProductsId int 
as
/*****************************/
-- 03/02/21	CKB, added ppo.isactive = 1
/*****************************/

select ppo.optionId
,ppo.optionGroupId
,pog.optionGroupCaption
,pog.optionGroupType
, po.optionCaption 
,max(coalesce(oppo.optionPrice,ppo.optionPrice)) as optionPrice
,selected = case when oppo.optionID is not null then 1 else 0 end
,active = po.isActive
,textValue = rtrim(substring(isnull(oppo.textValue,''),1,case when charindex('[',isnull(oppo.textValue,'')) > 0 then charindex('[',isnull(oppo.textValue,''))-1 else len(isnull(oppo.textValue,'')) end))
,ordersProductsGUID
--select *
from dbo.tblOrders_Products op
inner join dbo.nopxref_tblProduct_ProductOptions ppo
	on op.productID = ppo.productId
inner join dbo.nopxref_tblProductOptions po
	on ppo.optionId = po.optionID
inner join dbo.nopxref_tblProductOptionGroups pog
	on po.optionGroupID = pog.optionGroupID
left join dbo.vwtblOrdersProducts_ProductOptions_Trans oppo
	on op.id = oppo.ordersProductsID
		and pog.optionGroupCaption = oppo.optionCaption
		and (rtrim(substring(po.optionCaption,1,case when charindex('[',po.optionCaption) > 0 then charindex('[',po.optionCaption)-1 else len(po.optionCaption) end))  =  rtrim(substring(oppo.textValue,1,case when charindex('[',oppo.textValue) > 0 then charindex('[',oppo.textValue)-1 else len(oppo.textValue) end))
			or pog.optionGroupType = 'text')			
		and oppo.deletex <> 'yes'
where op.id = @ordersProductsId
	and pog.isEditable = 1
	and po.isEditable = 1
	and pog.isActive = 1
	and ppo.isActive  = 1
group by ppo.optionId,pog.optionGroupCaption, ppo.optionGroupId,pog.optionGroupType, po.optionCaption,case when oppo.optionID is not null then 1 else 0 end,po.isActive,rtrim(substring(isnull(oppo.textValue,''),1,case when charindex('[',isnull(oppo.textValue,'')) > 0 then charindex('[',isnull(oppo.textValue,''))-1 else len(isnull(oppo.textValue,'')) end)),ordersProductsGUID
order by pog.optionGroupCaption, ppo.optionGroupId, po.optionCaption