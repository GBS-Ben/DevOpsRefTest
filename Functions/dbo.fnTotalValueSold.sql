CREATE FUNCTION [dbo].[fnTotalValueSold] (@ProductID INT)
RETURNS float
 AS
BEGIN
 DECLARE @Output float;  

  SET @Output = (SELECT DISTINCT sum(p.productPrice*p.productQuantity)	    
    FROM tblProducts q 
    JOIN tblOrders_Products p ON p.productID=q.productID 
    JOIN tblOrders o on p.orderID=o.orderID
	    WHERE  q.ProductID = @ProductID 
      AND o.orderstatus <> 'Cancelled' AND o.orderStatus <> 'Failed'
	    AND p.deletex <> 'yes'
      AND q.parentProductID = @ProductID)


  	if @Output is null
  		begin
  			set @Output='0'
  		END

 RETURN @Output
END