CREATE PROCEDURE [dbo].[usp_getCauseValues] 
AS
SELECT
a.orderNo,
dbo.fn_getOrderViewMarkdownLink(a.orderNo, a.orderNo) AS 'orderNo_link',
a.orderDate, 
DATEPART(YYYY, a.orderDate) AS 'orderYear', DATEPART(mm, a.orderDate) AS 'orderMonth', 
a.orderTotal, a.orderStatus, a.displayPaymentStatus,
REPLACE(c.firstName + ' ' + c.surName, '  ', ' ') AS 'customerName', c.email,
p.productCode, p.productName, p.productPrice, p.productQuantity, p.productPrice * p.productQuantity AS 'productSales',
x.textValue AS 'causeSelected',
c.company AS 'billingCompany', c.street AS 'billingStreet', c.street2 AS 'billingStreet2', c.suburb AS 'billingCity',
c.[state] AS 'billingState', c.postCode AS 'billingZip', c.phone, 
REPLACE(s.shipping_FirstName + ' ' + s.shipping_SurName, '  ', ' ') AS 'shippingName', 
s.shipping_Company AS 'shippingCompany', s.shipping_street AS 'shippingStreet', s.shipping_Street2 AS 'shippingStreet2',
s.shipping_Suburb AS 'shippingCity', s.shipping_State AS 'shippingState', s.shipping_postCode AS 'shippingZip',
a.customerID, a.orderID, p.productID, p.[ID]
FROM tblOrders a 
INNER JOIN tblOrders_Products p ON a.orderID = p.orderID
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrdersProducts_productOptions x ON p.[ID] = x.ordersProductsID
WHERE 
--a.orderDate BETWEEN '20180201' AND '20190201'
a.orderDate > (getdate() - 730)
AND a.orderStatus NOT IN ('Cancelled', 'Failed')
AND p.deleteX <> 'Yes'
AND x.deleteX <> 'Yes'
AND x.optionCaption in ('Cause','Charity')
ORDER BY orderDate