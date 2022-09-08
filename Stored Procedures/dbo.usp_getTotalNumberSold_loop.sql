CREATE PROCEDURE [dbo].[usp_getTotalNumberSold_loop]  
@parentProductID int, @startDate varchar (255), @endDate varchar (255)
as
declare @productID int
declare @QTY int
declare @checker int
declare @numUnits int

--reset data
delete from tblINVproductQTY

--Make sure table doesn't exist first (in case of FAIL during PSU last time it ran in this proc.)
IF OBJECT_ID(N'tbl_tempParentProductID', N'U') IS NOT NULL 
DROP TABLE tbl_tempParentProductID

CREATE TABLE tbl_tempParentProductID (
 RowID int IDENTITY(1, 1), 
 ProductID varchar(50),
 parentProductID varchar(50)
)
DECLARE @NumberRecords int, @RowCount int

-- Insert the resultset we want to loop through
-- into the temporary table
INSERT INTO tbl_tempParentProductID (productID, parentProductID)
select productID, parentProductID from tblProducts where parentProductID=@parentProductID

-- Get the number of records in the temporary table
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

-- loop through all records in the temporary table
-- using the WHILE loop construct
WHILE @RowCount <= @NumberRecords
BEGIN
 SELECT @productID = productID
 FROM tbl_tempParentProductID
 WHERE RowID = @RowCount

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

			insert into tblINVproductQTY (productID, productQTY)
			select @productID, @QTY

SET @RowCount = @RowCount + 1
END

select sum(productQTY) as 'productQTYTotal' from tblINVproductQTY

-- drop the temporary table
IF OBJECT_ID(N'tbl_tempParentProductID', N'U') IS NOT NULL 
DROP TABLE tbl_tempParentProductID