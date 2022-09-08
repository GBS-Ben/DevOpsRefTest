CREATE PROC GetDailySales @Store VARCHAR(3), @orderDate1 VARCHAR(50), @orderDate2 VARCHAR(50)
AS
SELECT @orderDate1, SUM(o.CalcOrderTotal)
FROM tblOrders o
WHERE orderStatus NOT IN ('failed', 'cancelled')
AND SUBSTRING(o.orderNo, 1, 3) = @Store
AND o.orderDate BETWEEN @orderDate1 AND @orderDate2
AND o.paymentMethodID = 1