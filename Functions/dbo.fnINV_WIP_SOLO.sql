CREATE FUNCTION [dbo].[fnINV_WIP_SOLO](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT
 DECLARE @Parent INT

    set @Output = dbo.fnINV_WIPHOLD(@productID) - dbo.fnINV_ONHOLD_SOLO(@productID);
    
    RETURN @Output
END