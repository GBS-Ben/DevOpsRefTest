CREATE proc [dbo].[usp_DeleteProductOptions_iFrame_02052021] 
@ordersProductsId int
,@optionIdDelete int
,@optionPrice decimal(15,2)
as

--declare @ordersProductsId int = 555970522
--,@optionIdDelete int = 10054
--,@optionPrice decimal(15,2) = 0.16

declare @optionId int 
,@optionCaption varchar(255)
,@textValue varchar(4000)

select @optionId = pol.optionId
,@optionCaption = pog.optionGroupCaption
,@textValue = po.optionCaption -- case when @optionPrice > 0 then po.optionCaption + ' [+$' + rtrim(cast(@optionPrice as varchar(10))) + ']' else po.optionCaption end
--select pol.optionid,pog.optionGroupCaption,po.optionCaption
from nopxref_tblProductOptions po
inner join nopxref_tblProductOptionGroups pog
	on po.optionGroupId = pog.optionGroupId
left join 
	(select optionCaption, max(optionId) optionId
	 from dbo.tblProductOptions
	 where optionID <> 252
	 group by optionCaption) pol
	on pog.optionGroupCaption = pol.optionCaption
where po.optionId = @optionIdDelete
;

with cteOPPOs as 
(
	select pkid,ordersProductsID,optionID,optionCaption,rtrim(substring(isnull(oppo.textValue,''),1,case when charindex('[',isnull(oppo.textValue,'')) > 0 then charindex('[',isnull(oppo.textValue,''))-1 else len(isnull(oppo.textValue,'')) end)) as textValue,deletex
	from tblOrdersProducts_ProductOptions oppo
	where ordersProductsID = @ordersProductsId
	  and deletex <> 'yes'
),
cteOPPOTrans as 
(
	select legacyOptionID,legacyOptionCaption,rtrim(substring(isnull(t.legacytextValue,''),1,case when charindex('[',isnull(t.legacytextValue,'')) > 0 then charindex('[',isnull(t.legacytextValue,''))-1 else len(isnull(t.legacytextValue,'')) end))  as legacyTextValue,
			newOptionID,newOptionCaption,rtrim(substring(isnull(t.newtextValue,''),1,case when charindex('[',isnull(t.newtextValue,'')) > 0 then charindex('[',isnull(t.newtextValue,''))-1 else len(isnull(t.newtextValue,'')) end))  as newTextValue
	from tblOPPO_Translations t
)

update dbo.tblOrdersProducts_ProductOptions set deletex = 'yes'
--select c.textValue,* 
from cteOPPOs c
inner join tblOrdersProducts_ProductOptions oppo on c.pkid = oppo.pkid
left join cteOPPOTrans t on c.optionid = t.legacyoptionid and c.optionCaption = t.legacyOptionCaption and c.textValue = t.legacyTextValue
where c.ordersProductsID = @ordersProductsId
	and ((t.newoptionID = @optionId
	and t.newoptionCaption = @optionCaption
	and t.newtextValue = @textValue)
	or (c.optionid = @optionid
	and c.optionCaption = @optionCaption
	and c.textValue = @textValue))
	and c.deletex <> 'yes'