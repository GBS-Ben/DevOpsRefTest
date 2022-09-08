CREATE PROC usp_getKWRD
as
delete   from tblKWRD
insert into tblKWRD ([orderNo], [orderTotal], [orderDate], [orderStatus], [coordIDUsed], [brokerOwnerIDUsed], [shipping_firstName], [shipping_Company], [shipping_street], [shipping_street2], [shipping_suburb], [shipping_state], [shipping_postCode], [shipping_phone], [billingPhone], [email], [RED Day 101 Ways QuickCard (#KWRD09QC1)], [RED Day 101 Ways QuickStix - Case (#KWRD09QS1)], [RED Day 101 Ways QuickStix (#KWRD09QS1)], [RED Day Balloons (#KWRD09BL1)], [RED Day Button (#KWRD09BU1)], [RED Day Car/Window Sign (#KWRD09CS1)], [RED Day Envelope (#KWRD09EV1)], [RED Day Insert (#KWRD09IN1)], [RED Day Magnets (#KWRD09MA1)], [RED Day Postcard - Jumbo (#KWRD09PJ1)], [RED Day Postcard - Regular (#KWRD09PR1)], [RED Day Project/Lawn Sign (#KWRD09YS1)], [RED Day T-shirt - L (#KWRD09TS3)], [RED Day T-shirt - M (#KWRD09TS2)], [RED Day T-shirt - S (#KWRD09TS1)], [RED Day T-shirt - XL (#KWRD09TS4)], [RED Day T-shirt - XXL (#KWRD09TS5)], [RED Day T-shirt - XXXL (#KWRD09TS6)], [RED Day Water Bottle (#KWRD09WB1)])
select distinct o.orderNo, o.orderTotal, o.orderDate, o.orderStatus, o.coordIDUsed, o.brokerOwnerIDUsed,
s.shipping_firstName, s.shipping_Company, s.shipping_street, s.shipping_street2, s.shipping_suburb, s.shipping_state, s.shipping_postCode, s.shipping_phone, 
c.phone as 'billingPhone', c.email,
'0' as 'RED Day 101 Ways QuickCard (#KWRD09QC1)', '0' as 'RED Day 101 Ways QuickStix - Case (#KWRD09QS1)', '0' as 'RED Day 101 Ways QuickStix (#KWRD09QS1)', 
'0' as 'RED Day Balloons (#KWRD09BL1)', '0' as 'RED Day Button (#KWRD09BU1)', '0' as 'RED Day Car/Window Sign (#KWRD09CS1)', '0' as 'RED Day Envelope (#KWRD09EV1)', 
'0' as 'RED Day Insert (#KWRD09IN1)', '0' as 'RED Day Magnets (#KWRD09MA1)', '0' as 'RED Day Postcard - Jumbo (#KWRD09PJ1)', '0' as 'RED Day Postcard - Regular (#KWRD09PR1)', 
'0' as 'RED Day Project/Lawn Sign (#KWRD09YS1)', '0' as 'RED Day T-shirt - L (#KWRD09TS3)', '0' as 'RED Day T-shirt - M (#KWRD09TS2)', '0' as 'RED Day T-shirt - S (#KWRD09TS1)', 
'0' as 'RED Day T-shirt - XL (#KWRD09TS4)', '0' as 'RED Day T-shirt - XXL (#KWRD09TS5)', '0' as 'RED Day T-shirt - XXXL (#KWRD09TS6)', '0' as 'RED Day Water Bottle (#KWRD09WB1)'
from tblCustomers_ShippingAddress s join tblOrders o on s.orderNo=o.orderNo
join tblCustomers c on o.customerID=c.customerID
where o.orderStatus<>'failed' and o.orderStatus<>'cancelled'
and o.orderID in
(select distinct orderID from tblOrders_Products where deleteX<>'yes' and productName like '%KWRD%')
order by o.orderNo

exec usp_cursor_KWRD1
select * from tblKWRD