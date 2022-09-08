CREATE PROCEDURE [dbo].[usp_u_cpopDiff_importDate_v_Notes]
AS
SET NOCOUNT ON;

BEGIN TRY
--------------------------------------------------------------------------------------------------------------------------------// BEGIN POPINV RUNNER
--POPINV -  UPDATES INV VALUES FOR ALL PRODUCTS RELATED TO ORDERNO @TIME OF ORDER EDIT
-- Create a temporary table, note the IDENTITY
-- column that will be used to loop through
-- the rows of this table

--Make sure table doesn't exist first (in case of FAIL during POPINV last time it ran in this proc.)
IF OBJECT_ID(N'tempPOPINV_Runner', N'U') IS NOT NULL 
DROP TABLE tempPOPINV_Runner

CREATE TABLE tempPOPINV_Runner (
 RowID int IDENTITY(1, 1), 
 productID int
)
DECLARE @NumberRecords int, @RowCount int
DECLARE @productID int

-- Insert the resultset we want to loop through
-- into the temporary table
INSERT INTO tempPOPINV_Runner (productID)
select distinct productID from tblOrders_Products where orderID in (select distinct orderID from tblOrders where orderNo in
(select distinct jobNumber 
from tbl_Notes 
where jobNumber is not null 
and noteDate>(select distinct top 1 importDate from tblOrders where importDate is not null order by importDate desc)))

-- Get the number of records in the temporary table
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

-- loop through all records in the temporary table
-- using the WHILE loop construct
WHILE @RowCount <= @NumberRecords
BEGIN
 SELECT @productID = productID
 FROM tempPOPINV_Runner
 WHERE RowID = @RowCount

exec usp_popInv @productID

SET @RowCount = @RowCount + 1
END

-- drop the temporary table
IF OBJECT_ID(N'tempPOPINV_Runner', N'U') IS NOT NULL 
DROP TABLE tempPOPINV_Runner
--------------------------------------------------------------------------------------------------------------------------------// END POPINV RUNNER


-- OLD CURSOR CODE THAT WAS, WELL, A CURSOR.  LEFT HERE FOR REFERENCE.

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH