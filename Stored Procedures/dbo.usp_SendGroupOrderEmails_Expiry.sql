CREATE PROC[dbo].[usp_SendGroupOrderEmails_Expiry] as
DECLARE
--04/27/21		CKB, Markful

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

--First deal with expired coupons
update tblGroupOrders
set Status='Expired' 
--select * from tblGroupOrders
where couponSent='Yes' and couponExpirey<getDate()

update tblGroupOrders
set couponStatus='Expired' 
--select * from tblGroupOrders
where couponSent='Yes' and couponExpirey<getDate()

set nocount on
declare cursor_exp1 cursor for

--select * from tblGroupOrders where uniqueID =500579

--TEST--TEST--TEST--TEST
/*
update tblGroupOrders
--set insertDate=convert(datetime,'08/01/07'), CouponSent='Yes', couponDate=convert(datetime,'08/01/07') , couponExpirey=convert(datetime,'01/01/08') , couponStatus='Active'
set couponNum=9
where uniqueID=500579
*/
--TEST--TEST--TEST--TEST--TEST

--select * from tblGroupOrders where datediff(dd,getdate(),couponExpirey)<45
--Tickler Email: 45 Days out
select distinct uniqueID, firstName, lastName, email, couponNum from tblGroupOrders
where couponNum<>0 and couponSent='Yes' and datediff(dd,getdate(),couponExpirey)<45
and couponStatus='Active'
and expiryWarningSent<>'Yes'

open cursor_exp1
fetch next from cursor_exp1
into @uniqueID , @firstName , @lastName , @email1 , @couponNum
while @@fetch_status = 0
begin

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
				'Your Group Coordinator Coupon Expires Soon'
			
				set @body=

				'Dear ' + @FIRSTNAME+',

We''ve noticed that you have not yet used your coupon worth $25 in "House Money."  

To use your coupon, enter your code below in the "Coupon Code" box during the check out process.

GRP'+@couponNum+'

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

			--select * from tblGroupOrders
			update tblGroupOrders
			set expiryWarningSent='Yes'
			where couponNum=@couponNum
				
			--update tblCustomers
			/*
				update tblGroupOrders
				set couponSent='Yes',
				couponStatus='Active',
				couponDate=getdate(),
				couponExpirey=dateadd(day,90,getdate())				
				where uniqueID=@uniqueID
			*/
			fetch next from cursor_exp1
			into @uniqueID , @firstName , @lastName , @email1 , @couponNum

		end

close cursor_exp1
deallocate cursor_exp1