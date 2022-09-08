CREATE PROC usp_getBB_ShipLater
AS
SELECT REPLACE(c.firstName + ' ' + c.surName, '  ', ' ') AS 'customerName', 
c.email,
a.orderNo, op.productName
FROM tblOrders a
JOIN tblCustomers c
	ON a.customerID = c.customerID
JOIN tblOrders_Products op
	ON a.orderID = op.orderID
JOIN tblOrdersProducts_productOptions x
	ON op.ID = x.ordersProductsID
WHERE 
op.deleteX <> 'yes'
AND x.deleteX <> 'yes'
AND x.optionID = 456