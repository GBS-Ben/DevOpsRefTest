CREATE PROC usp_updateChaseTransaction_orderNo
@PKID INT,
@newOrderNo VARCHAR(50)
AS
/*
This SPROC updates an orderNo in tblChaseTransactions to @orderNo on a manual basis via the discrep tabs on the Intranet.
*/
UPDATE tblChaseTransactions
SET orderNo = @newOrderNo
WHERE PKID = @PKID