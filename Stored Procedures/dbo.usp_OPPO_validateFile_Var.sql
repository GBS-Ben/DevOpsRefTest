CREATE PROCEDURE [dbo].[usp_OPPO_validateFile_Var] @ProductType NVARCHAR(50)
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
						EXEC [usp_OPPO_validateFile_Var] 'NC'

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
-------------------------------------------------------------------------------
*/
IF @ProductType IS NULL
BEGIN
	SET @ProductType = 'BP'
END

--insert new records to be checked
--Business Cards ///////////////////////////////////////////////////////////////////////
DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;


IF @ProductType = 'BP'
BEGIN
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3))
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled')
		AND (oppo.textValue LIKE '/InProduction%' -- Regular BCs
				  OR
				  (oppo.textValue LIKE '%BPFA%' AND (oppo.textValue LIKE '%-FRONT-%' OR oppo.textValue LIKE '%-BACK-%'))) --BPFAs
		AND SUBSTRING(op.productCode, 1, 2) = 'BP' 

		UPDATE x
		SET fileExists = dbo.fn_FileExists(@UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')),
			   fileChecked = 1,
			   fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered')
		AND SUBSTRING(op.productCode, 1, 2) = 'BP' 		
END

--Notecards ///////////////////////////////////////////////////////////////////////
IF @ProductType = 'NC'
BEGIN
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3))
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND (oppo.textValue LIKE '/InProduction%'
				 OR
				 oppo.textValue LIKE '\\Arc\archives\webstores\OPC\%')
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled')
		AND SUBSTRING(op.productCode, 1, 2) = 'NC'
		AND SUBSTRING(op.productCode, 3, 2) <> 'EV'

		UPDATE x
		SET fileExists = dbo.fn_FileExists(@UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')),
			   fileChecked = 1,
			   fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered')
		AND SUBSTRING(op.productCode, 1, 2) = 'NC'
		AND SUBSTRING(op.productCode, 3, 2) <> 'EV'
END		

--Quickcards ///////////////////////////////////////////////////////////////////////
IF @ProductType = 'QC'
BEGIN
		INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension)
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3))
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		WHERE x.PKID IS NULL
		AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
		AND oppo.deleteX <> 'yes'
		AND oppo.textValue LIKE '/InProduction%'
		AND op.processType = 'fasTrak'
		AND o.orderStatus NOT IN ('Failed', 'Cancelled')
		AND SUBSTRING(op.productCode, 3, 2) = 'QC'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)

		UPDATE x
		SET fileExists = dbo.fn_FileExists(@UncBasePath + REPLACE(REPLACE((RIGHT(x.textValue, CHARINDEX('/', REVERSE(x.textValue)))), '/', ''), '.JPG', '.PDF')),
			   fileChecked = 1,
			   fileCheckedOn = GETDATE()
		FROM tblOPPO_fileExists x
		INNER JOIN tblOrders_Products op ON x.OPID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		WHERE x.fileExists = 0
		AND x.ignoreCheck = 0
		AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered')
		AND SUBSTRING(op.productCode, 3, 2) = 'QC'
		AND SUBSTRING(op.productCode, 1, 2) IN
				(SELECT productCode
				FROM tblSwitch_productCodes)
END