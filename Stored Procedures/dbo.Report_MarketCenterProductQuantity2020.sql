

CREATE PROCEDURE Report_MarketCenterProductQuantity2020
AS
SELECT GbsCompanyId AS [MC-ID]
	, productcode 
	, ProductName
	, SUM(CASE WHEN LEFT(productcode,2) = 'BP' THEN 100* productQuantity ELSE productQuantity END) AS [Product Quantity]
	, count(Id)  AS [Order Quantity]   --select DISTINCT o.OrderStatus 
FROM tblOrders_Products op
INNER JOIN tblOrders o On o.Orderid = op.orderID 
INNER JOIN tblOrderView ov ON ov.orderID = o.orderID 
WHERE --(op.GbsCompanyId = 'TH-100-01983')-- OR CustomerEmail LIKE 'robert%slack%')
--and productCode like 'AP%' 
	-- o.orderStatus NOT IN ('canceled','Waiting For Payment','Waiting On Customer')
	 o.orderStatus IN ('In Transit','Delivered')
	AND NULLIF(GbsCompanyId,'') IS NOT NULL
	AND o.orderDate BETWEEN '1/1/2020' and '12/31/2020'
GROUP BY GbsCompanyId, productcode, ProductName
ORDER BY 4 desc