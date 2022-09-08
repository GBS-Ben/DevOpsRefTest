CREATE PROCEDURE "dbo"."dashboard_CommissionsReport" 
as

with Company as
(
       select *
       from
       (
       SELECT ordersProductsID
                ,optionCaption
                ,textValue
       FROM dbo.tblOrdersProducts_ProductOptions
       where optionCaption in ('Company Name')
       ) src
       pivot
       (
              max(textValue)
              for OptionCaption in ([Company Name])
       ) pv
)
,OPO_Company as
(
select op.orderID, max(c.[Company Name]) as [Company Name]
from dbo.tblOrders_Products op
left join Company c
	on op.ID = c.ordersProductsID
group by op.orderID
)
select o.orderNo as [OrderNumber]
,opoc.[Company Name] as [CompanyName]
,o.orderDate as [OrderDate]
,vsu.sVoucherCode as [DiscountCode]
,coalesce(vsu.sVoucherAmountApplied,o.calcVouchers) as [DiscountAmount]
,o.calcCredits as [CreditAmount]
,o.orderTotal as [OrderTotal]
from dbo.tblOrders o
left join OPO_Company opoc
	on o.orderID = opoc.orderID
left join dbo.tblVouchersSalesUse vsu
	on o.orderID = vsu.orderID
where o.orderDate > getdate() - 730 --Last 2 years
	and o.orderStatus not in ('Cancelled','Failed')
	and (o.calcVouchers <> 0 or o.calcCredits <> 0)