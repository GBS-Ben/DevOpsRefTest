CREATE FUNCTION [dbo].[fnStockLevel](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT

SET @Output = dbo.fnINVCount(@productID) 
              + dbo.fnINV_ADJ(@productID)
              - dbo.fnINV_PS(@productID)
              + dbo.fnINV_WIPHOLD(@productID);

if @Output is null
		begin
			set @Output='0'
		end


 RETURN @Output

END