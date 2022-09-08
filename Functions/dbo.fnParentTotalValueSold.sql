CREATE FUNCTION [dbo].[fnParentTotalValueSold] (@ProductID INT)
RETURNS float
 AS
BEGIN
 DECLARE @Output float;  

    SET @Output = (Select sum(op.productPrice*op.productQuantity)
      FROM [dbo].[tblProducts]as p
      INNER JOIN tblOrders_Products op ON
          op.productID = p.productID
      INNER JOIN tblOrders o ON 
          o.orderID = op.orderID  
      WHERE  (p.parentProductID = @ProductID )     
           AND o.orderStatus not in ('Cancelled', 'Failed')
           AND op.deletex <> 'yes'
               )


  	if @Output is null
  		begin
  			set @Output='0'
  		END

 RETURN @Output
END