﻿create proc usp_getFBALL
as
--All football magnet buyers since 8/10/11. Emails only.
select distinct email from tblCustomers where customerID in
(select customerID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed'
and orderDate>=convert(datetime,'03/10/2013')
and orderID in
(select orderID from tblOrders_Products where deleteX<>'yes'
and productName like '%football%' 
--and productName like '%2013%'
))
and email like '%@%'
and email not like '@%'
and email not like '%,%'
and email not like '%"%'
and email not like '%-list@%'
and email not like '%-request@%'
and email not like 'administrator@%'
and email not like 'admissions@%'
and email not like 'alumni@%'
and email not like '%announce%'
and email not like 'anonymous@%'
and email not like 'billing@%'
and email not like 'busdev@%'
and email not like 'careers@%'
and email not like 'comments@%'
and email not like 'contact@%'
and email not like 'customerservice@%'
and email not like 'development@%'
and email not like 'editor@%'
and email not like 'enquiries@%'
and email not like 'feedback@%'
and email not like 'help@%'
and email not like 'hr@%'
and email not like 'info@%'
and email not like 'info-%@%'
and email not like 'inquiries@%'
and email not like 'jobs@%'
and email not like 'join@%'
and email not like 'join-%@%'
and email not like 'list@%'
and email not like 'list-%@%'
and email not like 'mail@%'
and email not like 'marketing@%'
and email not like 'newsletter@%'
and email not like 'postmaster@%'
and email not like 'pr@%'
and email not like 'publications@%'
and email not like 'register@%'
and email not like 'request@%'
and email not like 'root@%'
and email not like 'security@%'
and email not like 'service@%'
and email not like 'services@%'
and email not like 'staff@%'
and email not like '%subscribe%'
and email not like 'support@%'
and email not like 'tech@%'
and email not like 'techsupport@%'
and email not like 'test@%'
and email not like 'user@%'
and email not like 'webadmin@%'
and email not like 'webdesign@%'
and email not like 'webinfo@%'
and email not like 'webmaster@%'
and email not like 'welcome@%'
and email not like '%www%'
and email not like '%hk' 
and email not like '%hostmaster%' 
and email not like '%domain%'
and email not like '%au'
and email not like '%lo'
and email not like '%premiumservices%'
and email not like '%safe%'
and email not like '%majordomo%'
and email not like '%au'
and email not like '%lo'
and email not like '%spam%'
and email is not null
and email not like '%Leike%'
and company not like '%Leike%'
order by email