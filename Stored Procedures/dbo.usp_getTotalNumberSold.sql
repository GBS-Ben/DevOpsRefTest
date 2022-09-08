CREATE   proc [dbo].[usp_getTotalNumberSold]  
@parentProductID int, @startDate varchar (255), @endDate varchar (255)
as
declare @productID int
declare @QTY int
declare @checker int
declare @numUnits int

--reset data
delete from tblINVproductQTY

set nocount on
declare cursor_e154 cursor for
select productID from tblProducts where parentProductID=@parentProductID

open cursor_e154
fetch next from cursor_e154
into @productID
while @@fetch_status = 0
begin

--set @checker
set @checker=(select productID from tblINVproductQTY where productID=@productID)

if @checker is null
	begin
		set @checker=0
	end

--set @numUnits
set @numUnits=(select distinct(numUnits) from tblProducts where productID=@productID)
--select * from tblProducts
set @QTY=(select sum(b.productQuantity*@numUnits)
		from tblProducts a join tblOrders_Products b
		on a.productID=b.productID
		where a.productID=@productID
		and b.deleteX<>'Yes'
		--and a.productType='Stock'
		and a.parentProductID=@parentProductID
		and b.orderID in (select orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed'
				and orderDate>=convert(datetime,@startDate)
				and orderDate<dateadd(day,1,(convert(datetime,@endDate))))
	)
-- 						<dateadd(day,1,(convert(datetime,@endDate)))

	if @checker is null
		begin
			fetch next from cursor_e154    		
			into @productID
		end

	if @checker=0
		begin
			insert into tblINVproductQTY (productID, productQTY)
			select @productID, @QTY
		end

	fetch next from cursor_e154    		
	into @productID
	end

--select productID, productQTY from tblINVproductQTY 
select sum(productQTY) as 'productQTYTotal' from tblINVproductQTY
--insert into tblINVproductQTY
--sp_columns 'tblINVproductQTY'


close cursor_e154
deallocate cursor_e154