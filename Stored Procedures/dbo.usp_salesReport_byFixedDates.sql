

CREATE   Proc usp_salesReport_byFixedDates
--THIS PROC PULLS DATA FOR PRODUCT_INVENTORY REPORT FOR NOTEPAD MAGS
--example:  exec usp_salesReport_byFixedDates 'Last 90'  exec usp_salesReport_byFixedDates 'Yesterday'
@interval varchar(255) --accepts: 'Last 7', 'Last 30', 'Last 60', 'Last 90', 'Last 120', 'Last 5 Months', 'Last Year'
as

declare 
@startDate datetime,
@endDate datetime

set @endDate='01/01/2999'
--YESTERDAY
if @interval='Yesterday'
begin
set @startdate=(select dbo.kk_fn_UTIL_DateRound(getdate(), -1))
set @enddate=(select dbo.kk_fn_UTIL_DateRound(getdate(), 0))
end

--LAST 7
if @interval='Last 7'
begin
set @startDate=dateadd(dd,-8,getdate())
end

--LAST 30
if @interval='Last 30'
begin
set @startDate=dateadd(dd,-31,getdate())
end

--LAST 60
if @interval='Last 60'
begin
set @startDate=dateadd(dd,-61,getdate())
end

--LAST 90
if @interval='Last 90'
begin
set @startDate=dateadd(dd,-91,getdate())
end

--LAST 120
if @interval='Last 120'
begin
set @startDate=dateadd(dd,-121,getdate())
end

--LAST 6 Months
if @interval='LAST 6 Months'
begin
set @startDate=dateadd(dd,-183,getdate())
end

--LAST Year
if @interval='Last Year'
begin
set @startDate=dateadd(dd,-366,getdate())
end

if @endDate='01/01/2999'
begin
select a.orderNo, a.orderstatus, a.orderDate, 
b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
count(distinct(e.productName)),
sum(a.orderTotal-a.taxAmountAdded-a.shippingAmount) as 'subTotal', a.taxAmountAdded as 'Tax', a.shippingAmount as 'ShippingTotal', a.orderTotal as 'OrderTotal',
a.reasonForPurchase, a.referrer,
b.trackingNumber
from 
tblOrders a left join tblJobtrack b on a.orderNo=b.jobNumber
join tblCustomers c on a.customerID=c.customerID
join tblCustomers_ShippingAddress d on a.customerID=d.customerID
join tblOrders_Products e on a.orderID=e.orderID
where e.deletex<>'yes'
and a.orderDate>convert(datetime,@startDate)
and a.orderDate<getdate()
and a.orderStatus<>'Failed'
and a.orderStatus<>'Cancelled'
group by  a.orderNo, a.orderstatus, a.orderDate, 
b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
 a.taxAmountAdded, a.shippingAmount, a.orderTotal,
a.reasonForPurchase, a.referrer,
b.trackingNumber
order by a.orderStatus
end

if @endDate <>'01/01/2999'
begin
select a.orderNo, a.orderstatus, a.orderDate, 
b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
count(distinct(e.productName)),
sum(a.orderTotal-a.taxAmountAdded-a.shippingAmount) as 'subTotal', a.taxAmountAdded as 'Tax', a.shippingAmount as 'ShippingTotal', a.orderTotal as 'OrderTotal',
a.reasonForPurchase, a.referrer,
b.trackingNumber
from 
tblOrders a left join tblJobtrack b on a.orderNo=b.jobNumber
join tblCustomers c on a.customerID=c.customerID
join tblCustomers_ShippingAddress d on a.customerID=d.customerID
join tblOrders_Products e on a.orderID=e.orderID
where e.deletex<>'yes'
and a.orderDate>convert(datetime,@startDate)
and a.orderDate<@endDate
and a.orderStatus<>'Failed'
and a.orderStatus<>'Cancelled'
group by  a.orderNo, a.orderstatus, a.orderDate, 
b.[pickup date], 
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email, 
d.shipping_firstName, d.shipping_company, d.shipping_street, d.shipping_street2, d.shipping_suburb, d.shipping_state, d.shipping_postCode, d.shipping_phone, 
 a.taxAmountAdded, a.shippingAmount, a.orderTotal,
a.reasonForPurchase, a.referrer,
b.trackingNumber
order by a.orderStatus
end