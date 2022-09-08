CREATE PROC [dbo].[usp_getEverything_NOP] @tron VARCHAR(20)
AS

IF LEN(@tron) = 6
BEGIN
	SET @tron = 'NCC' + @tron
END

--LOCAL
SELECT 'Local - tblOrders' AS 'tableName', *
FROM tblOrders
WHERE orderNo = @tron

SELECT 'Local - tblOrders_Products' AS 'tableName', *
FROM tblOrders_Products
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders
	WHERE orderNo = @tron)

SELECT 'Local - OPPO' AS 'tableName', * 
FROM tblOrdersProducts_productOptions
WHERE ordersProductsID IN
	(SELECT ID
	FROM tblOrders_Products
	WHERE orderID IN
		(SELECT orderID
		FROM tblOrders
		WHERE orderNo = @tron))

SELECT 'Local - tblCustomers' AS 'tableName', *
FROM tblCustomers
WHERE customerID IN
	(SELECT customerID
	FROM tblOrders
	WHERE orderNo = @tron)

SELECT 'Local - tblCustomers_ShippingAddress' AS 'tableName', *
FROM tblCustomers_ShippingAddress
WHERE orderNo IN
	(SELECT orderNo
	FROM tblOrders
	WHERE orderNo = @tron)

SELECT 'Local - tblCustomers_BillingAddress' AS 'tableName', *
FROM tblCustomers_BillingAddress
WHERE orderNo IN
	(SELECT orderNo
	FROM tblOrders
	WHERE orderNo = @tron)

--REMOTE

SELECT 'Remote - Order' AS 'tableName', *
FROM SQL01.nopcommerce.dbo.[order]
WHERE ID IN
	(SELECT nopID
	FROM SQL01.nopcommerce.dbo.tblNOPOrder
	WHERE gbsOrderID = @tron)

SELECT 'REMOTE - OrderItem' AS 'tableName', *
FROM SQL01.nopcommerce.dbo.orderItem
WHERE orderID IN
	(SELECT ID
	FROM SQL01.nopcommerce.dbo.[order]
	WHERE ID IN
		(SELECT nopID
		FROM SQL01.nopcommerce.dbo.tblNOPOrder
		WHERE gbsOrderID = @tron))


SELECT 'Remote - Customer' AS 'tableName', *
FROM SQL01.nopcommerce.dbo.customer
WHERE ID IN
	(SELECT customerID
	FROM SQL01.nopcommerce.dbo.[order]
	WHERE ID IN
		(SELECT nopID
		FROM SQL01.nopcommerce.dbo.tblNOPOrder
		WHERE gbsOrderID = @tron))

SELECT 'Remote - Customer Billing' AS 'tableName', *
FROM SQL01.nopcommerce.dbo.[Address]
WHERE ID IN
	(SELECT BillingAddressID
	FROM SQL01.nopcommerce.dbo.[order]
	WHERE ID IN
		(SELECT nopID
		FROM SQL01.nopcommerce.dbo.tblNOPOrder
		WHERE gbsOrderID = @tron))

SELECT 'Remote - Customer Shipping' AS 'tableName', *
FROM SQL01.nopcommerce.dbo.[Address]
WHERE ID IN
	(SELECT ShippingAddressID
	FROM SQL01.nopcommerce.dbo.[order]
	WHERE ID IN
		(SELECT nopID
		FROM SQL01.nopcommerce.dbo.tblNOPOrder
		WHERE gbsOrderID = @tron))