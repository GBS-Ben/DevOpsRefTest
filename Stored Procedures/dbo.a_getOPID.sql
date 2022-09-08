CREATE PROCEDURE "dbo"."a_getOPID"
@id INT 
AS
SELECT
	o.orderNo,
	op.id as OPID,
	op.productCode,
	o.orderDate,
	o.orderStatus,
	o.orderType,
	op.fastTrak_status as productStatus,
	op.switch_create,
	op.processType,
	op.deleteX as productDeleted,
	o.displayPaymentStatus as payment,
	CONCAT(o.shipping_FirstName, ' ', o.shipping_Surname) as customerName,
	dbo.fn_getOrderViewLink(o.orderNo) as intranetLink
FROM tblOrders_products op
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
AND op.id = @id