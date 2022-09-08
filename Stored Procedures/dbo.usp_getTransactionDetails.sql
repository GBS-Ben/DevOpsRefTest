CREATE PROC [dbo].[usp_getTransactionDetails]
@orderNo VARCHAR(50)
AS
SELECT 'tblTransactions' AS 'table', a.* FROM tblTransactions a WHERE a.orderNo = @orderNo
SELECT 'tblChaseTransactions' AS 'table', b.* FROM tblChaseTransactions b WHERE b.orderNo = @orderNo
SELECT 'tblTransactions_CompositeKey' AS 'table', c.* FROM tblTransactions_CompositeKey c WHERE c.orderNo = @orderNo
--SELECT orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, paymentDate)) + '.' + SUBSTRING(responseOrderNo, PATINDEX('%[^0]%', responseOrderNo+'.'), LEN(responseOrderNo)) + '.' + CONVERT(VARCHAR(50), paymentAmount)  
--FROM tblTransactions WHERE orderNo = @orderNo