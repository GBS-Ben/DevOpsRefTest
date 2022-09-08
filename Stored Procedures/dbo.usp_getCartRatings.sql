CREATE PROC usp_getCartRatings 
@startDate VARCHAR(50), @endDate VARCHAR(50)
AS
SELECT  a.ID, a.orderID, a.orderNo, b.orderDate, a.productID, a.rating, a.comments
FROM tblRatings a
JOIN tblOrders b
ON a.orderNo = b.orderNo
WHERE a.orderNo
IN (SELECT orderNo
FROM tblOrders
WHERE orderDate >= CONVERT(DATETIME, @startDate)
AND orderDate <= CONVERT(DATETIME, @endDate))
ORDER BY orderDate

--//Example:
--EXEC usp_getCartRatings '08/01/2015', '08/31/2015'