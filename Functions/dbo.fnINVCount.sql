CREATE FUNCTION [dbo].[fnINVCount](@productID INT)
RETURNS int
 AS
BEGIN
 DECLARE @Output INT
 DECLARE @Parent INT
 DECLARE @InvDate DATETIME

  SET @Output = 0; -- Default to zero
  SET @Parent = (SELECT parentProductID  FROM tblProducts WHERE productID = @productID);
  if @Parent is null
	begin
	set @Parent='0'
	END

  SET @InvDate = dbo.fnINVCountDate(@productID);
  IF @Parent <>0
    BEGIN
    	if @InvDate<>0
    	begin
    		set @Output=(select inventoryCount from tblProducts where productID=@productID)
    		
    			if @Output is null
    			begin
    				set @Output=0
    			end
      end
    END

  if @Parent=0
  BEGIN
  	if @InvDate<>0
  	begin
  		set @Output=(select inventoryCount from tblProducts where productID=@productID)
  		
  			if @Output is null
  			begin
  				set @Output=0
  			end
  	end
  END

 RETURN @Output

END