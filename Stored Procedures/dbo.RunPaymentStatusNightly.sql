CREATE PROCEDURE [dbo].[RunPaymentStatusNightly]
AS
/*
-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			08/03/16
Purpose			Runs payment status update against recent WFP orders.
-------------------------------------------------------------------------------
Modification History

08/02/19		New
04/27/21		CKB, Markful

-------------------------------------------------------------------------------
*/

IF OBJECT_ID('tempdb..#WFPX') IS NOT NULL 
DROP TABLE #WFPX

CREATE TABLE #WFPX (
RowID INT IDENTITY(1, 1), 
orderNo VARCHAR(255))

DECLARE @NumRec INT, 
		@RWCT INT, 
		@orderNo NVARCHAR(255)

INSERT INTO #WFPX (orderNo)
SELECT DISTINCT orderNo
FROM tblOrders o
WHERE displayPaymentStatus IN ('waiting for payment', '', 'Partial Payment Received')
AND orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'in transit', 'in transit usps')
AND SUBSTRING(orderNo, 1, 3) IN ( 'HOM', 'NCC','MRK')
AND DATEDIFF(dd, orderDate, GETDATE()) < 90


SET @NumRec = @@ROWCOUNT
SET @RWCT = 1

WHILE @RWCT <= @NumRec
BEGIN
	SELECT @orderNo = orderNo
	FROM #WFPX
	WHERE RowID = @RWCT

	EXEC usp_paymentStatus @orderNo

	SET @RWCT = @RWCT + 1
END