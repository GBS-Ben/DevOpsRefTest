CREATE FUNCTION "dbo"."fn_getOrderViewLink"
(@orderNo VARCHAR(32))
RETURNS VARCHAR(128)
AS
BEGIN
  DECLARE @orderViewLink varChar(128);
	SELECT @orderViewLink = CONCAT('http://intranet/gbs/admin/orderView.asp?i=', o.orderID, '&o=orders.asp&OrderNum=', @orderNo )
	FROM tblOrders o
	WHERE o.orderNo = @orderNo;
  RETURN @orderViewLink;
END