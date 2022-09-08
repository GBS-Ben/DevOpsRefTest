CREATE PROC [dbo].[usp_ReviewOrders]
AS

TRUNCATE TABLE tblReviewedFailedOrders

INSERT INTO tblReviewedFailedOrders (customerID, orderID, firstName, company, street, street2, suburb, [state], postCode, phone, fax, email, orderNo, orderDate, orderTotal, orderStatus)
SELECT DISTINCT
b.customerID,  a.orderID,  b.firstName,  b.company,  b.street,  b.street2, 
b.suburb,  b.[state],  b.postCode,  b.phone,  b.fax,  b.email, 
a.orderNo,  a.orderDate,  a.orderTotal,  a.orderStatus
FROM tblOrders a 
JOIN tblCustomers b
	ON a.customerID = b.customerID
WHERE a.orderStatus = 'failed'
AND DATEDIFF(dd, a.orderdate, GETDATE()) < 71