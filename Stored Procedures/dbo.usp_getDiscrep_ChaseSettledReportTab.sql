CREATE PROC [dbo].[usp_getDiscrep_ChaseSettledReportTab]
AS
/*
-------------------------------------------------------------------------------
Author				Jeremy Fifer
Created			01/26/15
Purpose			Used on Starfall (PMI).
-------------------------------------------------------------------------------
Modification History
01/26/15			created, jf
05/01/19			updated, jf
-------------------------------------------------------------------------------
*/
SELECT 
--primary columns
batchNumber,
transactionDateTime,
authCode,
customData,
rowID,
amount,
entryMode, 
batchClose,
cardHolderNo,

--misc columns
PKID, merchantName, reportingMerchantNo, seqNo, cardType,  
expDate, termOPID, transactionType, recordType, currency, 
PNSMerchNo, [sys], totalTime, orderNo

FROM tblChaseTransactions
WHERE verified <> 1
AND orderNo NOT LIKE 'gbs%'
AND customData NOT LIKE '%gbs%'
AND transactionDateTime > DATEADD(DD,  -180, GETDATE())
ORDER BY transactionDateTime DESC