CREATE PROCEDURE "dbo"."getOrderPayment"
@orderID INT
AS
SELECT TOP 20
o.orderID,
o.orderNo,
o.paymentAmountRequired,
o.orderDate ,
o.orderStatus,
c.firstName
FROM tblOrders o
LEFT JOIN tblCustomers c
	ON o.customerID = c.customerID
WHERE c.email = (Select email from tblCustomers where customerID = c.customerID)
ORDER BY orderDate DESC;