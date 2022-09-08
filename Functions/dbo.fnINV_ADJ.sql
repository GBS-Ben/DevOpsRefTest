CREATE FUNCTION [dbo].[fnINV_ADJ](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT
 DECLARE @Parent INT

  SET @Parent = (SELECT parentProductID  FROM tblProducts WHERE productID = @productID);
  if @Parent is null
	begin
	set @Parent='0'
	END

if @Parent<>0
BEGIN
	set @Output=(select sum(adjustment)
	from tblInventoryAdjustment
	where productID=@Parent
	and adjDate>=dbo.fnINVCountDate(@productID))
END

if @Parent=0
BEGIN
	set @Output=(select sum(adjustment)
	from tblInventoryAdjustment
	where productID=@productID
	and adjDate>=dbo.fnINVCountDate(@productID))
END

	if @Output is null
			begin
				set @Output='0'
			end

 RETURN @Output

END