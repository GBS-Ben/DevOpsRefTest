
CREATE PROC usp_popInvNightly
AS 
-------------------------------------------------------------------------------
-- Author Jeremy Fifer
-- Created 07/09/08
-- Purpose    updates inventory nightly for all products within recent timeline
-------------------------------------------------------------------------------
-- Modification History
--07/09/08		Created, jf
--10/02/18		Changed name from "usp_u_cpopInvRefresh". Killed usp_popInvRunner job too. Got rid of godforsaken cursor. Updated main query, jf.
-------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#tempPSU_IAR') IS NOT NULL
DROP TABLE #tempPSU_IAR

CREATE TABLE #tempPSU_IAR (
	 RowID INT IDENTITY(1, 1), 
	 productID INT)

DECLARE @NumberRecords INT, @RowCount INT
DECLARE @productID INT

INSERT INTO #tempPSU_IAR (productID)
SELECT DISTINCT op.productID  
FROM tblOrders_Products op
INNER JOIN tblOrders o ON op.orderID = o.orderID
WHERE DATEDIFF(DD, o.modified_on, GETDATE()) <= 1
	   OR DATEDIFF(DD, op.modified_on, GETDATE()) <= 1

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
		SELECT @productID = productID
		FROM #tempPSU_IAR
		WHERE RowID = @RowCount

		EXEC usp_popInv @productID

		SET @RowCount = @RowCount + 1
END

IF OBJECT_ID('tempdb..#tempPSU_IAR') IS NOT NULL
DROP TABLE #tempPSU_IAR