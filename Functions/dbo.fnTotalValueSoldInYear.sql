CREATE FUNCTION [dbo].[fnTotalValueSoldInYear] (@ProductID INT, @Year INTEGER)
RETURNS Money
 AS
BEGIN
 DECLARE @Output  NUMERIC;
 DECLARE @Output2 VARCHAR(50);

    SET @Output = (Select sum(op.productPrice*op.productQuantity)
      FROM [dbo].[tblProducts]as p
      INNER JOIN tblOrders_Products op ON
          op.productID = p.productID
      INNER JOIN tblOrders o ON 
          o.orderID = op.orderID  
      WHERE  (p.parentProductID = @ProductID )     
           AND o.orderStatus not in ('Cancelled', 'Failed')
           AND op.deletex <> 'yes'
           AND YEAR(o.orderDate) = @Year
               )


  	if @Output is null
  		begin
  			SET @Output='0'
  		END
SET @Output2 =  CONVERT(varchar,@Output, 1);
 RETURN @Output2
END