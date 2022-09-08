
CREATE PROCEDURE [dbo].[usp_badges]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/20/10
Purpose     Preps badge data for IMAGE/IMPO.
-------------------------------------------------------------------------------
Modification History

03/14/2017	Rewrite for performance. Old code found at: [dbo].[usp_badges_archiveAsOf_031417_01]
07/16/18	Removed fastTrak_productType sections (2 of them), jf.
07/20/18		Added the following line to the initial query: [AND (a.optionCaption LIKE 'Name:%' OR a.optionCaption LIKE 'Agent Name:%')]; jf.
07/24/18		Reverted above, jf.
06/08/20		Added this where necessary: 
					UPDATE tblBadges
					SET X = REPLACE(X,'&#237','í')
04/27/21		CKB, Markful

-------------------------------------------------------------------------------
*/

SET NOCOUNT ON;

BEGIN TRY

-- START INSERTS:
TRUNCATE TABLE tblBadges
INSERT INTO tblBadges (sortNo, Contact, Title, RO, orderNo, orderID, OPPO_ordersProductsID, productCode)

SELECT 
--x.nop, --we should modify this query to use x.nop=1 at a later date (2/4/19)
'9999999' AS 'sortNo',
a.textValue AS 'Contact', 
'' AS 'Title',
'RO' AS 'RO',
x.orderNo AS 'orderNo',
x.orderID AS 'orderID',
a.ordersProductsID,
b.productCode
FROM tblOrdersProducts_productOptions a 
INNER JOIN tblOrders_Products b 
	ON a.ordersProductsID = b.[ID]
INNER JOIN tblOrders x 
	ON b.orderID = x.orderID
WHERE 
x.orderStatus NOT IN ('failed', 'cancelled', 'waiting for payment')
AND SUBSTRING(b.productCode, 1, 2) = 'NB'
AND SUBSTRING(b.productCode, 3, 2) <> 'CU'
AND b.productCode NOT IN ('NB2CRB-001-100', 'NB2COB-001-100')
AND b.deleteX <> 'yes'
AND a.deleteX <> 'yes'
AND (a.optionCaption LIKE 'Name%' OR a.optionCaption LIKE 'Agent Name%')
AND 
	(DATEDIFF(DD, x.orderDate, GETDATE()) <= 200 
	OR 
	x.orderNo IN
		(SELECT DISTINCT orderNo 
		FROM tblOrders
		WHERE orderID IN
			(SELECT DISTINCT orderID 
			FROM tblOrders_Products
			WHERE deleteX <> 'yes'
			AND fastTrak_resubmit = 1)
		)
	)

--TITLE (if it exists for given OPID)
UPDATE tblBadges
SET Title = k.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions k 
	ON a.OPPO_ordersProductsID = k.ordersProductsID
WHERE (k.optionCaption LIKE 'Title:%' OR k.optionCaption = 'Customer Title')
AND k.deleteX <> 'yes'
	
--RO
UPDATE tblBadges
SET RO = REPLACE(SUBSTRING(b.productCode,5,1), '#', '')
FROM tblBadges a 
INNER JOIN tblOrders_Products b
	ON a.OPPO_ordersProductsID = b.[ID]
WHERE 
SUBSTRING(b.productCode,5,2) IN ('OV', 'OG', 'OS', 'OB', 'OF', 'RC', 'RB', 'RG', 'RS', 'RF')

UPDATE tblBadges
SET RO = 'R'
WHERE RO = 'RO'

--BKGND
UPDATE tblBadges
SET BKGND = SUBSTRING(b.productCode,1,10)
FROM tblBadges p  
INNER JOIN tblOrders_Products b
	ON p.OPPO_ordersProductsID = b.[ID]
WHERE LEN(b.productCode) = 14

-- New productCodes (as of 6/15/16; jf) BKGND
UPDATE tblBadges
SET BKGND = SUBSTRING(b.productCode,1,20)
FROM tblBadges p  
INNER JOIN tblOrders_Products b
	ON p.OPPO_ordersProductsID = b.[ID]
WHERE LEN(b.productCode) = 20

-- ~~~~~~~~~~~~~~~~~  CLEAN!  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~BEGIN
--TITLE FIELD
UPDATE tblBadges
SET title = REPLACE(title,'&#174;','®')

UPDATE tblBadges
SET title = REPLACE(title,'&#174','®')

UPDATE tblBadges
SET title = REPLACE(title,'(R)','®')

UPDATE tblBadges
SET title = REPLACE(title,'&amp;','&')

UPDATE tblBadges
SET title = REPLACE(title,'&amp','&')

UPDATE tblBadges
SET title = REPLACE(title,'&quot;','"')

UPDATE tblBadges
SET title = REPLACE(title,'&quot','"')

UPDATE tblBadges
SET title = REPLACE(title,'&#233;','é')

UPDATE tblBadges
SET title = REPLACE(title,'&#233','é')

UPDATE tblBadges
SET title = REPLACE(title,'&#241;','ñ')

UPDATE tblBadges
SET title = REPLACE(title,'&#241','ñ')

UPDATE tblBadges
SET title = REPLACE(title,'&#211;','Ó')

UPDATE tblBadges
SET title = REPLACE(title,'&#243;','Ó')

UPDATE tblBadges
SET title = REPLACE(title,'&#211','Ó')

UPDATE tblBadges
SET title = REPLACE(title,'&#243','Ó')

UPDATE tblBadges
SET title = REPLACE(title,'realtor','REALTOR')

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR-Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR - Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET title = REPLACE(title,'REALTOR','REALTOR®')
WHERE title NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblBadges
SET title = REPLACE(title,'®®','®')

UPDATE tblBadges
SET title = REPLACE(title,'®-',' ® -')

UPDATE tblBadges
SET title = REPLACE(title,'-®',' - ®')

UPDATE tblBadges
SET title = REPLACE(title,',',', ')

UPDATE tblBadges
SET title = REPLACE(title,'  ',' ')

UPDATE tblBadges
SET title = REPLACE(title,'  ',' ')

--contact FIELD
UPDATE tblBadges
SET contact = REPLACE(contact,'&#174;','®')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#174','®')

UPDATE tblBadges
SET contact = REPLACE(contact,'(R)','®')

UPDATE tblBadges
SET contact = REPLACE(contact,'&amp;','&')

UPDATE tblBadges
SET contact = REPLACE(contact,'&amp','&')

UPDATE tblBadges
SET contact = REPLACE(contact,'&quot;','"')

UPDATE tblBadges
SET contact = REPLACE(contact,'&quot','"')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#233;','é')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#233','é')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#241;','ñ')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#241','ñ')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#237','í')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#237;','í')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#211;','Ó')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#243;','Ó')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#211','Ó')

UPDATE tblBadges
SET contact = REPLACE(contact,'&#243','Ó')

UPDATE tblBadges
SET contact = REPLACE(contact,'realtor','REALTOR')

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR-Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR - Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR Associate','REALTOR-ASSOCIATE®')

UPDATE tblBadges
SET contact = REPLACE(contact,'REALTOR','REALTOR®')
WHERE contact NOT LIKE '%REALTOR-ASSOCIATE%'

UPDATE tblBadges
SET contact = REPLACE(contact,'®®','®')

UPDATE tblBadges
SET contact = REPLACE(contact,'®-',' ® -')

UPDATE tblBadges
SET contact = REPLACE(contact,'-®',' - ®')

UPDATE tblBadges
SET contact = REPLACE(contact,',',', ')

UPDATE tblBadges
SET contact = REPLACE(contact,'  ',' ')

UPDATE tblBadges
SET contact = REPLACE(contact,'  ',' ')


--COMPANY FIELDS
-- first grab info input by customer, if present.
UPDATE tblBadges
SET COtext1 = b.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions b
	ON a.OPPO_ordersProductsID = b.ordersProductsID
WHERE optionCaption LIKE 'Company:%'
AND b.deleteX <> 'yes'

UPDATE tblBadges
SET COtext2 = b.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions b
	ON a.OPPO_ordersProductsID = b.ordersProductsID
WHERE optionCaption LIKE 'Company 2:%'
AND b.deleteX <> 'yes'

UPDATE tblBadges
SET COtext1 = b.textValue
FROM tblBadges a
INNER JOIN tblOrdersProducts_ProductOptions b
	ON a.OPPO_ordersProductsID = b.ordersProductsID
WHERE (optionCaption LIKE '%Title2:%' OR optionCaption = 'Customer Title 2')
AND b.deleteX <> 'yes'

--now deal with any NULLS left over
UPDATE tblBadges
SET COtext1 = '' 
WHERE COtext1 IS NULL

UPDATE tblBadges
SET COtext2 = '' 
WHERE COtext2 IS NULL

--COtext1 FIELD
UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#174;','®')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#174','®')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'(R)','®')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&amp;','&')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&amp','&')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&quot;','"')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&quot','"')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#233;','é')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#233','é')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#241;','ñ')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#241','ñ')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#237','í')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#237;','í')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#211;','Ó')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#243;','Ó')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#211','Ó')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'&#243','Ó')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,',',', ')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,' ,',',')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'  ',' ')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'  ',' ')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'remax','RE/MAX')

UPDATE tblBadges
SET COtext1 = REPLACE(COtext1,'Re/Max','RE/MAX')

--COtext2 FIELD
UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#174;','®')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#174','®')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'(R)','®')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&amp;','&')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&amp','&')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&quot;','"')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&quot','"')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#233;','é')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#233','é')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#241;','ñ')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#241','ñ')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#237','í')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#237;','í')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#211;','Ó')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#243;','Ó')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#211','Ó')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'&#243','Ó')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,',',', ')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,' ,',',')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'  ',' ')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'  ',' ')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'remax','RE/MAX')

UPDATE tblBadges
SET COtext2 = REPLACE(COtext2,'Re/Max','RE/MAX')

UPDATE tblBadges
SET COtextAll = COtext1 + ' ' + COtext2

--Now grab info from tblNameBadgeMaster if customer provided no data.
UPDATE tblBadges
SET COtext1 = b.COtext1
FROM tblBadges a
INNER JOIN tblNameBadgeMaster b
	ON SUBSTRING(a.productCode,3,2) = b.company
AND SUBSTRING(a.productCode,12,3) = b.officeNo
AND SUBSTRING(a.productCode,12,3) NOT IN ('100', '101')
AND b.COtext1 IS NOT NULL
AND b.company IS NOT NULL
AND b.officeNo IS NOT NULL

UPDATE tblBadges
SET COtext2 = b.COtext2
FROM tblBadges a
INNER JOIN tblNameBadgeMaster b
	ON SUBSTRING(a.productCode,3,2) = b.company
AND SUBSTRING(a.productCode,12,3) = b.officeNo
AND SUBSTRING(a.productCode,12,3) NOT IN ('100', '101')
AND b.COtext2 IS NOT NULL
AND b.company IS NOT NULL
AND b.officeNo IS NOT NULL

UPDATE tblBadges
SET COtextAll = b.COtextAll
FROM tblBadges a
INNER JOIN tblNameBadgeMaster b
	ON SUBSTRING(a.productCode,3,2) = b.company
AND SUBSTRING(a.productCode,12,3) = b.officeNo
AND SUBSTRING(a.productCode,12,3) NOT IN ('100', '101')
AND b.COtextAll IS NOT NULL
AND b.company IS NOT NULL
AND b.officeNo IS NOT NULL

--RE/MAX & PRUDENTIAL FIXES
UPDATE tblBadges
SET COtextAll = 'RE/MAX ' + COtextAll
WHERE SUBSTRING(BKGND,3,2) = 'RM' 
AND SUBSTRING(productCode,12,3) = '101'
AND COtextAll IS NOT NULL 
AND COtextAll <> '' 
AND COtextAll <> ' ' 
AND COtextAll <> '  '

UPDATE tblBadges
SET COtextAll = 'Prudential  ' + COtextAll
WHERE SUBSTRING(BKGND,3,2) = 'PR' 
AND SUBSTRING(productCode,12,3) = '101'
AND COtextAll IS NOT NULL 
AND COtextAll <> '' 
AND COtextAll <> ' ' 
AND COtextAll <> '  '

UPDATE tblBadges 
SET COtextAll = REPLACE(COtextAll,'RE/MAX RE/MAX','RE/MAX ')

UPDATE tblBadges 
SET COtextAll = REPLACE(COtextAll,'Prudential Prudential','Prudential ')

UPDATE tblBadges
SET COtextAll = REPLACE(COtextAll,'  ',' ')

UPDATE tblBadges
SET COtextAll = REPLACE(COtextAll,'  ',' ')

--OTHER FIELDS
UPDATE tblBadges
SET SHT = '' WHERE SHT IS NULL

UPDATE tblBadges
SET POS = '' WHERE POS IS NULL

UPDATE tblBadges
SET COLogo = '' WHERE COLogo IS NULL

--TAG: REALTOR FIX (AS OF 07/12/11)
UPDATE tblBadges
SET contact = REPLACE(contact,'®','<V>®<P>'),
title = REPLACE(title,'®','<V>®<P>'),
COLogo = REPLACE(COLogo,'®','<V>®<P>'),
COtext1 = REPLACE(COtext1,'®','<V>®<P>'),
COtext2 = REPLACE(COtext2,'®','<V>®<P>'),
COtextAll = REPLACE(COtextAll,'®','<V>®<P>')

--TAG: REALTOR FIX (AS OF 05/02/12)
UPDATE tblBadges
SET contact = REPLACE(contact,'<V>®<P>Â<V>®<P>','<V>®<P>'),
title = REPLACE(title,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COLogo = REPLACE(COLogo,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COtext1 = REPLACE(COtext1,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COtext2 = REPLACE(COtext2,'<V>®<P>Â<V>®<P>','<V>®<P>'),
COtextAll = REPLACE(COtextAll,'<V>®<P>Â<V>®<P>','<V>®<P>')

-- (Fix added ON 10/17/14)
UPDATE tblBadges
SET contact = REPLACE(contact,'Â',''),
title = REPLACE(title,'Â',''),
COLogo = REPLACE(COLogo,'Â',''),
COtext1 = REPLACE(COtext1,'Â',''),
COtext2 = REPLACE(COtext2,'Â',''),
COtextAll = REPLACE(COtextAll,'Â','')

--TAG: NAME FIX FOR NJ ORDERS (AS OF 7/18/11)
UPDATE tblBadges
SET Contact = '<z16>' + Contact + '<z20>'
WHERE orderNo IN
	(SELECT orderNo 
	FROM tblCustomers_ShippingAddress 
	WHERE shipping_State = 'NJ' 
	AND (orderNo LIKE 'HOM%' or orderNo LIKE 'MRK%'))
	OR orderNo IN
		(SELECT orderNo 
		FROM tblOrders 
		WHERE (orderNo LIKE 'HOM%' or orderNo LIKE 'MRK%')
		AND customerID IN 
			(SELECT customerID 
			FROM tblCustomers 
			WHERE [state] = 'NJ'))

-- ~~~~~~~~~~~~~~~~~  CLEAN!  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~END

-- CREATE QTY TABLE
TRUNCATE TABLE tblNBQTY

SET IDENTITY_INSERT  tblNBQTY ON
	INSERT INTO tblNBQTY ([ID], productCode, productQuantity, orderID)
	SELECT DISTINCT [ID], productCode, productQuantity, orderID
	FROM tblOrders_Products
	WHERE productCode LIKE 'NB%'
	AND productQuantity > 1
	AND deleteX <> 'Yes'
SET IDENTITY_INSERT  tblNBQTY OFF

--Update quantities in tblBadges
--first do the ones that have multiple instances
UPDATE tblBadges
SET QTY = b.productQuantity
FROM tblBadges a
INNER JOIN tblNBQTY b
	ON a.OPPO_ordersProductsID = b.[ID]
    
--now do the ones that have only one instance
UPDATE tblBadges
SET QTY = 1
WHERE QTY IS NULL

-- RUN INTEGER DUPE CODE
DROP TABLE tblBadgesQTYDupe
CREATE TABLE [dbo].[tblBadgesQTYDupe](
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

INSERT INTO tblBadgesQTYDupe (Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, QTY, orderID, productCode)
SELECT a.Contact, a.Title, a.BKGND, a.SHT, a.POS, a.COLogo, a.COtextAll, a.COtext1, a.COtext2, a.RO, a.orderNo, a.OPPO_ordersProductsID, a.QTY, a.orderID, productCode
FROM tblBadges a
INNER JOIN  INtegers b ON b.i between 1 AND a.QTY

TRUNCATE TABLE tblBadges
INSERT INTO tblBadges (Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, QTY, orderID, productCode)
SELECT Contact, Title, BKGND, SHT, POS, COLogo, COtextAll, COtext1, COtext2, RO, orderNo, OPPO_ordersProductsID, QTY, orderID, productCode
FROM tblBadgesQTYDupe

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

DECLARE @max INT, @COUNT INT
SET @max = (SELECT TOP 1 PKID 
			FROM tblBadges_bounce 
			ORDER BY PKID DESC)
IF @max = 0
BEGIN
	SET @max = 0
END

SET @COUNT = (SELECT COUNT(*) 
				FROM tblBadges_bounce)
IF @COUNT = 0
BEGIN
	SET @COUNT = 0
END

UPDATE tblBadges_bounce
SET sortNo = @COUNT-(@max-PKID)

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
SET @max = (SELECT TOP 1 PKID 
			FROM tblBadges_OV 
			ORDER BY PKID DESC)
IF @max = 0
BEGIN
	SET @max = 0
END

SET @COUNT = (SELECT COUNT(*) FROM tblBadges_OV)
IF @COUNT = 0
BEGIN
	SET @COUNT = 0
END

UPDATE tblBadges_OV
SET sortNo = @COUNT-(@max-PKID)

--FIX SORT RC   
SET @max = (SELECT TOP 1 PKID 
			FROM tblBadges_RC 
			ORDER BY PKID DESC)
IF @max = 0
BEGIN
	SET @max = 0
END

SET @COUNT = (SELECT COUNT(*) 
				FROM tblBadges_RC)
IF @COUNT = 0
BEGIN
	SET @COUNT = 0
END

UPDATE tblBadges_RC
SET sortNo = @COUNT-(@max-PKID)

--RE ORDER FOR EXPORT
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ADDRESSES BEGIN.

DROP TABLE [dbo].[tblBadges_Addresses]

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
INNER JOIN tblOrders o 
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products p 
	ON o.orderID = p.orderID
INNER JOIN tblOrdersProducts_ProductOptions z 
	ON p.[ID] = z.ordersProductsID
WHERE p.deleteX <> 'yes'
AND (z.optionCaption LIKE 'Name:%' OR z.optionCaption = 'Agent Name')
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
DROP TABLE tblBadges_Addresses_Clean
SELECT DISTINCT sortNo, shipName, shipCompany, address, address2, city, st, zip, orderNo, badgeName, badgeQTY, pkid
INTO tblBadges_Addresses_Clean
FROM tblBadges_Addresses
ORDER BY orderNo ASC

--push back.
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
DECLARE @maxA INT, @COUNTA INT

SET @maxA = (SELECT TOP 1 PKID 
				FROM tblBadges_Addresses 
				ORDER BY PKID DESC)

IF @maxA = 0
BEGIN
	SET @maxA = 0
END

SET @COUNTA = (SELECT COUNT(*) 
				FROM tblBadges_Addresses)

IF @COUNTA = 0
BEGIN
	SET @COUNTA = 0
END

UPDATE tblBadges_Addresses
SET sortNo = @COUNTA-(@maxA-PKID)

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


END TRY
BEGIN CATCH

--Capture errors if they happen
EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH