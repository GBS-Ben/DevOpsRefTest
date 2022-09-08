CREATE proc [dbo].[usp_getups]
@orderno varchar(255)
as
select distinct a.[Package Activity Date],a.[Package Activity Time],
substring(a.[Package Reference Number Value 1],3,2)+''+substring(a.[Package Reference Number Value 1],13,4),
a.[Tracking Number], a.[UPS Location],a.[UPS Location State/Province],a.[UPS Location Country], a.[Record Type],
a.[Driver Release],a.[Delivery Location],a.[Residential Address],a.[Signed For By],a.[Exception Reason Code],
a.[Delivery Street Number],a.[Delivery Street Prefix],a.[Delivery Street Name],a.[Delivery Street Type],
a.[Delivery Street Suffix],a.[Delivery Building Name],a.[Delivery Room/Suite/Floor],a.[Delivery City],a.[Delivery State/Province],a.[Delivery Postal Code],
b.[UPS Service], b.[Pickup Date],b.[Scheduled Delivery Date], b.[Package Count],
y.shipping_nickname,y.shipping_company,y.shipping_fullname,y.shipping_street,
y.shipping_street2,y.shipping_suburb,y.shipping_state, y.shipping_postcode,y.shipping_phone,
x.orderstatus
from tbl_UPSQuantumViewCapture a join tbljobtrack b
on a.[Tracking Number]=b.trackingnumber
join tblorders x
on b.jobnumber=x.orderNo
join tblCustomers_ShippingAddress y
on x.customerid=y.customerid
where 
b.jobnumber=@orderNo and
len(a.[Package Reference Number Value 1])=16
order by [package activity date] desc,[package activity time] desc