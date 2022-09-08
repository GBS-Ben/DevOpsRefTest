CREATE PROCEDURE [dbo].[usp_insertTransactions]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/3/14
-- Purpose     updates transactional data from Chase.
-------------------------------------------------------------------------------
-- Modification History
--
-- 08/03/14	new, jf
-- 12/14/17	updated, jf
-- 10/14/21	fixing missing zeroes in orderno (at top of proc)
-------------------------------------------------------------------------------
SET NOCOUNT ON;

BEGIN TRY
--//////////////////////////////////////////////////////////// GET NEW CHASE TRANSACTIONS
--PERFORM INITIAL SCRUB OF DATA
UPDATE tblChaseInbound
SET authCode = ''
WHERE authCode IS NULL

UPDATE tblChaseInbound
SET orderNo = case 
	when left(orderNo,8) = '00000000' then REPLACE(orderNo, '00000000', '')
	when left(orderNo,7) = '0000000' then REPLACE(orderNo, '0000000', '')
	when left(orderNo,6) = '000000' then REPLACE(orderNo, '000000', '')
	when left(orderNo,5) = '00000' then REPLACE(orderNo, '00000', '')
	when left(orderNo,4) = '0000' then REPLACE(orderNo, '0000', '')
	when left(orderNo,3) = '000' then REPLACE(orderNo, '000', '')
	when left(orderNo,2) = '00' then REPLACE(orderNo, '00', '')
	when left(orderNo,1) = '0' then REPLACE(orderNo, '0', '')
	when charindex('-',orderNo) > 0 then substring(orderNo,charindex('-',orderNo)+1,len(orderNo)) 
	else orderNo end

-- Fixing missing zeroes in orderNo code, jf 14OCT21
UPDATE tblChaseInbound
SET orderNo = RIGHT(customData, 10)
WHERE LEN(orderNo) < LEN(customData)
AND transactionDateTime > GETDATE()-75
AND customData LIKE '%-MRK%'
AND orderNo <> RIGHT(customData, 10)

--UPDATE tblChaseInbound
--SET rowID = seqNo + '_' + authCode + '_' + orderNo + '_' + CONVERT(nVARCHAR(255), amount)

UPDATE tblChaseInbound
SET rowID = batchNumber + '_' + seqNo + '_' + orderNo + '_' + CONVERT(nVARCHAR(255), amount)

UPDATE tblChaseTransactions
SET authCode = b.authCode
FROM tblChaseTransactions a
INNER JOIN tblChaseInbound b
	ON a.orderNo = b.orderNo
WHERE a.seqNo = b.seqNo
AND a.amount = b.amount
AND (a.authCode IS NULL OR a.authCode = '' OR a.authCode = ' ')
AND b.authCode IS NOT NULL
AND b.authCode <> ''
AND b.authCode <> ' '

--SELECT DISTINCT FRESH RECORDS INTO tblChaseTransactions
INSERT INTO tblChaseTransactions
(batchNumber, merchantName, transactionDateTime, reportingMerchantNo, batchClose, seqNo, cardType, cardHolderNo, expDate, authCode, entryMode, termOPID, transactionType, recordType, amount, currency, legacyTermID, PNSMerchNo, [sys], totalTime, orderNo, customData, routingNo, rowID)
SELECT DISTINCT batchNumber, merchantName, transactionDateTime, reportingMerchantNo, batchClose, seqNo, cardType, cardHolderNo, expDate, authCode, entryMode, termOPID, transactionType, recordType, amount, currency, legacyTermID, PNSMerchNo, [sys], totalTime, orderNo, customData, routingNo, rowID
FROM tblChaseInbound
WHERE rowID NOT IN
(SELECT DISTINCT rowID 
FROM tblChaseTransactions 
WHERE rowID IS NOT NULL)
and batchClose >= '2020-12-01 00:00:00.000'

-- Fixing missing zeroes in orderNo code, jf 14OCT21
UPDATE tblChaseTransactions
SET orderNo = RIGHT(customData, 10)
WHERE LEN(orderNo) < LEN(customData)
AND transactionDateTime > GETDATE()-75
AND customData LIKE '%-MRK%'
AND orderNo <> RIGHT(customData, 10)

--INSERT composite key used in differential insert above to prevent INSERT on following run of this SPROC
-- (A)
INSERT INTO tblTransactions_CompositeKey (orderNo, compositeKey)
SELECT DISTINCT 
orderNo,
a.orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime))  + '.' + CONVERT(VARCHAR(50), amount)
FROM tblChaseTransactions a
WHERE orderNo IS NOT NULL
AND transactionDateTime IS NOT NULL
AND amount IS NOT NULL
AND a.orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime))  + '.' + CONVERT(VARCHAR(50), amount)
NOT IN
 (SELECT DISTINCT compositeKey
 FROM tblTransactions_CompositeKey
 WHERE compositeKey IS NOT NULL)

-- offset -1 second
-- (B)
INSERT INTO tblTransactions_CompositeKey (orderNo, compositeKey)
SELECT DISTINCT 
orderNo,
a.orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime)-1)  + '.' + CONVERT(VARCHAR(50), amount)
FROM tblChaseTransactions a
WHERE orderNo IS NOT NULL
AND transactionDateTime IS NOT NULL
AND amount IS NOT NULL
AND a.orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime)-1)  + '.' + CONVERT(VARCHAR(50), amount)
NOT IN
 (SELECT DISTINCT compositeKey
 FROM tblTransactions_CompositeKey
 WHERE compositeKey IS NOT NULL)

-- offset +1 second
-- (C)
INSERT INTO tblTransactions_CompositeKey (orderNo, compositeKey)
SELECT DISTINCT 
orderNo,
a.orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime)+1)  + '.' + CONVERT(VARCHAR(50), amount)
FROM tblChaseTransactions a
WHERE orderNo IS NOT NULL
AND transactionDateTime IS NOT NULL
AND amount IS NOT NULL
AND a.orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime)+1)  + '.' + CONVERT(VARCHAR(50), amount)
NOT IN
 (SELECT DISTINCT compositeKey
 FROM tblTransactions_CompositeKey
 WHERE compositeKey IS NOT NULL)

-- create key for records that have value in authCode (ideally, this is what we want to use solely going forward, however, this field is sporatic and often contains NULL values.
-- (D)
INSERT INTO tblTransactions_CompositeKey (orderNo, compositeKey)
SELECT DISTINCT 
orderNo,
a.orderNo + '.' + SUBSTRING(authCode, PATINDEX('%[^0]%', authCode+'.'), LEN(authCode)) + '.' + CONVERT(VARCHAR(50), amount)
FROM tblChaseTransactions a
WHERE orderNo IS NOT NULL
AND transactionDateTime IS NOT NULL
AND amount IS NOT NULL
AND authCode IS NOT NULL
AND a.orderNo + '.' + SUBSTRING(authCode, PATINDEX('%[^0]%', authCode+'.'), LEN(authCode)) + '.' + CONVERT(VARCHAR(50), amount)
NOT IN
 (SELECT DISTINCT compositeKey
 FROM tblTransactions_CompositeKey
 WHERE compositeKey IS NOT NULL)


----// Delete inbound data for this run
--TRUNCATE TABLE tblChaseInbound

--//////////////////////////////////////////////////////////// TBLTRANSACTIONS FROM HERE ON OUT

--//Clean responseOrderNo field where necessary.
UPDATE tblTransactions
SET responseOrderNo = REPLACE(responseOrderNo, '	', '')
WHERE responseOrderNo LIKE '%	%'

UPDATE tblTransactions
SET responseOrderNo = REPLACE(responseOrderNo, ' ', '')
WHERE responseOrderNo LIKE '% %'

--UPDATE rows in tblTransactions with verification statuses
-- "M" -------------------------------------
UPDATE tblTransactions
SET verify = 'MV'
WHERE 
verify = 'M'
AND orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, paymentDate)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, paymentDate))  + '.' + CONVERT(VARCHAR(50), paymentAmount) 
IN --time diffs
	(SELECT DISTINCT compositeKey
	FROM tblTransactions_CompositeKey
	WHERE compositeKey IS NOT NULL)
OR
verify = 'M'
AND orderNo + '.' + SUBSTRING(responseOrderNo, PATINDEX('%[^0]%', responseOrderNo+'.'), LEN(responseOrderNo)) + '.' + CONVERT(VARCHAR(50), paymentAmount) 
IN --authCode
	(SELECT DISTINCT compositeKey
	FROM tblTransactions_CompositeKey
	WHERE compositeKey IS NOT NULL)

-- "S" --------------------------------------
UPDATE tblTransactions
SET verify = 'SV'
WHERE 
verify = 'S'
AND orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, paymentDate)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, paymentDate))  + '.' + CONVERT(VARCHAR(50), paymentAmount) 
IN --time diffs
	(SELECT DISTINCT compositeKey
	FROM tblTransactions_CompositeKey
	WHERE compositeKey IS NOT NULL)

OR
verify = 'S'
AND orderNo + '.' + SUBSTRING(responseOrderNo, PATINDEX('%[^0]%', responseOrderNo+'.'), LEN(responseOrderNo))  + '.' + CONVERT(VARCHAR(50), paymentAmount) 
IN --authCode
	(SELECT DISTINCT compositeKey
	FROM tblTransactions_CompositeKey
	WHERE compositeKey IS NOT NULL)

--UPDATE rows in tblChaseTransactions with verification statuses
UPDATE tblChaseTransactions
SET verified = 1
WHERE 
verified <> 1
AND
(	orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime))  + '.' + CONVERT(VARCHAR(50),			
	amount) 
		IN -- (TIME exact)
		(SELECT DISTINCT compositeKey
		FROM tblTransactions_CompositeKey
		WHERE compositeKey IS NOT NULL)
	OR 
	orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime)-1)  + '.' + CONVERT(VARCHAR(50),		
	amount)
		IN -- (TIME -1)
			(SELECT DISTINCT compositeKey
			FROM tblTransactions_CompositeKey
			WHERE compositeKey IS NOT NULL)
	OR 
	orderNo + '.' + CONVERT(VARCHAR(255), DATEPART(MM, transactionDateTime)) + '.' + CONVERT(VARCHAR(255), DATEPART(SS, transactionDateTime)+1)  + '.' + CONVERT(VARCHAR(50), 
	amount)
		IN -- (TIME +1)
			(SELECT DISTINCT compositeKey
			FROM tblTransactions_CompositeKey
			WHERE compositeKey IS NOT NULL)
	OR
	orderNo + '.' + SUBSTRING(authCode, PATINDEX('%[^0]%', authCode+'.'), LEN(authCode))  + '.' + CONVERT(VARCHAR(50), amount) 
		IN -- (NO TIME, authCode)
			(SELECT DISTINCT compositeKey
			FROM tblTransactions_CompositeKey
			WHERE compositeKey IS NOT NULL)
)
AND orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblTransactions
	WHERE verify = 'SV'
	OR verify = 'MV')

	END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH