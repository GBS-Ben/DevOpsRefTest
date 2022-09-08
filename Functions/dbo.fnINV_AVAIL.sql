CREATE FUNCTION [dbo].[fnINV_AVAIL](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT
 SET @Output =   dbo.fnStockLevel(@productID)
               - dbo.fnINV_WIPHOLD(@productID);

if @Output is null
		begin
			set @Output='0'
		end


 RETURN @Output

END