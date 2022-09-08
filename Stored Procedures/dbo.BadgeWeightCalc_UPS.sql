CREATE PROC [dbo].[BadgeWeightCalc_UPS]
AS
/*
-------------------------------------------------------------------------------------
 Author      Jeremy Fifer
Created     09/11/19
Purpose     pulled out of MIGMISC.
-------------------------------------------------------------------------------------
Modification History
09/11/19	JF, created.
-------------------------------------------------------------------------------------
*/

;WITH CTE
AS
(SELECT o.orderID
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE SUBSTRING(op.productCode, 1 , 2) = 'NB'
AND op.deleteX <> 'yes'
AND o.orderStatus NOT IN ('Delivered', 'Cancelled', 'Failed', 'In Transit', 'In Transit USPS')
AND (o.calcBadges <> 3 
	OR o.calcBadges IS NULL))

UPDATE o 
SET calcBadges = 3
FROM tblOrders o
INNER JOIN CTE ON o.orderID = CTE.orderID

;WITH CTE
AS
(SELECT o.orderID
FROM tblOrders o
LEFT JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.calcBadges NOT IN (3, 0)
OR o.calcBadges IS NULL
AND DATEDIFF (DD, o.orderDate, GETDATE()) < 2)

UPDATE tblorders 
SET calcBadges = 0 
FROM tblOrders o
INNER JOIN CTE ON o.orderID = CTE.orderID