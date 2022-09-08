CREATE                  proc [dbo].[usp_manualINV_NEW]

-- ____________________________________________________________
-- 
-- CREATED BY: JF
-- CREATED DATE:  05/25/10
-- LAST UPDATE DATE:  05/25/10
-- LAST UPDATE:  N/A
--04/27/21		CKB, Markful
-- ____________________________________________________________

-- ____________________________________________________________
-- 
-- USAGE:  
-- 
-- This proc updates Inventory for a given product when:
-- 	1.  A manual inventory is run
-- 
-- ____________________________________________________________

----/--/--/--/--/--/--/--/--/--/--/ BEGIN --/--/--/--/--/--/--/--/--/--/--/


@productID_submitted varchar(255), @ADJ int, @author varchar(255)
as
declare 
@stockLevel int,
-- @INV_WIPHOLD_PHYS int,
-- @INV_WIPHOLDCHILD_PHYS int,
@parentProductID varchar(255),
@productID varchar(255),
@inventoryCountDate datetime


--SET INCOMING VARIABLES
if @productID_submitted is null
		begin
		set @productID_submitted='0'
		end

set @productID=@productID_submitted

-- --first exec usp_popINV for the given product so that any WIP ON HOLD values at the timestamp will be updated (revision: 042210 //not needed: 052110)
-- exec usp_popINV @productID

--now move forward with usp_manualINV
set @parentProductID=(select distinct parentproductID from tblProducts where parentproductID=@productID and productID<>@productID)

if @parentProductID is null
		begin
		set @parentProductID='0'
		end

if @ADJ is null
		begin
		set @ADJ='0'
		end

if @author is null
		begin
		set @author='Unknown'
		end



--if @productID is part of a WIP/ONHOLD order, then update tblOrders.invRefDate=inventoryCountDate
--note: inventoryCountDate was just set on productAE.asp, prior to the call of this proc.
set @inventoryCountDate=(select inventoryCountDate from tblProducts where productID=@productID and inventoryCountDate is NOT NULL
				and inventoryCountDate<>convert (datetime, '1974-01-01 00:00:00.000'))

--Timing.
IF @inventoryCountDate is null
		begin
		set @inventoryCountDate=getDate()
		end


--see if productID is part of a WIP/ONHOLD order right now:
IF @productID in
(select distinct productID from tblOrders_Products where deleteX<>'yes' and productID is not NULL and orderID in
(select orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' 
and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus not in ('ON Hom Dock','ON MRK Dock')))

--if so, update tblOrders.invRefDate, which is used in post-manual INV calcs:
		BEGIN
			update tblOrders
			set invRefDate=@inventoryCountDate
			where orderID in
			(select distinct orderID from tblOrders_Products where productID=@productID and deleteX<>'Yes')
			and  orderStatus<>'cancelled' and orderStatus<>'failed' 
			and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus not in ('ON Hom Dock','ON MRK Dock')
		END


--/////////////////////////////////////////////////////////////////////////////////////////////////////////////// KILL >
/*
--@INV_WIPHOLD_PHYS
            set @INV_WIPHOLD_PHYS=(select sum(a.productQuantity*b.numUnits) from tblOrders_Products a join tblProducts b
                                    on a.productID=b.productID                                          
                                    where b.productID=@productID and a.deletex <>'yes'
			and orderID not in
			(select distinct OrderID from tblOrders where 
			orderStatus='Delivered'
			or orderStatus like '%transit%' 
			or orderStatus like '%dock%'  
			or orderStatus='cancelled' 
			or orderStatus='failed'))

            if @INV_WIPHOLD_PHYS is null
                                    begin
                                    set @INV_WIPHOLD_PHYS='0'
                                    end


            set @INV_WIPHOLDCHILD_PHYS=(select sum(a.productQuantity*b.numUnits)  from tblOrders_Products a join tblProducts b
                                    on a.productID=b.productID
                                    where b.productID<>@productID 
		    and b.parentProductID=@productID
		    and a.deletex <>'yes'
			and orderID not in
			(select distinct OrderID from tblOrders 
			where orderStatus='Delivered'
			or orderStatus like '%transit%'
			or orderStatus like '%dock%'
			or orderStatus like '%cancelled%'
			or orderStatus like '%failed%'
			))

	if @INV_WIPHOLDCHILD_PHYS is null
	                                 begin
	                                 set @INV_WIPHOLDCHILD_PHYS='0'
	                                 end

                set @INV_WIPHOLD_PHYS=@INV_WIPHOLD_PHYS +@INV_WIPHOLDCHILD_PHYS

                if @INV_WIPHOLD_PHYS is null
	                                 begin
	                                 set @INV_WIPHOLD_PHYS='0'
	                                 end

--UPDATE INV_WIPHOLD_PHYS
update tblProducts
set INV_WIPHOLD_PHYS=@INV_WIPHOLD_PHYS
where productID=@productID

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////// KILL ^
*/

--UPDATE stock_level
set @stockLevel=@ADJ

if @stockLevel is null
                         begin
                         set @stockLevel='0'
                         end
update tblProducts
set stock_level=@stockLevel
where productID=@productID



--WRITE NOTES
insert into tbl_notes (jobNumber, notes, noteDate, author, notesType)
select @productID, 'Inventory was manually updated for productID '+@productID+' by: '+@author+' bringing the stock level to: '+convert(varchar(255),@stockLevel)+').', 
getDate(), @author, 'Inventory Adjustment'

--EXEC usp_popInv
exec usp_popInv @productID


----/--/--/--/--/--/--/--/--/--/--/ END --/--/--/--/--/--/--/--/--/--/--/