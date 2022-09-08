CREATE PROC [dbo].[FurnishedArtNotification]
AS
/*
-------------------------------------------------------------------------------------
 Author      Jeremy Fifer
Created     09/11/19
Purpose     pulled out of MIGMISC.
-------------------------------------------------------------------------------------
Modification History
09/11/19	JF, created.
-------------------------------------------------------------------------------------
*/

IF OBJECT_ID('tempdb..#tempPSU_MIG_Ze') IS NOT NULL
DROP TABLE #tempPSU_MIG_Ze
CREATE TABLE #tempPSU_MIG_Ze
	(
	 RowID INT IDENTITY(1, 1), 
	 OrderID INT,
	 ProductCode NVARCHAR(50)
	)
DECLARE @NumberRecordsQ INT, @RowCountQ INT
DECLARE @OrderID INT, @ProductCode NVARCHAR(50)

INSERT INTO #tempPSU_MIG_Ze (OrderID, ProductCode)
SELECT DISTINCT op.OrderID, op.ProductCode
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
LEFT JOIN FurnishedArtEmailLog fa ON o.orderNo = fa.OrderNo
WHERE fa.OrderNo IS NULL
AND (SUBSTRING(op.ProductCode, 1, 2) = 'FA'
	OR SUBSTRING(op.ProductCode, 3, 2) = 'FA')
AND DATEDIFF(DD, o.orderDate, GETDATE()) < 60

SET @NumberRecordsQ = @@RowCount
SET @RowCountQ = 1

WHILE @RowCountQ <= @NumberRecordsQ
BEGIN
	SELECT @OrderID = OrderID,
				  @ProductCode = ProductCode
	FROM #tempPSU_MIG_Ze
	WHERE RowID = @RowCountQ

	EXECUTE [FurnishedArt_sendEmail] @OrderID, @ProductCode

	SET @RowCountQ = @RowCountQ + 1
END

IF OBJECT_ID('tempdb..#tempPSU_MIG_Ze') IS NOT NULL
DROP TABLE #tempPSU_MIG_Ze