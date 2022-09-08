
CREATE PROC usp_getProducts_perCustomer
@customerID INT

AS

/*
---------------------------------------------------
-- Author        : JF	
-- Date			 : 07/23/15 	
-- Purpose       : used to retrieve products purchased for a given customer
-- Called by     : n/a
-- Modifications : n/a
---------------------------------------------------
*/

SELECT [ID], productID, productCode, productName
FROM tblOrders_Products
WHERE orderID IN
	(SELECT DISTINCT orderID
	FROM tblOrders
	WHERE customerID = @customerID
	AND orderStatus <> 'failed' 
	AND orderStatus <> 'cancelled')