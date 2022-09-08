CREATE  proc [dbo].[usp_ReviewOrders7days]
as
---CURSOR
--Declare variables
delete from tblReviewedFailedOrders

declare

@customerID int,
@orderID int,
@firstName varchar (255),
@company varchar (255),
@street varchar (255), 
@street2 varchar (255), 
@suburb varchar (255), 
@state varchar (255),
@postCode varchar (255),
@phone varchar (255),
@fax varchar (255),
@email varchar (255),
@orderNO varchar (255),
@orderDate datetime,
@orderTotal smallmoney,
@orderStatus varchar (255),
@AVAR int


set nocount on
select distinct
b.customerID, a.orderID, b.firstName, b.company, b.street, b.street2,
b.suburb, b.state, b.postCode, b.phone, b.fax, b.email,
a.orderNo, a.orderDate, a.orderTotal, a.orderStatus
--,c.productName, c.productPrice, c.productQuantity
from tblOrders a join tblCustomers b
on a.customerID=b.customerID
--join tblOrders_Products c
--on a.orderID=c.orderID
where a.orderStatus='failed'
and datediff(dd, a.orderdate, getdate())<7

open usp_cDIGGY
fetch next from usp_cDIGGY
into @customerID, @orderID, @firstName, @company, @street, @street2, @suburb, @state, @postCode, @phone, @fax, @email, @orderNO, @orderDate, @orderTotal, @orderStatus
while @@fetch_status = 0
begin
--delete from tblReviewedFailedOrders
--sp_columns 'tblReviewedFailedOrders'
SET @AVAR=0
set @AVAR=(select count(orderNo) from tblOrders 
where
orderNo<>@orderNo and datediff(hh,@orderDate, orderDate)<24 and orderStatus<>'Failed' and orderStatus<>'Cancelled' and customerID in
	(select customerID from tblCustomers where firstName=@firstName
		and customerID in
		(select distinct customerID from tblOrders where orderStatus<>'failed' and orderStatus<>'cancelled'
		and  datediff(hh,@orderDate, orderDate)<24
		)
	)
or
orderNo<>@orderNo and datediff(hh,@orderDate, orderDate)<24 and orderStatus<>'Failed' and orderStatus<>'Cancelled' and customerID in
	(select customerID from tblCustomers where email=@email
		and customerID in
		(select distinct customerID from tblOrders where orderStatus<>'failed' and orderStatus<>'cancelled'
		and  datediff(hh,@orderDate, orderDate)<24
		)
	)
or
orderNo<>@orderNo and datediff(hh,@orderDate, orderDate)<24 and orderStatus<>'Failed' and orderStatus<>'Cancelled' and customerID in
	(select customerID from tblCustomers where street=@street
		and customerID in
		(select distinct customerID from tblOrders where orderStatus<>'failed' and orderStatus<>'cancelled'
		and  datediff(hh,@orderDate, orderDate)<24
		)
	)
or
orderNo<>@orderNo and datediff(hh,@orderDate, orderDate)<24 and orderStatus<>'Failed' and orderStatus<>'Cancelled' and customerID in
	(select customerID from tblCustomers where phone=@phone
		and customerID in
		(select distinct customerID from tblOrders where orderStatus<>'failed' and orderStatus<>'cancelled'
		and  datediff(hh,@orderDate, orderDate)<24
		)
	)
)

if @AVAR is null
	BEGIN
	Set @AVAR=0
	END

If @AVAR=0
	BEGIN
	insert into tblReviewedFailedOrders (customerID,orderID,firstName,company,street,street2,suburb,state,postCode,phone,fax,email,orderNo,orderDate,orderTotal,orderStatus)
	values (@customerID, @orderID, @firstName, @company, @street, @street2, @suburb, @state, @postCode, @phone, @fax, @email, @orderNO, @orderDate, @orderTotal, @orderStatus)
	END
--,c.productName, c.productPrice, c.productQuantity
fetch next from usp_cDIGGY
into @customerID, @orderID, @firstName, @company, @street, @street2, @suburb, @state, @postCode, @phone, @fax, @email, @orderNO, @orderDate, @orderTotal, @orderStatus

end
close usp_cDIGGY
deallocate usp_cDIGGY

select * from tblReviewedFailedOrders