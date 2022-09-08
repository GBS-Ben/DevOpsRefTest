--04/27/21		CKB, Markful

CREATE PROC [dbo].[usp_esCustomNotepad24Hour]
as

/*
Created By: Jeremy Fifer
Created Date:  4/21/08
Last Update Date: 
Notes:  This proc sends out the Custom Notepad Email Reminder 24 hours after an order is received.
*/
DECLARE


@orderNo varchar (255),
@firstName varchar (255),
@email varchar (255),
@type varchar (255),
@emailSent datetime,
@bodytext varchar(8000),
@subjecttext varchar(255),
@recipient varchar(255)

set nocount on
declare cursor_e_CNP_1 cursor for


select distinct
a.orderNo, b.firstName, b.email, 'CustomNotepad', getdate()
from tblOrders a join tblCustomers b
on a.customerID=b.customerID
where a.orderStatus<>'cancelled' and a.orderStatus<>'failed' and b.email like '%@%'
and a.orderID in
(select distinct OrderID from tblOrders_Products where productName like '%#CNP%')
and datediff(dd,a.orderDate,getdate())>=1
--and datediff(dd,a.orderDate,getdate())<=2
and b.email not in (select distinct email from tblEmailCustomNotepad)
and a.orderNo not in (select distinct orderNo from tblEmailCustomNotepad)

open cursor_e_CNP_1
fetch next from cursor_e_CNP_1
into @orderNo, @firstName, @email, @type, @emailSent
while @@fetch_status = 0
begin

				set @subjecttext=
				'Your custom notepad order'
--Please change the auto response for custom notepad orders.  It needs to state 4-5 weeks production time after artwork is completed.  The response below says May 15, 2008.			
				set @bodytext=

				'Thanks again for your purchase of custom notepads yesterday!

This is a reminder to help you plan for this important marketing tool: Once you approve your artwork, we''ll ship the notepads to you within 3-4 weeks.

If you have any questions, please let us know. 

Thanks!
Your Markful Team

P.S. Would you please let your friends and associates know about the great deal you got on these custom notepads? We''d appreciate it.
'
	
			--send email

		EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Markful',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText


			--update tblEmailCustomNotepad
				insert into tblEmailCustomNotepad (orderno, firstName, email, type, emailSent)
				--select * from tblEmailCustomNotepad
				--values ('test', 'Jeremy Fifer', 'jeremy@gogbs.com', 'CustomNotepad', getdate())
				values (@orderNo, @firstName, @email, @type, @emailSent)

		fetch next from cursor_e_CNP_1    		
		into @orderNo, @firstName, @email, @type, @emailSent

		end

close cursor_e_CNP_1
deallocate cursor_e_CNP_1