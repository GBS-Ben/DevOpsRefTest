CREATE PROC [dbo].[Report_GetBusinessCards_iFrame_02052021]
AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     8/6/07
Purpose     Retrieves BC report for Ken, adhoc
-------------------------------------------------------------------------------------
Modification History

08/06/07	created, jf.
01/03/18	updated, jf.
12/01/18	updated to reflect bc options, jf
-------------------------------------------------------------------------------------
*/

TRUNCATE TABLE ReportBusinessCards
INSERT INTO ReportBusinessCards (orderNo, orderDate, orderMonth, orderYear, productCode, productQuantity, opidTotal, orderTotal, OPID)

SELECT DISTINCT
a.orderNo, 
a.orderDate, 
DATEPART(MM, a.orderDate) AS 'orderMonth', 
DATEPART(YY, a.orderDate) AS 'orderYear',
b.productCode,
b.productQuantity,
b.productQuantity * b.productPrice as 'opidTotal',
a.orderTotal, b.ID
FROM tblOrders a 
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
LEFT JOIN tblOrdersProducts_productOptions x ON b.[ID] = x.ordersProductsID
	AND x.deleteX <> 'Yes'
	AND x.optionID IN (571, 573, 574, 568) --(round, double thick 32 pt, Luxe ColorFill 42 pt, Soft Touch)
WHERE b.deleteX <> 'Yes'
AND a.orderStatus NOT IN ('cancelled', 'failed', 'migz')
AND SUBSTRING(b.productCode, 1, 2) = 'BP'
GROUP BY a.orderNo, a.orderDate, b.productCode, b.productQuantity, b.productPrice, a.orderTotal, b.ID
ORDER BY a.orderDate, a.orderTotal

UPDATE a
SET option_RoundedCorners = 1,
	optionTotal_RoundedCorners = a.productQuantity * b.optionPrice * 100
FROM ReportBusinessCards a
INNER JOIN tblOrdersProducts_productOptions b ON a.OPID = b.ordersProductsID
WHERE b.optionID = 571
AND b.deleteX = '0'

UPDATE a
SET option_DoubleThick32pt = 1,
	optionTotal_DoubleThick32pt = a.productQuantity * b.optionPrice * 100
FROM ReportBusinessCards a
INNER JOIN tblOrdersProducts_productOptions b ON a.OPID = b.ordersProductsID
WHERE b.optionID = 573
AND b.deleteX = '0'

UPDATE a
SET option_LuxeColorFill42pt = 1,
	optionTotal_LuxeColorFill42pt = a.productQuantity * b.optionPrice * 100
FROM ReportBusinessCards a
INNER JOIN tblOrdersProducts_productOptions b ON a.OPID = b.ordersProductsID
WHERE b.optionID = 574
AND b.deleteX = '0'

UPDATE a
SET option_SoftTouch = 1,
	optionTotal_SoftTouch = a.productQuantity * b.optionPrice * 100
FROM ReportBusinessCards a
INNER JOIN tblOrdersProducts_productOptions b ON a.OPID = b.ordersProductsID
WHERE b.optionID = 568
AND b.deleteX = '0'

UPDATE ReportBusinessCards SET optionTotal_RoundedCorners = 0 WHERE optionTotal_RoundedCorners IS NULL
UPDATE ReportBusinessCards SET optionTotal_DoubleThick32pt = 0 WHERE optionTotal_DoubleThick32pt IS NULL
UPDATE ReportBusinessCards SET optionTotal_LuxeColorFill42pt = 0 WHERE optionTotal_LuxeColorFill42pt IS NULL
UPDATE ReportBusinessCards SET optionTotal_SoftTouch = 0 WHERE optionTotal_SoftTouch IS NULL
UPDATE ReportBusinessCards SET oppoTotal = optionTotal_RoundedCorners + optionTotal_DoubleThick32pt + optionTotal_LuxeColorFill42pt + optionTotal_SoftTouch
UPDATE ReportBusinessCards SET opid_oppo_combinedTotal = opidTotal + oppoTotal

SELECT * FROM ReportBusinessCards
ORDER BY orderDate DESC