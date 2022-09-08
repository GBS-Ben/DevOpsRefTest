CREATE FUNCTION [dbo].[fnWasDateRange](@ProductID INT, @From DATETIME, @To DATETIME)
RETURNS BIT
 AS
BEGIN
 DECLARE @Output INT;
 DECLARE @Rtn BIT;
 SET @Rtn = 1;
    SET @Output = (SELECT count(*)
      from tblProducts as p 
      INNER JOIN tblOrders_Products tp ON
          tp.productID = @ProductID
      INNER JOIN tblOrders o ON
          o.orderID = tp.orderID
      WHERE  (p.ProductID = @ProductID 
      OR p.parentProductID = @ProductID  
      AND o.orderDate Between @From AND @To));

  	if @Output is NULL OR @Output = 0
  		begin
  			set @Rtn = 0;
  		END
    ELSE
      BEGIN
  			set @Rtn = 1;
      END
  
 RETURN @Rtn
END