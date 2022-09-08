CREATE      PROC [dbo].[usp_SendGroupOrderEmails_OneOff]
@uniqueID int
as
--04/27/21		CKB, Markful
DECLARE


@firstName varchar (255),
@email varchar (255),
@couponNum varchar(50),
@subject varchar (255),
@body varchar(8000)

--TESTING:
--select * from tblGroupOrders
--500069
--rob@advantagemci.com
--exec usp_SendGroupOrderEmails_OneOff '500069'
-- update tblGroupOrders set email='jeremy@gogbs.com' where uniqueID=500069
-- update tblGroupOrders set email='rob@advantagemci.com' where uniqueID=500069
-- select * from tblGroupOrders where uniqueID=500069

set @firstName=(select firstName from tblGroupOrders where uniqueID=@uniqueID)
set @email=(select email from tblGroupOrders where uniqueID=@uniqueID)
set @couponNum=(select couponNum from tblGroupOrders where uniqueID=@uniqueID)
set @subject='Your Group Coordinator Coupon is Enclosed'
set @body='Dear ' + @firstName+',

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
				--exec sp_send_cdosysmailtxt 'info@markful.com','jeremy@gogbs.com','Group Coordinator Follow Up',@body2
				--exec sp_send_cdosysmailtxt 'Jeremy@markful.com','jeremy@gogbs.com;shirefife@gmail.com','Group Coordinator Follow Up','test'