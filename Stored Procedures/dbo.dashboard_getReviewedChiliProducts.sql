CREATE PROCEDURE "dbo"."dashboard_getReviewedChiliProducts"

AS
SELECT 
	o.orderNo,
	d.ordersProductsID,
	dbo.fn_getOrderViewMarkdownLink(o.orderNo, o.orderNo) AS orderNo_link,
	d.reviewedOn
FROM dashboard_reviewedProducts d
JOIN tblOrders_products op
	ON op.id = d.ordersProductsID
JOIN tblOrders o
	ON o.orderID = op.orderID
ORDER BY d.reviewedOn desc