CREATE Procedure [dbo].[GetNopProductIdFromSku]
@opid int
AS 
BEGIN
DECLARE @OrderOffset INT; 
EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;

declare @orderItemId int
set @orderItemId = @opid - @OrderOffset
SELECT p.id AS NopProductId
FROM dbo.nopcommerce_orderitem oi
inner join dbo.nopcommerce_product p
	on oi.ProductId = p.Id
WHERE oi.id = @orderItemId

END