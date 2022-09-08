CREATE PROC [dbo].[GetEOM_backupCKB]
@month INT,
@year INT

AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     8/6/07
Purpose     Retrieves End of Month (EOM) report for Accounting.
Example		EXEC [GetEOM] '10', '2020' 
-------------------------------------------------------------------------------------
Modification History

12/04/15		Added secondary insert code near bottom, jf.
12/04/15		Add (AND z.authCode <> '') near LN80 to help remove duplicates, jf.
05/01/16		added tblOrders.billingReference, jf.
04/12/17		updated sproc to look at batchClose for date operations vs transactionDateTime, jf.
11/14/18		updated to look at customers_shippingAddress rather than tblOrders, for shipping information, jf
11/14/18		other code cleaned up, jf
06/04/19		separated MBPO values, jf.
05/12/21		updated RIGHT(z.customData, 10), jf.
-------------------------------------------------------------------------------------
*/
--Chase Transactions
TRUNCATE TABLE tblEOM_Bouncer
INSERT INTO tblEOM_Bouncer (storeID, [NO MATCH], transactionDateTime, orderNo, shipping_zip, goToState, subTotal, shipTotal, 
taxTotal, taxDescription, amount, calcOrderTotal, calcTransTotal, displayPaymentStatus, orderStatus, seqNo, cardType, cardHolderNo, 
expDate, authCode, entryMode, termOPID, transactionType, customerID, billingName, billing_Company, billing_street, billing_Suburb, 
billing_State, billing_postCode, billing_Phone, shippingName, shipping_Company, shipping_street, shipping_Suburb, shipping_State, 
shipping_postCode, shipping_Phone, email, batchNumber, batchClose, customData, orderID, rowID, rowSource, billingReference, calcProducts, calcOPPO, calcVouchers, calcCredits)

SELECT DISTINCT 'storeID'  =
CASE a.storeID
    WHEN '2' THEN 'HOM' 
    WHEN '4' THEN 'NCC'
    WHEN '3' THEN 'ADH'
    WHEN '5' THEN 'CMC'
    ELSE 'GBS'
END,
' ' AS 'NO MATCH', 
CONVERT(SMALLDATETIME, z.transactionDateTime) AS 'transactionDateTime',
a.orderNo, 
SUBSTRING(s.shipping_postCode, 1, 5) AS 'shipping_zip', 
s.shipping_State AS 'goToState',
a.calcProducts + a.calcOppo - a.calcVouchers AS 'subTotal',
a.shippingAmount AS 'shipTotal',
a.taxAmountAdded AS 'taxTotal',
CASE WHEN a.taxDescription LIKE '%exempt%' THEN 'Exempt'
	 ELSE ''
END AS 'taxDescription',
CONVERT(MONEY, z.amount) AS 'amount',
a.calcOrderTotal,
a.calcTransTotal,
a.displayPaymentStatus,
a.orderStatus,
z.seqNo, z.cardType, z.cardHolderNo, z.expDate, 
z.authCode, z.entryMode, z.termOPID, z.transactionType,
a.customerID, 
REPLACE(a.billing_firstName + ' ' + a.billing_surName, '  ', ' ') AS 'billingName',
a.billing_Company, a.billing_street, a.billing_Suburb, a.billing_State, a.billing_postCode, a.billing_Phone, 
REPLACE(s.shipping_firstName + ' ' + s.shipping_surName, '  ', ' ') AS 'shippingName',
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
c.email, z.batchNumber, z.batchClose,
CASE
	WHEN LEN(z.customData) IN (9,10) AND RIGHT(z.customData, 10) LIKE 'HOM%' THEN ' '
	ELSE z.customData
END AS 'customData',
a.orderID, z.rowID,
'1' AS 'source',
REPLACE(REPLACE(a.billingReference, CHAR(13), ' '), CHAR(10), ' ') AS 'billingReference',
a.calcProducts, a.calcOPPO, a.calcVouchers, a.calcCredits
FROM tblOrders a 
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblChaseTransactions z ON a.orderNo = REPLACE(z.orderNo, '000000', '')
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
WHERE DATEPART(mm, z.batchClose) = @month
AND DATEPART(yyyy, z.batchClose) = @year
AND z.authCode <> ''
GROUP BY
a.storeID, z.transactionDateTime, a.orderNo,
a.orderTotal, a.taxAmountAdded, a.shippingAmount, a.calcVouchers, a.calcCredits,
a.taxDescription,
a.calcOrderTotal,
a.calcTransTotal,
a.calcProducts, a.calcOppo,
a.displayPaymentStatus,
a.orderStatus, z.amount,
z.seqNo, z.cardType, z.cardHolderNo, z.expDate, 
z.authCode, z.entryMode, z.termOPID, z.transactionType,
a.customerID, a.billing_firstName, a.billing_surName,
a.billing_Company, a.billing_street, a.billing_Suburb, a.billing_State, a.billing_postCode, a.billing_Phone, 
s.shipping_firstName, s.shipping_surName,
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
c.email, z.batchNumber, z.batchClose, z.customData, z.rowID, a.orderID, a.billingReference,
a.calcProducts, a.calcOPPO, a.calcVouchers, a.calcCredits

UNION

--Intranet manual transactions (non-chase, non-web)
SELECT 'storeID'  =
CASE a.storeID
    WHEN '2' THEN 'HOM' 
    WHEN '4' THEN 'NCC'
    WHEN '3' THEN 'ADH'
    WHEN '5' THEN 'CMC'
    ELSE 'GBS'
END,
' ' AS 'NO MATCH', 
CONVERT(SMALLDATETIME, a.orderDate) AS 'transactionDateTime',
a.orderNo, SUBSTRING(s.shipping_postCode, 1, 5) AS 'shipping_zip', 
s.shipping_State AS 'goToState',
a.calcProducts + a.calcOppo - a.calcVouchers AS 'subTotal',
a.shippingAmount AS 'shipTotal',
a.taxAmountAdded AS 'taxTotal',
CASE WHEN a.taxDescription LIKE '%exempt%' THEN 'Exempt'
	 ELSE ''
END AS 'taxDescription',
CONVERT(MONEY, a.orderTotal) AS 'amount',
a.calcOrderTotal,
a.calcTransTotal,
a.displayPaymentStatus,
a.orderStatus,
'','','','','','','','',
a.customerID, 
REPLACE(a.billing_firstName + ' ' + a.billing_surName, '  ', ' ') AS 'billingName',
a.billing_Company, a.billing_street, a.billing_Suburb, a.billing_State, a.billing_postCode, a.billing_Phone, 
REPLACE(s.shipping_firstName + ' ' + s.shipping_surName, '  ', ' ') AS 'shippingName',
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
c.email, '','',
'' AS 'customData',
a.orderID, '',
'2' AS 'source',
REPLACE(REPLACE(a.billingReference, CHAR(13), ' '), CHAR(10), ' ') AS 'billingReference',
a.calcProducts, a.calcOPPO, a.calcVouchers, a.calcCredits
FROM tblOrders a 
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
WHERE DATEPART(mm, a.orderDate) = @month
AND DATEPART(yyyy, a.orderDate) = @year
AND a.paymentMethodID IN (8,9)
GROUP BY
a.storeID, a.orderDate, a.orderNo,
a.orderTotal, a.taxAmountAdded, a.shippingAmount, a.calcVouchers, a.calcCredits,
a.taxDescription,
a.calcOrderTotal,
a.calcTransTotal,
a.calcProducts, a.calcOppo,
a.displayPaymentStatus,
a.orderStatus, a.orderTotal,
a.customerID, a.billing_firstName, a.billing_surName,
a.billing_Company, a.billing_street, a.billing_Suburb, a.billing_State, a.billing_postCode, a.billing_Phone, 
s.shipping_firstName, s.shipping_surName,
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
c.email, a.orderID, a.billingReference,
a.calcProducts, a.calcOPPO, a.calcVouchers, a.calcCredits

--Secondary insert of those tranx that do not have authCodes.
INSERT INTO tblEOM_Bouncer (storeID, [NO MATCH], transactionDateTime, orderNo, shipping_zip, goToState, subTotal, shipTotal, 
taxTotal, taxDescription, amount, calcOrderTotal, calcTransTotal, displayPaymentStatus, orderStatus, seqNo, cardType, cardHolderNo, 
expDate, authCode, entryMode, termOPID, transactionType, customerID, billingName, billing_Company, billing_street, billing_Suburb, 
billing_State, billing_postCode, billing_Phone, shippingName, shipping_Company, shipping_street, shipping_Suburb, shipping_State, 
shipping_postCode, shipping_Phone, email, batchNumber, batchClose, customData, orderID, rowID, rowSource, billingReference, calcProducts, calcOPPO, calcVouchers, calcCredits)

SELECT DISTINCT 'storeID'  =
CASE a.storeID
    WHEN '2' THEN 'HOM' 
    WHEN '4' THEN 'NCC'
    WHEN '3' THEN 'ADH'
    WHEN '5' THEN 'CMC'
    ELSE 'GBS'
END,
' ' AS 'NO MATCH', 
CONVERT(SMALLDATETIME, z.transactionDateTime) AS 'transactionDateTime',
a.orderNo, 
SUBSTRING(s.shipping_postCode, 1, 5) AS 'shipping_zip', 
s.shipping_State AS 'goToState',
a.calcProducts + a.calcOppo - a.calcVouchers AS 'subTotal',
a.shippingAmount AS 'shipTotal',
a.taxAmountAdded AS 'taxTotal',
CASE
	WHEN a.taxDescription LIKE '%exempt%' THEN 'Exempt'
	ELSE ''
END AS 'taxDescription',
CONVERT(MONEY, z.amount) AS 'amount',
a.calcOrderTotal,
a.calcTransTotal,
a.displayPaymentStatus,
a.orderStatus,
z.seqNo, z.cardType, z.cardHolderNo, z.expDate, 
z.authCode, z.entryMode, z.termOPID, z.transactionType,
a.customerID, 
REPLACE(a.billing_firstName + ' ' + a.billing_surName, '  ', ' ') AS 'billingName',
a.billing_Company, a.billing_street, a.billing_Suburb, a.billing_State, a.billing_postCode, a.billing_Phone, 
REPLACE(s.shipping_firstName + ' ' + s.shipping_surName, '  ', ' ') AS 'shippingName',
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
c.email, z.batchNumber, z.batchClose,
CASE
	WHEN LEN(z.customData) IN (9,10) AND RIGHT(z.customData, 10) LIKE 'HOM%' THEN ' '
	ELSE z.customData
END AS 'customData',
a.orderID, z.rowID,
'1' AS 'source',
REPLACE(REPLACE(a.billingReference, CHAR(13), ' '), CHAR(10), ' ') AS 'billingReference',
a.calcProducts, a.calcOPPO, a.calcVouchers, a.calcCredits
FROM tblOrders a 
INNER JOIN tblCustomers c ON a.customerID = c.customerID
INNER JOIN tblChaseTransactions z ON a.orderNo = z.orderNo
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
WHERE DATEPART(mm, z.batchClose) = @month
AND DATEPART(yyyy, z.batchClose) = @year
AND z.authCode = ''
AND CONVERT(VARCHAR(10), z.seqNo) + '_' + CONVERT(VARCHAR(20), z.amount) + '_' + a.orderNo
NOT IN
	(SELECT CONVERT(VARCHAR(10), seqNo) + '_' + CONVERT(VARCHAR(20), amount) + '_' + orderNo
	FROM tblEOM_Bouncer
	WHERE authCode <> '')
GROUP BY
a.storeID, z.transactionDateTime, a.orderNo,
a.orderTotal, a.taxAmountAdded, a.shippingAmount, a.calcVouchers, a.calcCredits,
a.taxDescription,
a.calcOrderTotal,
a.calcTransTotal,
a.calcProducts, a.calcOppo,
a.displayPaymentStatus,
a.orderStatus, z.amount,
z.seqNo, z.cardType, z.cardHolderNo, z.expDate, 
z.authCode, z.entryMode, z.termOPID, z.transactionType,
a.customerID, a.billing_firstName, a.billing_surName,
a.billing_Company, a.billing_street, a.billing_Suburb, a.billing_State, a.billing_postCode, a.billing_Phone, 
s.shipping_firstName, s.shipping_surName,
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
c.email, z.batchNumber, z.batchClose, z.customData, z.rowID, a.orderID, a.billingReference,
a.calcProducts, a.calcOPPO, a.calcVouchers, a.calcCredits

--Update ADH shipping information
UPDATE e
SET shippingName = b.shipping_FullName, 
shipping_Company = b.shipping_company, 
shipping_street = b.shipping_street, 
shipping_Suburb = b.shipping_suburb, 
shipping_State = b.shipping_state, 
shipping_postCode = SUBSTRING(b.shipping_postCode, 1, 5), 
shipping_Phone = b.shipping_phone,
shipping_zip = SUBSTRING(b.shipping_postCode, 1, 5), 
goToState = b.shipping_state
FROM tblEOM_Bouncer e
INNER JOIN tblCustomers_ShippingAddress b ON e.orderNo = b.orderNo
WHERE SUBSTRING(e.orderNo, 1, 3) = 'ADH'

--monthly billing / purchase orders
UPDATE e
SET batchNumber = 'MB'
FROM tblEOM_Bouncer e
INNER JOIN tblOrders a ON e.orderNo = a.orderNo
WHERE a.paymentMethod = 'Monthly Billing'

UPDATE e
SET batchNumber = 'PO'
FROM tblEOM_Bouncer e
INNER JOIN tblOrders a ON e.orderNo = a.orderNo
WHERE SUBSTRING(a.paymentMethod, 1, 14) = 'Purchase Order'

--(1/2) fix shipping zips to remove stuff like "Don't Ship" from the zipcode field 
UPDATE e
SET shipping_postCode = o.shipping_postCode
FROM tblEOM_Bouncer e
INNER JOIN tblOrders o ON e.orderNo = o.orderNo
WHERE e.shipping_postCode LIKE '%[a-z]%'
AND o.shipping_postCode NOT LIKE '%[a-z]%'

--(2/2)
UPDATE e
SET shipping_postCode = a.ZipPostalCode
FROM sql01.nopCommerce.dbo.[address] a
INNER JOIN sql01.nopCommerce.dbo.customer c ON c.ShippingAddress_ID = a.ID
INNER JOIN sql01.nopCommerce.dbo.[order] o ON o.CustomerID = c.ID
INNER JOIN tblOrders x ON o.ID = x.orderID - 555444333
INNER JOIN tblEOM_Bouncer e ON e.orderNo = x.orderNo
WHERE  (e.shipping_postCode LIKE '%[a-z]%' OR e.shipping_postCode = '' OR e.shipping_postCode = ' ')

UPDATE e
SET shipping_zip = SUBSTRING(ISNULL(e.shipping_postCode, ''), 1, 5)
FROM tblEOM_Bouncer e
WHERE ISNULL(e.shipping_zip, '') <> SUBSTRING(ISNULL(e.shipping_postCode, ''), 1, 5)

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Retrieve records
SELECT storeID, [NO MATCH], transactionDateTime, orderNo, shipping_zip, goToState, subTotal, shipTotal, taxTotal, taxDescription, amount, calcOrderTotal, 
calcTransTotal, displayPaymentStatus, orderStatus, seqNo, cardType, cardHolderNo, expDate, authCode, entryMode, termOPID, transactionType, customerID, billingName, 
billing_Company, billing_street, billing_Suburb, billing_State, billing_postCode, billing_Phone, shippingName, shipping_Company, shipping_street, shipping_Suburb, 
shipping_State, shipping_postCode, shipping_Phone, email, batchNumber, batchClose, customData, orderID, rowID, rowSource, billingReference, calcProducts, calcOPPO, calcVouchers, calcCredits
FROM tblEOM_Bouncer
ORDER BY batchNumber, transactionDateTime

--Missing transactions
SELECT '?', 'Yes', 
CONVERT(SMALLDATETIME, z.transactionDateTime) AS 'transactionDateTime', 
REPLACE(z.orderNo,'000000', ''), 
'', '', 
'','','','', 
CONVERT(MONEY,z.amount),  '','','','',
z.seqNo, z.cardType, z.cardHolderNo, z.expDate, 
z.authCode, z.entryMode, z.termOPID, z.transactionType,
'',
'', '', '', '', '', '', 
'',
'', '', '', '', '', '', 
'', '', z.batchNumber, z.batchClose, z.customData,
'', z.rowID
,CONVERT(VARCHAR(10), z.seqNo) + '_' + CONVERT(VARCHAR(20), z.amount) + '_' + z.orderNo
FROM tblChaseTransactions z 
WHERE DATEPART(mm, z.batchClose) = @month
AND DATEPART(yyyy, z.batchClose) = @year
AND rowID NOT IN 
	(SELECT rowID 
	FROM tblEOM_Bouncer 
	WHERE rowID IS NOT NULL)
AND CONVERT(VARCHAR(10), z.seqNo) + '_' + CONVERT(VARCHAR(20), z.amount) + '_' + z.orderNo
NOT IN
	(SELECT CONVERT(VARCHAR(10), seqNo) + '_' + CONVERT(VARCHAR(20), amount) + '_' + orderNo
	FROM tblEOM_Bouncer
	WHERE authCode <> '')
ORDER BY z.transactionDateTime

--Checks
SELECT DISTINCT 'storeID' =
CASE o.storeID
    WHEN '2' THEN 'HOM'
    WHEN '4' THEN 'NCC'
    WHEN '3' THEN 'ADH'
    WHEN '5' THEN 'CMC'
    ELSE 'GBS'
END,
' ' AS 'NO MATCH',
o.orderDate, o.orderNo, 
SUBSTRING(s.shipping_postCode, 1, 5), 
s.shipping_State,
o.calcProducts + o.calcOppo - o.calcVouchers AS 'subTotal',
o.shippingAmount AS 'shipTotal', o.taxAmountAdded AS 'taxTotal',
CASE WHEN o.taxDescription LIKE '%exempt%' THEN 'Exempt'
	 ELSE ''
END,
o.orderTotal as 'amount',
o.calcOrderTotal AS 'calcOrderTotal',
o.calcTransTotal AS 'calcTransTotal',
o.displayPaymentStatus AS 'displayPaymentStatus',
o.orderStatus AS 'orderStatus',
'', '', '', '', 
'', '', '', '',
o.customerID, 
k.firstName + ' ' + k.surName AS 'billingName',
k.Company, k.street, k.Suburb, k.[State], k.postCode, k.Phone, 
REPLACE(s.shipping_firstName + ' ' + s.shipping_surName, '  ', ' ') AS 'shippingName',
s.shipping_Company, s.shipping_street, s.shipping_Suburb, s.shipping_State, s.shipping_postCode, s.shipping_Phone, 
k.email, '', '', '', o.orderID,
c.amount AS 'check_amount', c.method AS 'entry_type',
c.inputDate AS 'date_check_entered', c.checkNumber AS 'check_number',
c.pkid AS 'check_pkid',
o.calcProducts, o.calcOPPO, o.calcVouchers, o.calcCredits
FROM tbl_checks c 
INNER JOIN tblOrders o ON o.orderNo = c.jobNumber
INNER JOIN tblCustomers k ON o.customerID = k.customerID
INNER JOIN tblCustomers_ShippingAddress s ON o.orderNo = s.orderNo
WHERE DATEPART(mm, c.inputDate) = @month
AND DATEPART(yy, c.inputDate) = @year
ORDER BY c.inputDate

--WIP
SELECT a.orderNo, a.orderDate, b.paymentDate, a.orderStatus, a.orderTotal,
SUM(b.paymentAmount) AS 'amountReceived', b.paymentType, b.responseCode
FROM tblOrders a 
INNER JOIN tblTransactions b ON a.orderNo = b.orderNo
WHERE a.orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered', 'In Transit', 'In Transit USPS', 'MIGZ')
AND b.deleteX <> 'Yes'
GROUP BY a.orderNo, a.orderDate, b.paymentDate, a.orderStatus, a.orderTotal, b.paymentType, b.responseCode
ORDER BY a.orderDate DESC



/*
;WITH CTE 
AS
(SELECT DISTINCT orderNo FROM tblOrders WHERE orderNo IN --grab all ordernos from eom for this month.
(right here))

SELECT DISTINCT o.orderNo, o.orderDate, o.orderTotal, o.orderStatus, o.paymentMethod
FROM tblOrders o
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(mm, o.orderDate) = 05
AND DATEPART(yyyy, o.orderDate) = 2020
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM cte
	WHERE o.orderNo = cte.orderNo)
*/