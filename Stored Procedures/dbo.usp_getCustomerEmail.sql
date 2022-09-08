
CREATE PROC usp_getCustomerEmail @orderNo VARCHAR(50) = 0
AS
SELECT email 
FROM tblCustomers
WHERE customerID IN
	(SELECT customerID
	FROM tblOrders
	WHERE orderNo = @orderNo)