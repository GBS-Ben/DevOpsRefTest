CREATE PROC GetInProdEmails
AS

SELECT c.email, o.orderNo, o.orderStatus, o.orderDate
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus IN ('In House', 'In Production', 'On Proof', 'In Art')
ORDER BY o.orderDate DESC