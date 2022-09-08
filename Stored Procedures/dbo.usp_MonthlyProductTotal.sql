CREATE PROCEDURE [dbo].[usp_MonthlyProductTotal]
  @ProductID VARCHAR(50),
  @From DATETIME,
  @To DATETIME
AS 
BEGIN
  SELECT
   'Total' AS Catagory
    ,SUM(p.numUnits) AS Cartons 
    ,COUNT(*) AS Trans
    ,SUM(o.orderTotal) AS Revenue
    ,AVG(o.orderTotal) AS 'AVG'
    From tblOrders o
    INNER JOIN tblOrders_Products op ON
      op.orderID = o.orderID
    INNER JOIN tblProducts p ON
      p.productID = op.productID
    WHERE o.orderDate BETWEEN @From AND @To
      AND LEFT(op.productCode,2) = @ProductID
      AND o.orderStatus not in ('Cancelled', 'Failed')
      AND op.deletex <> 'yes'
  
    UNION
  
  SELECT
   'QS' AS Catagory
    ,SUM(p.numUnits) AS Cartons 
    ,COUNT(*) AS Trans
    ,SUM(o.orderTotal) AS Revenue 
    ,AVG(o.orderTotal) AS 'AVG'
    From tblOrders o
    INNER JOIN tblOrders_Products op ON
      op.orderID = o.orderID
     INNER JOIN tblProducts p ON
      p.productID = op.productID
    WHERE o.orderDate BETWEEN @From AND @To
      AND LEFT(op.productCode,2) = @ProductID
      AND SUBSTRING(op.productCode, 3,2) = 'QS'
      AND o.orderStatus not in ('Cancelled', 'Failed')
      AND op.deletex <> 'yes'
  
    UNION
  
  SELECT
   'QC' AS Catagory
    ,SUM(p.numUnits) AS Cartons 
    ,COUNT(*) AS Trans
    ,SUM(o.orderTotal) AS Revenue 
    ,AVG(o.orderTotal) AS 'AVG'
    From tblOrders o
    INNER JOIN tblOrders_Products op ON
      op.orderID = o.orderID
    INNER JOIN tblProducts p ON
      p.productID = op.productID
    WHERE o.orderDate BETWEEN @From AND @To
      AND LEFT(op.productCode,2) = @ProductID
      AND SUBSTRING(op.productCode, 3,2) = 'QC'
      AND o.orderStatus not in ('Cancelled', 'Failed')
      AND op.deletex <> 'yes'
  
      UNION
  
  SELECT
   'QM' AS Catagory
    ,SUM(p.numUnits) AS Cartons 
    ,COUNT(*) AS Trans
    ,SUM(o.orderTotal) AS Revenue 
    ,AVG(o.orderTotal) AS 'AVG'
    From tblOrders o
    INNER JOIN tblOrders_Products op ON
      op.orderID = o.orderID
    INNER JOIN tblProducts p ON
      p.productID = op.productID
    WHERE o.orderDate BETWEEN @From AND @To
      AND LEFT(op.productCode,2) = @ProductID
      AND SUBSTRING(op.productCode, 3,2) = 'QM'
      AND o.orderStatus not in ('Cancelled', 'Failed')
      AND op.deletex <> 'yes'
  
      UNION
  
  SELECT
   'FC' AS Catagory
    ,SUM(p.numUnits) AS Cartons 
    ,COUNT(*) AS Trans
    ,SUM(o.orderTotal) AS Revenue 
    ,AVG(o.orderTotal) AS 'AVG'
    From tblOrders o
    INNER JOIN tblOrders_Products op ON
      op.orderID = o.orderID
    INNER JOIN tblProducts p ON
      p.productID = op.productID
    WHERE o.orderDate BETWEEN @From AND @To
      AND LEFT(op.productCode,2) = @ProductID
      AND SUBSTRING(op.productCode, 3,2) = 'FC'
      AND o.orderStatus not in ('Cancelled', 'Failed')
      AND op.deletex <> 'yes';

END