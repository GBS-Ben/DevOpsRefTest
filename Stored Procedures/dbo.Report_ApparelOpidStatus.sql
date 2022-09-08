CREATE PROCEDURE [dbo].[Report_ApparelOpidStatus]
AS
/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		08/28/18
Purpose		Reports on Apparel for SSRS
-------------------------------------------------------------------------------
Modification History

08/28/18	Created, jf.
09/13/18	Updated to include G2G status, jf.
04/27/21	CKB, Markful
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

SELECT o.orderNo, o.orderDate, o.orderStatus, o.orderType,
	op.productID, op.productCode, op.productName, op.productPrice,
	op.productQuantity, op.fastTrak_status, op.modified_on,
	DATEDIFF(HH, OrderDate, GETDATE()) AS HoursSinceOrder,
	CASE WHEN  DATEDIFF(HH, OrderDate, GETDATE())  BETWEEN 0 AND 24 THEN '24 Or Less'
	 WHEN  DATEDIFF(HH, OrderDate, GETDATE())  BETWEEN 25 AND 48 THEN '25-48'
	 WHEN  DATEDIFF(HH, OrderDate, GETDATE())  BETWEEN 49 AND 72 THEN '49-72' 
	 WHEN  DATEDIFF(HH, OrderDate, GETDATE())  BETWEEN 73 AND 10000 THEN 'Over 72 Hours'
	END AS HoursSinceOrderGroup, 
	1 AS OpidCount,
	'http://intranet/gbs/admin/orderView.asp?i=' + CONVERT(VARCHAR(100),o.OrderId) + '&o=orders.asp&OrderNum=' + o.orderNo  + '&p=1' AS IntranetLink
--add days since order
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE op.productCode LIKE 'AP%'
AND o.orderStatus NOT IN ('ON HOM Dock','ON MRK Dock', 'In Transit', 'In Transit USPS', 'Delivered', 'Failed', 'Cancelled')
AND o.displayPaymentStatus = 'Good'
ORDER BY o.orderDate DESC, o.orderno