CREATE FUNCTION [dbo].[fnTotalValueSoldChildInPeriod] (@ProductID INT, @From DATETIME, @To DATETIME)
RETURNS Money
 AS
BEGIN
 DECLARE @Output Money;

  SET @Output = (SELECT DISTINCT sum(p.productPrice*p.productQuantity)	    
    FROM tblProducts q 
    JOIN tblOrders_Products p ON p.productID=q.productID 
    JOIN tblOrders o on p.orderID=o.orderID
	    WHERE  q.productID = @ProductID 
      AND o.orderstatus <> 'Cancelled' AND o.orderStatus <> 'Failed'
	    AND orderDate >= @From AND orderDate < @To
	    AND p.deletex <> 'yes')

  	if @Output is null
  		begin
  			SET @Output='0'
  		END

 RETURN @Output
END