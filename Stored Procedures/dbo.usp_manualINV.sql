--exec usp_manualINVx '158402','4','Jeremy Fifer'


CREATE                     proc [dbo].[usp_manualINV]

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
@childProductID varchar(255),
@productID varchar(255),
@inventoryCountDate datetime


--SET INCOMING VARIABLES
if @productID_submitted is null
		begin
		set @productID_submitted='0'
		end

set @productID=@productID_submitted

set @childProductID=(select distinct productID from tblProducts where parentProductID=@productID and productID<>@productID)


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

if @childProductID is null
		begin
		set @childProductID='0'
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

--///////////////////////////////////////////
/*
--all showing order dates.
HOM213288 --1 2010-08-10 15:32:54.000
HOM213394 --1 2010-08-11 12:54:12.000
HOM213416 --1 2010-08-11 14:55:52.000


select orderNo, invRefDate from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' 
and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus<>'ON Hom Dock'
and orderID in
(select orderID from tblORders_Products where productID=158405)

select * from tblProducts where productID=158405 --this is the child
select * from tblProducts where productID=158404 --1974-01-01 00:00:00.000
*/
--////////////////////////////////////////////


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

-- declare @productID int
-- set @productID=158404
--see if child product is part of a WIP/ONHOLD order right now:


IF @childProductID<>'0' and @childProductID  in
(select distinct productID from tblOrders_Products where deleteX<>'yes' and productID is not NULL and orderID in
(select orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' 
and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus not in ('ON Hom Dock','ON MRK Dock')))

--////////////////////////////////////////////////////
/*
declare @childProductID int
set @childProductID=158405
--select * from tblOrders where orderID IN


--OLD CODE:
IF @productID  in
(select distinct parentProductID from tblProducts where parentProductID is NOT NULL and parentProductID=@productID 
and productID<>@productID
and productID in
(select distinct productID from tblOrders_Products where deleteX<>'yes' and productID is not NULL and orderID in
(select orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' 
and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus<>'ON Hom Dock')))



BEGIN --
PRINT 'YEP'
END --
*/
--////////////////////////////////////////////////////


--if so, update tblOrders.invRefDate, which is used in post-manual INV calcs:
		BEGIN
			update tblOrders
			set invRefDate=@inventoryCountDate
			where orderID in

			(select distinct orderID from tblOrders_Products where deleteX<>'Yes'  and productID=@childProductID)
			and  orderStatus<>'cancelled' and orderStatus<>'failed' 
			and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus not in ('ON Hom Dock','ON MRK Dock')
		END

--/////////////
/*

declare @productID int
set @productID=158404
select * from tblOrders where orderID IN

declare @childProductID int
set @childProductID=158405
select * from tblOrders where orderID IN


			(select distinct orderID from tblOrders_Products where deleteX<>'Yes'  and productID=@childProductID)
			and  orderStatus<>'cancelled' and orderStatus<>'failed' 
			and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus<>'ON Hom Dock'

and orderNo in
(select orderNo from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' 
and orderStatus not like '%Transit%' and orderStatus<>'Delivered' and orderStatus<>'ON Hom Dock'
and orderID in
(select orderID from tblORders_Products where productID=158405))
*/
--/////////////








--   HOM210250	Debbie  Hines (444342015)	1	1	$48.35	7/8/2010 2:01:34 PM	In House
-- 2.	   HOM210646	David Humphreys(444342337)	7	7	$182.00	7/14/2010 12:46:35 PM	In House
-- 3.	   HOM210731	donald oldakowski(444342401)	--1	10	$254.00	7/15/2010 9:44:07 AM	In House
-- 4.	   HOM210737	Rick Purvis(444342407)	2	2	$64.35	7/15/2010 10:20:12 AM	In House
-- 5.	   HOM210780 1
-- HOM209417, 3
-- select * from tblproducts where productID='158402'
-- select orderNo, invRefDate from tblOrders
-- where orderNo='HOM210250'
-- or orderNo='HOM210646'
-- or orderNo='HOM210731'
-- or orderNo='HOM210737'
-- or orderNo='HOM210780'
-- or orderNo='HOM209417'
-- 
-- HOM210250	2010-07-16 07:57:40.000
-- HOM210646	2010-07-16 07:57:40.000
-- HOM210731	2010-07-15 09:44:07.000
-- HOM210737	2010-07-16 07:57:40.000
-- HOM210780	2010-07-16 07:57:40.000

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