CREATE  PROC [dbo].[usp_updateCRM_Z]
as
--04/27/21		CKB, Markful
set identity_insert tblCRM ON

insert into tblCRM 
(orderID, orderNo, orderAck, orderForPrint, orderJustPrinted, orderBatchedDate, orderPrintedDate, orderCancelled, 
customerID, membershipID, membershipType, sessionID, orderDate, orderTotal, taxAmountInTotal, taxAmountAdded, 
taxDescription, shippingAmount, shippingMethod, shippingDesc, feeAmount, paymentAmountRequired, paymentMethod, 
paymentMethodID, paymentMethodRDesc, paymentMethodIsCC, paymentMethodIsSC, cardNumber, cardExpiryMonth, 
cardExpiryYear, cardName, cardType, cardCCV, cardStoreInfo, shipping_Company, shipping_FirstName, shipping_Surname, 
shipping_Street, shipping_Suburb, shipping_State, shipping_PostCode, shipping_Country, shipping_Phone,specialInstructions, 
paymentProcessed, paymentProcessedDate, paymentSuccessful, ipAddress, referrer, archived, messageToCustomer, 
reasonforpurchase, status, statusTemp, orderStatus, statusDate, orderType, emailStatus, actMigStatus, tabStatus, importFlag, 
specialOffer, storeID, coordIDUsed, brokerOwnerIDUsed, seasonYear, email, CRM_inactive, survey_Respondant_052908, [differential])

select a.orderID, a.orderNo, a.orderAck, a.orderForPrint, a.orderJustPrinted, a.orderBatchedDate, a.orderPrintedDate, 
a.orderCancelled, a.customerID, a.membershipID, a.membershipType, a.sessionID, a.orderDate, a.orderTotal, 
a.taxAmountInTotal, a.taxAmountAdded, a.taxDescription, a.shippingAmount, a.shippingMethod, a.shippingDesc, 
a.feeAmount, a.paymentAmountRequired, a.paymentMethod, a.paymentMethodID, a.paymentMethodRDesc, 
a.paymentMethodIsCC, a.paymentMethodIsSC, a.cardNumber, a.cardExpiryMonth, a.cardExpiryYear, a.cardName, 
a.cardType, a.cardCCV, a.cardStoreInfo,

c.Company, c.FirstName, c.Surname, 
c.Street, c.Suburb, c.State, c.PostCode, c.Country, c.Phone,

a.specialInstructions, a. paymentProcessed, a. paymentProcessedDate, a. paymentSuccessful, a. ipAddress, a. referrer, 
a.archived, a. messageToCustomer, a. reasonforpurchase, a. status, a. statusTemp, a. orderStatus, a. statusDate, a. orderType, 
a.emailStatus, a. actMigStatus, a. tabStatus, a. importFlag, a. specialOffer, a. storeID, a. coordIDUsed, a. brokerOwnerIDUsed,

datepart(yy,a.orderDate) as 'seasonYear', c.email, 
0 as 'CRM_inactive',
'None' as 'survey_Respondant_052908',
getDate()

from tblOrders a join tblCustomers c on a.customerID=c.customerID
where a.orderNo not in (select distinct orderNo from tblCRM where orderNo is not null)
and a.orderNo not like 'LC108%'
and (a.orderNo like 'HOM%' OR a.orderNo like 'MRK%')

set identity_insert tblCRM OFF

--RUN UPDATES
update tblCRM
set CAT_Football='Yes' where CAT_Football is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%Football%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_Baseball='Yes' where CAT_Baseball is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%baseball%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_Calendars='Yes' where CAT_Calendars is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%calendar%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_Pad='Yes' where CAT_Pad is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%pad%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_Stock='Yes' where CAT_Stock is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productID in (select distinct ProductID from tblProducts where productType='Stock' and productType is not null))
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_Envelopes='Yes' where CAT_Envelopes is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_DoorknobBags='Yes' where CAT_DoorknobBags is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%doork%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set CAT_AdhesiveMags='Yes' where CAT_AdhesiveMags is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%adhesive%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set STYLE_Custom='Yes' where STYLE_Custom is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productID in (select distinct ProductID from tblProducts where productType='Custom' and productType is not null))
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set STYLE_QuickCard='Yes' where STYLE_QuickCard is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%quickcard%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)

update tblCRM
set STYLE_QuickStix='Yes' where STYLE_QuickStix is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%stix%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)



update tblCRM
set CRM_InfoBlockAvailable='Yes' where orderNo in (select distinct orderNo from tblInfoBlockMaster where orderNo is not null)
and CRM_InfoBlockAvailable is null
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL)