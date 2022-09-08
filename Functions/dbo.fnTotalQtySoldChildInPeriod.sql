CREATE FUNCTION [dbo].[fnTotalQtySoldChildInPeriod] (@ProductID INT, @From DATETIME, @To DATETIME)
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
      WHERE  (p.productID = @ProductID      
           AND o.orderstatus <> 'Cancelled' AND o.orderStatus <> 'Failed'
           AND op.deletex <> 'yes'
           AND o.orderDate BETWEEN @From AND @To)
               )

  	if @Output is null
  		begin
  			set @Output=0
  		END

 RETURN @Output
END