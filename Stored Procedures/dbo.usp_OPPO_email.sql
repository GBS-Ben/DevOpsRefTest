
CREATE PROC [dbo].[usp_OPPO_email]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/26/18
-- Purpose    Imports emails into tblOPPO_email so that we can use emails in product options.
--					  called by [usp_MIG_HOMLIVE] near Z97.
-------------------------------------------------------------------------------
-- Modification History
--
-- 07/26/18	Created, jf.
-- 08/02/18	JF, updated to deal with line breaks. Note, CHAR(10) does not exist w/o CHAR(13), so I only search for that, but replace both.
-- 09/11/19	JF, made this faster by limiting initial query with date range and putting rest of this think in a BEGIN/END.
-------------------------------------------------------------------------------
--Insert new records into tblOPPO_email 

INSERT INTO tblOPPO_email (orderID, orderNo, OPID, PKID, textValue, insertDate)
SELECT o.orderID, o.orderNo, op.ID, oppo.PKID, oppo.textValue, GETDATE()
FROM tblOrders o
INNER JOIN tblOrders_Products op	
	ON o.orderID = op.orderID
	AND DATEDIFF(DD, o.orderDate, GETDATE()) < 2
INNER JOIN tblOrdersProducts_productOptions oppo
	ON op.ID = oppo.ordersProductsID
LEFT JOIN tblOPPO_email z
	ON oppo.PKID = z.PKID
WHERE oppo.textValue LIKE '%@%'
AND oppo.deleteX <> 'yes'
AND DATEDIFF(DD, oppo.created_on, GETDATE()) < 2
AND z.PKID IS NULL

DECLARE @CountDirties INT = 0

SET @CountDirties = (SELECT ISNULL(COUNT(rowID), 0) 
						FROM tblOPPO_email 
						WHERE clean = 0
						AND email IS NOT NULL)

IF @CountDirties <> 0
BEGIN

		--STEP 1. CLEAN FRONT --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
		--set dirty to '1' for rows that need their fronts clean
		UPDATE tblOPPO_email
		SET dirty = 1
		WHERE textValue LIKE '% %@%'
		AND junk = 0
		AND clean = 0

		--clean fronts
		UPDATE tblOPPO_email
		SET cleanFront  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING (textValue, (PATINDEX('%@%', textValue)  +1 - CHARINDEX(' ', REVERSE(SUBSTRING(textValue, 1, PATINDEX('%@%', textValue))))) , 
									   CHARINDEX(' ', REVERSE(SUBSTRING(textValue, 1, PATINDEX('%@%', textValue))))), ' ' , ''), ':', ''), ';', ''), '=', ''), '"', '')
		WHERE textValue LIKE '% %@%'
		AND dirty = 1
		AND junk = 0
		AND clean = 0

		--bring in non-dirty fronts
		UPDATE tblOPPO_email
		SET cleanFront =   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(textValue, 1, PATINDEX('%@%', textValue)) , ' ' , ''), ':', ''), '/',''), ';', ''), '=', ''), '"', ''), '|', '')
		WHERE textValue NOT LIKE '% %@%'
		AND textValue LIKE '%@%'
		AND cleanFront IS NULL
		AND junk = 0
		AND clean = 0

		-- take additional passes through for oddities (this may grow over time)
		-- "~"
		UPDATE tblOPPO_email
		SET cleanFront  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING (cleanFront, (PATINDEX('%@%', cleanFront)  +1 - CHARINDEX('~', REVERSE(SUBSTRING(cleanFront, 1, PATINDEX('%@%', cleanFront))))) , 
									   CHARINDEX('~', REVERSE(SUBSTRING(cleanFront, 1, PATINDEX('%@%', cleanFront))))), ' ' , ''), ':', ''), ';', ''), '=', ''), '"', ''), '~', '')
		WHERE cleanFront LIKE '%~%@%'
		AND junk = 0
		AND clean = 0

		-- "/"
		UPDATE tblOPPO_email
		SET cleanFront  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING (cleanFront, (PATINDEX('%@%', cleanFront)  +1 - CHARINDEX('/', REVERSE(SUBSTRING(cleanFront, 1, PATINDEX('%@%', cleanFront))))) , 
									   CHARINDEX('/', REVERSE(SUBSTRING(cleanFront, 1, PATINDEX('%@%', cleanFront))))), ' ' , ''), ':', ''), ';', ''), '=', ''), '"', ''), '/', '')
		WHERE cleanFront LIKE '%/%@%'
		AND junk = 0
		AND clean = 0

		-- "|"
		UPDATE tblOPPO_email
		SET cleanFront  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING (cleanFront, (PATINDEX('%@%', cleanFront)  +1 - CHARINDEX('|', REVERSE(SUBSTRING(cleanFront, 1, PATINDEX('%@%', cleanFront))))) , 
									   CHARINDEX('|', REVERSE(SUBSTRING(cleanFront, 1, PATINDEX('%@%', cleanFront))))), ' ' , ''), ':', ''), ';', ''), '=', ''), '"', ''), '|', '')
		WHERE cleanFront LIKE '%|%@%'
		AND junk = 0
		AND clean = 0

		-- set dirty to zero
		UPDATE tblOPPO_email
		SET dirty = 0
		WHERE cleanFront IS NOT NULL
		AND junk = 0
		AND clean = 0

		--STEP 2. CLEAN BACK--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
		--set dirty to '1' for rows that need their backs clean
		UPDATE tblOPPO_email
		SET dirty = 1
		WHERE textValue LIKE '%@% %'
		AND junk = 0
		AND clean = 0

		--clean backs
		UPDATE tblOPPO_email
		SET cleanBack = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(textValue, PATINDEX('%@%', textValue) + 1, 
									 (CHARINDEX(' ', textValue, PATINDEX('%@%', textValue))  - PATINDEX('%@%', textValue))), ' ' , ''), ':', ''), '/', ''), ';', ''), '=', ''), '"', '')
		WHERE textValue LIKE '%@% %'
		AND dirty = 1
		AND junk = 0
		AND clean = 0

		--bring in non-dirty backs
		UPDATE tblOPPO_email
		SET cleanBack =   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(textValue, PATINDEX('%@%', textValue) + 1, (LEN(textValue) - PATINDEX('%@%', textValue))) , ' ' , ''), ':', ''), '/',''), ';', ''), '=', ''), '"', ''), '|', '')
		WHERE textValue NOT LIKE '%@% %'
		AND textValue LIKE '%@%'
		AND cleanBack IS NULL
		AND junk = 0
		AND clean = 0

		--set dirty to zero
		UPDATE tblOPPO_email
		SET dirty = 0
		WHERE cleanBack IS NOT NULL
		AND junk = 0
		AND clean = 0

		--STEP 3. CLEAN JUNK --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
		UPDATE tblOPPO_email
		SET cleanFront = REPLACE(cleanFront, '	', '')
		WHERE cleanFront LIKE '%	%'
		AND junk = 0
		AND clean = 0

		UPDATE tblOPPO_email
		SET cleanFront = ''
		WHERE cleanFront = '@'
		AND junk = 0
		AND clean = 0

		--Clean Junk
		UPDATE tblOPPO_email
		SET cleanBack = SUBSTRING(cleanBack, 1, LEN(cleanBack)-1)
		WHERE (junk = 0 AND clean = 0)
		AND (cleanBack LIKE '%,'
				 OR cleanBack LIKE '%.'
				 OR cleanBack LIKE '%)'
				 OR cleanBack LIKE '%*'
				 OR cleanBack LIKE '%#'
				 OR cleanBack LIKE '%-'
				 OR cleanBack LIKE '%`'
				 OR cleanBack LIKE '%®')

		UPDATE tblOPPO_email
		SET cleanBack = REPLACE(cleanBack, ',', '.')
		WHERE cleanBack LIKE '%,%'
		AND junk = 0
		AND clean = 0

		--assign JUNK status at this point (this may change as we modify the above code to work better)
		UPDATE tblOPPO_email
		SET junk = 1
		WHERE cleanFront NOT LIKE '%@%'
		AND junk = 0
		AND clean = 0

		UPDATE tblOPPO_email
		SET junk = 1
		WHERE cleanBack NOT LIKE '%.%'
		AND junk = 0
		AND clean = 0

		--STEP 4. CREATE NEW CLEAN EMAIL --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
		UPDATE tblOPPO_email 
		SET email = LOWER(cleanFront + cleanBack),
			   dirty = 0,
			   clean = 1
		WHERE junk = 0
		AND clean = 0

		--STEP 5. DEAL WITH LINE BREAKS --++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
		UPDATE tblOPPO_email 
		SET dirty = 1,
			   clean = 0
		WHERE junk = 0
		AND clean = 1
		AND email LIKE  '%'+CHAR(13)+'%'

		--clean fronts
		UPDATE tblOPPO_email
		SET cleanFront2  = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING (email, (PATINDEX('%@%', email)  +1 - CHARINDEX(''+CHAR(13)+'', REVERSE(SUBSTRING(email, 1, PATINDEX('%@%', email))))) , 
									   CHARINDEX(''+CHAR(13)+'', REVERSE(SUBSTRING(email, 1, PATINDEX('%@%', email))))), ' ' , ''), ':', ''), ';', ''), '=', ''), '"', ''), ''+CHAR(13)+'', ''), ''+CHAR(10)+'', '')
		WHERE email LIKE '%'+CHAR(13)+'%@%'
		AND dirty = 1
		AND junk = 0
		AND clean = 0

		--clean backs
		UPDATE tblOPPO_email
		SET cleanBack2 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(email, PATINDEX('%@%', email) + 1, 
									 (CHARINDEX(''+CHAR(13)+'', email, PATINDEX('%@%', email))  - PATINDEX('%@%', email))), ' ' , ''), ':', ''), '/', ''), ';', ''), '=', ''), '"', ''), ''+CHAR(13)+'', ''), ''+CHAR(10)+'', '')
		WHERE email LIKE '%@%'+CHAR(13)+'%'
		AND dirty = 1
		AND junk = 0
		AND clean = 0

		--bring in non-dirty values when NULL
		UPDATE tblOPPO_email
		SET cleanFront2 = cleanFront
		WHERE cleanFront2 IS NULL

		UPDATE tblOPPO_email
		SET cleanBack2 = cleanBack
		WHERE cleanBack2 IS NULL

		--Clean Junk
		UPDATE tblOPPO_email
		SET cleanBack2 = SUBSTRING(cleanBack2, 1, LEN(cleanBack2)-1)
		WHERE (junk = 0 AND clean = 0)
		AND (cleanBack2 LIKE '%,'
				 OR cleanBack2 LIKE '%.'
				 OR cleanBack2 LIKE '%)'
				 OR cleanBack2 LIKE '%*'
				 OR cleanBack2 LIKE '%#'
				 OR cleanBack2 LIKE '%-'
				 OR cleanBack2 LIKE '%`'
				 OR cleanBack2 LIKE '%®')

		--Build email2
		UPDATE tblOPPO_email 
		SET email2 = LOWER(cleanFront2 + cleanBack2)
		WHERE email LIKE '%'+CHAR(13)+'%'
		AND dirty = 1
		AND junk = 0
		AND clean = 0

		--UPDATE email with the clean email2 value when email contains line break
		UPDATE tblOPPO_email
		SET email = email2,
				dirty = 0,
				clean = 1
		WHERE email LIKE '%'+CHAR(13)+'%'
		AND dirty = 1
		AND junk = 0
		AND clean = 0

END