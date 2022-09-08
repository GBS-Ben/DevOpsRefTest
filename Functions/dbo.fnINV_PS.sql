CREATE FUNCTION [dbo].[fnINV_PS](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT
 DECLARE @Parent INT
 DECLARE @INV_PSCHILD INT
 DECLARE @DATE AS DATETIME

 SET @DATE = dbo.fnINVCountDate(@productID);

  SET @Parent = (SELECT parentProductID  FROM tblProducts WHERE productID = @productID);
  if @Parent is null
	begin
	set @Parent='0'
	END

if @Parent<>0
BEGIN

	set @Output=(select sum(productQuantity) 
               from tblOrders_Products 
               where productID=@productID 
                 and deletex <>'yes' 
                 and OrderID in
            				(select distinct OrderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' 
            				and invRefDate>=@DATE and invRefDate is not NULL))

	if @Output is null
			begin
				set @Output='0'
			end


	set @INV_PSCHILD=(select sum(a.productQuantity*b.numUnits)  from tblOrders_Products a join tblProducts b
	                                    on a.productID=b.productID
	                                    where b.productID<>@productID 
			    and b.parentProductID=@productID
	                                    and a.deletex <>'yes'
	                                    and a.orderID in
		                                    (select distinct OrderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed'
		                                    and invRefDate>=@DATE and invRefDate is not NULL))
	if @INV_PSCHILD is null
			begin
			set @INV_PSCHILD='0'
			end

	
	set @Output=@Output+@INV_PSCHILD
END

if @Parent=0
BEGIN

	set @Output=(select sum(productQuantity) 
               from tblOrders_Products 
               where productID=@productID 
               and deletex <>'yes' 
               and OrderID in
        				(select distinct OrderID 
                  from tblOrders 
                  where orderStatus<>'cancelled' 
                  and orderStatus<>'failed' 
        				  and invRefDate>=@DATE 
                  and invRefDate is not NULL))
	if @Output is null
			begin
				set @Output='0'
			end
END


 RETURN @Output

END