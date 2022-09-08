CREATE function [dbo].[fn_GetOppoFileName] 
(@ordersProductsId int
,@surfaceId int
,@extension varchar(20))

returns varchar(100)
as
--declare
--@ordersProductsId int = 555802082
--,@surfaceId int = 1
--,@extension varchar(20) = '.pdf'
begin
declare @returnFileName varchar(100)


IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblOrders_Products op inner join dbo.tblOrders o ON op.orderID = o.orderID WHERE op.ID = @ordersProductsId)
BEGIN
	
		--There are cases where the @ordersProductsId doesn't exist.  We should still create a filename
		SELECT @returnFileName = convert(varchar(8),GETDATE(),112) 
				+ '-gbsxyz'
				+ '-' + trim(convert(varchar(12),@ordersProductsId)) 
				+ '-' + case @surfaceId when 1 then 'front1' when 2 then 'back2' when 3 then 'inside3' when 4 then 'envfront' when 5 then 'envback' when 6 then 'postcardfront' when 99 then 'mailerList' else '' end
				+ '.' + trim(@extension)
			

				return @returnFileName;
END

select 
@returnFileName = convert(varchar(8),ISNULL(o.orderDate,GETDATE()),112) 
	+ '-' + ISNULL(left(op.productCode,6),'ZZXXZZ')
	+ '-' + trim(convert(varchar(12),@ordersProductsId)) 
	+ '-' + case @surfaceId when 1 then 'front1' when 2 then 'back2' when 3 then 'inside3' when 4 then 'envfront' when 5 then 'envback' when 6 then 'postcardfront' when 99 then 'mailerList' else '' end
	+ '.' + trim(@extension)
from dbo.tblOrders_Products op
inner join dbo.tblOrders o
	on op.orderID = o.orderID
where op.ID = @ordersProductsId

return @returnFileName
end