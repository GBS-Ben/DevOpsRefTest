CREATE PROC usp_getOrderNo
@ID INT

AS
SELECT orderNo 
FROM tblOrders
WHERE orderID IN
	(SELECT orderID 
	FROM tblOrders_products
	WHERE [ID] = @ID)