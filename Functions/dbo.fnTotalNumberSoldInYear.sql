CREATE FUNCTION [dbo].[fnTotalNumberSoldInYear] (@ProductID INT, @Year INTEGER)
RETURNS float
 AS
BEGIN
 DECLARE @Output float;

    SET @Output = (Select sum(op.productQuantity) 
      FROM [dbo].[tblProducts]as p
      INNER JOIN tblOrders_Products op ON
          op.productID = p.productID
      INNER JOIN tblOrders o ON 
          o.orderID = op.orderID  
      WHERE  (p.productID = @ProductID )     
           AND o.orderStatus not in ('Cancelled', 'Failed')
           AND op.deletex <> 'yes'
           AND YEAR(o.orderDate) = @Year
               )

  	if @Output is null
  		begin
  			set @Output=0
  		END

 RETURN @Output
END