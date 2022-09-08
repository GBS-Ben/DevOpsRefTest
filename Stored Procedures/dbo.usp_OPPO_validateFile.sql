CREATE PROCEDURE [dbo].[usp_OPPO_validateFile] @ProductType NVARCHAR(50)
AS
/*-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			08/06/18
Purpose			Validates that OPC asset files exists on local directory through
				a series of different checks. These will eventually become
				outdated as we move to a single OPC directory for all files.
				usp_MIG_MISC inserts records into tblOPPO_fileExists, this sproc validates file existence.

				Also see: [usp_OPPO_validateFile_override]

				Example:
				EXEC [usp_OPPO_validateFile] 'BP'
				EXEC [usp_OPPO_validateFile] 'NC'
				EXEC [usp_OPPO_validateFile] 'QC'
				EXEC [usp_OPPO_validateFile] 'QM'



-------------------------------------------------------------------------------
Modification History

08/06/18	    Created, jf.
08/07/18	    Added PDF extension replacement on each statement, jf.
08/10/18	    Trimmed entire sproc, added third statement, jf.
09/28/18		Added ignoreCheck functionality, jf.
10/16/18		Added orderStatus check, jf.
10/16/18		Brought INSERT into sproc; it used to sit in MIG_MISC, jf.
10/16/18		Updated orderstatus check in initial insert; it used to also exclude ('Delivered', 'In Transit', 'In Transit USPS'), jf.
10/16/18		Added additional ignore statements to final UPDATE; see inline discussion ,jf.
10/19/18		variablized it, jf.
11/01/18		Added FA sections (Furnished Art) to account for their special snowflake image paths, jf.
11/29/18		Added QM, jf.
03/08/19		Added GUID OPPO check in BP clauses, jf.
08/20/19		Addded Q3 Section to deal with new Canvas pathless textValue strings, jf.
08/20/19		Pulled "Delivered" from the FN check because we sometimes have in house OPIDs on delivered orders (why!?), jf.
08/07/20		JF, fixed subquery fileExists logic for QC and QM and put a date range too.
08/17/20		JF, pulled out OPC subq for QC.
09/15/20		JF, pulled out OPC subq for QM. Now there are no references for OPC in this procedure.
12/07/20		CKB, iFrame conversion changes
02/08/21		JF, removed the new NOT EXISTS queries throughout, see inline notes on BP.
02/10/21		BS, ignore some textvalues
02/11/21		JF, fixed BS's failure as a human.  = 'http://summerhall'
02/25/21		CKB, killed QM2 section.  ORDERID_OPID.pdf is not the correct file for most.
03/02/21		BS, ADD some QC, QM Magic to pull in orderId_opid
03/04/21		JF, fixed the LIKE thing.
04/27/21		CKB, Markful
08/03/21		CKB, added signs
02/24/22		CKB, added notecard oppo fix to correct timing issue
-------------------------------------------------------------------------------
*/
IF @ProductType IS NULL
BEGIN
	SET @ProductType = 'BP'
END

--insert new records to be checked
--/////////////////////////////////////////////////////////////////////////////////
--Business Cards //////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////////////
DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, fileType)
	SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
	oppo.textValue
	, CASE WHEN SUBSTRING(op.productCode, 1, 2) = 'BP' THEN 'BP'
		   WHEN SUBSTRING(op.productCode, 1, 2) = 'NC' AND SUBSTRING(op.productCode, 3, 2) <> 'EV' THEN 'NC'
			WHEN SUBSTRING(op.productCode, 3, 2) = 'QC' AND s.productcode IS NOT NULL THEN 'QC'
			WHEN SUBSTRING(op.productCode, 3, 2) = 'QM' AND S.productCode IS NOT NULL THEN 'QM'
			WHEN SUBSTRING(op.productCode,1,2) = 'SN' THEN 'SN'
			WHEN op.productCode like 'NB__S%' and op.productCode NOT LIKE 'NB___U%' THEN 'NBS'
			WHEN SUBSTRING(op.productCode,1,1) = 'PC' then 'PC'
	END 
	FROM tblOrdersProducts_productOptions oppo
	INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
	INNER JOIN tblOrders o ON op.orderID = o.orderID
	INNER JOIN tblProductOptions po on oppo.optionID = po.optionID AND isFileOppo = 1 and po.optionCaption like '%UNC File'
	LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
	LEFT JOIN tblSwitch_productCodes s ON SUBSTRING(op.productCode, 1, 2) = s.productCode
	WHERE x.PKID IS NULL
	AND oppo.deleteX <> 'yes'
	AND (op.processType = 'fasTrak' or substring(op.productCode,1,2) = 'sn' or (op.productCode like 'NB__S%' and op.productCode NOT LIKE 'NB___U%') or op.productCode like 'BP%' or op.productCode like 'PC%')  -- fastrak or fake-trak
	AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
	AND DATEDIFF(DD, op.created_on, GETDATE()) < 90
	AND DATEDIFF(MI, op.created_on, GETDATE()) > 10  --buffer so maintenance steps have time to run
	AND LEFT(oppo.textValue,17) <> 'http://summerhall'

IF @ProductType = 'BP'
BEGIN

	
		--(BP1) Regular BPFAs
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, fileType)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
		@UncBasePath + REPLACE(REPLACE((RIGHT(oppo.textValue, CHARINDEX('/', REVERSE(oppo.textValue)))), '/', ''), '.JPG', '.PDF')
		, 'BP'
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND (oppo.textValue LIKE '/InProduction%' -- Regular BCs
			OR (oppo.textValue LIKE '%-%-%-%-%.pdf' AND LEN(oppo.textValue) = 40)-- GUIDs that are created by migration
			OR (oppo.textValue LIKE '%BPFA%' AND (oppo.textValue LIKE '%-FRONT-%' OR oppo.textValue LIKE '%-BACK-%'))) --BPFAs; Furnished Art
		AND SUBSTRING(op.productCode, 1, 2) = 'BP' 
		AND oppo.textValue NOT LIKE 'http://summerhall/webstores%'
		AND oppo.created_on > '2/7/2021'
		--JF removed this because it's broken; 08FEB2021 @ 11:19am
		--AND REPLACE(REPLACE((RIGHT(oppo.textValue, CHARINDEX('/', REVERSE(oppo.textValue)))), '/', ''), '.JPG', '.PDF')
			--NOT IN (SELECT reverse(substring(reverse(filepath),1,charindex('\',reverse(filepath))-1)) from tblOPPO_fileExists fe where op.id = fe.OPID)

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath IS NULL
		AND x.isCustomInsert = 0
		AND x.fileType = 'BP'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('\', REVERSE(x.textValue)))), '\', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath = @UncBasePath
		AND x.isCustomInsert = 0
		AND x.fileType = 'BP'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(x.textValue, '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE x.textValue NOT LIKE '%/%'
		AND x.textValue NOT LIKE '%\%'
		AND (x.filePath IS NULL
			 OR x.filePath = @UncBasePath) --BPFAs; Furnished Art sometimes don't path correctly and filePath comes in vanilla.
		AND x.isCustomInsert = 0
		AND x.fileType = 'BP'

		UPDATE x
		SET fileExists = dbo.fn_FileExists(x.filePath),
			fileChecked = 1,
			fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'MIGZ') --, pulled 'Delivered' 8/20/19, jf.
		AND SUBSTRING(op.productCode, 1, 2) = 'BP' 	
		AND x.isCustomInsert = 0
		AND x.fileType = 'BP'
		
END

--/////////////////////////////////////////////////////////////////////////////////
--Notecards ///////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////////////

IF @ProductType = 'NC'
BEGIN
	
	EXEC Maintenance_NoteCardOppos

	INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, fileType)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
		@UncBasePath + REPLACE(REPLACE((RIGHT(oppo.textValue, CHARINDEX('/', REVERSE(oppo.textValue)))), '/', ''), '.JPG', '.PDF')
		, 'NC'
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND (oppo.textValue LIKE '/InProduction%'
			OR oppo.textValue LIKE '\\Arc\archives\webstores\OPC\%')
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 1, 2) = 'NC'
		AND SUBSTRING(op.productCode, 3, 2) <> 'EV'
		AND oppo.textValue NOT LIKE 'http://summerhall/webstores%'
		AND oppo.created_on > '2/7/2021'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath IS NULL
		AND x.isCustomInsert = 0
		AND x.fileType = 'NC'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('\', REVERSE(x.textValue)))), '\', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath = @UncBasePath
		AND x.isCustomInsert = 0
		AND x.fileType = 'NC'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(x.textValue, '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE x.textValue NOT LIKE '%/%'
		AND x.textValue NOT LIKE '%\%'
		AND (x.filePath IS NULL
			 OR x.filePath = @UncBasePath) --NCFAs; Furnished Art sometimes don't path correctly and filePath comes in vanilla.
		AND x.isCustomInsert = 0
		AND x.fileType = 'NC'

		UPDATE x
		SET fileExists = dbo.fn_FileExists(x.filePath),
			fileChecked = 1,
			fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'MIGZ') --, pulled 'Delivered' 8/20/19, jf.
		AND SUBSTRING(op.productCode, 1, 2) = 'NC'
		AND SUBSTRING(op.productCode, 3, 2) <> 'EV'
		AND x.isCustomInsert = 0
		AND x.fileType = 'NC'
END		

--/////////////////////////////////////////////////////////////////////////////////
--Quickcards //////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////////////

IF @ProductType = 'QC'
BEGIN

		--(QC1) regular opc QCs
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, fileType)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
		@UncBasePath + REPLACE(REPLACE((RIGHT(oppo.textValue, CHARINDEX('/', REVERSE(oppo.textValue)))), '/', ''), '.JPG', '.PDF')
		, 'QC'
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND oppo.textValue LIKE '/InProduction%'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 3, 2) = 'QC'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
		AND LEFT(oppo.textValue,17) <> 'http://summerhall'	
		AND oppo.created_on > '2/7/2021'


		----(QC2) custom insert QCs
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, isCustomInsert, fileType)
		SELECT op.ID, op.ID, REPLACE(REPLACE(o.orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(255), op.ID) + '.pdf', 'PDF',
		@UncBasePath + REPLACE(REPLACE(o.orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(255), op.ID) + '.pdf'
		, 1, 'QC'
		FROM tblOrders_Products op 
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON op.ID = x.PKID
		WHERE   x.PKID IS NULL
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 3, 2) = 'QC'
		AND (op.processType = 'fasTrak' OR fastTrak_status IN ( 'Good To Go', 'In House') )
		AND o.orderDate > '20200501'
		AND EXISTS	(SELECT productCode
				FROM tblSwitch_productCodes)
		AND NOT EXISTS(
					SELECT TOP 1 1 FROM tblOrdersProducts_ProductOptions oppo 
					WHERE oppo.ordersProductsID = op.Id
					AND optionCaption LIKE 'CanvasHiResFront%'
					AND deletex <> 'yes'
					)

		--(QC3) New Canvas QCs that do not pass paths through 
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, isCustomInsert, fileType)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
		@UncBasePath + oppo.textValue
		, 1, 'QC'
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND oppo.optionCaption = 'Intranet PDF'
		AND oppo.textValue NOT LIKE '%/%'
		AND oppo.textValue NOT LIKE '%\%'
		AND oppo.textValue <> '0_-1.pdf'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 3, 2) = 'QC'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
		--AND  oppo.textValue
		--	NOT IN (SELECT reverse(substring(reverse(filepath),1,charindex('\',reverse(filepath))-1)) from tblOPPO_fileExists fe where op.ID = fe.OPID)
		AND LEFT(oppo.textValue,17) <> 'http://summerhall'


		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath IS NULL
		AND x.isCustomInsert = 0
		AND x.fileType = 'QC'
		
		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('\', REVERSE(x.textValue)))), '\', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath = @UncBasePath
		AND x.isCustomInsert = 0
		AND x.fileType = 'QC'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(x.textValue, '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE x.textValue NOT LIKE '%/%'
		AND x.textValue NOT LIKE '%\%'
		AND (x.filePath IS NULL
			 OR x.filePath = @UncBasePath) --QCFAs; Furnished Art sometimes don't path correctly and filePath comes in vanilla.
		AND x.isCustomInsert = 0
		AND x.fileType = 'QC'
		
		UPDATE x
		SET fileExists = dbo.fn_FileExists(x.filePath),
			   fileChecked = 1,
			   fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'MIGZ') --, pulled 'Delivered' 8/20/19, jf.
		AND SUBSTRING(op.productCode, 3, 2) = 'QC'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
		AND x.fileType = 'QC'
END	

--/////////////////////////////////////////////////////////////////////////////////
--Quickmags ///////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////////////

IF @ProductType = 'QM'
BEGIN


		--(QM1) regular opc QMs
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, fileType)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
		@UncBasePath + REPLACE(REPLACE((RIGHT(oppo.textValue, CHARINDEX('/', REVERSE(oppo.textValue)))), '/', ''), '.JPG', '.PDF')
		, 'QM'
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND oppo.textValue LIKE '/InProduction%'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 3, 2) = 'QM'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
		--AND REPLACE(REPLACE((RIGHT(oppo.textValue, CHARINDEX('/', REVERSE(oppo.textValue)))), '/', ''), '.JPG', '.PDF')
		--	NOT IN (SELECT reverse(substring(reverse(filepath),1,charindex('\',reverse(filepath))-1)) from tblOPPO_fileExists fe where op.id = fe.OPID)
		AND LEFT(oppo.textValue,17) <> 'http://summerhall'
		AND oppo.created_on > '2/7/2021'

		----(QM2) custom insert QMs
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, isCustomInsert, fileType)
		SELECT op.ID, op.ID, REPLACE(REPLACE(o.orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(255), op.ID) + '.pdf', 'PDF',
		@UncBasePath + REPLACE(REPLACE(o.orderNo, 'HOM', ''),'MRK','') + '_' + CONVERT(VARCHAR(255), op.ID) + '.pdf'
		, 1, 'QM'
		FROM tblOrders_Products op 
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON op.ID = x.PKID
		WHERE   x.PKID IS NULL
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 3, 2) = 'QM'
		AND (op.processType = 'fasTrak' OR fastTrak_status IN ( 'Good To Go', 'In House') )
		AND o.orderDate > '20200501'
		AND EXISTS	(SELECT productCode
				FROM tblSwitch_productCodes)
		AND NOT EXISTS(
					SELECT TOP 1 1 FROM tblOrdersProducts_ProductOptions oppo 
					WHERE oppo.ordersProductsID = op.Id
					AND optionCaption LIKE 'CanvasHiResFront%'
					AND deletex <> 'yes'
					)


		--(QM3) New Canvas QMs that do not pass paths through 
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, filePath, isCustomInsert, fileType)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)),
		@UncBasePath + oppo.textValue
		, 1, 'QM'
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND oppo.optionCaption = 'Intranet PDF'
		AND oppo.textValue NOT LIKE '%/%'
		AND oppo.textValue NOT LIKE '%\%'
		AND oppo.textValue <> '0_-1.pdf'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
		AND SUBSTRING(op.productCode, 3, 2) = 'QM'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
		--AND  oppo.textValue
		--	NOT IN (SELECT reverse(substring(reverse(filepath),1,charindex('\',reverse(filepath))-1)) from tblOPPO_fileExists fe where op.id = fe.OPID)
		AND LEFT(oppo.textValue,17) <> 'http://summerhall'
		AND oppo.created_on > '2/7/2021'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath IS NULL
		AND x.isCustomInsert = 0
		AND x.fileType = 'QM'
		
		UPDATE x
		SET filePath = @UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('\', REVERSE(x.textValue)))), '\', ''), '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE filePath = @UncBasePath
		AND x.isCustomInsert = 0
		AND x.fileType = 'QM'

		UPDATE x
		SET filePath = @UncBasePath + REPLACE(x.textValue, '.JPG', '.PDF')
		FROM tblOPPO_fileExists x
		WHERE x.textValue NOT LIKE '%/%'
		AND x.textValue NOT LIKE '%\%'
		AND (x.filePath IS NULL
			 OR x.filePath = @UncBasePath) --QMFAs; Furnished Art sometimes don't path correctly and filePath comes in vanilla.
		AND x.isCustomInsert = 0
		AND x.fileType = 'QM'
		
		UPDATE x
		SET fileExists = dbo.fn_FileExists(x.filePath),
			   fileChecked = 1,
			   fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'MIGZ') --, pulled 'Delivered' 8/20/19, jf.
		AND SUBSTRING(op.productCode, 3, 2) = 'QM'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
		AND x.fileType = 'QM'
END