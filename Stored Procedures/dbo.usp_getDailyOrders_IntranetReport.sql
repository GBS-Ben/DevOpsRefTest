CREATE proc usp_getDailyOrders_IntranetReport
as
declare 
@dd int,
@mm int,
@yy int

if @dd is null
begin
set @dd=(select datepart(dd,getdate()))
end

if @mm is null
begin
set @mm=(select datepart(mm,getdate()))
end

if @yy is null
begin
set @yy=(select datepart(yy,getdate()))
end


select a.orderNo, a.orderStatus, a.orderDate, 
b.firstName, b.surName, b.company, b.street, b.street2, b.suburb, b.state, b.postCode, b.phone, b.email,
c.shipping_firstName, c.shipping_SurName, c.shipping_Company, c.shipping_street, c.shipping_street2, c.shipping_suburb, c.shipping_state, c.shipping_postCode, c.shipping_phone, 
count(distinct(d.productName)) as 'countDiffProducts',
a.orderTotal-a.taxAmountAdded-a.shippingAmount as 'SubTotal', a.shippingAmount, a.taxAmountAdded, a.orderTotal, a.referrer
from tblOrders a join tblCustomers b on a.customerID=b.customerID
join tblCustomers_ShippingAddress c on a.orderNo=c.orderNo
join tblOrders_Products d on a.orderID=d.orderID
where d.deleteX<>'yes'
and datepart(dd,orderDate)='14'
and datepart(mm,orderDate)='01'
and datepart(yy,orderDate)='2010'
-- and datepart(dd,orderDate)=@dd
-- and datepart(dd,orderDate)=@mm
-- and datepart(dd,orderDate)=@yy
group by
a.orderNo, a.orderStatus, a.orderDate, b.firstName, b.surName, b.company, b.street, b.street2, b.suburb, b.state, b.postCode, b.phone, b.email,
c.shipping_firstName, c.shipping_SurName, c.shipping_Company, c.shipping_street, c.shipping_street2, c.shipping_suburb, c.shipping_state, c.shipping_postCode, c.shipping_phone, 
-- count(distinct(d.productName)),
a.shippingAmount, a.taxAmountAdded, a.orderTotal, a.referrer
order by orderDate ASC