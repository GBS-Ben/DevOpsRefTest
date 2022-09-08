CREATE PROCEDURE [dbo].[getYearlyProductTotals2]
  @ProductID AS INT
AS 
BEGIN
Select YEAR(o.orderDate) AS 'Year'
      , sum(op.productQuantity) AS 'Number'
      , sum(op.productPrice*op.productQuantity) AS 'Amount'
      FROM [dbo].[tblProducts]as p
      INNER JOIN tblOrders_Products op ON
          op.productID = p.productID
      INNER JOIN tblOrders o ON 
          o.orderID = op.orderID  
      WHERE  (p.productID = @ProductID )     
           AND o.orderStatus not in ('Cancelled', 'Failed')
           AND op.deletex <> 'yes'
           AND YEAR(o.orderDate) > 2003
      GROUP BY YEAR(o.orderDate)
END