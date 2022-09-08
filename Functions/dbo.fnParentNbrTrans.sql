CREATE FUNCTION [dbo].[fnParentNbrTrans](@ProductID INT, @From DATETIME, @To DATETIME)
RETURNS float
 AS
BEGIN
 DECLARE @Output float;  

    SET @Output = (SELECT COUNT(distinct(NumTrans)) 
                  FROM [dbo].[totalInventory]as q  
                  WHERE orderDate BETWEEN  @From AND @To
                    AND (q.parentProductID = @ProductID)
      )

  	if @Output is null
  		begin
  			set @Output='0'
  		END

 RETURN @Output
END