CREATE PROC usp_verifySettledReportTransaction
@PKID INT
AS
/*
This SPROC updates a line item in tblChaseTransactions to "V" status on a manual basis via the discrep tabs on the Intranet.
*/
UPDATE tblChaseTransactions
SET verified = 1
WHERE verified <> 1
AND PKID = @PKID