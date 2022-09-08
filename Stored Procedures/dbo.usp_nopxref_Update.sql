CREATE proc [dbo].[usp_nopxref_Update] as
if object_id('tempdb..#PAData') is not null
	drop table #PAData

create table #PAData
(productCode varchar(50)
,PPAM_Id int
,PA_Id int
,optionGroup varchar(50)
,optionCaption varchar(255)
,optionPrice decimal(15,4))

insert into #PAData(productCode,PPAM_Id,PA_Id,optionGroup,optionCaption,optionPrice)
select  --top 10000
case when CHARINDEX('-GBS',a.Sku) <> 0 then LEFT(a.Sku,CHARINDEX('-GBS',a.Sku)-1) else a.Sku end as productCode --natural key for product
,ppam.id as PPAM_Id
,ppam.ProductAttributeId as PA_Id
,pa.[Name] as optionGroup
,optionCaption = case when pav.[Name] is null then pa.[Name] else pav.[Name] end 
,isnull(pav.PriceAdjustment,0) as optionPrice
from dbo.nopcommerce_Product a
inner join dbo.nopcommerce_Product_ProductAttribute_Mapping ppam
	on a.id = ppam.ProductId
inner join dbo.nopcommerce_ProductAttribute pa
	on ppam.ProductAttributeId = pa.id
left join dbo.nopcommerce_ProductAttributeValue pav
	on ppam.Id = pav.ProductAttributeMappingId
where a.sku is not null
and len(rtrim(a.sku)) > 0
and Published = 1
and Deleted = 0
and ppam.ProductAttributeId not in (1,72,82,80,147,131,128)

if object_id('tempdb..#ProductOptionGroups') is not null
	drop table #ProductOptionGroups

create table #ProductOptionGroups
(optionGroupCaption nvarchar(50)
,optionGroupType nvarchar(50)
,isEditable bit
,isActive bit
,nopProductAttributeId int
)

insert into #ProductOptionGroups(optionGroupCaption,optionGroupType,isEditable,isActive,nopProductAttributeId)
select 
optionGroupCaption = a.optionGroup
,optionGroupType = 'text'
,isEditable = 1
,isActive = 1
,nopProductAttributeId = a.PA_Id
from #PAData a
group by a.PA_Id
,a.optionGroup

--insert new POGs that do not exist or name changed
INSERT INTO [dbo].[nopxref_tblProductOptionGroups]
           ([optionGroupCaption]
           ,[optionGroupType]
           ,[isEditable]
		   ,[isActive]
           ,[nopProductAttributeId])
select 
[optionGroupCaption]
,[optionGroupType]
,[isEditable]
,[isActive]
,[nopProductAttributeId] 
from #ProductOptionGroups spog
where not exists
	(select top 1 1 
	 from dbo.nopxref_tblProductOptionGroups pog
	 where spog.nopProductAttributeId = pog.nopProductAttributeId
		and spog.optionGroupCaption = pog.optionGroupCaption
		and pog.isActive = 1)

--deactivate old POG records
update dbo.nopxref_tblProductOptionGroups set isActive = 0, dateUpdated = getdate()
where optionGroupId in
(
	select a.optionGroupId
	from 
	(
		select pog.optionGroupId
		,RowNum = ROW_NUMBER() over (partition by pog.nopProductAttributeId order by pog.dateCreated desc)
		from dbo.nopxref_tblProductOptionGroups pog
		where pog.isActive = 1
	) a
	where a.RowNum > 1
)

if object_id('tempdb..#ProductOptions') is not null
	drop table #ProductOptions

create table #ProductOptions
(	[optionGroupId] int,
	[optionCaption] varchar(255),
	[displayOnOrderView] bit,
	[orderViewDisplayText] varchar(255),
	[displayOnJobTicket] bit,
	[jobTicketDisplayText] varchar(255),
	[displayOnReceipt] bit,
	[receiptDisplayText] varchar(255),
	[isFileOppo] bit,
	[isHyperlink] bit,
	[isEditable] bit,
	[isActive] bit
)

insert into #ProductOptions(optionGroupId,optionCaption,displayOnOrderView,orderViewDisplayText,displayOnJobTicket,jobTicketDisplayText,displayOnReceipt,receiptDisplayText,isFileOppo,isHyperlink,isEditable,isActive)
select b.optionGroupId
,a.optionCaption
,displayOnOrderView = 1
,orderViewDisplayText = a.optionCaption
,displayOnJobTicket = 1
,jobTicketDisplayText = a.optionCaption
,displayOnReceipt = 1
,receiptDisplayText = a.optionCaption
,isFileOppo = 0
,isHyperLink = 0
,isEditable = 1
,isActive = 1
from nopxref_tblProductOptionGroups b
left join #PAData a
	on a.optionGroup = b.optionGroupCaption
where b.isActive = 1
group by b.optionGroupId
--,a.optionGroup
,optionCaption

--insert new POs that do not exist 
INSERT INTO [dbo].[nopxref_tblProductOptions]
           ([optionGroupId]
           ,[optionCaption]
           ,[displayOnOrderView]
           ,[orderViewDisplayText]
           ,[displayOnJobTicket]
           ,[jobTicketDisplayText]
           ,[displayOnReceipt]
           ,[receiptDisplayText]
           ,[isFileOppo]
           ,[isHyperlink]
           ,[isEditable]
		   ,[isActive]
		   )
select 
[optionGroupId]
,[optionCaption]
,[displayOnOrderView]
,[orderViewDisplayText]
,[displayOnJobTicket]
,[jobTicketDisplayText]
,[displayOnReceipt]
,[receiptDisplayText]
,[isFileOppo]
,[isHyperlink]
,[isEditable]
,[isActive]
from #ProductOptions spo
where not exists
	(select top 1 1 
	 from dbo.nopxref_tblProductOptions po
	 where spo.optionGroupId = po.optionGroupId
		and spo.optionCaption = po.optionCaption
		and po.isActive = 1)

--deactivate old PO records
update dbo.nopxref_tblProductOptions set isActive = 0, dateUpdated = getdate()
where optionGroupId in
(
	select a.optionId
	from 
	(
		select po.optionId
		,RowNum = ROW_NUMBER() over (partition by po.optionGroupId,po.optionCaption order by po.dateCreated desc)
		from dbo.nopxref_tblProductOptions po
		where po.isActive = 1
	) a
	where a.RowNum > 1
)

INSERT INTO [dbo].[nopxref_tblProduct_ProductOptions]
           ([productID]
           ,[optionID]
           ,[optionGroupID]
           ,[optionPrice]
           ,[optionDiscountApplies]
           ,[displayOnOrderView]
           ,[orderViewDisplayText]
           ,[displayOnJobTicket]
           ,[jobTicketDisplayText]
           ,[displayOnReceipt]
           ,[receiptDisplayText]
           ,[isEditable]
		   )
select distinct --top 1000 
p.productId
,po.optionId
,pog.optionGroupId
,a.optionPrice
,optionDiscountApplies = 1
,displayOnOrderView = 1
,orderViewDisplayText = a.optionCaption
,displayOnJobTicket = 1
,jobTicketDisplayText = a.optionCaption
,displayOnReceipt = 1
,receiptDisplayText = a.optionCaption
,isEditable = 1 
from #PAData a
inner join dbo.tblProducts p
	on a.productCode = p.productCode
inner join nopxref_tblProductOptionGroups pog
	on a.optionGroup = pog.optionGroupCaption
inner join nopxref_tblProductOptions po
	on pog.optionGroupId = po.optionGroupId
		and a.optionCaption = po.optionCaption
where not exists
	(select top 1 1 from nopxref_tblProduct_ProductOptions ppo where ppo.productId = p.productId and ppo.optionId = po.optionId)