--04/27/2021		CKB, Markful

CREATE PROC [dbo].[Report_StuckBadges_Last30Days]
AS
SELECT DISTINCT o.orderNo, o.orderDate, o.orderStatus, op.ID, op.productCode, 
op.productName, op.fasttrak_status, op.productQuantity, op.processType, op.deleteX
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'in transit','in transit usps', 'on hom dock', 'on mrk dock')
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'nb%'
AND o.orderDate > GETDATE()-31
ORDER BY o.orderstatus