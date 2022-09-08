CREATE PROCEDURE [dbo].[GetChildInventoryAll]

	@From datetime,
	@To datetime,
	@Parent int,
	@CountRow INT OUTPUT
AS
BEGIN
--04/27/21	CKB, Markful

	SET NOCOUNT ON;
SELECT a.ProductId,
	    a.productCode,
	    a.productName,
		a.stock_Level - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO as AvailStock,
		a.productType,
	    a.onOrder,
	  --  a.INV_ONHOLD_SOLO/a.numUnits as OnHold,
	    a.INV_WIP_SOLO as WIP,
	    a.stock_Level as PhysStock,
	    a.productOnline as Hide,
	    a.stock_LowLevel as MinStock,
	    a.stock_Level as StockLevel,
	    a.parentProductId,	 
	    a.numUnits,  
	        (SELECT DISTINCT sum(p.productQuantity) AS 'SumProdQuantity' FROM tblOrders_Products p JOIN tblOrders o on p.orderID=o.orderID JOIN tblProducts ps on p.productID=ps.productID WHERE ps.productID = a.productID AND o.orderAck=0 AND o.paymentProcessed=0 AND o.paymentSuccessful=0 AND p.deleteX <> 'Yes' AND (o.orderStatus like '%waiting for payment%' AND o.orderStatus <> 'Cancelled' AND o.orderStatus <> 'Failed' AND o.orderStatus <> 'On HOM Dock' AND o.orderStatus <> 'On MRK Dock' AND o.orderStatus NOT LIKE '%Transit%' AND o.orderStatus <> 'Delivered') AND orderDate >= @From AND orderDate < @To) as 'OnHold',
   
    (SELECT DISTINCT sum(p.productPrice*p.productQuantity) AS 'SumProdQuantity'	FROM tblProducts q JOIN tblOrders_Products p ON p.productID=q.productID JOIN tblOrders o on p.orderID=o.orderID
	    WHERE  q.ProductID = a.ProductID and o.orderstatus <> 'Cancelled' AND o.orderStatus <> 'Failed'
	  AND orderDate >= @From AND orderDate < @To 
	   AND p.deletex <> 'yes'
	   	    ) as 'totalValueSold', 
	   (SELECT SUM(p.productQuantity)  AS 'SumProdQuantity'	
	    FROM tblProducts q JOIN tblOrders_Products p ON p.productID=q.productID JOIN tblOrders o on p.orderID=o.orderID
	    WHERE  q.ProductID = a.ProductID and o.orderstatus <> 'Cancelled' AND o.orderStatus <> 'Failed'
	  AND orderDate >= @From AND orderDate < @To 
	   AND p.deletex <> 'yes'
	    )as 'totalNumberSold',
	    (
	    SELECT COUNT(DISTINCT(orderNo)) AS 'CountDistinctOrders' FROM tblOrders WHERE orderstatus <> 'failed' AND orderStatus <> 'cancelled'
	    AND orderDate >= @From AND orderDate < @To 
	     AND orderID IN (SELECT DISTINCT orderID FROM tblOrders_Products p JOIN tblProducts q ON q.productid=p.productid WHERE q.productID = a.productID AND deletex <> 'yes'))
	      as 'NumTrans'
	    FROM tblProducts a
	  --  where a.parentProductID = @Parent
	 END