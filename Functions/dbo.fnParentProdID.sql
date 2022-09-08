CREATE FUNCTION [dbo].[fnParentProdID](@iIn int)
 RETURNS int
 AS
 BEGIN
 DECLARE @Output int;
 
 SET @Output = 0;  

 SET @Output = (select distinct parentproductID from tblProducts where parentproductID=@iIn and productID<>@iIn);
 if @Output is null
  	begin
  	set @Output = 0
	  END
 RETURN @Output
 END