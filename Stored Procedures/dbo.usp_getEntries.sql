create proc usp_getEntries @orderNo varchar(255)
as
select a.firstName, a.lastName, a.address1, a.city, a.st, a.zip, a.phone, a.email, a.q1, a.q2, a.insertDate, a.entryFormID,
e.entryCode, p.productName,
o.orderNo, o.orderDate, o.orderStatus, o.orderTotal,
c.firstName, c.company, c.street, c.street2, c.suburb, c.state, c.postCode, c.phone, c.email
from tblFreeStuffEntry a join tblProducts_EntryCodes e on substring(a.entryCode,1,4)=e.entryCode
join tblOrders_Products p on e.orderDetailID=p.[ID]
join tblOrders o on p.orderID=o.orderID
join tblCustomers c on o.customerID=c.customerID
where o.orderStatus<>'failed' and o.orderStatus<>'cancelled'
and p.deleteX<>'yes'
and o.orderNo=@orderNo