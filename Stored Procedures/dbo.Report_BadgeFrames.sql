CREATE PROCEDURE [dbo].[Report_BadgeFrames]
AS
/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		12/05/19
Purpose		Reports on Badge Frames for Art Dept
-------------------------------------------------------------------------------
Modification History

12/05/19	Created, jf.

-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

SELECT DISTINCT op.ID AS OPID, op.productCode, op.productName, 
oppx.optionCaption, oppx.textValue, op.productQuantity,
o.orderno, o.orderstatus, o.orderdate
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
WHERE 
o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND op.deleteX <> 'yes'
AND DATEDIFF(DD, o.orderDate, GETDATE()) < 90
AND oppx.optionCaption = 'Frame Style'
ORDER BY o.orderDate DESC