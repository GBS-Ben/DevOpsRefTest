CREATE                                                      PROC [dbo].[usp_sendCPN]
as

/*
Created By: Jeremy Fifer
Created Date:  9/11/06
Last Update Date: 01/04/2008
--04/27/21		CKB, Markful
Notes:  This proc runs the second step of the email series (ES) program.  
It notifies customers that their order has shipped.
This step is broken into 2 cursors, each taking into account which type of products were purchased in the order
in order to determine what product upsell message is used.
*/
DECLARE

--these or data vars:
@count varchar(50),
@importDate datetime,
-- @orderNo varchar (255),
-- @orderDate datetime,
-- @orderTotal money,
-- @orderStatus varchar (255),
-- @firstName varchar (255),
-- @company varchar (255),
-- @state varchar (255),
-- @CustomerEmail varchar (255),
-- @phone varchar (255),

--these are email-centric vars:
@bodytext varchar(8000),
@subjecttext varchar(255),
@recipient varchar(255),
@email varchar (255)

set nocount on
declare cursor_e14 cursor for

--select * from tblORders
-- sp_columns 'tblORders'

select count(*) from tblOrders where importDate=(select top 1 importDate from tblOrders order by importDate desc)
and orderID in
(select distinct orderID from tblVouchersSalesUse where sVoucherCode='kwvip50')
-- (select distinct orderID from tblVouchersSalesUse where sVoucherCode='S-Fsurvey08')

-- select a.orderNo, a.orderDate, a.orderTotal, a.orderStatus, c.firstName, c.company, c.state, c.email, c.phone
-- from tblOrders a join tblCustomers c on a.customerID=c.customerID
-- where a.orderStatus<>'cancelled' and a.orderStatus<>'failed' 
-- and a.orderID in
-- (select distinct orderID from tblVouchersSalesUse where sVoucherCode='kwvip50')
-- order by a.orderDate desc
--select * from tblVouchersSalesUse


-- SELECT DISTINCT tblOrders.orderID, tblOrders.orderNo, tblCustomers.firstName, tblCustomers.surname, tblCustomers.company, 
-- tblCustomers.state, tblCustomers.postCode, tblCustomers.phone, tblOrders.orderDate, tblOrders.orderStatus, tblOrders.orderTotal 
-- FROM (tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID) 
-- LEFT JOIN tblOrders_Products ON tblOrders.orderID = tblOrders_Products.orderID 
-- JOIN tblVouchersSalesUse ON tblOrders.orderID = tblVouchersSalesUse.orderID 
-- WHERE tblVouchersSalesUse.sVoucherCode = 'kwvip50' AND (NOT tblOrders.orderCancelled=1 OR tblOrders.orderCancelled IS NULL) ORDER BY orderDate DESC

-- sp_columns 'tblOrders'
-- select * from tblOrders where brokerOwnerIDUsed='kwvip50'
-- select * from tblGroupOrders
-- select * from tblVouchersSalesUse order by vDateTime desc
-- select * from tblVouchersSales order by datecreated desc
-- where sVoucherCode='kwvip50'

-- select * from tblVouchersSalesUse where sVoucherCode='NAHREP10%'
-- select * from tblVouchersSales where sVoucherCode='kwvip50'
-- select * from tblorders where orderID=328344320


open cursor_e14
fetch next from cursor_e14
into @count
while @@fetch_status = 0
begin


if
@count is NULL or @count=0 or @count='0'
--@orderNo in (select orderNo from tblOrders where emailStatus=2)
begin
		--open cursor_e14
		fetch next from cursor_e14    		
		into @count
end
else
if
@count is not NULL and @count<>0 and @count<>'0'
--@orderNo in (select orderNo from tblOrders where emailStatus=2)
begin
set @importDate=(select top 1 importDate from tblOrders order by importDate desc)
	if @importDate is null
	begin
	set @importDate=getdate()
	end

				set @email=
				'bobby@gogbs.com;jeremy@gogbs.com'
				
				set @subjecttext=
				'Mastery Client Special Gift: kwvip50 coupon used on a new order'
			
				set @bodytext=

				'Gina,

On our most recent import of new orders, the coupon "kwvip50" was used '+convert(varchar(50),@count)+' time(s).  

Click here to view the details:  http://192.168.1.9/gbs/admin/voucherSalesUsage.asp?i=9077

Import Time: '+convert(varchar(255),@importDate)+'

If you have any problems, please contact Jeremy.

Thank you.'

	
			--send email
	EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Markful',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText

end
		fetch next from cursor_e14    		
		into @count

		end

close cursor_e14
deallocate cursor_e14