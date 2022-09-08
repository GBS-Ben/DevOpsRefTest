CREATE PROCEDURE "dbo"."getOrderView"
@orderNo VARCHAR(32)
AS

SELECT
	o.orderNo,
	o.orderID,
	o.orderStatus,
	o.customerID
FROM tblOrders o
WHERE o.orderNo = @orderNo;