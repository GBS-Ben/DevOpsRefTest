
CREATE  Proc usp_salesReport_byDateRange
--THIS PROC PULLS DAILY REPORTS FOR MIKE
@startDate datetime,
@endDate datetime
AS
select a.orderNo, a.orderstatus, a.orderDate, 
b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
count(distinct(e.productName)),
sum(a.orderTotal-a.taxAmountAdded-a.shippingAmount) as 'subTotal', a.taxAmountAdded as 'Tax', a.shippingAmount as 'ShippingTotal', a.orderTotal as 'OrderTotal',
a.reasonForPurchase, a.referrer,
b.trackingNumber
from 
tblOrders a join tblJobtrack b on a.orderNo=b.jobNumber
join tblCustomers c on a.customerID=c.customerID
join tblCustomers_ShippingAddress d on a.customerID=d.customerID
join tblOrders_Products e on a.orderID=e.orderID
where e.deletex<>'yes'
and a.orderDate>convert(datetime,@startDate)
and a.orderDate<dateadd(day,1,(convert(datetime,@endDate)))
group by  a.orderNo, a.orderstatus, a.orderDate, 
b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
 a.taxAmountAdded, a.shippingAmount, a.orderTotal,
a.reasonForPurchase, a.referrer,
b.trackingNumber
order by a.orderDate