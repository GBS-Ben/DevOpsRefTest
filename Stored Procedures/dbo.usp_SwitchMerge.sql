CREATE PROCEDURE [dbo].[usp_SwitchMerge] 
AS
/*
-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			07/27/16
Purpose			Preps select sports-related product data for switch automation.
				Runs in tandem to usp_SuperMerge.
-------------------------------------------------------------------------------
Modification History

07/07/16		Major changes noted throughout for first live  of usage, jf
07/08/16		Removed pathing from photo, logo, overflow fields. (commented out), jf
07/12/16		Changes to productBack path and DDF Name value, jf
07/27/16		Added tblSwitchMerge_templateReference work at end of sproc, jf
10/18/16		Changed initial query to check against tblSwitchMerge_templateReference, jf
10/19/16		Updated exception products in initial query, jf
06/07/16		Added QS exception in initial query, jf
07/09/18		Added 'AP%' to the exclusion list at the beginning of the sproc, jf.
11/06/18		Added shipping statuses to orderStatus check in initial query to prevent the creation of art folders for already shipped orders, jf
01/24/19		Removed ":" from the 10 Info Line statements, jf.
01/03/20		Added OPPO Canvas Artwork File Name from tblOrdersProducts_ProductOptions - optionCaption, Location:Last Update, ct
04/24/20		BJS, Y2k  STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'')
04/27/21		CKB, Markful
-------------------------------------------------------------------------------
*/

SET NOCOUNT ON;

BEGIN TRY

	-- 1. Empty table for fresh data
	TRUNCATE TABLE tblSwitchMerge

	--2. Populate table with initial values
	INSERT INTO tblSwitchMerge (PKID, orderNo, ordersProductsID, productID, productCode, productName, productQuantity, 
								template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, jobProductID)
	SELECT DISTINCT STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,''), a.orderNo, b.[ID], b.productID, b.productCode, b.productName, b.productQuantity,
	'HOM_Shortrun:SwitchMergeIn:Templates:X.gp',
	'SwitchMerge',
	'HOM_Shortrun:~HOM Active Jobs:' +  STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'') + '_' +  CONVERT(VARCHAR(50), b.ID) + ':' +  STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'') + '_' +  CONVERT(VARCHAR(50), b.ID) + '.HOM.qxp', 
	'ART DEPARTMENT-NEW:For SQL:FastTrak:Merge:Logs:' + STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'') + '_' +  CONVERT(VARCHAR(50), b.ID) + '.log', 
	'Graphic Business Solutions',
	'QXP',
	 STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'') + '_' +  CONVERT(VARCHAR(50), b.ID)
	FROM tblOrders a
	INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
	WHERE b.deleteX <> 'yes'
	AND b.processType = 'Custom'			
	AND a.orderType = 'Custom'
	AND b.ID NOT IN
			(SELECT ordersProductsID
			FROM tblOrdersProducts_productOptions
			WHERE deleteX <> 'yes'
			AND optionCaption = 'OPC')
	AND b.productName NOT LIKE '%Envelope%'
	AND b.productCode NOT LIKE 'NB%'
	AND b.productCode NOT LIKE 'NC%'
	AND b.productCode NOT LIKE 'BPFA%'
	AND b.productCode NOT LIKE 'ADJ%'
	AND SUBSTRING(b.productCode, 3, 2) <> 'QS'
	AND b.productCode <> 'RAP01'
	AND b.productCode NOT LIKE 'LH%'
	AND b.productCode NOT LIKE 'MS%'
	AND b.productCode NOT LIKE 'AP%'
	AND  STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'') NOT IN 
			(SELECT PKID
			FROM tblSwitchMerge
			WHERE PKID IS NOT NULL)
	AND DATEDIFF(MI, a.created_on, GETDATE()) > 10
	AND a.orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'in transit', 'in transit usps', 'on hom dock', 'on mrk dock')
	
			--TO RUN FB PNP AND CUSTOM ONLY, CHANGE THE SWITCHMERGE_CREATE CHECK TO "=1",
			--THEN ACTIVATE THE BLOCK OF CODE BELOW, SAVE SPROC, RUN SWITCHMERGE, 
			--THEN COME BACK AND RETURN EVERYTHING TO NORMAL.

			AND b.switchMerge_create = 0
	
			/*
			AND b.deleteX <> 'yes'
			AND b.processType LIKE 'Custom'
			AND b.productCode LIKE 'FB%'
			AND DATEPART(YY, a.orderDate) = '2020'
			*/

	ORDER BY  STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'')

	-- 3. Do field updates
	--INPUT 1 (yourname)
	UPDATE tblSwitchMerge
	SET yourName = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 1%'
	AND a.yourname IS NULL
	AND p.deleteX <> 'yes'

	--INPUT 2 (yourcompany)
	UPDATE tblSwitchMerge
	SET yourcompany = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p ON a.ordersProductsID = p.ordersProductsID
	WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 2%'
		  OR 
		  CONVERT(VARCHAR(255), p.optionCaption) LIKE '%Background Color%')
	AND p.deleteX <> 'yes'

	--INPUT 3 (input1)
	UPDATE tblSwitchMerge
	SET input1 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 3%'
	 OR CONVERT(VARCHAR(255), p.optionCaption) LIKE '%Text Color%')
	AND p.deleteX <> 'yes'

	--INPUT 4 /a
	UPDATE tblSwitchMerge
	SET input2 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 4%'
	 OR CONVERT(VARCHAR(255), p.optionGroupCaption) LIKE '%Frame%')
	AND p.deleteX <> 'yes'

	--INPUT 5 /a
	UPDATE tblSwitchMerge
	SET input3 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE (CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 5%'
	 OR CONVERT(VARCHAR(255), p.optionGroupCaption) LIKE '%Shape%')
	AND p.deleteX <> 'yes'

	--INPUT 6 /a
	UPDATE tblSwitchMerge
	SET input4 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 6%'
	AND p.deleteX <> 'yes'

	--INPUT 7
	UPDATE tblSwitchMerge
	SET input5 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 7%'
	AND p.deleteX <> 'yes'

	--INPUT 8
	UPDATE tblSwitchMerge
	SET input6 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 8%'
	AND p.deleteX <> 'yes'

	--INPUT 9
	UPDATE tblSwitchMerge
	SET input7 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 9%'
	AND p.deleteX <> 'yes'

	--INPUT 10
	UPDATE tblSwitchMerge
	SET input8 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Info Line 10%'
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET marketCenterName = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Market Center Name:%'
	AND p.deleteX <> 'yes'

	--topImage
	/*
		1. If that opid has that product option, and the value is "Default", then the value for the topImage field is: "<first six characters of the product code>-top<last two characters of product code>.gp"
		2. If that opid has that product option, and the value is "Black", then the value for the topImage field is: "<first six characters of the product code>-topBK.gp"
		3. If that opid has that product option, and the value is "White", then the value for the topImage field is: "<first six characters of the product code>-topWH.gp"
		4. If the opid has no product option "Background" (I think that's optionID 375), then leave the topImage field null,
	*/
	--1.
	UPDATE tblSwitchMerge
	SET topImage = SUBSTRING(productCode, 1, 6) + '-top' + RIGHT(productCode, 2) + '.gp'
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE p.ordersProductsID IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = '375'
		AND optionCaption = 'Default')

	--2.
	UPDATE tblSwitchMerge
	SET topImage = SUBSTRING(productCode, 1, 6) + '-top' + 'BK.gp'
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE p.ordersProductsID IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = '376'
		AND optionCaption = 'Black')

	--3.
	UPDATE tblSwitchMerge
	SET topImage = SUBSTRING(productCode, 1, 6) + '-top' + 'WH.gp'
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE p.ordersProductsID IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = '377'
		AND optionCaption = 'White')

	--4.
	UPDATE tblSwitchMerge
	SET topImage = NULL
	WHERE topImage NOT LIKE '%.gp'

	--5.
	UPDATE tblSwitchMerge
	SET topImage = 'HOM_Shortrun:SwitchMergeIn:CustomMagnetBackgrounds:Tops:' + topImage
	WHERE topImage IS NOT NULL
	AND topImage <> ''

	--csz
	UPDATE tblSwitchMerge
	SET csz = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'City/state/zip:%'
	AND p.deleteX <> 'yes'

	--yourName2
	UPDATE tblSwitchMerge
	SET yourName2 = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Your name:%'
	AND p.deleteX <> 'yes'

	--streetAddress
	UPDATE tblSwitchMerge
	SET streetAddress = CONVERT(VARCHAR(255), p.textValue)
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE CONVERT(VARCHAR(255), p.optionCaption) LIKE 'Street address:%'
	AND p.deleteX <> 'yes'

	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
	-- 3	A. Realtor Symbol
	-- 4	B. Equal Housing Opportunity Symbol
	-- 5	C. Realtor - MLS Combo Symbol
	-- 6	D. ABR Symbol
	-- 7	E. CRS Symbol
	-- 8	F. GRI Symbol
	-- 9	G. CRB Symbol
	-- 10	H. WCR Symbol
	-- 11	I. CRP Symbol
	-- 12	J. MLS Symbol
	-- 13	K. e-Pro Symbol
	-- 14	L. SRES Symbol
	-- 15	M. FDIC Symbol
	-- 141	N. Equal Housing Lender Symbol
	-- 155	O. NAHREP Symbol

	--400/401/402  VARIOUS NEW Symbol Types
	--400 is always Symbol #1, 401 is Symbol #2, 402 is Symbol #3

	--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.textValue
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 400
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 3
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 4
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 5
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 6
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 7
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 8
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 9
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 10
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 11
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 12
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 13
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 14
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 15
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 141
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionID = 155
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionCaption LIKE '%facebook%'
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionCaption LIKE '%linkedin%'
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionCaption LIKE '%SFR%'
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol1 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol1 IS NULL
	AND p.optionCaption LIKE '%Twitter%'
	AND p.deleteX <> 'yes'

	--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2
	UPDATE tblSwitchMerge
	SET profsymbol2 = p.textValue
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 401
	AND p.textValue <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 3
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 4
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 5
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 6
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 7
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 8
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 9
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 10
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 11
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 12
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 13
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 14
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 15
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 141
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 155
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%facebook%'
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%linkedin%'
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%SFR%'
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol2 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol2 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%Twitter%'
	AND p.optionCaption <> a.profsymbol1
	AND p.deleteX <> 'yes'

	--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3
	UPDATE tblSwitchMerge
	SET profsymbol3 = p.textValue
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 402
	AND p.textValue <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.textValue <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 3
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 4
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 5
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 6
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 7
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 8
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 9
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 10
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 11
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 12
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 13
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 14
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 15
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 141
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionID = 155
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%Facebook%'
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%linkedin%'
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%SFR%'
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	UPDATE tblSwitchMerge
	SET profsymbol3 = p.optionCaption
	FROM tblSwitchMerge a
	INNER JOIN tblOrdersProducts_ProductOptions p
		ON a.ordersProductsID = p.ordersProductsID
	WHERE a.profsymbol3 IS NULL
	AND a.profsymbol1 IS NOT NULL
	AND p.optionCaption LIKE '%Twitter%'
	AND p.optionCaption <> a.profsymbol1
	AND a.profsymbol2 IS NOT NULL
	AND p.optionCaption <> a.profsymbol2
	AND p.deleteX <> 'yes'

	--// Get symbol file names
	--400 series updates first.
	/*
	realtor
	equal housing opportunity
	facebook
	realtor-mls combo
	mls
	linkedin
	abr
	twitter
	gri
	crs
	sfr
	equal housing lender
	Realtor - MLS Combo
	e-pro
	sres
	wcr
	crp
	nahrep
	fdic
	crb
	multi-million *** no background avail.
	cdpe *** no background avail.
	gold-key *** no background avail.
	nar *** no background avail.
	mrp *** no background avail.
	youtube *** no background avail.
	instagram black *** no background avail.
	Pinterest Red *** no background avail.
	*/

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'A.Realtor.R.Stroke.eps'
	WHERE profsymbol1 = 'realtor'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'A.Realtor.R.Stroke.eps'
	WHERE profsymbol2 = 'realtor'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'A.Realtor.R.Stroke.eps'
	WHERE profsymbol3 = 'realtor'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'A.Realtor.R.Stroke.eps'
	WHERE profsymbol1 LIKE '%Realtor Symbol%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'A.Realtor.R.Stroke.eps'
	WHERE profsymbol2 LIKE '%Realtor Symbol%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'A.Realtor.R.Stroke.eps'
	WHERE profsymbol3 LIKE '%Realtor Symbol%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'B.EqualHousing.Stroke.eps'
	WHERE profsymbol1 LIKE '%Equal Housing Opportunity%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'B.EqualHousing.Stroke.eps'
	WHERE profsymbol2 LIKE '%Equal Housing Opportunity%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'B.EqualHousing.Stroke.eps'
	WHERE profsymbol3 LIKE '%Equal Housing Opportunity%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol1 LIKE '%realtor-mls combo%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol2 LIKE '%realtor-mls combo%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol3 LIKE '%realtor-mls combo%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol1 LIKE '%Realtor/MLS%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol2 LIKE '%Realtor/MLS%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol3 LIKE '%Realtor/MLS%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'J.MLS.Stroked.eps'
	WHERE profsymbol1 = 'mls'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'J.MLS.Stroked.eps'
	WHERE profsymbol2 = 'mls'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'J.MLS.Stroked.eps'
	WHERE profsymbol1 LIKE '%MLS Symbol%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'J.MLS.Stroked.eps'
	WHERE profsymbol2 LIKE '%MLS Symbol%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'J.MLS.Stroked.eps'
	WHERE profsymbol3 LIKE '%MLS Symbol%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'J.MLS.Stroked.eps'
	WHERE profsymbol3 = 'mls'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'D.abr.Stroke.eps'
	WHERE profsymbol1 LIKE '%ABR%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'D.abr.Stroke.eps'
	WHERE profsymbol2 LIKE '%ABR%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'D.abr.Stroke.eps'
	WHERE profsymbol3 LIKE '%ABR%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'E.crs.Stroke.eps'
	WHERE profsymbol1 LIKE '%CRS%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'E.crs.Stroke.eps'
	WHERE profsymbol2 LIKE '%CRS%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'E.crs.Stroke.eps'
	WHERE profsymbol3 LIKE '%CRS%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'F.gri.Stroke.eps'
	WHERE profsymbol1 LIKE '%GRI%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'F.gri.Stroke.eps'
	WHERE profsymbol2 LIKE '%GRI%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'F.gri.Stroke.eps'
	WHERE profsymbol3 LIKE '%GRI%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'N.EHLender.Stroke.eps'
	WHERE profsymbol1 LIKE '%Equal Housing Lender%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'N.EHLender.Stroke.eps'
	WHERE profsymbol2 LIKE '%Equal Housing Lender%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'N.EHLender.Stroke.eps'
	WHERE profsymbol3 LIKE '%Equal Housing Lender%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol1 LIKE '%Realtor - MLS Combo%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol2 LIKE '%Realtor - MLS Combo%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'C.Realtor.MLS.Stroke.eps'
	WHERE profsymbol3 LIKE '%Realtor - MLS Combo%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'K.epro.Stroke.eps'
	WHERE profsymbol1 LIKE '%e-Pro%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'K.epro.Stroke.eps'
	WHERE profsymbol2 LIKE '%e-Pro%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'K.epro.Stroke.eps'
	WHERE profsymbol3 LIKE '%e-Pro%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'L.sres.Stroke.eps'
	WHERE profsymbol1 LIKE '%SRES%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'L.sres.Stroke.eps'
	WHERE profsymbol2 LIKE '%SRES%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'L.sres.Stroke.eps'
	WHERE profsymbol3 LIKE '%SRES%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'H.WCI.Stroke.eps'
	WHERE profsymbol1 LIKE '%WCR%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'H.WCI.Stroke.eps'
	WHERE profsymbol2 LIKE '%WCR%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'H.WCI.Stroke.eps'
	WHERE profsymbol3 LIKE '%WCR%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'I.crp.stroke.eps'
	WHERE profsymbol1 LIKE '%CRP%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'I.crp.stroke.eps'
	WHERE profsymbol2 LIKE '%CRP%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'I.crp.stroke.eps'
	WHERE profsymbol3 LIKE '%CRP%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'M.FDIC.Stroke.eps'
	WHERE profsymbol1 LIKE '%FDIC%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'M.FDIC.Stroke.eps'
	WHERE profsymbol2 LIKE '%FDIC%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'M.FDIC.Stroke.eps'
	WHERE profsymbol3 LIKE '%FDIC%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'O.NAHREP.Stroke.eps'
	WHERE profsymbol1 LIKE '%NAHREP%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'O.NAHREP.Stroke.eps'
	WHERE profsymbol2 LIKE '%NAHREP%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'O.NAHREP.Stroke.eps'
	WHERE profsymbol3 LIKE '%NAHREP%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'G.crb.Stroke.eps'
	WHERE profsymbol1 LIKE '%CRB%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'G.crb.Stroke.eps'
	WHERE profsymbol2 LIKE '%CRB%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'G.crb.Stroke.eps'
	WHERE profsymbol3 LIKE '%CRB%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'Facebook.Stroke.eps'
	WHERE profsymbol1 LIKE '%facebook%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'Facebook.Stroke.eps'
	WHERE profsymbol2 LIKE '%facebook%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'Facebook.Stroke.eps'
	WHERE profsymbol3 LIKE '%facebook%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'LinkedIn.Stroke.eps'
	WHERE profsymbol1 LIKE '%linkedin%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'LinkedIn.Stroke.eps'
	WHERE profsymbol2 LIKE '%linkedin%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'LinkedIn.Stroke.eps'
	WHERE profsymbol3 LIKE '%linkedin%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'SFR.Stroke.eps'
	WHERE profsymbol1 LIKE '%SFR%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'SFR.Stroke.eps'
	WHERE profsymbol2 LIKE '%SFR%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'SFR.Stroke.eps'
	WHERE profsymbol3 LIKE '%SFR%'

	UPDATE tblSwitchMerge
	SET profsymbol1 = 'Twitter.Stroke.eps'
	WHERE profsymbol1 LIKE '%twitter%'

	UPDATE tblSwitchMerge
	SET profsymbol2 = 'Twitter.Stroke.eps'
	WHERE profsymbol2 LIKE '%twitter%'

	UPDATE tblSwitchMerge
	SET profsymbol3 = 'Twitter.Stroke.eps'
	WHERE profsymbol3 LIKE '%twitter%'


	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.

	--BKGND_OLD
	UPDATE tblSwitchMerge
	SET bkgnd_old = x.artBackgroundImageName
	FROM tblSwitchMerge a
	INNER JOIN tblProducts x
		ON a.productID = x.productID
	WHERE a.bkgnd_old IS NULL
	AND x.artBackgroundImageName IS NOT NULL

	-- FIX NCC ROWS
	UPDATE tblSwitchMerge
	SET yourName = NULL
	WHERE orderNo IN 
		(SELECT orderNo
		FROM tblOrders
		WHERE orderID IN 
			(SELECT orderID
			 FROM tblOrders_Products
			 WHERE productID IN 
				 (SELECT productID
				 FROM tblProducts
				 WHERE productCompany = 'NCC')))

	--ENTERDATE
	UPDATE tblSwitchMerge
	SET enterDate = CONVERT(VARCHAR(255), DATEPART(MONTH, GETDATE())) + '/' + CONVERT(VARCHAR(255), DATEPART(DAY, GETDATE())) + '/' + CONVERT(VARCHAR(255), DATEPART(YEAR, GETDATE()))
	WHERE enterDate IS NULL
	AND orderNo IS NOT NULL

	--DELETE STOCK-ONLY ORDERS
	DELETE FROM tblSwitchMerge
	WHERE orderNo IN 
		(SELECT orderNo
		 FROM tblOrders
		 WHERE orderType = 'Stock')

	--DELETE NULL ORDERNO'S
	DELETE FROM tblSwitchMerge
	WHERE orderNo IS NULL

	DELETE FROM tblSwitchMerge
	WHERE orderNo NOT IN 
		(SELECT orderNo
		 FROM tblOrders a
		 WHERE DATEDIFF(dd, a.orderDate, GETDATE()) < 170
 		 AND a.orderStatus <> 'failed'
		 AND a.orderStatus <> 'cancelled'
		 AND a.orderType = 'Custom'
		 AND a.orderID IN 
			 (SELECT orderID
			 FROM tblOrders_Products
			 WHERE deleteX <> 'yes'
			 AND productCode NOT LIKE '%NB%'
		 AND orderID IS NOT NULL))
	AND productCode <> 'NB00SU-001'

	-- 4. Clean data so that it is in the format required by Production.
	-- FIX productQuantity
	UPDATE tblSwitchMerge
	SET productQuantity = productQuantity * 500
	WHERE productCode LIKE 'BC%'
	AND productQuantity IS NOT NULL

	UPDATE tblSwitchMerge
	SET productQuantity = productQuantity * 500
	WHERE productCode LIKE 'KWBC%'
	AND productQuantity IS NOT NULL

	UPDATE tblSwitchMerge
	SET productQuantity = productQuantity * 250
	WHERE productCode LIKE 'GNNC%'
	AND productQuantity IS NOT NULL

	UPDATE tblSwitchMerge
	SET productQuantity = productQuantity * 100
	WHERE productCode NOT LIKE 'BC%'
	AND productCode NOT LIKE 'GNNC%'
	AND productCode NOT LIKE 'HLBG%'
	AND productQuantity IS NOT NULL

	-- FIX groupPicture
	UPDATE tblSwitchMerge
	SET groupPicture = ''
	WHERE groupPicture IS NULL

	UPDATE tblSwitchMerge
	SET groupPicture = productCode + '.gp'
	WHERE productCode NOT LIKE 'BB%'
	AND productCode NOT LIKE 'FB%'
	AND productCode NOT LIKE 'BK%'
	AND productCode NOT LIKE 'HY%'
	AND productCode NOT LIKE 'HB%'
	AND productCode NOT LIKE 'BH%'
	AND productCode NOT LIKE 'CA%'
	AND productCode NOT LIKE 'PG%'
	AND groupPicture NOT LIKE '%.gp'
	AND groupPicture NOT LIKE '%.eps'

	UPDATE tblSwitchMerge
	SET groupPicture = productCode + '.eps'
	WHERE groupPicture NOT LIKE '%.gp'
	AND groupPicture NOT LIKE '%.eps'
	AND (productCode LIKE 'FB%' 
		OR productCode LIKE 'BK%' 
		OR productCode LIKE 'BB%' 
		OR productCode LIKE 'HY%'
		OR productCode LIKE 'BH%'
		OR productCode LIKE 'PG%'
		OR productCode LIKE 'CA%'
		OR productCode LIKE 'HB%')

	UPDATE tblSwitchMerge
	SET groupPicture = productCode + '.gp'
	WHERE groupPicture NOT LIKE '%.gp'
	AND groupPicture NOT LIKE '%.eps'
	AND (productCode LIKE 'BC%'
		OR productName LIKE '%calendar%'
		OR productName LIKE '%Halloween Bag%')

	UPDATE tblSwitchMerge
	SET groupPicture = productCode + '.eps'
	WHERE productCode NOT LIKE 'BC%'
	AND productName NOT LIKE '%Halloween Bag%'
	AND groupPicture NOT LIKE '%.gp'
	AND groupPicture NOT LIKE '%.eps'

	--All products starting with BB, FB, BK, and HY should have QC changed to QS and QM changed to QS.
	UPDATE tblSwitchMerge
	SET groupPicture = REPLACE(groupPicture, 'QC', 'QS')
	WHERE groupPicture LIKE 'BB%'
	OR groupPicture LIKE 'FB%'
	OR groupPicture LIKE 'BK%'
	OR groupPicture LIKE 'HY%'
	OR groupPicture LIKE 'PG%'
	OR groupPicture LIKE 'HB%'
	OR groupPicture LIKE 'BH%'

	UPDATE tblSwitchMerge
	SET groupPicture = REPLACE(groupPicture, 'QM', 'QS')
	WHERE groupPicture LIKE 'BB%'
	OR groupPicture LIKE 'FB%'
	OR groupPicture LIKE 'BK%'
	OR groupPicture LIKE 'HY%'
	OR groupPicture LIKE 'PG%'
	OR groupPicture LIKE 'HB%'
	OR groupPicture LIKE 'BH%'

	--//new code; jf 7/7/16.
	UPDATE tblSwitchMerge
	SET groupPicture = 'HOM_Shortrun:SwitchMergeIn:CustomMagnetBackgrounds:' + SUBSTRING(productCode, 1, 2) + ':' + groupPicture
	WHERE groupPicture IS NOT NULL
	AND groupPicture <> ''

	-- wipe projectName
	UPDATE tblSwitchMerge
	SET projectName = NULL

	-- FIX bkgnd_old
	UPDATE tblSwitchMerge
	SET bkgnd_old = REPLACE(REPLACE(bkgnd_old, 'QC', 'QS'), 'QM', 'QS')
	WHERE productCode LIKE 'FB%'
	OR productCode LIKE 'BB%'
	OR productCode LIKE 'HK%'
	OR productCode LIKE 'BK%'

	UPDATE tblSwitchMerge
	SET bkgnd_old = REPLACE(bkgnd_old, 'SP', '')
	WHERE bkgnd_old LIKE '%SP'

	-- FIX sequencing for orders that have more than 1 custom product in the order (XXXXX_1, XXXXX_2, etc.)
	TRUNCATE TABLE tblSwitchMerge_Sequencer

	INSERT INTO tblSwitchMerge_Sequencer (PKID, countPKID)
	SELECT PKID AS 'PKID', COUNT(PKID) AS 'countPKID'
	FROM tblSwitchMerge
	GROUP BY PKID
	HAVING COUNT(PKID) > 1
	ORDER BY COUNT(PKID) DESC

	UPDATE tblSwitchMerge
	SET sequencer = b.countPKID
	FROM tblSwitchMerge a INNER JOIN  tblSwitchMerge_Sequencer b ON  a.PKID = b.PKID

	UPDATE tblSwitchMerge_Sequencer
	SET lowestArb = b.arb
	FROM tblSwitchMerge_Sequencer a INNER JOIN  tblSwitchMerge b ON  a.PKID = b.PKID
	WHERE b.arb IN 
		(SELECT TOP 1 arb
		FROM tblSwitchMerge
		WHERE PKID = a.PKID
		ORDER BY arb ASC)

	UPDATE tblSwitchMerge
	SET PKID = CONVERT(VARCHAR(50), a.PKID) + '_' + CONVERT(VARCHAR(50), (a.arb-b.lowestArb+1))
	FROM tblSwitchMerge a INNER JOIN  tblSwitchMerge_Sequencer b ON  a.PKID = b.PKID

	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--SET NULLS: for comparitive clauses to follow.
	UPDATE tblSwitchMerge
	SET logo1 = ''
	WHERE logo1 IS NULL

	UPDATE tblSwitchMerge
	SET logo2 = ''
	WHERE logo2 IS NULL

	UPDATE tblSwitchMerge
	SET photo1 = ''
	WHERE photo1 IS NULL

	UPDATE tblSwitchMerge
	SET photo2 = ''
	WHERE photo2 IS NULL

	UPDATE tblSwitchMerge
	SET overflow1 = ''
	WHERE overflow1 IS NULL

	UPDATE tblSwitchMerge
	SET overflow2 = ''
	WHERE overflow2 IS NULL

	UPDATE tblSwitchMerge
	SET overflow3 = ''
	WHERE overflow3 IS NULL

	UPDATE tblSwitchMerge
	SET overflow4 = ''
	WHERE overflow4 IS NULL

	UPDATE tblSwitchMerge
	SET overflow5 = ''
	WHERE overflow5 IS NULL

	UPDATE tblSwitchMerge
	SET previousJobArt = ''
	WHERE previousJobArt IS NULL

	UPDATE tblSwitchMerge
	SET previousJobInfo = ''
	WHERE previousJobInfo IS NULL

	UPDATE tblSwitchMerge
	SET artInstructions = ''
	WHERE artInstructions IS NULL

	--- PART 1/1 (Create-Your-Own Merge Columns): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE tblSwitchMerge
	SET backgroundFileName = ''
	WHERE backgroundFileName IS NULL

	UPDATE tblSwitchMerge
	SET layoutFileName = ''
	WHERE layoutFileName IS NULL

	UPDATE tblSwitchMerge
	SET productBack = ''
	WHERE productBack IS NULL

	UPDATE tblSwitchMerge
	SET team1FileName = ''
	WHERE team1FileName IS NULL

	UPDATE tblSwitchMerge
	SET team2FileName = ''
	WHERE team2FileName IS NULL

	UPDATE tblSwitchMerge
	SET team3FileName = ''
	WHERE team3FileName IS NULL

	UPDATE tblSwitchMerge
	SET team4FileName = ''
	WHERE team4FileName IS NULL

	UPDATE tblSwitchMerge
	SET team5FileName = ''
	WHERE team5FileName IS NULL

	UPDATE tblSwitchMerge
	SET team6FileName = ''
	WHERE team6FileName IS NULL

	UPDATE tblSwitchMerge
	SET backgroundFileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Background File Name'
	AND b.deleteX <> 'yes'
	AND a.backgroundFileName <> b.textValue

	UPDATE tblSwitchMerge
	SET layoutFileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Layout File Name'
	AND b.deleteX <> 'yes'
	AND a.layoutFileName <> b.textValue

	--// new update to extension on productBack as of 7/7/16; jf.
	--	  additional update to add path to productBack; 7/12/16; jf.
	UPDATE tblSwitchMerge
	SET productBack = 'HOM_Shortrun:SwitchMergeIn:Backs:' + b.textValue + '.eps'
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Product Back'
	AND b.deleteX <> 'yes'
	AND a.productBack <> b.textValue

	UPDATE tblSwitchMerge
	SET team1FileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Team 1 File Name'
	AND b.deleteX <> 'yes'
	AND a.team1FileName <> b.textValue

	UPDATE tblSwitchMerge
	SET team2FileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 2 File Name'
	AND b.deleteX <> 'yes'
	AND a.team2FileName <> b.textValue

	UPDATE tblSwitchMerge
	SET team3FileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Team 3 File Name'
	AND b.deleteX <> 'yes'
	AND a.team3FileName <> b.textValue

	UPDATE tblSwitchMerge
	SET team4FileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE   b.optionCaption = 'Team 4 File Name'
	AND b.deleteX <> 'yes'
	AND a.team4FileName <> b.textValue

	UPDATE tblSwitchMerge
	SET team5FileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Team 5 File Name'
	AND b.deleteX <> 'yes'
	AND a.team5FileName <> b.textValue

	UPDATE tblSwitchMerge
	SET team6FileName = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Team 6 File Name'
	AND b.deleteX <> 'yes'
	AND a.team6FileName <> b.textValue

	--- PART 1/3 (LOGO): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ******** LOGO1 ************
	UPDATE tblSwitchMerge
	SET logo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.logo1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.logo1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.logo1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.logo1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.logo1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue

	-- ******** LOGO2 ************
	UPDATE tblSwitchMerge
	SET logo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.logo1 <> ''
	AND a.logo2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.logo1 <> ''
	AND a.logo2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.logo1 <> ''
	AND a.logo2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.logo1 <> ''
	AND a.logo2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.logo1 <> ''
	AND a.logo2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue

	--- PART 2/3 (PHOTO): ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ******** PHOTO1 ************
	UPDATE tblSwitchMerge
	SET photo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.photo1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.photo1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.photo1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.photo1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.photo1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue

	-- ******** PHOTO2 ************
	UPDATE tblSwitchMerge
	SET photo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.photo1 <> ''
	AND a.photo2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.photo1 <> ''
	AND a.photo2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.photo1 <> ''
	AND a.photo2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.photo1 <> ''
	AND a.photo2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.photo1 <> ''
	AND a.photo2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue

	--- PART 3/3 (OVERFLOW): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ******** OVERFLOW1 ************
	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 1%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption LIKE '%File Name 2%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 3%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 4%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue

	-- ******** OVERFLOW2 ************
	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 1%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 2%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 3%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 4%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue

	-- ******** OVERFLOW3 ************
	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 1%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 2%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 3%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 4%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue

	-- ******** OVERFLOW4 ************
	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 1%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 2%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 3%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name 4%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue

	-- ******** OVERFLOW5 ************
	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE '%-v%'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'logo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'photo%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '1.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '2.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '3.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '4.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue LIKE 'misc%'
	AND SUBSTRING(RIGHT(b.textValue, 5), 1, 2) = '5.'
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	-- ******** MISC ************
	--MISC LOGOS
	UPDATE tblSwitchMerge
	SET logo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE '%logo%'
	AND a.logo1 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET logo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE '%logo%'
	AND a.logo1 <> ''
	AND a.logo2 = ''
	AND b.deleteX <> 'yes'
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	--MISC PHOTOS
	UPDATE tblSwitchMerge
	SET photo1 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE '%phot%'
	AND a.photo1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET photo2 = b.textValue
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE '%File Name%'
	AND b.textValue LIKE '%phot%'
	AND a.photo1 <> ''
	AND a.photo2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	--MISC UNKNOWN FILES
	UPDATE tblSwitchMerge
	SET overflow1 = LEFT(b.textValue, 255)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.overflow1 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow2 = LEFT(b.textValue, 255)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.overflow1 <> ''
	AND a.overflow2 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow3 = LEFT(b.textValue, 255)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow4 = LEFT(b.textValue, 255)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	UPDATE tblSwitchMerge
	SET overflow5 = LEFT(b.textValue, 255)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption LIKE 'File Name%'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.overflow1 <> ''
	AND a.overflow2 <> ''
	AND a.overflow3 <> ''
	AND a.overflow4 <> ''
	AND a.overflow5 = ''
	AND b.deleteX <> 'yes'
	AND a.photo1 <> b.textValue
	AND a.photo2 <> b.textValue
	AND a.logo1 <> b.textValue
	AND a.logo2 <> b.textValue
	AND a.overflow1 <> b.textValue
	AND a.overflow2 <> b.textValue
	AND a.overflow3 <> b.textValue
	AND a.overflow4 <> b.textValue
	AND a.overflow5 <> b.textValue

	-- ******** THE INSTRUCTIONS ************
	UPDATE tblSwitchMerge
	SET previousJobArt = LEFT(b.textValue, 250)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Previous Job Art'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.previousJobArt <> b.textValue

	UPDATE tblSwitchMerge
	SET previousJobInfo = LEFT(b.textValue, 250)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Previous Job Info'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.previousJobInfo <> b.textValue

	UPDATE tblSwitchMerge
	SET artInstructions = LEFT(b.textValue, 250)
	FROM tblSwitchMerge a INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption = 'Art Instructions'
	AND b.textValue IS NOT NULL
	AND b.textValue <> ''
	AND a.artInstructions <> b.textValue

	--// CLEAN BEGIN ------------------------------------------------------------------------------------------------------------------------------
	--yourName FIELD
	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#174', '®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '(R)', '®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&amp', '&')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&quot', '"')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'REALTOR', 'REALTOR®')
	WHERE yourName NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, 'REALTORS', 'REALTORS®')
	WHERE yourName NOT LIKE '%REALTORS®%'
	AND yourName LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '®®', '®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, ',', ', ')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, ' ', ' ')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, ' ', ' ')

	UPDATE tblSwitchMerge
	SET yourName = REPLACE(yourName, '®', '<V>®<P>')

	--yourCompany FIELD
	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#174', '®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '(R)', '®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&amp', '&')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&quot', '"')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'REALTOR', 'REALTOR®')
	WHERE yourCompany NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, 'REALTORS', 'REALTORS®')
	WHERE yourCompany NOT LIKE '%REALTORS®%'
	AND yourCompany LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '®®', '®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, ',', ', ')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, ' ', ' ')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, ' ', ' ')

	UPDATE tblSwitchMerge
	SET yourCompany = REPLACE(yourCompany, '®', '<V>®<P>')

	--input1 FIELD
	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'REALTOR', 'REALTOR®')
	WHERE input1 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, 'REALTORS', 'REALTORS®')
	WHERE input1 NOT LIKE '%REALTORS®%'
	AND input1 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '®®', '®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, ',', ', ')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input1 = REPLACE(input1, '®', '<V>®<P>')

	--input2 FIELD
	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'REALTOR', 'REALTOR®')
	WHERE input2 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, 'REALTORS', 'REALTORS®')
	WHERE input2 NOT LIKE '%REALTORS®%'
	AND input2 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '®®', '®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, ',', ', ')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input2 = REPLACE(input2, '®', '<V>®<P>')

	--input3 FIELD
	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'REALTOR', 'REALTOR®')
	WHERE input3 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, 'REALTORS', 'REALTORS®')
	WHERE input3 NOT LIKE '%REALTORS®%'
	AND input3 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '®®', '®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, ',', ', ')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input3 = REPLACE(input3, '®', '<V>®<P>')

	--input4 FIELD
	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'REALTOR', 'REALTOR®')
	WHERE input4 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, 'REALTORS', 'REALTORS®')
	WHERE input4 NOT LIKE '%REALTORS®%'
	AND input4 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '®®', '®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, ',', ', ')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input4 = REPLACE(input4, '®', '<V>®<P>')

	--input5 FIELD
	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'REALTOR', 'REALTOR®')
	WHERE input5 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, 'REALTORS', 'REALTORS®')
	WHERE input5 NOT LIKE '%REALTORS®%'
	AND input5 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '®®', '®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, ',', ', ')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input5 = REPLACE(input5, '®', '<V>®<P>')

	--input6 FIELD
	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'REALTOR', 'REALTOR®')
	WHERE input6 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, 'REALTORS', 'REALTORS®')
	WHERE input6 NOT LIKE '%REALTORS®%'
	AND input6 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '®®', '®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, ',', ', ')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input6 = REPLACE(input6, '®', '<V>®<P>')

	--input7 FIELD
	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'REALTOR', 'REALTOR®')
	WHERE input7 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, 'REALTORS', 'REALTORS®')
	WHERE input7 NOT LIKE '%REALTORS®%'
	AND input7 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '®®', '®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, ',', ', ')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input7 = REPLACE(input7, '®', '<V>®<P>')

	--input8 FIELD
	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#174', '®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '(R)', '®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&amp', '&')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&quot', '"')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'REALTOR', 'REALTOR®')
	WHERE input8 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, 'REALTORS', 'REALTORS®')
	WHERE input8 NOT LIKE '%REALTORS®%'
	AND input8 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '®®', '®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, ',', ', ')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, ' ', ' ')

	UPDATE tblSwitchMerge
	SET input8 = REPLACE(input8, '®', '<V>®<P>')

	--marketCenterName FIELD
	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#174', '®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '(R)', '®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&amp', '&')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&quot', '"')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'REALTOR', 'REALTOR®')
	WHERE marketCenterName NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, 'REALTORS', 'REALTORS®')
	WHERE marketCenterName NOT LIKE '%REALTORS®%'
	AND marketCenterName LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '®®', '®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, ',', ', ')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, ' ', ' ')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, ' ', ' ')

	UPDATE tblSwitchMerge
	SET marketCenterName = REPLACE(marketCenterName, '®', '<V>®<P>')

	--topImage FIELD
	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#174', '®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '(R)', '®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&amp', '&')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&quot', '"')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'REALTOR', 'REALTOR®')
	WHERE topImage NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, 'REALTORS', 'REALTORS®')
	WHERE topImage NOT LIKE '%REALTORS®%'
	AND topImage LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '®®', '®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, ',', ', ')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, ' ', ' ')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, ' ', ' ')

	UPDATE tblSwitchMerge
	SET topImage = REPLACE(topImage, '®', '<V>®<P>')

	--streetAddress FIELD
	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#174', '®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '(R)', '®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&amp', '&')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&quot', '"')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'REALTOR', 'REALTOR®')
	WHERE streetAddress NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, 'REALTORS', 'REALTORS®')
	WHERE streetAddress NOT LIKE '%REALTORS®%'
	AND streetAddress LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '®®', '®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, ',', ', ')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, ' ', ' ')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, ' ', ' ')

	UPDATE tblSwitchMerge
	SET streetAddress = REPLACE(streetAddress, '®', '<V>®<P>')

	--csz FIELD
	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#174', '®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '(R)', '®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&amp', '&')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&quot', '"')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'REALTOR', 'REALTOR®')
	WHERE csz NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, 'REALTORS', 'REALTORS®')
	WHERE csz NOT LIKE '%REALTORS®%'
	AND csz LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '®®', '®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, ',', ', ')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, ' ', ' ')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, ' ', ' ')

	UPDATE tblSwitchMerge
	SET csz = REPLACE(csz, '®', '<V>®<P>')

	--yourName2 FIELD
	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#174', '®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '(R)', '®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&amp', '&')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&quot', '"')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'REALTOR', 'REALTOR®')
	WHERE yourName2 NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, 'REALTORS', 'REALTORS®')
	WHERE yourName2 NOT LIKE '%REALTORS®%'
	AND yourName2 LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '®®', '®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, ',', ', ')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, ' ', ' ')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, ' ', ' ')

	UPDATE tblSwitchMerge
	SET yourName2 = REPLACE(yourName2, '®', '<V>®<P>')

	--artInstructions FIELD
	UPDATE tblSwitchMerge
	SET artInstructions = LEFT(artInstructions, 230)
	WHERE Len(artInstructions) > 230

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#174', '®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '(R)', '®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&amp', '&')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&quot', '"')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'REALTOR', 'REALTOR®')
	WHERE artInstructions NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, 'REALTORS', 'REALTORS®')
	WHERE artInstructions NOT LIKE '%REALTORS®%'
	AND artInstructions LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '®®', '®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, CHAR(13) + CHAR(10), ' ')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, ',', ', ')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, ' ', ' ')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, ' ', ' ')

	UPDATE tblSwitchMerge
	SET artInstructions = REPLACE(artInstructions, '®', '<V>®<P>')

	--previousJobArt FIELD
	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#174', '®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '(R)', '®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&amp', '&')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&quot', '"')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'REALTOR', 'REALTOR®')
	WHERE previousJobArt NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, 'REALTORS', 'REALTORS®')
	WHERE previousJobArt NOT LIKE '%REALTORS®%'
	AND previousJobArt LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '®®', '®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, ',', ', ')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, CHAR(13) + CHAR(10), ' ')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, ' ', ' ')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, ' ', ' ')

	UPDATE tblSwitchMerge
	SET previousJobArt = REPLACE(previousJobArt, '®', '<V>®<P>')

	--previousJobInfo FIELD
	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#174;', '®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#174', '®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '(R)', '®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&amp;', '&')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&amp', '&')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&quot;', '"')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&quot', '"')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#233;', 'é')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#233', 'é')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#241;', 'ñ')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#241', 'ñ')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#211;', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#243;', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#211', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '&#243', 'Ó')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'realtor', 'REALTOR')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR-Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR - Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR Associate', 'REALTOR-ASSOCIATE®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'REALTOR', 'REALTOR®')
	WHERE previousJobInfo NOT LIKE '%REALTOR-ASSOCIATE%'

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, 'REALTORS', 'REALTORS®')
	WHERE previousJobInfo NOT LIKE '%REALTORS®%'
	AND previousJobInfo LIKE '%REALTORS%'

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '®®', '®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '®-', ' ® -')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '-®', ' - ®')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, ',', ', ')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, CHAR(13) + CHAR(10), ' ')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, ' ', ' ')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, ' ', ' ')

	UPDATE tblSwitchMerge
	SET previousJobInfo = REPLACE(previousJobInfo, '®', '<V>®<P>')

	--// CLEAN END--------------------------------------------------------------------------------------------------------------------------------------------
	--// Update 2 columns in the SwitchMerge when a product is an OPC product (JF 092514)
	UPDATE tblSwitchMerge
	SET overflow1 = 'OPC'
	WHERE ordersProductsID IN 
		(SELECT ordersProductsID
		 FROM tblOrdersProducts_productOptions
		 WHERE optionCaption = 'OPC')

	UPDATE tblSwitchMerge
	SET logo1 = RIGHT(logo1, CHARINDEX('/', REVERSE(logo1)) - 1)
	WHERE logo1 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET logo2 = RIGHT(logo2, CHARINDEX('/', REVERSE(logo2)) - 1)
	WHERE logo2 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET photo1 = RIGHT(photo1, CHARINDEX('/', REVERSE(photo1)) - 1)
	WHERE photo1 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET photo2 = RIGHT(photo2, CHARINDEX('/', REVERSE(photo2)) - 1)
	WHERE photo2 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET overflow1 = RIGHT(overflow1, CHARINDEX('/', REVERSE(overflow1)) - 1)
	WHERE overflow1 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET overflow2 = RIGHT(overflow2, CHARINDEX('/', REVERSE(overflow2)) - 1)
	WHERE overflow2 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET overflow3 = RIGHT(overflow3, CHARINDEX('/', REVERSE(overflow3)) - 1)
	WHERE overflow3 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET overflow4 = RIGHT(overflow4, CHARINDEX('/', REVERSE(overflow4)) - 1)
	WHERE overflow4 LIKE '%/%'

	UPDATE tblSwitchMerge
	SET overflow5 = RIGHT(overflow5, CHARINDEX('/', REVERSE(overflow5)) - 1)
	WHERE overflow5 LIKE '%/%'

	--// new updates to profSymbol fields; jf 7/7/16.
	UPDATE tblSwitchMerge
	SET profSymbol1 = 'HOM_Shortrun:SwitchMergeIn:Realtor symbols Stroked:' + profSymbol1
	WHERE profSymbol1 IS NOT NULL
	AND profSymbol1 <> '' 

	UPDATE tblSwitchMerge
	SET profSymbol2 = 'HOM_Shortrun:SwitchMergeIn:Realtor symbols Stroked:' + profSymbol2
	WHERE profSymbol2 IS NOT NULL
	AND profSymbol2 <> '' 

	UPDATE tblSwitchMerge
	SET profSymbol3 = 'HOM_Shortrun:SwitchMergeIn:Realtor symbols Stroked:' + profSymbol3
	WHERE profSymbol3 IS NOT NULL
	AND profSymbol3 <> '' 

	--// Template work; jf 9/27/16.
	--//-----------------------------------------------------------------------------------------------------------------------
	--//Denull productBack
	UPDATE tblSwitchMerge
	SET productBack = ''
	WHERE productBack IS NULL

	--1. SET TEMPLATES
	--CA
	UPDATE tblSwitchMerge
	SET template = REPLACE(template, 'X.gp', b.templateBase)
	--select a.template, a.productBack, b.*
	FROM tblSwitchMerge a
	INNER JOIN tblSwitchMerge_templateReference b
		ON SUBSTRING(a.productCode, 1, 4) = SUBSTRING(b.productCode, 1, 4)
	WHERE SUBSTRING(a.productCode, 7, 4) = SUBSTRING(b.productCode, 7, 4)
	AND a.productCode LIKE 'CA%'
	AND LEN(a.productCode) > 4

	--SPORTS
	UPDATE tblSwitchMerge
	SET template = REPLACE(template, 'X.gp', b.templateBase)
	--select a.template. a.productBack, b.*
	FROM tblSwitchMerge a
	INNER JOIN tblSwitchMerge_templateReference b
		ON SUBSTRING(a.productCode, 1, 3) = SUBSTRING(b.productCode, 1, 3)
	WHERE LEN(b.productCode) = 3

	--SPORTS
	UPDATE tblSwitchMerge
	SET template = REPLACE(template, 'X.gp', b.templateBase)
	--select a.template. a.productBack, b.*
	FROM tblSwitchMerge a
	INNER JOIN tblSwitchMerge_templateReference b
		ON SUBSTRING(a.productCode, 1, 4) = SUBSTRING(b.productCode, 1, 4)
	WHERE LEN(b.productCode) = 4

	--EXACT MATCHES
	UPDATE tblSwitchMerge
	SET template = REPLACE(template, 'X.gp', b.templateBase)
	--select  *
	FROM tblSwitchMerge a
	INNER JOIN tblSwitchMerge_templateReference b
		ON a.productCode = b.productCode

	--GENERICS
	UPDATE tblSwitchMerge
	SET template = 'HOM_Shortrun:SwitchMergeIn:Templates:GENTEMP.gp'
	WHERE template IS NULL
	OR template = ''
	OR template = 'HOM_Shortrun:SwitchMergeIn:Templates:X.gp'

	--2. SET FONT COLORS (currently only applies to CA products) (and now Generics too; JF 10/18/16)
	UPDATE tblSwitchMerge
	SET 
	yourName = '<c"' + b.fontColor + '">' + yourName,
	yourCompany = '<c"' + b.fontColor + '">' + yourCompany,
	input1 = '<c"' + b.fontColor + '">' + input1,
	input2 = '<c"' + b.fontColor + '">' + input2,
	input3 = '<c"' + b.fontColor + '">' + input3,
	input4 = '<c"' + b.fontColor + '">' + input4,
	input5 = '<c"' + b.fontColor + '">' + input5,
	input6 = '<c"' + b.fontColor + '">' + input6
	--select a.*
	FROM tblSwitchMerge a
	INNER JOIN tblSwitchMerge_templateReference b
		ON SUBSTRING(a.productCode, 1, 4) = SUBSTRING(b.productCode, 1, 4)
	WHERE SUBSTRING(a.productCode, 7, 4) = SUBSTRING(b.productCode, 7, 4)
	AND a.productCode LIKE 'CA%'
	AND b.fontColor IS NOT NULL
	OR template = 'HOM_Shortrun:SwitchMergeIn:Templates:GENTEMP.gp'

	--3. PRODUCT BACK CONSIDERATIONS
	--if there is a productBack for an OPID, then add "D" prior to extension.
	UPDATE tblSwitchMerge
	SET template = REPLACE(template, '.gp', 'D.gp')
	WHERE productBack IS NOT NULL
	AND productBack <> ''
	AND template <> 'HOM_Shortrun:SwitchMergeIn:Templates:GENTEMP.gp'

	--select * from tblSwitchMerge_templateReference
	--select * FROM tblSwitchMerge

	UPDATE tblswitchmerge
		SET artwork = CONVERT(VARCHAR(255), p.textValue)
		FROM tblswitchmerge a
			INNER JOIN tblOrdersProducts_ProductOptions p ON a.ordersProductsID = p.ordersProductsID
		WHERE convert(VARCHAR(255), p.optionCaption) = 'Artwork'
			AND p.deleteX <> 'yes'


END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH


SELECT * FROM tblswitchmerge