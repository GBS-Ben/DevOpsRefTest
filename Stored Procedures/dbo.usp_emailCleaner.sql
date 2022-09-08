CREATE PROC usp_emailCleaner
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/25/18
-- Purpose    Email cleaner.
--					  Not an active sproc. Use the code below as you see fit.
-------------------------------------------------------------------------------
-- Modification History
--
-- 07/25/18	Created, jf.
-------------------------------------------------------------------------------
/*

HOW TO USE:

1. Create the following columns in a temp table or copy and use tempJF_jdiv if it's around. Basically, you need these columns:

			+ oldEmail (this is the email field you'll be pulling from) (differs per run)
			+ newEmail (nvcmax)
			+ cleanFront (nvcmax)
			+ cleanBack (nvcmax)
			+ wasCleaned (bit=0)
			+ BCimageURL (nvcmax)

2. Load your emails into the "oldEmail" column then run following three steps in order.
3. Join your data back in based off of "oldEmail" or however you want to get 'em in.
4. Get BC IMAGE URL (if applicable to your project).

*/

--STEP 1. CLEAN FRONT --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
UPDATE tempJF_jdiv02 SET cleanFront = '', wasCleaned = 0

--~love needed
UPDATE tempJF_jdiv02
SET cleanFront  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING (OPID_EMAIL, (PATINDEX('%@%', OPID_EMAIL)  +1 - CHARINDEX(' ', REVERSE(SUBSTRING(OPID_EMAIL, 1, PATINDEX('%@%', OPID_EMAIL))))) , 
							   CHARINDEX(' ', REVERSE(SUBSTRING(OPID_EMAIL, 1, PATINDEX('%@%', OPID_EMAIL))))), ' ' , ''), ':', ''), '/',''), ';', ''), '=', ''), '"', ''), '|', ''),
	   wasCleaned = 1
WHERE OPID_EMAIL LIKE '% %@%'

--~no love lost
UPDATE tempJF_jdiv02
SET cleanFront =   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(OPID_EMAIL, 1, PATINDEX('%@%', OPID_EMAIL)) , ' ' , ''), ':', ''), '/',''), ';', ''), '=', ''), '"', ''), '|', '')
WHERE OPID_EMAIL NOT LIKE '% %@%'
AND OPID_EMAIL LIKE '%@%'
AND cleanFront = ''

--STEP 2. CLEAN BACK--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
UPDATE tempJF_jdiv02 SET cleanBack = '' 

-- help wanted
UPDATE tempJF_jdiv02
SET cleanBack = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(OPID_EMAIL, PATINDEX('%@%', OPID_EMAIL) + 1, 
							 (CHARINDEX(' ', OPID_EMAIL, PATINDEX('%@%', OPID_EMAIL))  - PATINDEX('%@%', OPID_EMAIL))), ' ' , ''), ':', ''), '/', ''), ';', ''), '=', ''), '"', ''),
	   wasCleaned = 1
WHERE OPID_EMAIL LIKE '%@% %'

--~no help needed
UPDATE tempJF_jdiv02
SET cleanBack =   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(OPID_EMAIL, PATINDEX('%@%', OPID_EMAIL) + 1, (LEN(OPID_EMAIL) - PATINDEX('%@%', OPID_EMAIL))) , ' ' , ''), ':', ''), '/',''), ';', ''), '=', ''), '"', ''), '|', '')
WHERE OPID_EMAIL NOT LIKE '%@% %'
AND OPID_EMAIL LIKE '%@%'
AND cleanBack = ''

--STEP 3. CREATE NEW CLEAN EMAIL --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
UPDATE tempJF_jdiv02 
SET newEmail = cleanFront + cleanBack

UPDATE tempJF_jdiv02 
SET newEmail = ''
WHERE newEmail NOT LIKE '%.%'

UPDATE tempJF_jdiv02
SET newEmail = LOWER(newEmail)
WHERE newEmail <> ''

--STEP 4. (OPTIONAL) GRAB BIZCARD URL IMAGE --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
--Gluon
UPDATE tempJF_jdiv02
SET BCimageURL = 'https://gluon.houseofmagnets.com' + oppo.textValue
FROM tempJF_jdiv02 a
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products op
	ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo
	ON op.ID = oppo.ordersProductsID
WHERE oppo.textvalue LIKE '/OpcPreview/BusinessCards/%'

UPDATE tempJF_jdiv02
SET BCimageURL = 'https:' + oppo.textValue
FROM tempJF_jdiv02 a
INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
INNER JOIN tblOrders_Products op
	ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo
	ON op.ID = oppo.ordersProductsID
WHERE oppo.textvalue LIKE '%//canvas.houseofmagnets.com/api/rendering/GetProofImage/%'
AND BCimageURL IS NULL

DELETE FROM tempJF_jdiv02
WHERE BCimageURL IS NULL

SELECT 
orderNo, billing_postCode, 
URL1, URL2, newEmail AS 'CLEAN_EMAIL', BCimageURL
FROM tempJF_jdiv02
WHERE newEmail <> ''
AND URL1 <> 'URL1'
ORDER BY orderNo