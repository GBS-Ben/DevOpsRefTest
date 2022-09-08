CREATE FUNCTION [dbo].[fnINV_ONHOLD_SOLO](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT
 DECLARE @Parent INT
 DECLARE @INV_ONHOLD_SOLOCHILD INT

  SET @Parent = (SELECT parentProductID  FROM tblProducts WHERE productID = @productID);
  if @Parent is null
	begin
	set @Parent='0'
	END

  if @Parent<>0
BEGIN
	set @Output=(select sum(a.productQuantity*b.numUnits) from tblOrders_Products a join tblProducts b
	on a.productID=b.productID
	where b.productID=@productID and a.deletex <>'yes'
			and orderID in
			(select distinct OrderID from tblOrders 
			where orderStatus like '%waiting%'))

	if @Output is null
		begin
			set @Output='0'
		end


	set @INV_ONHOLD_SOLOCHILD=
    (select sum(a.productQuantity*b.numUnits)  from tblOrders_Products a 
      join tblProducts b
        on a.productID=b.productID
        where b.productID<>@productID 
		    and b.parentProductID=@productID
		    and a.deletex <>'yes'
  			and orderID in
    			(select distinct OrderID from tblOrders 
    			where orderStatus like '%waiting%'))

	if @INV_ONHOLD_SOLOCHILD is null
		begin
			set @INV_ONHOLD_SOLOCHILD='0'
		end

	set @Output=@Output+@INV_ONHOLD_SOLOCHILD
END

if @Parent=0
BEGIN
	set @Output=(select sum(a.productQuantity*b.numUnits) from tblOrders_Products a join tblProducts b
	on a.productID=b.productID
	where b.productID=@productID and a.deletex <>'yes'
			and orderID in
			(select distinct OrderID from tblOrders 
			where orderStatus like '%waiting%'))

	if @Output is null
		begin
			set @Output='0'
		end
END

 RETURN @Output

END