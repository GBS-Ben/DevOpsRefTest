CREATE PROC [dbo].[usp_getDiscrep_TransactionsTab]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     08/3/14
Purpose     Retrieves transaction tab data on http://sbs/gbs/admin/chaseReport.asp?navSection=Reports
-------------------------------------------------------------------------------
Modification History

08/03/14			new, jf
12/14/17			updated responseDesc NOT IN section as per BB request, jf.
05/01/19			cleaned up, jf
-------------------------------------------------------------------------------
*/
SELECT 
--primary columns
a.orderNo, 
a.paymentAmount,
a.paymentDate, 
a.responseCode, a.responseDesc,
a.responseOrderNo, 
a.responseErrorDesc,
a.verify, 
a.traceNumber,

--misc columns:
a.paymentID, a.orderID, a.responseSummary, a.responseRRN, a.responseOtherInfo, 
a.ipAddress, a.cardNumber, a.cardExpiry, a.cardName, a.cardType, 
a.processTime, a.paymentType, a.ActionCode, a.deletex

FROM tblTransactions a
INNER JOIN tblOrders b ON a.orderNo = b.orderNo
	AND a.verify NOT IN ('MV', 'SV')
	AND a.actionCode <> 'VOID'
	AND a.responseDesc NOT IN 
		('Merchant Override', 'Merchant Override Decline', 'Lost / Stolen Card', 'Invalid PIN', 
		'Invalid Expiration Date', 'Invalid Credit Card Number', 'Do Not Honor', 'Pickup', 
		'Other Error', 'Call voice center ')
LEFT JOIN tblChaseTransactions x ON a.orderNo = x.orderNo
WHERE 
paymentDate > DATEADD(DD,  -180, GETDATE())
AND paymentDate < (SELECT TOP 1 transactionDateTime
									FROM tblChaseTransactions
									WHERE transactionDateTime IS NOT NULL
									ORDER BY transactionDateTime DESC)
AND x.orderNo IS NULL
ORDER BY paymentDate DESC