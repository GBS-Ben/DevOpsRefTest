
CREATE PROCEDURE "dbo".[imposerBatchUpdate_iFrame_02052021] @ImpositionID INT
AS
/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		11/06/18
Purpose		Runs updates post-impo

-------------------------------------------------------------------------------
Modification History

11/06/18	Created, jf.

-------------------------------------------------------------------------------
*/
BEGIN TRY 

IF @ImpositionID IS NULL
BEGIN
	SET @ImpositionID = 0
END

--update statuses -----------------------------------

UPDATE tblOrders_Products
SET fastTrak_status = 'In Production', 
fastTrak_imposedOn = GETDATE(),
fastTrak_resubmit = 0
WHERE [ID] IN
	(SELECT OPID
	FROM ImposerNCCavitiesLog
	WHERE ImpositionID = @ImpositionID)

--write notes ----------------------------------------

IF OBJECT_ID('tempdb..#tempPSUOPIDNotes') IS NOT NULL 
DROP TABLE #tempPSUOPIDNotes

CREATE TABLE #tempPSUOPIDNotes (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @OPID INT,
		@NumberRecords INT, 
		@RowCount INT

INSERT INTO #tempPSUOPIDNotes (OPID)
SELECT DISTINCT OPID
FROM ImposerNCCavitiesLog
WHERE ImpositionID = @ImpositionID
ORDER BY OPID

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @OPID = OPID
	FROM #tempPSUOPIDNotes
	WHERE RowID = @RowCount

	--isSimplex
	 
	INSERT INTO tbl_notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
	SELECT DISTINCT o.orderID, o.orderNo, 
	'Imposition successful for OPID ' + CONVERT(VARCHAR(50), @OPID) + ' on ' + 'NC_S_' + CONVERT(VARCHAR(50), @ImpositionID) + '.' AS notes,
	GETDATE(), 'Imposer', 'product', @OPID
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
	WHERE op.ID = @OPID
	AND oppx.optionCaption NOT IN ('Greeting', 'Inside Intranet PDF')

	--isDuplex

	INSERT INTO tbl_notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
	SELECT DISTINCT o.orderID, o.orderNo, 
	'Imposition successful for OPID ' + CONVERT(VARCHAR(50), @OPID) + ' on ' + 'NC_D_' + CONVERT(VARCHAR(50), @ImpositionID) + '.' AS notes,
	GETDATE(), 'Imposer', 'product', @OPID
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
	WHERE op.ID = @OPID
	AND oppx.optionCaption IN ('Greeting', 'Inside Intranet PDF')

SET @RowCount = @RowCount + 1
END

--END
END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH