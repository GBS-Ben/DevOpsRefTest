-- =============================================
-- Author:		CKBrowne
-- Create date: 01/04/21
-- Description:	Identifies the files that need to be inserted into tblOPPO_FileExists
-- =============================================

CREATE PROCEDURE [dbo].[usp_OPPO_GetNewFiles]

	@Days INT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @UncBasePath VARCHAR(100); 
	EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

	-- Get post-iFrame conversion files
	WITH cteNewFiles AS (
		SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)) AS Extension,
		CASE WHEN charindex('\',oppo.textValue) = 0 THEN oppo.textValue
		WHEN CHARINDEX('\',oppo.textValue) > 0 THEN right(oppo.textValue, charindex('\', reverse(oppo.textValue) + '\') - 1)
		END AS [fileName],
		oppo.textValue as FilePath
		, CASE WHEN left(op.productCode,2) = 'BP' THEN 'BP'
			WHEN left(op.productCode,2) = 'NC' THEN 'NC'
			WHEN left(op.productCode,2) = 'CA' THEN 'CA'
			WHEN left(op.productCode,2) = 'SN' THEN 'SN'
			WHEN left(op.productCode,2) = 'NB' THEN 'NB'
			WHEN left(op.productCode,2) = 'CM' THEN 'CM'
			WHEN left(op.productCode,2) = 'LH' THEN 'LH'
			WHEN left(op.productCode,2) = 'EV' THEN 'EV'
			WHEN SUBSTRING(op.productCode,3,2) = 'QC' THEN 'QC'
			WHEN SUBSTRING(op.productCode,3,2) = 'QM' THEN 'QM'
			WHEN SUBSTRING(op.productCode,3,2) = 'BU' THEN 'BU'
			WHEN SUBSTRING(op.productCode,3,2) = 'CH' THEN 'CH'
			WHEN SUBSTRING(op.productCode,3,2) = 'CC' THEN 'CC'
			WHEN SUBSTRING(op.productCode,3,2) = 'EX' THEN 'EX'
			WHEN SUBSTRING(op.productCode,3,2) = 'FB' THEN 'FB'
			WHEN SUBSTRING(op.productCode,3,2) = 'FC' THEN 'FC'
			WHEN SUBSTRING(op.productCode,3,2) = 'HM' THEN 'HM'
			WHEN SUBSTRING(op.productCode,3,2) = 'JU' THEN 'JU'
			ELSE NULL END	as fileType
		FROM tblOrdersProducts_productOptions oppo
		INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
		INNER JOIN tblOrders o ON op.orderID = o.orderID
		INNER JOIN tblProductOptions po on oppo.optionID = po.optionID AND isFileOppo = 1 AND po.optionCaption like '%UNC File'
		LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
		LEFT JOIN tblSwitch_productCodes s ON SUBSTRING(op.productCode, 1, 2) = s.productCode
		WHERE x.PKID IS NULL
		AND o.orderStatus NOT IN ('Failed','Cancelled')
		AND op.deletex <> 'yes'
		AND oppo.deletex <> 'yes'
		AND oppo.textValue IS NOT NULL
		AND o.orderDate > (getdate() - @Days) 
	)
	SELECT PKID
		, ordersProductsID as OPID
		, textValue
		, Extension as extension
		, [fileName]
		, FilePath as filePath
		, FileType  as fileType
	FROM cteNewFiles
	UNION
	-- Get pre-iFrame conversion files 
	SELECT PKID,OPID, textValue,extension,[filename],filePath,fileType FROM (
		SELECT oppo.PKID
		,oppo.ordersProductsID as OPID
		,oppo.textValue
		,UPPER(RIGHT(oppo.textValue,3)) as extension
		, CASE WHEN charindex('/',oppo.textValue) = 0 THEN oppo.textValue
			WHEN CHARINDEX('/',oppo.textValue) > 0 THEN RIGHT(oppo.textValue, charindex('/', reverse(oppo.textValue) + '/') - 1)
			end [fileName]
		,@UncBasePath + 
			CASE WHEN charindex('/',oppo.textValue) = 0 THEN oppo.textValue
			WHEN CHARINDEX('/',oppo.textValue) > 0 THEN RIGHT(oppo.textValue, charindex('/', reverse(oppo.textValue) + '/') - 1)
			END AS filePath
		,CASE WHEN left(op.productCode,2) = 'BP' THEN 'BP'
			WHEN left(op.productCode,2) = 'NC' THEN 'NC'
			WHEN left(op.productCode,2) = 'CA' THEN 'CA'
			WHEN left(op.productCode,2) = 'SN' THEN 'SN'
			WHEN left(op.productCode,2) = 'NB' THEN 'NB'
			WHEN left(op.productCode,2) = 'CM' THEN 'CM'
			WHEN left(op.productCode,2) = 'LH' THEN 'LH'
			WHEN left(op.productCode,2) = 'EV' THEN 'EV'
			WHEN SUBSTRING(op.productCode,3,2) = 'QC' THEN 'QC'
			WHEN SUBSTRING(op.productCode,3,2) = 'QM' THEN 'QM'
			WHEN SUBSTRING(op.productCode,3,2) = 'BU' THEN 'BU'
			WHEN SUBSTRING(op.productCode,3,2) = 'CH' THEN 'CH'
			WHEN SUBSTRING(op.productCode,3,2) = 'CC' THEN 'CC'
			WHEN SUBSTRING(op.productCode,3,2) = 'EX' THEN 'EX'
			WHEN SUBSTRING(op.productCode,3,2) = 'FB' THEN 'FB'
			WHEN SUBSTRING(op.productCode,3,2) = 'FC' THEN 'FC'
			WHEN SUBSTRING(op.productCode,3,2) = 'HM' THEN 'HM'
			WHEN SUBSTRING(op.productCode,3,2) = 'JU' THEN 'JU'
			ELSE NULL END
		AS fileType
		FROM dbo.tblOrders o
		INNER JOIN dbo.tblOrders_Products op
			ON o.orderID = op.orderID
		INNER JOIN dbo.tblOrdersProducts_ProductOptions oppo
			ON op.ID = oppo.ordersProductsID
		LEFT JOIN dbo.tblOPPO_fileExists ofe ON ofe.PKID = oppo.PKID
		WHERE ofe.PKID IS NULL
		AND
		o.orderStatus not in ('Failed','Cancelled')
		AND op.deletex <> 'yes'
		AND oppo.deletex <> 'yes'
		AND oppo.textValue IS NOT NULL
		AND o.orderDate > (getdate() - 10) 
		AND oppo.optionID IN
		(
		 537	--32	Web PDF
		,539	--32	Intranet PDF
		,544	--19	Back Web PDF
		,546	--19	Back Intranet PDF
		,558	--19	Inside Intranet PDF
		,560	--19	Inside Web PDF
		)
		AND oppo.textValue NOT LIKE '%.houseofmagnets.com%'

	) oldfiles
	WHERE NOT EXISTS 
		(SELECT TOP 1 1 FROM cteNewFiles n WHERE n.FilePath = oldfiles.filepath)
END