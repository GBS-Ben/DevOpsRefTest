
CREATE PROC ReportSalesAll
@PC CHAR(2),
@MM CHAR(2),
@YY CHAR(4)

AS

---===================================================================

DECLARE @SUM_OPID SMALLMONEY,
		@SUM_OPPX SMALLMONEY

SET @SUM_OPID = (SELECT 
SUM(op.productQuantity * op.productPrice)
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE SUBSTRING(op.productCode, 1, 2) = @PC
AND op.deleteX <> 'yes'
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND DATEPART(MM, o.orderDate) = @MM
AND DATEPART(YY, o.orderDate) = @YY)

SET @SUM_OPPX = (SELECT 
SUM(oppx.optionPrice)
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
WHERE SUBSTRING(op.productCode, 1, 2) = @PC
AND op.deleteX <> 'yes'
AND oppx.deleteX <> 'yes'
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND DATEPART(MM, o.orderDate) = @MM
AND DATEPART(YY, o.orderDate) = @YY)

SELECT @PC, @MM, @YY, @SUM_OPID, @SUM_OPPX, ISNULL(@SUM_OPID, 0) + ISNULL(@SUM_OPPX, 0)

---===================================================================