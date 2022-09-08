create proc dashboard_AmazonOrderDashboard as

with latest_orders as
(
select [order-id], max(Id) maxId
from [dbo].[tblAMZN_UnshippedOrders_Stage]
group by [order-id]
)
,imported_orders as
(
select a.[order-id], max(dateCreated) dateCreated
from dbo.tblAMZ_orderImporter a
inner join latest_orders b
	on a.[order-id] = b.[order-id]
group by a.[order-id]
)
,created_orders as
(
select a.[order-id], a.orderNo, max(created_on) dateCreated, sum(isnull(try_convert(decimal(15,2),a.[item-price]),0) + isnull(try_convert(decimal(15,2),a.[item-tax]),0)) orderTotal
from dbo.tblAMZ_orderValid a
inner join latest_orders b
	on a.[order-id] = b.[order-id]
group by a.[order-id], a.orderNo
)
,ship_orders as
(
select a.[order-id], a.orderStatus, a.docked_on, a.shipped_on, a.delivered_on, a.orderPrintedDate, isValidated, addrExists
from dbo.tblAMZ_orderShip a
inner join latest_orders b
	on a.[order-id] = b.[order-id]
)

,get_shipped_orders as
(
select a.[order-id], a.[tracking-number], a.[ship-date], a.[ship-method], amz_update, count(distinct [order-item-Id]) numberOfItems
from dbo.tblAMZ_getShipped a
inner join latest_orders b
	on a.[order-id] = b.[order-id]
group by a.[order-id], a.[tracking-number], a.[ship-date], a.[ship-method], amz_update
)

select  
a.[order-id]
,c.orderNo
,c.orderTotal
,b.dateCreated as OrderImportDate
,c.dateCreated as OrderCreatedDate
--,d.*
,e.[ship-date] as ShipDate
,e.[ship-method] as ShippingMethod
,e.[tracking-number] as TrackingNumber
,e.numberOfItems as NumberOfItems
,e.amz_update

from latest_orders a with(nolock) 
left join imported_orders b
       on trim(a.[order-id]) = trim(b.[order-id])
left join created_orders c
       on a.[order-id] = c.[order-id]
left join ship_orders d
       on a.[order-id] = d.[order-id]
left join get_shipped_orders e
       on a.[order-id] = e.[order-id]

--where b.[order-id] is null

order by a.[order-id], c.orderNo