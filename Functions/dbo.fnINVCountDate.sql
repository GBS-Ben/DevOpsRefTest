CREATE FUNCTION [dbo].[fnINVCountDate](@productID INT)
RETURNS DATETIME
 AS
BEGIN
 DECLARE @Output DATETIME
 DECLARE @Parent INT
 DECLARE @inventoryCountDate DATETIME

  SET @Parent = (SELECT parentProductID  FROM tblProducts WHERE productID = @productID);
  if @Parent is null
	begin
	set @Parent='0'
	END

if @Parent<>0
BEGIN
	set @Output=(select distinct inventoryCountDate from tblProducts where productID=@Parent)
	
	if @Output is null
	begin
		set @Output=convert(datetime,'01/01/1974')
	end

END

-- STEP B2:  if parentProductID IS NOT available
if @Parent=0
BEGIN
	set @Output=(select inventoryCountDate from tblProducts where productID=@productID)
	
	if @Output is null
	begin
		set @Output=convert(datetime,'01/01/1974')
	end
 
END


 RETURN @Output

END