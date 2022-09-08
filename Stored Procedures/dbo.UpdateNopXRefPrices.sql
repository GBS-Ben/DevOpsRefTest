CREATE proc [dbo].[UpdateNopXRefPrices]
as 

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
inner join [dbo].[nopCommerce_Product_ProductAttribute_Mapping] ppam
	on a.id = ppam.ProductId
inner join [dbo].[nopCommerce_ProductAttribute] pa
	on ppam.ProductAttributeId = pa.id
left join [dbo].[nopCommerce_ProductAttributeValue] pav
	on ppam.Id = pav.ProductAttributeMappingId
where a.sku is not null
and len(rtrim(a.sku)) > 0
and Published = 1
and Deleted = 0
and ppam.ProductAttributeId not in (1,72,82,80,147,131,128)


select distinct --top 1000 
p.productId
,po.optionId
,pog.optionGroupId
,a.optionPrice
into #oppo
from #PAData a
inner join dbo.tblProducts p
	on a.productCode = p.productCode
inner join nopxref_tblProductOptionGroups pog
	on a.optionGroup = pog.optionGroupCaption
inner join nopxref_tblProductOptions po
	on pog.optionGroupId = po.optionGroupId
		and a.optionCaption = po.optionCaption

update n set optionPrice = o.optionPrice
from [nopxref_tblProduct_ProductOptions] n
inner join #oppo o on n.productid = o.productID and n.optionId = o.optionID and n.optionGroupId = o.optionGroupId
where n.optionPrice <> o.optionPrice