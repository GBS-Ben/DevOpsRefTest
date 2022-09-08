
CREATE PROCEDURE [dbo].[usp_NewModBadges]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/20/10
Purpose     Preps badge data for IMAGE/IMPO.
-------------------------------------------------------------------------------
Modification History

03/14/17		Rewrite for performance. Old code found at: [dbo].[usp_badges_archiveAsOf_031417_01]
07/16/18		Removed fastTrak_productType sections (2 of them), jf.
07/20/18		Added the following line to the initial query: [AND (a.optionCaption LIKE 'Name:%' OR a.optionCaption LIKE 'Agent Name:%')]; jf.
07/24/18		Reverted above, jf.
12/26/18		Rewrite Badges to perform better, jf.
02/04/19		JF, Added optionCaption variants to intake NOP OPIDs because whoever set the templates up decided to make different optionCaption field names. :/
					(z.optionCaption LIKE 'Name:%' OR z.optionCaption = 'Agent Name')
					(k.optionCaption LIKE 'Title:%' OR k.optionCaption = 'Customer Title')
					(optionCaption LIKE '%Title2:%' OR optionCaption = 'Customer Title 2')
02/05/19		JF, trunc'd tblBadges, it was corrupt. Added textValue omits in first query.
02/14/19		JF, I had to change "AGENT NAME" check from an "=" to a LIKE statement because whoever is creating these badge templates loves colons and hates me.
05/03/19		JF, updated initial query to this [AND DATEDIFF(DD, o.orderDate, GETDATE()) < 180] from the @lastrun business b/c badges where getting left behind on SSIS errors.
06/06/19		BS, Added temp table check prior to all drops
04/17/19		JF added code to intial statement to prevent shaped badges from being brought in. (AND SUBSTRING(op.productCode, 5, 2) <> 'CS')
06/08/20		Added this where necessary: 
					UPDATE tblBadges
					SET X = REPLACE(X,'&#237','í')
04/27/21		CKB, Markful
07/14/21		JF, added logging; changed init date range to 90 days from 365.
-------------------------------------------------------------------------------
*/

SET NOCOUNT ON;

BEGIN TRY
--/////////////////////////////////////////////////////////////////////////////////////////////////////// DATA ACQUIRE BEGIN
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Get timestamp of last successful run of this sproc
DECLARE @LastRun DATETIME2 = GETDATE()
SET @LastRun = (SELECT TOP 1 LastRun FROM BadgeLog)

INSERT INTO logBadges (logValue, logTime) SELECT 'A - Begin Log', GETDATE()

--Create temp table that will house all OPIDs upserted post @LastRun
IF OBJECT_ID('tempdb..#NewModBadges') IS NOT NULL DROP TABLE #NewModBadges				
CREATE TABLE #NewModBadges (
		RowID INT IDENTITY(1, 1) 
		,sortNo INT
		,Contact NVARCHAR(255)
		,Title NVARCHAR(255)
		,RO NVARCHAR(50)
		,orderNo NVARCHAR(50)
		,orderID INT
		,OPID INT
		,productCode NVARCHAR(255))

--Only upsert records
INSERT INTO #NewModBadges (sortNo, Contact, Title, RO, orderNo, orderID, OPID, productCode)
SELECT 
'9999999' AS 'sortNo',
oppo.textValue AS 'Contact', 
'' AS 'Title',
'RO' AS 'RO',
o.orderNo AS 'orderNo',
o.orderID AS 'orderID',
oppo.ordersProductsID,
op.productCode
FROM tblOrdersProducts_productOptions oppo 
INNER JOIN tblOrders_Products op 
	ON oppo.ordersProductsID = op.[ID]
INNER JOIN tblOrders o
	ON op.orderID = o.orderID
WHERE 
o.orderStatus NOT IN ('failed', 'cancelled', 'waiting for payment')
AND SUBSTRING(op.productCode, 1, 2) = 'NB'
AND SUBSTRING(op.productCode, 3, 2) <> 'CU'
AND SUBSTRING(op.productCode, 5, 2) <> 'CS' --CUSTOM SHAPE; THESE ARE NOT FASTRACKED
AND op.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND op.deleteX <> 'yes'
AND oppo.deleteX <> 'yes'
AND (oppo.optionCaption LIKE 'Name%' OR oppo.optionCaption LIKE 'Agent Name%')
AND DATEDIFF(DD, o.orderDate, GETDATE()) < 90
AND oppo.textValue NOT LIKE '%spread%'
AND oppo.textValue NOT LIKE '%excel%'

-- Populate tblBadges:
TRUNCATE TABLE tblBadges
INSERT INTO tblBadges (sortNo, Contact, Title, RO, orderNo, orderID, OPPO_ordersProductsID, productCode, NewModBadge)
SELECT sortNo, Contact, Title, RO, orderNo, orderID, OPID, productCode, 1
FROM #NewModBadges

--///////////////////////////////////////////////////////////////////////////////////////////////////////// DATA CLEAN BEGIN
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
INSERT INTO logBadges (logValue, logTime) SELECT 'B', GETDATE()

--TITLE (if it exists for given OPID)
UPDATE a
SET title = oppo.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPPO_ordersProductsID = oppo.ordersProductsID
WHERE (oppo.optionCaption LIKE 'Title:%' OR oppo.optionCaption = 'Customer Title')
AND oppo.deleteX <> 'yes'
AND a.NewModBadge = 1
	
--RO
UPDATE a
SET RO = REPLACE(SUBSTRING(op.productCode, 5, 1), '#', '')
FROM tblBadges a 
INNER JOIN tblOrders_Products op ON a.OPPO_ordersProductsID = op.[ID]
WHERE SUBSTRING(op.productCode, 5, 2) IN ('OV', 'OG', 'OS', 'OB', 'OF', 'RC', 'RB', 'RG', 'RS', 'RF')
AND a.NewModBadge = 1

UPDATE tblBadges
SET RO = 'R'
WHERE RO = 'RO'

--BKGND
UPDATE a
SET BKGND = SUBSTRING(op.productCode, 1, 10)
FROM tblBadges a  
INNER JOIN tblOrders_Products op ON a.OPPO_ordersProductsID = op.[ID]
WHERE LEN(op.productCode) = 14
AND a.NewModBadge = 1

--BKGND part 2
UPDATE a
SET BKGND = SUBSTRING(op.productCode,1,20)
FROM tblBadges a  
INNER JOIN tblOrders_Products op ON a.OPPO_ordersProductsID = op.[ID]
WHERE LEN(op.productCode) = 20
AND a.NewModBadge = 1

INSERT INTO logBadges (logValue, logTime) SELECT 'C', GETDATE()

--TITLE FIELD
UPDATE tblBadges
SET title = REPLACE(title,'&#174;','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#174','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'(R)','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&amp;','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&amp','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&quot;','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&quot','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#233;','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#233','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#241;','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#241','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#237;','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#237','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#211;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#243;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#211','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'&#243','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'realtor','REALTOR')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR-Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR - Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR','REALTOR®')
WHERE title NOT LIKE '%REALTOR-ASSOCIATE%'
AND NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'®®','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'®-',' ® -')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'-®',' - ®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,',',', ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET title = REPLACE(title,'  ',' ')
WHERE NewModBadge = 1

--contact FIELD
UPDATE tblBadges
SET contact = REPLACE(contact,'&#174;','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#174','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'(R)','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&amp;','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&amp','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&quot;','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&quot','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#233;','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#233','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#241;','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#241','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#237;','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#237','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#211;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#243;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#211','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'&#243','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'realtor','REALTOR')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR-Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR - Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR Associate','REALTOR-ASSOCIATE®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR','REALTOR®')
WHERE contact NOT LIKE '%REALTOR-ASSOCIATE%'
AND NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'®®','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'®-',' ® -')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'-®',' - ®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,',',', ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET contact = REPLACE(contact,'  ',' ')
WHERE NewModBadge = 1

INSERT INTO logBadges (logValue, logTime) SELECT 'D', GETDATE()

--COMPANY FIELDS
--first grab info input by customer, if present.
UPDATE a
SET COtext1 = oppo.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPPO_ordersProductsID = oppo.ordersProductsID
WHERE oppo.optionCaption LIKE 'Company:%'
AND oppo.deleteX <> 'yes'
AND a.NewModBadge = 1

UPDATE a
SET COtext1 = oppo.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPPO_ordersProductsID = oppo.ordersProductsID
WHERE (oppo.optionCaption LIKE '%Title2:%' OR oppo.optionCaption = 'Customer Title 2')
AND oppo.deleteX <> 'yes'
AND a.NewModBadge = 1

UPDATE a
SET COtext2 = oppo.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions oppo ON a.OPPO_ordersProductsID = oppo.ordersProductsID
WHERE oppo.optionCaption LIKE 'Company 2:%'
AND oppo.deleteX <> 'yes'
AND a.NewModBadge = 1

--now deal with any NULLS left over
UPDATE tblBadges
SET COtext1 = '' 
WHERE COtext1 IS NULL
AND NewModBadge = 1

UPDATE tblBadges
SET COtext2 = '' 
WHERE COtext2 IS NULL
AND NewModBadge = 1

--COtext1 FIELD
UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#174;','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#174','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'(R)','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&amp;','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&amp','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&quot;','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&quot','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#233;','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#233','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#241;','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#241','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#211;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#237;','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#237','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#243;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#211','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#243','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,',',', ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,' ,',',')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'remax','RE/MAX')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'Re/Max','RE/MAX')
WHERE NewModBadge = 1

--COtext2 FIELD
UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#174;','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#174','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'(R)','®')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&amp;','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&amp','&')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&quot;','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&quot','"')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#233;','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#233','é')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#241;','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#241','ñ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#237;','í')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#237','í')
WHERE NewModBadge = 1


UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#211;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#243;','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#211','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#243','Ó')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,',',', ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,' ,',',')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'remax','RE/MAX')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'Re/Max','RE/MAX')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtextAll = COtext1 + ' ' + COtext2
WHERE NewModBadge = 1

INSERT INTO logBadges (logValue, logTime) SELECT 'E', GETDATE()

--Now grab info from tblNameBadgeMaster if customer provided no data.
UPDATE a
SET COtext1 = b.COtext1
FROM tblBadges a
INNER JOIN tblNameBadgeMaster b ON SUBSTRING(a.productCode, 3, 2) = b.company
AND SUBSTRING(a.productCode, 12, 3) = b.officeNo
AND SUBSTRING(a.productCode, 12, 3) NOT IN ('100', '101')
AND b.COtext1 IS NOT NULL
AND b.company IS NOT NULL
AND b.officeNo IS NOT NULL
AND a.NewModBadge = 1

UPDATE a
SET COtext2 = b.COtext2
FROM tblBadges a
INNER JOIN tblNameBadgeMaster b ON SUBSTRING(a.productCode, 3, 2) = b.company
AND SUBSTRING(a.productCode, 12, 3) = b.officeNo
AND SUBSTRING(a.productCode, 12, 3) NOT IN ('100', '101')
AND b.COtext2 IS NOT NULL
AND b.company IS NOT NULL
AND b.officeNo IS NOT NULL
AND a.NewModBadge = 1

UPDATE a
SET COtextAll = b.COtextAll
FROM tblBadges a
INNER JOIN tblNameBadgeMaster b ON SUBSTRING(a.productCode, 3, 2) = b.company
AND SUBSTRING(a.productCode, 12, 3) = b.officeNo
AND SUBSTRING(a.productCode, 12, 3) NOT IN ('100', '101')
AND b.COtextAll IS NOT NULL
AND b.company IS NOT NULL
AND b.officeNo IS NOT NULL
AND a.NewModBadge = 1

--RE/MAX & PRUDENTIAL FIXES
UPDATE tblBadges
SET COtextAll = 'RE/MAX ' + COtextAll
WHERE SUBSTRING(BKGND, 3, 2) = 'RM' 
AND SUBSTRING(productCode, 12, 3) = '101'
AND COtextAll IS NOT NULL 
AND COtextAll <> '' 
AND COtextAll <> ' ' 
AND COtextAll <> '  '
AND NewModBadge = 1

UPDATE tblBadges
SET COtextAll = 'Prudential  ' + COtextAll
WHERE SUBSTRING(BKGND, 3, 2) = 'PR' 
AND SUBSTRING(productCode, 12, 3) = '101'
AND COtextAll IS NOT NULL 
AND COtextAll <> '' 
AND COtextAll <> ' ' 
AND COtextAll <> '  '
AND NewModBadge = 1

UPDATE tblBadges 
SET COtextAll = REPLACE(COtextAll,'RE/MAX RE/MAX','RE/MAX ')
WHERE NewModBadge = 1

UPDATE tblBadges 
SET COtextAll = REPLACE(COtextAll,'Prudential Prudential','Prudential ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtextAll = REPLACE(COtextAll,'  ',' ')
WHERE NewModBadge = 1

UPDATE tblBadges
SET COtextAll = REPLACE(COtextAll,'  ',' ')
WHERE NewModBadge = 1

--OTHER FIELDS
UPDATE tblBadges
SET SHT = '' 
WHERE SHT IS NULL
AND NewModBadge = 1

UPDATE tblBadges
SET POS = '' 
WHERE POS IS NULL
AND NewModBadge = 1

UPDATE tblBadges
SET COLogo = '' 
WHERE COLogo IS NULL
AND NewModBadge = 1

--TAG: REALTOR FIX (AS OF 07/12/11)
UPDATE tblBadges
SET contact = REPLACE(contact,'®','<V>®<P>'),
title = REPLACE(title,'®','<V>®<P>'),
COLogo = REPLACE(COLogo,'®','<V>®<P>'),
COtext1 = REPLACE(COtext1,'®','<V>®<P>'),
COtext2 = REPLACE(COtext2,'®','<V>®<P>'),
COtextAll = REPLACE(COtextAll,'®','<V>®<P>')
WHERE NewModBadge = 1

--TAG: REALTOR FIX (AS OF 05/02/12)
UPDATE tblBadges
SET contact = REPLACE(contact,'<V>®<P>Â<V>®<P>','<V>®<P>'),
title = REPLACE(title,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COLogo = REPLACE(COLogo,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COtext1 = REPLACE(COtext1,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COtext2 = REPLACE(COtext2,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COtextAll = REPLACE(COtextAll,'<V>®<P>Â<V>®<P>','<V>®<P>')
WHERE NewModBadge = 1

-- (Fix added ON 10/17/14)
UPDATE tblBadges
SET contact = REPLACE(contact,'Â',''),
title = REPLACE(title,'Â',''),
COLogo = REPLACE(COLogo,'Â',''),
COtext1 = REPLACE(COtext1,'Â',''),
COtext2 = REPLACE(COtext2,'Â',''),
COtextAll = REPLACE(COtextAll,'Â','')
WHERE NewModBadge = 1

--TAG: NAME FIX FOR NJ ORDERS (AS OF 7/18/11)
UPDATE a
SET Contact = '<z16>' + Contact + '<z20>'
FROM tblBadges a
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
INNER JOIN tblCustomers c ON c.customerID = o.customerID
INNER JOIN tblCustomers_ShippingAddress csa ON csa.orderNo = o.orderNo
WHERE SUBSTRING(a.orderNo, 1, 3) IN ('HOM','MRK')
AND a.NewModBadge = 1
AND (csa.shipping_State = 'NJ'
	OR c.[state] = 'NJ')

--Update quantities as necessary
;WITH cte AS
	(SELECT op.ID, op.productCode, op.productQuantity, op.orderID
	FROM tblOrders_Products op
	INNER JOIN #NewModBadges nmb ON op.ID = nmb.OPID
	WHERE op.productQuantity > 1
	AND op.deleteX <> 'yes') 

--Update quantities in tblBadges where QTY>1
UPDATE a
SET QTY = cte.productQuantity
FROM tblBadges a
INNER JOIN cte ON a.OPPO_ordersProductsID = cte.[ID]
WHERE a.NewModBadge = 1
    
---Update quantities in tblBadges where QTY IS NULL
UPDATE tblBadges
SET QTY = 1
WHERE QTY IS NULL
AND NewModBadge = 1

INSERT INTO logBadges (logValue, logTime) SELECT 'F', GETDATE()

--///////////////////////////////////////////////////////////////////////////////////////////////// DATA PREP & OUTPUT BEGIN
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--REWRITE ENDS HERE, THE REST IS THE SAME FOR NOW.

-- RUN INTEGER DUPE CODE
IF OBJECT_ID('tempdb..#BadgesQTYDupe') IS NOT NULL DROP TABLE #BadgesQTYDupe			
CREATE TABLE #BadgesQTYDupe (
	[sortNo] [int] NULL,
	[Contact] [VARCHAR](255) NULL,
	[Title] [VARCHAR](255) NULL,
	[BKGND] [VARCHAR](255) NULL,
	[SHT] [VARCHAR](255) NULL,
	[POS] [VARCHAR](255) NULL,
	[COLogo] [VARCHAR](255) NULL,
	[COtextAll] [VARCHAR](255) NULL,
	[COtext1] [VARCHAR](255) NULL,
	[COtext2] [VARCHAR](255) NULL,
	[RO] [VARCHAR](255) NULL,
	[orderNo] [nVARCHAR](255) NULL,
	[pkid] [int] IDENTITY(1,1) NOT NULL,
	[OPPO_ordersProductsID] [int] NULL,
	[QTY] [int] NULL,
	[orderID] [int] NULL,
	[productCode] [VARCHAR](255) NULL
) ON [PRIMARY]

INSERT INTO #BadgesQTYDupe (Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, QTY, orderID, productCode)
SELECT a.Contact, a.Title, a.BKGND, a.SHT, a.POS, a.COLogo, a.COtextAll, a.COtext1, a.COtext2, a.RO, a.orderNo, a.OPPO_ordersProductsID, a.QTY, a.orderID, productCode
FROM tblBadges a
INNER JOIN integers b ON b.i BETWEEN 1 AND a.QTY

TRUNCATE TABLE tblBadges
INSERT INTO tblBadges (Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, QTY, orderID, productCode)
SELECT Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, QTY, orderID, productCode
FROM #BadgesQTYDupe

--FIX SORT
DROP TABLE [tblBadges_bounce]
CREATE TABLE [dbo].[tblBadges_bounce](
	[sortNo] [int] NULL,
	[Contact] [VARCHAR](255) NULL,
	[Title] [VARCHAR](255) NULL,
	[BKGND] [VARCHAR](255) NULL,
	[SHT] [VARCHAR](255) NULL,
	[POS] [VARCHAR](255) NULL,
	[COLogo] [VARCHAR](255) NULL,
	[COtextAll] [VARCHAR](255) NULL,
	[COtext1] [VARCHAR](255) NULL,
	[COtext2] [VARCHAR](255) NULL,
	[RO] [VARCHAR](255) NULL,
	[orderNo] [nVARCHAR](255) NULL,
	[pkid] [int] IDENTITY(1,1) NOT NULL,
	[OPPO_ordersProductsID] [int] NULL,
	[QTY] [int] NULL,
	[orderID] [int] NULL,
	[productCode] [VARCHAR](255) NULL
) ON [PRIMARY]

INSERT INTO tblBadges_bounce (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, orderID, OPPO_ordersProductsID, QTY, productCode)
SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, orderID, OPPO_ordersProductsID, QTY, productCode
FROM tblBadges
ORDER BY orderNo ASC, RO ASC

DECLARE @max INT, @count INT
SET @max = (SELECT TOP 1 ISNULL(PKID, 0)
			FROM tblBadges_bounce 
			ORDER BY PKID DESC)

SET @count = (SELECT ISNULL(COUNT(PKID), 0) FROM tblBadges_bounce)

UPDATE tblBadges_bounce
SET sortNo = @count - (@max - PKID)

--PUSH CLEAN DATA BACK TO tblBADGES
TRUNCATE TABLE tblBadges
INSERT INTO tblBadges (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, orderID, OPPO_ordersProductsID, QTY, productCode)
SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, orderID, OPPO_ordersProductsID, QTY, productCode
FROM tblBadges_bounce
ORDER BY orderNo ASC, RO ASC

--SEPARATE OV/RC
TRUNCATE TABLE tblBadges_OV
TRUNCATE TABLE tblBadges_RC

INSERT INTO tblBadges_OV (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo)
SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo FROM tblBadges
WHERE RO = 'O'

INSERT INTO tblBadges_RC (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo)
SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo FROM tblBadges
WHERE RO = 'R'

--FIX SORT OV
SET @max = (SELECT TOP 1 ISNULL(PKID, 0)
			FROM tblBadges_OV 
			ORDER BY PKID DESC)

SET @count = (SELECT ISNULL(COUNT(PKID), 0) FROM tblBadges_OV)

UPDATE tblBadges_OV
SET sortNo = @count - (@max - PKID)

--FIX SORT RC   
SET @max = (SELECT TOP 1 ISNULL(PKID, 0)
			FROM tblBadges_RC 
			ORDER BY PKID DESC)

SET @count = (SELECT ISNULL(COUNT(PKID), 0) FROM tblBadges_RC)

UPDATE tblBadges_RC
SET sortNo = @count - (@max - PKID)

--REORDER FOR EXPORT
TRUNCATE TABLE tblBadges_RC_Bounce
INSERT INTO tblBadges_RC_Bounce (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo)
SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo
FROM tblBadges_RC
ORDER BY sortNo ASC

TRUNCATE TABLE tblBadges_OV_Bounce
INSERT INTO tblBadges_OV_Bounce (sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo)
SELECT sortNo, Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo
FROM tblBadges_OV
ORDER BY sortNo ASC

INSERT INTO logBadges (logValue, logTime) SELECT 'G', GETDATE()

--ADDRESSES BEGIN
IF OBJECT_ID('tblBadges_Addresses') IS NOT NULL
DROP TABLE [tblBadges_Addresses]			

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[tblBadges_Addresses](
	[sortNo] [int] NULL,
	[shipName] [nVARCHAR](255) NULL,
	[shipCompany] [nVARCHAR](255) NULL,
	[address] [nVARCHAR](255) NULL,
	[address2] [nVARCHAR](255) NULL,
	[city] [nVARCHAR](255) NULL,
	[st] [nVARCHAR](255) NULL,
	[zip] [nVARCHAR](255) NULL,
	[orderNo] [nVARCHAR](255) NULL,
	[badgeName] [nVARCHAR](255) NULL,
	[badgeQTY] [int] NULL,
	[OPPO_ordersproductsID] [int] NULL,
	[pkid] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

INSERT INTO tblBadges_Addresses (sortNo, shipName, shipCompany, [address], address2, city, st, zip, orderNo, badgeName, badgeQTY, OPPO_ordersProductsID)
SELECT DISTINCT '999999999',
REPLACE(a.shipping_firstName + ' ' + a.shipping_surName, '  ', ' ') AS 'shipName', 
a.shipping_Company AS 'shipCompany', 
a.shipping_Street AS 'address', 
a.shipping_Street2 AS 'address2', 
a.shipping_suburb AS 'city', 
a.shipping_State AS 'st', 
a.shipping_postCode AS 'zip', 
a.orderNo AS 'orderNo', 
z.textValue AS 'badgeName', 
SUM(p.productQuantity) AS 'badgeQTY', 
p.[ID]
FROM tblCustomers_ShippingAddress a 
INNER JOIN tblOrders o ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND (z.optionCaption LIKE 'Name%' OR z.optionCaption LIKE 'Agent Name%')
AND z.deleteX <> 'yes'
AND SUBSTRING(p.productCode, 1, 2) = 'NB'
AND SUBSTRING(p.productCode, 3, 2) <> 'CU'
AND p.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND o.orderStatus NOT IN ('cancelled', 'failed', 'waiting for payment')
GROUP BY a.shipping_firstName, a.shipping_surName, a.shipping_Company, a.shipping_Street, a.shipping_Street2, 
a.shipping_suburb, a.shipping_State, a.shipping_postCode, a.orderNo, z.textValue, p.[ID]

--grab total QTY per orderNo
TRUNCATE TABLE tblBadges_Addresses_PKIDMIRROR
INSERT INTO tblBadges_Addresses_PKIDMIRROR (badgeQTY, orderNo)
SELECT SUM(badgeQTY) AS 'badgeQTY', orderNo
FROM tblBadges_Addresses
GROUP BY orderNo

--now, UPDATE.
UPDATE tblBadges_Addresses
SET badgeQTY = b.badgeQTY
FROM tblBadges_Addresses a
INNER JOIN tblBadges_Addresses_PKIDMIRROR b ON a.orderNo = b.orderNo

--CONSOLIDATE
-- for some reason, in the past the typical TRUNCATE/INSERT combo caused issues here so it was changed to this, investigate, 3/17/17 jf.
IF OBJECT_ID('tblBadges_Addresses_Clean') IS NOT NULL
DROP TABLE tblBadges_Addresses_Clean
SELECT DISTINCT sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY, pkid
INTO tblBadges_Addresses_Clean
FROM tblBadges_Addresses
ORDER BY orderNo ASC

--push back.
IF OBJECT_ID('tblBadges_Addresses') IS NOT NULL
DROP TABLE tblBadges_Addresses
CREATE TABLE [dbo].[tblBadges_Addresses](
	[sortNo] [int] NULL,
	[shipName] [nVARCHAR](255) NULL,
	[shipCompany] [nVARCHAR](255) NULL,
	[address] [nVARCHAR](255) NULL,
	[address2] [nVARCHAR](255) NULL,
	[city] [nVARCHAR](255) NULL,
	[st] [nVARCHAR](255) NULL,
	[zip] [nVARCHAR](255) NULL,
	[orderNo] [nVARCHAR](255) NULL,
	[badgeName] [nVARCHAR](255) NULL,
	[badgeQTY] [int] NULL,
	[OPPO_ordersproductsID] [int] NULL,
	[pkid] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

INSERT INTO tblBadges_Addresses (sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY)
SELECT DISTINCT sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY
FROM tblBadges_Addresses_Clean

--FIX SORT
DECLARE @maxA INT, @countA INT

SET @maxA = (SELECT TOP 1 PKID 
				FROM tblBadges_Addresses 
				ORDER BY PKID DESC)

IF @maxA = 0
BEGIN
	SET @maxA = 0
END

SET @countA = (SELECT COUNT(*) 
				FROM tblBadges_Addresses)

IF @countA = 0
BEGIN
	SET @countA = 0
END

UPDATE tblBadges_Addresses
SET sortNo = @countA-(@maxA-PKID)

INSERT INTO logBadges (logValue, logTime) SELECT 'H', GETDATE()

--REORDER
TRUNCATE TABLE tblBadges_Addresses_Bounce
SET IDENTITY_INSERT tblBadges_Addresses_Bounce ON

	INSERT INTO tblBadges_Addresses_Bounce (sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY, pkid)
	SELECT  sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY, pkid
	FROM tblBadges_Addresses
	ORDER BY CONVERT(INT,sortNo) ASC

SET IDENTITY_INSERT tblBadges_Addresses_Bounce OFF

--push back
TRUNCATE TABLE tblBadges_Addresses
SET IDENTITY_INSERT tblBadges_Addresses ON

	INSERT INTO tblBadges_Addresses (sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY, pkid)
	SELECT sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY, pkid
	FROM tblBadges_Addresses_Bounce
	ORDER BY convert(INT,sortNo) ASC

SET IDENTITY_INSERT tblBadges_Addresses OFF

--Now change CSZ value to say "Ship with orderNo HOMXXX" if said order has other products in it besides name badges.
UPDATE tblBadges_Addresses
SET city = 'Ship with orderNo: ' + orderNo + '.'
WHERE orderNo IN
	(SELECT DISTINCT orderNo 
	FROM tblOrders 
			WHERE orderNo IS NOT NULL 
			AND orderID IN
					(SELECT DISTINCT orderID 
					FROM tblOrders_Products 
					WHERE orderID IS NOT NULL
					AND deleteX <> 'yes'
					AND productCode NOT LIKE 'NB%')
		)

UPDATE tblBadges_Addresses
SET [address] = NULL, 
	address2 = NULL, 
	st = NULL, 
	zip = NULL
WHERE city LIKE 'Ship with orderNo%'

INSERT INTO logBadges (logValue, logTime) SELECT 'I', GETDATE()

--// Create final datasource for SSIS
TRUNCATE TABLE tblBadgeMerge
INSERT INTO tblBadgeMerge (sortNo, Contact, Title, BKGND, sht, pos, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, badgeName)
SELECT a.sortNo, a.Contact, a.Title, a.BKGND, a.sht, a.pos, a.COLogo, a.COtextAll, a.COtext1, a.COtext2, a.RO, a.orderNo, 
a.OPPO_ordersProductsID, a.Contact
FROM tblBadges a
ORDER BY a.sortNo ASC

UPDATE tblBadgeMerge
SET shipName = b.shipName,
shipCompany = b.shipCompany,
[address] = b.[address],
address2 = b.address2,
city = b.city,
st = b.st,
zip = b.zip,
badgeQTY = b.badgeQTY,
PKID = b.PKID
FROM tblBadgeMerge a
INNER JOIN tblBadges_Addresses b
	ON a.orderNo = b.orderNo

--REORDER
TRUNCATE TABLE tblBadgeMerge_Bounce
INSERT INTO tblBadgeMerge_Bounce (sortNo, Contact, Title, BKGND, sht, pos, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, 
									shipName, shipCompany, [address], address2, city, st, zip, badgeName, badgeQTY, PKID)
SELECT sortNo, Contact, Title, BKGND, sht, pos, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, 
shipName, shipCompany, [address], address2, city, st, zip, badgeName, badgeQTY, PKID
FROM tblBadgeMerge
ORDER BY CONVERT(INT, sortNo) ASC

--push back
TRUNCATE TABLE tblBadgeMerge
INSERT INTO tblBadgeMerge (sortNo, Contact, Title, BKGND, sht, pos, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, 
							shipName, shipCompany, [address], address2, city, st, zip, badgeName, badgeQTY, PKID)
SELECT sortNo, Contact, Title, BKGND, sht, pos, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, 
shipName, shipCompany, [address], address2, city, st, zip, badgeName, badgeQTY, PKID
FROM tblBadgeMerge_Bounce
ORDER BY CONVERT(INT, sortNo) ASC

INSERT INTO logBadges (logValue, logTime) SELECT 'J - End Log', GETDATE()

--Timestamp BadgeLog table for future runs
UPDATE BadgeLog SET LastRun = GETDATE()

END TRY
BEGIN CATCH

--Capture errors if they happen
EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH