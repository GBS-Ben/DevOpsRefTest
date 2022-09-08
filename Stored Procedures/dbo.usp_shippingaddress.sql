CREATE proc usp_shippingaddress
@customerid varchar(255)
as
select 
s.shippingaddressid as 'Shipping_ID',
s.shipping_nickname as 'Shipping_NickName',
s.shipping_firstname+s.shipping_surname as 'Shipping_Name',
s.shipping_company as 'Shipping_Company',
s.shipping_street as 'Shipping_Street1',
s.shipping_street2 as 'Shipping_Street2',
s.shipping_suburb as 'Shipping_City',
s.shipping_state as 'Shipping_State',
s.shipping_postcode as 'Shipping_Zip'
from tblcustomers_shippingaddress s join tblcustomers c
on s.customerid=c.customerid
where c.customerid=@customerid