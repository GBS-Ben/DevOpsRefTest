CREATE FUNCTION [dbo].[fnINV_WIPHOLD](@productID INT)
 RETURNS int
 AS
 BEGIN
 DECLARE @Output INT
 DECLARE @INV_WIPHOLDCHILD INT
 DECLARE @Parent INT

  SET @Parent = (SELECT parentProductID  FROM tblProducts WHERE productID = @productID);
if @Parent<>0
BEGIN
	set @Output=(select sum(a.productQuantity*b.numUnits) from tblOrders_Products a join tblProducts b
	on @productID=b.productID
	where b.productID=a.productID and a.deletex <>'yes'
			and orderID not in
			(select distinct OrderID from tblOrders 
			where orderStatus='Delivered'
			or orderStatus like '%transit%' 
			or orderStatus like '%dock%' 
			or orderStatus='cancelled' 
			or orderStatus='failed'))

	if @Output is null
		begin
			set @Output='0'
		END

  	set @INV_WIPHOLDCHILD=(select sum(a.productQuantity*b.numUnits)  from tblOrders_Products a join tblProducts b
                                    on a.productID=b.productID
                                    where b.productID<>@productID 
		    and b.parentProductID=@productID
		    and a.deletex <>'yes'
			and orderID not in
			(select distinct OrderID from tblOrders 
			where orderStatus='Delivered'
			or orderStatus like '%transit%' 
			or orderStatus like '%dock%' 
			or orderStatus='cancelled' 
			or orderStatus='failed'))

	if @INV_WIPHOLDCHILD is null
		begin
			set @INV_WIPHOLDCHILD='0'
		end

	set @Output=@Output+@INV_WIPHOLDCHILD

END
ELSE
 BEGIN
	set @Output=(select sum(a.productQuantity*b.numUnits) from tblOrders_Products a join tblProducts b
	on a.productID=b.productID
	where b.productID=@productID and a.deletex <>'yes'
			and orderID not in
			(select distinct OrderID from tblOrders 
			where orderStatus='Delivered'
			or orderStatus like '%transit%' 
			or orderStatus like '%dock%' 
			or orderStatus='cancelled' 
			or orderStatus='failed'))

	if @Output is null
		begin
			set @Output='0'
		end
END
 RETURN @Output
 END