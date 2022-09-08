CREATE PROCEDURE [dbo].[usp_popInvRunner]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/26/09
-- Purpose     Periodically runs pop_INV to populate inventory for backdoor updates to OPIDs and products.		
-------------------------------------------------------------------------------
-- Modification History
--01/26/09		Created, jf
--10/01/18		Pulled UNION out that joined tblProducts (we'll catch those changes nightly. 
--They are to see new PPID associations, in case some were made post-creation of a given product), jf.
--10/02/18		Updated query to look at only orders created w/in last 30 days. Anything else will get picked up during the nightly run, jf.
-------------------------------------------------------------------------------

IF OBJECT_ID(N'tempPOPINV_Runner', N'U') IS NOT NULL 
DROP TABLE tempPOPINV_Runner

CREATE TABLE tempPOPINV_Runner (
		 RowID INT IDENTITY(1, 1), 
		 productID INT)

DECLARE @NumberRecords INT, @RowCount INT
DECLARE @productID INT

INSERT INTO tempPOPINV_Runner (productID)
SELECT DISTINCT productID 
FROM tblOrders_Products op
WHERE deleteX <> 'yes'
AND DATEDIFF(DD, created_on, GETDATE()) < 30
AND modified_on > (SELECT lastPopInvRun 
										FROM tblLastPopInvRun)

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
			SELECT @productID = productID
			FROM tempPOPINV_Runner
			WHERE RowID = @RowCount

			--// update inventory for product
			EXEC usp_popInv @productID

			--// update lastPopInvRun date to current
			UPDATE tblLastPopInvRun
			SET lastPopInvRun = GETDATE()

			SET @RowCount = @RowCount + 1
END

IF OBJECT_ID(N'tempPOPINV_Runner', N'U') IS NOT NULL 
DROP TABLE tempPOPINV_Runner