
CREATE proc usp_SalesReport_Yesterday
as
declare @startdate datetime, @enddate datetime
set @startdate=(select dbo.kk_fn_UTIL_DateRound(getdate(), -1))
set @enddate=(select dbo.kk_fn_UTIL_DateRound(getdate(), 0))
--print @startdate
--print @enddate
delete from tblOrders_Yesterday_Report
--sp_columns 'tblOrders_Yesterday_Report'
insert into tblOrders_Yesterday_Report (orderNo, orderStatus, orderDate, firstName, company, street, street2, suburb, state, postCode, phone, email, NumDistinctProducts, subTotal, Tax, ShippingTotal, OrderTotal, reasonForPurchase, referrer)
select a.orderNo, a.orderStatus, a.orderDate, 
--b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
--d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
count(distinct(e.productName)) as 'NumDistinctProducts',
sum(a.orderTotal-a.taxAmountAdded-a.shippingAmount) as 'subTotal', a.taxAmountAdded as 'Tax', a.shippingAmount as 'ShippingTotal', a.orderTotal as 'OrderTotal',
a.reasonForPurchase, a.referrer
--b.trackingNumber
--into tblOrders_Yesterday_Report
from 
tblOrders a join tblOrders_Products e on a.orderID=e.orderID
join tblCustomers c on a.customerID=c.customerID
--join tblCustomers_ShippingAddress d on a.customerID=d.customerID
where e.deletex<>'yes'
and a.orderDate>@startdate
and a.orderDate<@endDate
and a.orderStatus<>'failed'
and a.orderStatus<>'cancelled'
--and a.orderDate>convert(datetime,@startDate)
--and a.orderDate<dateadd(day,1,(convert(datetime,@endDate)))
group by  a.orderNo, a.orderStatus, a.orderDate, 
--b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
--d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
 a.taxAmountAdded, a.shippingAmount, a.orderTotal,
a.reasonForPurchase, a.referrer
--b.trackingNumber
order by a.orderDate
select * from tblOrders_Yesterday_Report