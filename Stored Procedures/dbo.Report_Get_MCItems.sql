CREATE proc [dbo].[Report_Get_MCItems]
AS
with EmployeeCount as
(
       select *
       from
       (
       SELECT [ordersProductsID]
                ,[optionCaption]
                ,[textValue]
       FROM [dbo].[tblOrdersProducts_ProductOptions]
       where optionCaption in ('Employee Count','Company Name')
       ) src
       pivot
       (
              max(textValue)
              for OptionCaption in ([Employee Count],[Company Name])
       ) pv
)
,MarketCenter as
(
select 
	cl.companyName
	,mc.mcId
	,item = '(' +
	stuff((select (', ' + mci.itemName)
		   from [dbo].[HOMLive_MarketingCenterItems] mci
		   where mci.mcId = mc.mcId
		   order by mci.itemName
		   for xml path ('') ), 1,1, '') + ')'
from [dbo].[HOMLive_CompanyList] cl
inner join [dbo].[HOMLive_MarketingCenters] mc
       on cl.companyId = mc.companyId
)
select distinct
o.orderNo
,CONVERT(VARCHAR(255),(DATEPART(YYYY, o.orderDate))) + '/' + RIGHT('00' + CONVERT(VARCHAR(255),(DATEPART(mm, o.orderDate))), 2) + '/' + RIGHT('00' + CONVERT(VARCHAR(255),(DATEPART(dd, o.orderDate))), 2) as orderDate
,o.billing_FirstName
,o.billing_Street
,o.billing_Company
,o.billing_Street2
,o.billing_Suburb
,o.billing_State
,o.billing_Phone
,o.billing_PostCode
,c.email
,ec.[Company Name]
,ec.[Employee Count]
,mc.companyName MCName
,mc.item as MCItems
from dbo.tblOrders o
inner join dbo.tblOrders_Products op
       on o.orderID = op.orderID
inner join dbo.tblCustomers c
       on o.customerID = c.customerID
left join EmployeeCount ec
       on op.ID = ec.ordersProductsID
left join MarketCenter mc
       on ec.[Company Name] like --'%' + 
		mc.companyName + '%'
where op.productID = 200232
and orderDate > getdate() -(365)
AND orderStatus NOT IN ('Cancelled', 'Waiting for payment')
ORDER BY orderDate DESC