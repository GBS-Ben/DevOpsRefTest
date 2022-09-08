CREATE PROCEDURE "dbo"."getOrderHistory"
@customerID INT
AS
-- Gets previous 20 orders from the same customer email as the customerID provided.
-- Not sure exactly why we use email instead of just customerID directly, but that's how the orderView page on the intranet works
-- and I get the results I'd expect with this, so I'm calling it "okay for now".
SELECT TOP 20 
	o.orderID,
	o.orderNo,
	o.paymentAmountRequired AS orderTotal,
	o.orderDate,
	o.orderStatus AS status
FROM tblOrders o
LEFT JOIN tblCustomers c ON o.customerID = c.customerID
WHERE c.email in (SELECT cc.email from tblCustomers cc where cc.customerID = @customerID)
ORDER BY o.orderDate DESC;