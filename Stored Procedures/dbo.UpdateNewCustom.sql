CREATE PROC [dbo].[UpdateNewCustom]
@security_user VARCHAR(225),
@tab VARCHAR(255) , --='New-Apparel',
@orderID INT --= 555656852

AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     11/01/2020
Purpose     Updates values on the Intranet here: http://sbs/gbs/admin/ordersNewCustom88.asp
Related		EXEC GetNewCustom
-------------------------------------------------------------------------------------
Modification History

11/01/2020	JF, created.
11/16/2020	JF, updated MISC to join on OPID
09/02/2021	JF, added UYLA and Shaped Badges and modified MISC
10/18/2021	JF, Added Pens.
10/20/2021	JF, Added Custom Art.
12/2/2021	CKB, Added digitize art tab
01/25/2022  JSB, Added Large Format Logo Setup tab.
02/09/2022  JSB, Added Vouchers, Mailing Services, NotePads, Awards, and Magnetic Business Cards Tabs.
02/10/2022  JSB, Using vwCustomTab88 to find custom tabs.
-------------------------------------------------------------------------------------
*/
DECLARE @cursorID INT
DECLARE @RowCnt BIGINT
DECLARE @updateValue INT
DECLARE @updateDate DATETIME



BEGIN TRY
DROP TABLE IF EXISTS #processed
CREATE TABLE #processed([row] INT, OPID INT)
IF @tab <> '' AND @tab <> 'New-WFP'
BEGIN	
	INSERT INTO #processed SELECT ROW_NUMBER() OVER (ORDER BY op.ID) , op.ID FROM tblOrders_Products op INNER JOIN vwCustomTab88 ct ON ct.ID = op.ID WHERE op.orderID = @orderID AND ct.TabSelected=@tab
END

IF @tab = 'New-WFP'
BEGIN	
	INSERT INTO #processed SELECT ROW_NUMBER() OVER (ORDER BY op.ID) , op.ID FROM tblOrders_Products op WHERE op.orderID = @orderID
END

UPDATE op
SET isPrinted = 1
FROM tblOrders_Products op
INNER JOIN #processed p ON p.OPID = op.ID

UPDATE o
SET orderAck = 1, orderForPrint = 1, orderBatchedDate = GETDATE()
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderID = @orderID
AND o.orderType = 'Custom' 
AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xx
		WHERE xx.deleteX <> 'yes'
		AND xx.processType = 'Custom'
		AND xx.isPrinted = 0
		AND op.orderID = xx.orderID)

SET @cursorID = 1
SELECT @RowCnt = COUNT(*) FROM #processed
SET @updateDate = GETDATE()
WHILE @cursorID <= @RowCnt
BEGIN
	SELECT @updateValue = OPID FROM #processed WHERE [Row] = @cursorID
		EXEC [dbo].[EntityLog_Insert]  @updateValue, 'OPID', 'Process and Print', @tab, @updateDate , @security_user
	SET @cursorID = @cursorID + 1

END
END TRY
BEGIN CATCH
	EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH