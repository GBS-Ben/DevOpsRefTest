CREATE PROCEDURE  [dbo].[usp_orderView] 
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     09/14/18
-- Purpose    Refreshes view of data used for critical pages on intranet.
-------------------------------------------------------------------------------
-- Modification History

--09/14/18		Created, jf.
--09/11/19		JF, made it faster.
-------------------------------------------------------------------------------
BEGIN TRY
SET NOCOUNT ON;

DROP TABLE IF EXISTS #tempCompany

SELECT op.orderID, MAX(CASE WHEN oppo.optionCaption = 'Company Name' AND oppo.textValue IS NOT NULL THEN oppo.textValue END) AS Company
INTO #tempCompany
FROM tblOrders_Products op
INNER JOIN tblOrdersProducts_ProductOptions oppo 
ON oppo.ordersProductsID = op.ID
INNER JOIN tblOrders a
ON a.orderID = op.OrderID
WHERE a.archived = 0
AND a.orderStatus NOT IN ('ADHMIG', 'MIGZ')
AND DATEDIFF(MM, a.orderDate, GETDATE()) < = 2
AND (LEN(a.orderNo) = 9 OR LEN(a.orderNo) = 10)
GROUP BY op.orderID

create nonclustered index IX_temp_Orderid on #tempcompany (orderID ASC)

INSERT INTO tblOrderView
(orderID, orderNo, orderNumeric, orderStatus, lastStatusUpdate, orderType, [status], 
orderDate, orderTotal, paymentProcessed, coordIDUsed, brokerOwnerIDUsed, 
specialOffer, customerID, shippingDesc, 
shippingMethod, shipDate, storeID, archived, 
firstName, surname, company, street, suburb, [state], postCode, phone, fax, email, 
shipping_Company, shipping_FirstName, 
shipping_Surname, shipping_Street, shipping_Street2, shipping_Suburb, shipping_State, 
shipping_PostCode, shipping_Country, shipping_Phone, 

tblOrders_billing_Company, tblOrders_billing_FirstName, 
tblOrders_billing_Surname, tblOrders_billing_Street, 
tblOrders_billing_Street2, tblOrders_billing_Suburb, 
tblOrders_billing_State, tblOrders_billing_PostCode, 
tblOrders_billing_Country, tblOrders_billing_Phone, 

tblOrders_shipping_Company, tblOrders_shipping_FirstName, 
tblOrders_shipping_Surname, tblOrders_shipping_Street, 
tblOrders_shipping_Street2, tblOrders_shipping_Suburb, 
tblOrders_shipping_State, tblOrders_shipping_PostCode, 
tblOrders_shipping_Country, tblOrders_shipping_Phone, 

orderAck, paymentSuccessful, tabStatus, 
paymentAmountRequired, paymentMethod, statusDate, 
searchName, searchCompany, searchAddress, searchCity, searchState, searchZip, searchPhone, 
cartVersion, NOP)

SELECT DISTINCT
a.orderID, a.orderNo, 
RIGHT(a.orderNo, 6) AS 'orderNumeric', a.orderStatus, a.lastStatusUpdate, a.orderType, a.[status], 
a.orderDate, a.orderTotal, a.paymentProcessed, a.coordIDUsed, a.brokerOwnerIDUsed, 
a.specialOffer, a.customerID, 
CONVERT(VARCHAR(255), a.shippingDesc ) AS 'shippingDesc', 
a.shippingMethod, a.shipDate, a.storeID, a.archived, 
b.firstName, left(b.surname,50), ISNULL(tc.company, ''),
b.street, b.suburb, b.[state], LEFT(b.postCode,15), b.phone, b.fax, b.email, 
SUBSTRING(c.shipping_Company, 1, 50), c.shipping_FirstName, 
c.shipping_Surname, c.shipping_Street, c.shipping_Street2, LEFT(c.shipping_Suburb,50), c.shipping_State, 
LEFT(c.shipping_PostCode,15), c.shipping_Country, c.shipping_Phone, 

LEFT(a.billing_Company,50), LEFT(a.billing_FirstName,50), 
LEFT(a.billing_Surname,50), a.billing_Street, 
a.billing_Street2, a.billing_Suburb, 
a.billing_State, LEFT(a.billing_PostCode,15), 
a.billing_Country, a.billing_Phone, 

a.shipping_Company, a.shipping_FirstName, 
a.shipping_Surname, a.shipping_Street, 
a.shipping_Street2, a.shipping_Suburb, 
a.shipping_State,LEFT(a.shipping_PostCode,15), 
a.shipping_Country, a.shipping_Phone, 

a.orderAck, a.paymentSuccessful, a.tabStatus, 
a.paymentAmountRequired, left(a.paymentMethod,50), a.statusDate, 
b.firstName + ' ' + b.surname + ' ' + c.shipping_FullName AS 'searchName', 
SUBSTRING(b.company + ' ' + c.shipping_Company, 1, 50) AS 'searchCompany', 
b.street+' '+c.shipping_Street+' '+ c.shipping_Street2 AS 'searchAddress', 
b.suburb+' '+c.shipping_Suburb AS 'searchCity', 
b.[state]+' '+c.shipping_State AS 'searchState', 
REPLACE(b.postCode,'Arcadia, CA 91007','') +' ' +c.shipping_PostCode AS 'searchZip', 
LEFT(b.phone+' '+c.shipping_Phone,255) AS 'searchPhone', 
a.cartVersion, a.NOP
FROM tblOrders a 
LEFT JOIN tblOrderView ov 
	ON ov.orderNo = a.orderNo
INNER JOIN tblCustomers b 
	ON a.customerID = b.customerID
LEFT JOIN tblCustomers_ShippingAddress c 
	ON a.orderNo = c.orderNo
LEFT JOIN tblCustomers_BillingAddress y 
	ON a.orderNo = y.orderNo
LEFT JOIN #tempCompany tc
	ON tc.orderID = a.orderID
WHERE ov.orderNo IS NULL 
AND a.archived = 0
AND a.orderStatus NOT IN ('ADHMIG', 'MIGZ')
AND DATEDIFF(MM, a.orderDate, GETDATE()) < = 2
AND (LEN(a.orderNo) = 9 OR LEN(a.orderNo) = 10)

--The following updates are for presentation on orders.asp
UPDATE tblOrderView
SET orderType = b.orderType
FROM tblOrderView a
INNER JOIN tblOrders b
	ON a.orderID = b.orderID
WHERE a.orderType <> b.orderType

UPDATE tblOrderView
SET tblOrders_billing_FirstName = Shipping_FirstName,
	tblOrders_billing_SurName = Shipping_SurName
WHERE (tblOrders_billing_FirstName IS NULL OR tblOrders_billing_FirstName = '')
AND Shipping_FirstName <> ''
AND DATEDIFF(DD, orderDate, GETDATE()) < 10

UPDATE tblOrderView 
SET [state] = tblOrders_shipping_State
WHERE ([state] IS NULL OR [state] = '') 
AND tblOrders_shipping_State IS NOT NULL 
AND DATEDIFF(DD, orderDate, GETDATE()) < 10

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH