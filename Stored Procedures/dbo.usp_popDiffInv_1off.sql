CREATE PROC [dbo].[usp_popDiffInv_1off]
@productName varchar(255), @startingINV int
as
declare 
@Avar int, --[original stock value from ken's sheet]
@Bvar int, --[all orders since 8/9]
@Cvar int, --[all adj since 8/10]
@Dvar int, --[alltime all orders]
@Evar int,  --[alltime adj]
@Xvar int,
@productID int

set @startingINV=5
set @Avar=@startingINV

set @productID=(select productID from tblProducts where productName like '%'+@productName+')%')
if @productID is null
	begin
	print 'ProductID Not Found'
	end

set @productID=4159

--select * from tblProducts where productID=3020
--BVAR [all orders since 8/9]
set @Bvar=(
select sum(productQuantity) from tblOrders_Products where productID=@productID
 and deletex <>'yes'
and orderID in
(select distinct OrderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed'
and orderDate>convert(datetime,'08/09/2007')))

if @Bvar is null
		begin
		set @Bvar='0'
		end

--CVAR [all adj since 8/10]
set @Cvar=(
select sum(adjustment) from tblInventoryAdjustment where productID=@productID
and adjDate>convert(datetime,'08/10/2007'))

if @Cvar is null
		begin
		set @Cvar='0'
		end

--DVAR --[alltime all orders]
set @Dvar=(
select sum(productQuantity) from tblOrders_Products where productID=@productID
 and deletex <>'yes'
and orderID in
(select distinct OrderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed'))

--EVAR --[alltime adj]
set @Evar=(select sum(adjustment) from tblInventoryAdjustment where productID=@productID)

--XVAR
--x=[original stock value from ken's sheet]-[all orders since 8/9]+[all adj since 8/10]+[alltime all orders]-[alltime adj]
set @Xvar=@Avar-@Bvar+@Cvar+@Dvar-@Evar

Insert into tblInventoryAdjustment (productID, adjustment, adjDate, adjUser, adjNote)
Values (@productID, @Xvar, getdate(), 'System', 'Setting Initial Inventory Amount')

exec usp_popINV @productID