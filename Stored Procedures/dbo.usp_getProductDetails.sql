
CREATE PROC usp_getProductDetails 
@ID INT
AS
SELECT * FROM tblOrders_Products
WHERE ID = @ID

SELECT * FROM tblOrdersProducts_productOptions
WHERE ordersProductsID = @ID

SELECT * FROM tblOrders
WHERE orderID IN
(SELECT orderID
FROM tblOrders_Products
WHERE ID = @ID)

SELECT * FROM tblProducts
WHERE productID IN
(SELECT productID
FROM tblOrders_Products
WHERE ID = @ID)