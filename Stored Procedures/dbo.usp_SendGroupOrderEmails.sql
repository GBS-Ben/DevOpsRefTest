CREATE     PROC [dbo].[usp_SendGroupOrderEmails] as
DECLARE

@uniqueID int,
@firstName varchar (255),
@lastName varchar (255),
@email varchar (255),
@email1 varchar (255),
@email2 varchar (255),
@couponNum varchar(50),
@subject varchar (255),
@body varchar(8000),
@body2 varchar(8000)

set nocount on
declare cursor_e1 cursor for

select distinct uniqueID, firstName, lastName, email, couponNum from tblGroupOrders
where couponNum<>0 and couponSent='No'

open cursor_e1
fetch next from cursor_e1
into @uniqueID , @firstName , @lastName , @email1 , @couponNum
while @@fetch_status = 0
begin

if
@uniqueID in (select uniqueID from tblGroupOrders where couponSent='Yes' and uniqueID=@uniqueID)
	begin
			fetch next from cursor_e1
			into @uniqueID , @firstName , @lastName , @email1 , @couponNum
	end
else

--> @@@@@@@   TESTING TESTING TESTING TESTING TESTING TESTING TESTING
				--set @email1='ken@gogbs.com,kevin@gogbs.com,katie@gogbs.com,clint@gogbs.com,jeremy@gogbs.com,shirefife@gmail.com' --FOR TESTING PURPOSES
				--set @email1='jeremy@gogbs.com,shirefife@gmail.com' --FOR TESTING PURPOSES
				--set @email2='ken@gogbs.com,kevin@gogbs.com,katie@gogbs.com,clint@gogbs.com,jeremy@gogbs.com,shirefife@gmail.com' --FOR TESTING PURPOSES

				--set @email1='jeremy@gogbs.com,shirefife@gmail.com' --FOR TESTING PURPOSES
				--set @email2='jeremy@gogbs.com,shirefife@gmail.com' --FOR TESTING PURPOSES

--update tblGroupOrders set couponSent='No' where uniqueID>=500571

--select * from tblGroupOrders order by insertDate where uniqueID >= 500571
--> @@@@@@@   TESTING TESTING TESTING TESTING TESTING TESTING TESTING
				

				set @subject=
				'Your Group Coordinator Coupon is Enclosed'
			
				set @body=

				'Dear ' + @FIRSTNAME+',

Congratulations on becoming a Markful Group Coordinator!  As a way of saying "Thanks" and getting you started, we are providing you with $25 in "House Money." On your next order enter your code below in the "Coupon Code" box during the check out process.

GRP'+@couponNum+'

Within the next week to ten days you''ll receive a confirming gift certificate with other valuable information and samples in the mail.

Throughout the year, we''ll give you advance notice on upcoming promotions with special pricing for group orders. We''ll provide the support materials you''ll need to generate interest in your office and to place the order - product samples, group order forms, and other marketing pieces.

Remember, the more you order, the more you save. Which translates to more generous rewards for YOU!  

Our excellent Coordinator Support team is dedicated to helping you succeed.  If you have any questions, please feel free to contact me at 800-789-6247 or email me at Katie@markful.com.  

Thank you for your continued business with Markful.

Katie Blackburn
Group Sales Coordinator
Markful
800-789-6247
Katie@markful.com
'


			--send email
--Link=  http://dbserver/gbs/admin/groupOrderForm.asp?ID='+convert(varchar(255),@uniqueID)+'
				exec sp_send_cdosysmailtxt 'Katie@markful.com','Katie@markful.com',@subject,@body


set @body2=

'Hi Katie,

For your records, here''s a recently sent Group Coordinator coupon:

Name= '+@firstName+' '+@lastName+'
Email= '+@email1+'
Coupon= GRP'+@couponNum+'
				'

			--send follow up email to Katie
				--exec sp_send_cdosysmailtxt 'info@markful.com','jeremy@gogbs.com','Group Coordinator Follow Up',@body2
				exec sp_send_cdosysmailtxt 'info@markful.com','katie@gogbs.com;clint@gogbs.com;jeremy@gogbs.com','Group Coordinator Follow Up',@body2

				--exec sp_send_cdosysmailtxt 'Jeremy@markful.com','jeremy@gogbs.com;shirefife@gmail.com','Group Coordinator Follow Up','test'


			--update tblCustomers
				update tblGroupOrders
				set couponSent='Yes',
				couponStatus='Active',
				couponDate=getdate(),
				couponExpirey=dateadd(day,90,getdate())				
				where uniqueID=@uniqueID

			fetch next from cursor_e1
			into @uniqueID , @firstName , @lastName , @email1 , @couponNum

		end

close cursor_e1
deallocate cursor_e1