CREATE PROC [dbo].[usp_verifyTransaction]
@paymentID VARCHAR(100), @userName VARCHAR(100)
AS
/*
This SPROC updates a transaction to "V" status on a manual basis via the discrep tabs on the Intranet.
*/

--// Verify transaction
UPDATE tblTransactions
SET verify = verify + 'V'
WHERE verify NOT LIKE '%V%'
AND paymentID = CONVERT(BIGINT, @paymentID)

--// Write notes to tbl_notes documenting the verification
INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType)
SELECT orderNo, 
'A transaction has been manually verified for this order; paymentID: ' + CONVERT(VARCHAR(255), paymentID) + '; authCode: ' + responseOrderNo + '.', 
GETDATE(), @userName, 'order'
FROM tblTransactions
WHERE paymentID = CONVERT(BIGINT, @paymentID)