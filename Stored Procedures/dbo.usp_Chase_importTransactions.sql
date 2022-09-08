
CREATE PROC [usp_Chase_importTransactions]

AS

--// Perform initial scrub of data
UPDATE tblChase_inboundTransactions
SET authCode = ''
WHERE authCode IS NULL

UPDATE tblChase_inboundTransactions
SET orderNo = REPLACE(orderNo, '0000000', '')

UPDATE tblChase_inboundTransactions
SET rowID = seqNo + '_' + authCode + '_' + orderNo + '_' + CONVERT(nVARCHAR(255), amount)

--// Push differential data over to clean table
INSERT INTO tblChase_Transactions (batchNumber, merchantName, transactionDateTime, reportingMerchantNo, batchClose, seqNo, cardType, cardHolderNo, expDate, authCode, entryMode, 
termOPID, transactionType, recordType, amount, currency, legacyTermID, PNSMerchNo, [sys], totalTime, orderNo, customData, routingNo, rowID)
SELECT batchNumber, merchantName, transactionDateTime, reportingMerchantNo, batchClose, seqNo, cardType, cardHolderNo, expDate, authCode, entryMode, 
termOPID, transactionType, recordType, amount, currency, legacyTermID, PNSMerchNo, [sys], totalTime, orderNo, customData, routingNo, rowID
FROM tblChase_inboundTransactions
WHERE rowID NOT IN
(SELECT DISTINCT rowID
FROM tblChase_Transactions
WHERE rowID IS NOT NULL)

--// Delete inbound data for next run.
DELETE FROM tblChase_inboundTransactions

--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////--//////////////