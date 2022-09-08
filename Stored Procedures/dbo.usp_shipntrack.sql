CREATE  proc [dbo].[usp_shipntrack]
@orderno  varchar (255)
as
select 
x.trackingnumber as 'Tracking_Number',
x.jobnumber as 'Order_Number',
convert(varchar(255),(datepart(mm,x.shipdate)))+'/'+ convert(varchar(255),(datepart(dd,x.shipdate)))+'/'+ 
convert(varchar(255),(datepart(yy,x.shipdate)))  as 'Ship_Date',
x.freight as 'Freight',
x.weight as 'Weight',
convert(varchar(255),(datepart(mm,x.emailsent)))+'/'+ convert(varchar(255),(datepart(dd,x.emailsent)))+'/'+ 
convert(varchar(255),(datepart(yy,x.emailsent)))  as 'Notification_Date'
from tbl_upsx_email x inner join tblorders o
on x.jobnumber = o.orderno
where o.orderno like '%'+@orderno+'%'