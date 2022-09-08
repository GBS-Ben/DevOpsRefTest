CREATE PROC usp_getCauseValues_byDateRange
@startDate VARCHAR(50),
@endDate VARCHAR(50)

AS
SELECT a.orderNo, a.orderDate, 
DATEPART(YYYY, a.orderDate) AS 'orderYear', 
DATEPART(mm, a.orderDate) AS 'orderMonth', 
a.orderTotal, a.orderStatus, a.displayPaymentStatus,
REPLACE(c.firstName + ' ' + c.surName, '  ', ' ') AS 'customerName', c.email,
p.productCode, p.productName, p.productPrice, p.productQuantity, p.productPrice * p.productQuantity AS 'productSales',
-- 'productSalesLessDonation',
x.textValue AS 'causeSelected',
c.company AS 'billingCompany', c.street AS 'billingStreet', c.street2 AS 'billingStreet2', c.suburb AS 'billingCity',
c.[state] AS 'billingState', c.postCode AS 'billingZip', c.phone, 
REPLACE(s.shipping_FirstName + ' ' + s.shipping_SurName, '  ', ' ') AS 'shippingName', 
s.shipping_Company AS 'shippingCompany', s.shipping_street AS 'shippingStreet', s.shipping_Street2 AS 'shippingStreet2',
s.shipping_Suburb AS 'shippingCity', s.shipping_State AS 'shippingState', s.shipping_postCode AS 'shippingZip',
a.customerID, a.orderID, p.productID, p.[ID]
--prevCustomer
FROM tblOrders a JOIN tblOrders_Products p ON a.orderID = p.orderID
				 JOIN tblCustomers c ON a.customerID = c.customerID
				 JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
				 JOIN tblOrdersProducts_productOptions x ON p.[ID] = x.ordersProductsID
WHERE 
    a.orderDate >= CONVERT(DATETIME, @startDate)
AND a.orderDate < CONVERT(DATETIME, @endDate)
AND a.orderStatus <> 'Cancelled'
AND a.orderStatus <> 'Failed'
AND p.deleteX <> 'Yes'
AND x.deleteX <> 'Yes'
AND x.optionCaption = 'Cause'