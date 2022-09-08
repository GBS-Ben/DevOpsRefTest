create proc usp_getEntriesSummary
@orderNo varchar(255),
@sponsorEmail varchar(255)
as

--GENERIC QUESTIONS
select distinct a.firstName as 'entryPerson_firstName', a.lastName as 'entryPerson_lastName', a.address1 as 'entryPerson_address', a.city as 'entryPerson_city', a.st as 'entryPerson_state', a.zip as 'entryPerson_zip', 
a.phone as 'entryPerson_phone', a.email as 'entryPerson_email', 
'Are you interested in buying or selling a home, or keeping track of the market within the next 12 months?', a.q1, 
'Do you know someone who is planning to buy/sell a home in the next 12 months?', a.q2,
x.orderNumber as  'NONDISPLAYEDFIELD_tblCustomInput.orderNumber',
x.inserts_Email as 'NONDISPLAYEDFIELD_tblCustomInput.inserts_Email'
from tblFreeStuffEntry a join tblProducts_EntryCodes e on substring(a.entryCode,1,4)=e.entryCode
join tblOrders_Products p on e.orderDetailID=p.[ID]
join tblOrders o on p.orderID=o.orderID
join tblCustomers c on o.customerID=c.customerID
join tblCustomInput x on x.orderDetailID=e.orderDetailID
where o.orderStatus<>'failed' and o.orderStatus<>'cancelled'
and p.deleteX<>'yes'
and x.inserts_Q1=''
and x.inserts_Q2=''
and x.inserts_Email<>'' and x.inserts_Email is not null
and len(a.email)>7
and (a.email) not like '%@none.com'
and (a.email) not like '%houseofmagnets.com'
and (a.email) not like '%HOUSEofFREESTUFF.com'
and (a.email) not like '%@111.com'
and (a.email) not like '%@abc.com'
and (a.email) not like '%@fff.com'
and (a.email) not like '%@xyz.com'
and (a.email) not like '%.c'
and (a.email) not like '% %'
and (a.email) not like '%spam%'
and (a.email) not like '%comd'
and (a.email) not like '0000%'
and (a.email) not like '%@test.%'
and (a.email) not like '%testing%'
and (a.email) not like 'test@%'
and (a.email) <>''
and (a.email) not like '%uneeknet.com%'
and (a.email) not like 'none@%'
and a.firstName not like 'test%'
and a.lastName not like 'test%'
and a.firstName <>''
and a.lastName <>''
and a.firstName is not null
and a.lastName is not null
and a.firstName not like '0000%'
and a.lastName not like '0000%'
and a.lastName<>'a'
and a.lastName<>'x'
and a.firstName<>'2'
and a.lastName<>'3'
and a.firstName<>'aaa'
and a.lastName<>'nnnnnnnnn'
and a.zip not like '%[a-z]%'
and a.firstName not like 'abc%'
and o.orderNo=@orderNo
and x.inserts_Email=@sponsorEmail

UNION
--CUSTOM QUESTIONS
select a.firstName as 'entryPerson_firstName', a.lastName as 'entryPerson_lastName', a.address1 as 'entryPerson_address', a.city as 'entryPerson_city', a.st as 'entryPerson_state', a.zip as 'entryPerson_zip', 
a.phone as 'entryPerson_phone', a.email as 'entryPerson_email', 
x.inserts_Q1, a.q1,
x.inserts_Q2, a.q2,
x.orderNumber as  'NONDISPLAYEDFIELD_tblCustomInput.orderNumber',
x.inserts_Email as 'NONDISPLAYEDFIELD_tblCustomInput.inserts_Email'
from tblFreeStuffEntry a join tblProducts_EntryCodes e on substring(a.entryCode,1,4)=e.entryCode
join tblOrders_Products p on e.orderDetailID=p.[ID]
join tblOrders o on p.orderID=o.orderID
join tblCustomers c on o.customerID=c.customerID
join tblCustomInput x on x.orderDetailID=e.orderDetailID
where o.orderStatus<>'failed' and o.orderStatus<>'cancelled'
and p.deleteX<>'yes'
and x.inserts_Q1<>''
and x.inserts_Q2<>''
and x.inserts_Email<>'' and x.inserts_Email is not null
and len(a.email)>7
and (a.email) not like '%@none.com'
and (a.email) not like '%houseofmagnets.com'
and (a.email) not like '%HOUSEofFREESTUFF.com'
and (a.email) not like '%@111.com'
and (a.email) not like '%@abc.com'
and (a.email) not like '%@fff.com'
and (a.email) not like '%@xyz.com'
and (a.email) not like '%.c'
and (a.email) not like '% %'
and (a.email) not like '%spam%'
and (a.email) not like '%comd'
and (a.email) not like '0000%'
and (a.email) not like '%@test.%'
and (a.email) not like '%testing%'
and (a.email) not like 'test@%'
and (a.email) <>''
and (a.email) not like '%uneeknet.com%'
and (a.email) not like 'none@%'
and a.firstName not like 'test%'
and a.lastName not like 'test%'
and a.firstName <>''
and a.lastName <>''
and a.firstName is not null
and a.lastName is not null
and a.firstName not like '0000%'
and a.lastName not like '0000%'
and a.lastName<>'a'
and a.lastName<>'x'
and a.firstName<>'2'
and a.lastName<>'3'
and a.firstName<>'aaa'
and a.lastName<>'nnnnnnnnn'
and a.zip not like '%[a-z]%'
and a.firstName not like 'abc%'
and o.orderNo=@orderNo
and x.inserts_Email=@sponsorEmail

order by x.inserts_Email