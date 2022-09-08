CREATE PROC [dbo].[usp_FT_OPC_IMAGE_preSSIS]

--//***************************
/*

This SPROC is run as step 1 of 
the SSIS package that brings
OPC orders into the FT.

select * from tblW2PMerge
sp_columns 'tblW2PMerge'

usp_getOPPO 'HOM371253'

EXEC usp_OPC_reset

*/
--//***************************

AS
SET NOCOUNT ON;

BEGIN TRY

	DELETE FROM tblW2PMerge
	INSERT INTO tblW2PMerge (Template, [DDF Name], [Output Path], [Log File Path], [Output Style], [Output Format], bkgnd, CustomerFile, productBack, orderNo, orderID, productCode,  productName, logo1, logo2, photo1, photo2, ordersProductsID)

	SELECT DISTINCT --7832
	'Macintosh HD:GBS Hot Folder:Templates:Web2p_' + SUBSTRING(op.productCode, 3, 2) + 'D' + '.gp' AS 'Template', 
	'Web2P merge3' AS 'DDF Name',
	'MERGE CENTRAL:Web2P Print Files:~~ReadyToPrint:' + SUBSTRING(op.productCode, 3, 2) + 'D:' + o.orderNo + '_' + CONVERT(VARCHAR(50), x.ordersProductsID) + '_' + SUBSTRING(op.productCode, 3, 2) + '.pdf' AS 'Output Path',
	'ART DEPARTMENT-NEW:For SQL:FastTrak:web2p:Logs:' + o.orderNo + '_' + CONVERT(VARCHAR(50), x.ordersProductsID) + '.log' AS 'Log File Path',
	'Graphic Business Solutions' AS 'Output Style',
	'PDF' AS 'Output Format',
	' ' AS 'bkgnd', --placeholder
	' ' AS 'customerFile', --placeholder
	' ' AS 'productBack', --placeholder
	o.orderNo AS 'orderNo',
	o.orderID AS 'orderID',
	op.productCode AS 'productCode',
	op.productName AS 'productName',
	' ' AS logo1, --placeholder
	' ' AS logo2, --placeholder
	' ' AS photo1, --placeholder
	' ' AS photo2, --placeholder
	x.ordersProductsID AS 'ordersProductsID'
	--INTO tblW2PMerge_BAK
	FROM
	tblOrders o INNER JOIN tblOrders_Products op
	ON o.orderID = op.orderID
	INNER JOIN tblOrdersProducts_productOptions x
	ON op.[ID] = x.ordersProductsID
	WHERE
	op.deleteX <> 'yes'
	AND op.fastTrak_productType = 'OPC'
	AND op.fastTrak_completed <> 1
	AND op.orderID IN
		(SELECT DISTINCT orderID
		FROM tblOrders
		WHERE orderStatus <> 'cancelled'
		AND orderStatus <> 'failed'
		AND orderStatus <> 'Waiting For Payment'
		AND orderStatus <> 'GTG-Waiting For Payment'
		AND orderStatus <> 'Pending'
		AND orderID > 444333222)

	AND 
		(
			-- products that have never been exported before
			(op.fastTrak_imageFile_exported = 0 AND op.fastTrak_resubmit = 0) 
			OR 
			-- resubmitted products
			op.fastTrak_resubmit = 1
		)
	AND (SUBSTRING(op.productCode, 3, 2) = 'QC' 
		OR
		SUBSTRING(op.productCode, 3, 2) = 'FC' 
		OR
		SUBSTRING(op.productCode, 3, 2) = 'BU' 
		OR
		SUBSTRING(op.productCode, 3, 2) = 'JU' 
		OR
		SUBSTRING(op.productCode, 3, 2) = 'EX' 
		)
	ORDER BY x.ordersProductsID ASC


	-- ******** bkgnd ******************************************************************

	update tblW2PMerge
	set bkgnd=''
	where bkgnd is NULL

	update tblW2PMerge
	set bkgnd=productCode+'.gp'
	where productCode not like 'BB%'
	and productCode not like 'FB%'
	and productCode not like 'BK%'
	and productCode not like 'HY%'
	and bkgnd not like '%.gp'
	and bkgnd not like '%.eps'

	update tblW2PMerge
	set bkgnd=productCode+'.eps'
	where productCode like 'BB%'  and bkgnd not like '%.gp' and bkgnd not like '%.eps'
	or productCode  like 'FB%'  and bkgnd not like '%.gp' and bkgnd not like '%.eps'
	or productCode like 'BK%'  and bkgnd not like '%.gp' and bkgnd not like '%.eps'
	or productCode like 'HY%'  and bkgnd not like '%.gp' and bkgnd not like '%.eps'

	update tblW2PMerge
	set bkgnd=productCode+'.gp'
	where productCode like 'BC%' and bkgnd not like '%.gp' and bkgnd not like '%.eps'
	or productName like '%calendar%' and bkgnd not like '%.gp' and bkgnd not like '%.eps'
	or productName like '%Halloween Bag%' and bkgnd not like '%.gp' and bkgnd not like '%.eps'

	update tblW2PMerge
	set bkgnd=productCode+'.eps'
	where productCode not like 'BC%'
	and productName not like '%calendar%'
	and productName not like '%Halloween Bag%'
	and bkgnd not like '%.gp'
	and bkgnd not like '%.eps'

	--select productCode, productName from tblProducts where productName like '%cal%'

	--All products starting with BB, FB, BK, and HY should have QC changed to QS and QM changed to QS.

	update tblW2PMerge
	set bkgnd=replace(bkgnd,'QC','QS')
	where bkgnd like 'BB%'
	or bkgnd  like 'FB%'
	or bkgnd  like 'BK%'
	or bkgnd  like 'HY%'

	update tblW2PMerge
	set bkgnd=replace(bkgnd,'QM','QS')
	where bkgnd like 'BB%'
	or bkgnd  like 'FB%'
	or bkgnd  like 'BK%'
	or bkgnd  like 'HY%'

	UPDATE tblW2PMerge
	SET bkgnd = 'HOM_Shortrun:SUPERmergeIN:Custom Magnet Backgrounds:' + SUBSTRING(productCode, 1, 2) + ':' + bkgnd
	WHERE bkgnd IS NOT NULL
	AND bkgnd <> ''

	--// customerFile --//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
	UPDATE tblW2PMerge
	SET customerFile = ''
	WHERE customerFile IS NULL

	UPDATE tblW2PMerge
	SET customerFile2 = ''
	WHERE customerFile2 IS NULL

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue

	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue

	--// customerFile2 --//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	update tblW2PMerge
	set customerFile2=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.customerFile<>''
	and a.customerFile2='' 
	and b.deleteX<>'yes'
	and a.customerFile<>b.textValue
	and a.customerFile2<>b.textValue

	--CRAZY UNKNOWN FILES
	update tblW2PMerge
	set customerFile=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue is NOT NULL
	and b.textValue <>''
	and a.customerFile='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.customerFile<>b.textValue

	/*
	--//Not doing anything with file extensions as per KH. Save here in case of change.
	update tblW2PMerge set customerFile=replace(customerFile,'.bmp','.eps') where customerFile like '%logo%' and customerFile like '%.bmp'
	update tblW2PMerge set customerFile=replace(customerFile,'.jpg','.eps') where customerFile like '%logo%' and customerFile like '%.jpg'
	update tblW2PMerge set customerFile=replace(customerFile,'.jpeg','.eps') where customerFile like '%logo%' and customerFile like '%.jpeg'
	update tblW2PMerge set customerFile=replace(customerFile,'.gif','.eps') where customerFile like '%logo%' and customerFile like '%.gif'
	update tblW2PMerge set customerFile=replace(customerFile,'.png','.eps') where customerFile like '%logo%' and customerFile like '%.png'
	update tblW2PMerge set customerFile=replace(customerFile,'.tif','.eps') where customerFile like '%logo%' and customerFile like '%.tif'
	update tblW2PMerge set customerFile=replace(customerFile,'.pdf','.eps') where customerFile like '%logo%' and customerFile like '%.pdf'
	update tblW2PMerge set customerFile=replace(customerFile,'.psd','.eps') where customerFile like '%logo%' and customerFile like '%.psd'

	update tblW2PMerge set customerFile=replace(customerFile,'.bmp','.eps') where customerFile like '%photo%' and customerFile like '%.bmp'
	update tblW2PMerge set customerFile=replace(customerFile,'.jpg','.eps') where customerFile like '%photo%' and customerFile like '%.jpg'
	update tblW2PMerge set customerFile=replace(customerFile,'.jpeg','.eps') where customerFile like '%photo%' and customerFile like '%.jpeg'
	update tblW2PMerge set customerFile=replace(customerFile,'.gif','.eps') where customerFile like '%photo%' and customerFile like '%.gif'
	update tblW2PMerge set customerFile=replace(customerFile,'.png','.eps') where customerFile like '%photo%' and customerFile like '%.png'
	update tblW2PMerge set customerFile=replace(customerFile,'.tif','.eps') where customerFile like '%photo%' and customerFile like '%.tif'
	update tblW2PMerge set customerFile=replace(customerFile,'.pdf','.eps') where customerFile like '%photo%' and customerFile like '%.pdf'
	update tblW2PMerge set customerFile=replace(customerFile,'.psd','.eps') where customerFile like '%photo%' and customerFile like '%.psd'

	update tblW2PMerge set customerFile=replace(customerFile,'.bmp','.eps') where customerFile like '%misc%' and customerFile like '%.bmp'
	update tblW2PMerge set customerFile=replace(customerFile,'.jpg','.eps') where customerFile like '%misc%' and customerFile like '%.jpg'
	update tblW2PMerge set customerFile=replace(customerFile,'.jpeg','.eps') where customerFile like '%misc%' and customerFile like '%.jpeg'
	update tblW2PMerge set customerFile=replace(customerFile,'.gif','.eps') where customerFile like '%misc%' and customerFile like '%.gif'
	update tblW2PMerge set customerFile=replace(customerFile,'.png','.eps') where customerFile like '%misc%' and customerFile like '%.png'
	update tblW2PMerge set customerFile=replace(customerFile,'.tif','.eps') where customerFile like '%misc%' and customerFile like '%.tif'
	update tblW2PMerge set customerFile=replace(customerFile,'.pdf','.eps') where customerFile like '%misc%' and customerFile like '%.pdf'
	update tblW2PMerge set customerFile=replace(customerFile,'.psd','.eps') where customerFile like '%misc%' and customerFile like '%.psd'

	--ADD .EPS EXTENSION ON ALL IMAGES WHERE .EPS DOES NOT EXIST YET
	update tblW2PMerge set customerFile=customerFile+'.eps' where customerFile like '%photo%' and customerFile not like '%.eps'
	update tblW2PMerge set customerFile=customerFile+'.eps' where customerFile like '%logo%' and customerFile not like '%.eps'
	update tblW2PMerge set customerFile=customerFile+'.eps' where customerFile like '%misc%' and customerFile not like '%.eps'
	*/

	--// Find best customerFile and use it for export

	UPDATE tblW2PMerge set customerFile='' where customerFile is NULL
	UPDATE tblW2PMerge set customerFile2='' where customerFile2 is NULL

	UPDATE tblW2PMerge
	SET customerFileExport = customerFile
	--Select customerFile from tblW2PMerge
	WHERE customerFile LIKE '%-%'
	AND customerFile LIKE '%.pdf'

	UPDATE tblW2PMerge
	SET customerFileExport = customerFile2
	--Select customerFile2 from tblW2PMerge
	WHERE customerFileExport IS NULL 
	AND customerFile2 LIKE '%-%'
	AND customerFile2 LIKE '%.pdf'

	UPDATE tblW2PMerge
	SET customerFileExport = RIGHT(customerFileExport, 24)
	WHERE customerFileExport LIKE '%/%'

	UPDATE tblW2PMerge
	SET customerFileExport = 'arc:webstores:' + customerFileExport
	WHERE customerFileExport IS NOT NULL
	AND customerFileExport <> ''

	/* WORK

	EXEC usp_OPC_reset
	EXEC usp_FT_OPC_IMAGE_preSSIS
	SELECT * FROM tblW2PMerge
	SELECT RIGHT(customerFileExport, CHARINDEX('/',REVERSE(customerFileExport))-1)
	FROM tblW2PMerge
	WHERE customerFileExport IS NOT NULL

	 */

	-- ******** PRODUCTBACK ******************************************************************

	UPDATE tblW2PMerge 
	set productBack=b.textValue
	from tblW2PMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption = 'Product Back'
	and b.deleteX<>'yes'
	and a.productBack<>b.textValue
	and productBack IS NOT NULL

	UPDATE tblW2PMerge
	SET productBack = NULL
	WHERE productBack LIKE '%BLANK%'

	UPDATE tblW2PMerge
	SET productBack = NULL
	WHERE productBack = ''

	UPDATE tblW2PMerge
	SET productBack = NULL
	WHERE SUBSTRING(productCode, 3,2) <> 'QC'

	UPDATE tblW2PMerge
	SET productBack = 'HOM_Shortrun:SUPERmergeIN:Custom Magnet Backgrounds:' + SUBSTRING(productCode, 1, 2) + ':' + + SUBSTRING(productCode, 1, 3) + 'X' + + SUBSTRING(productCode, 5, 2) + '_' + productBack + '.pdf'
	WHERE SUBSTRING(productCode, 3,2) = 'QC'

	--// Fix Template & "Output Path"

	UPDATE tblW2PMerge 
	SET template = REPLACE(template, 'D.gp', 'S.gp')
	WHERE productBack IS NULL
	OR productBack = ''

	UPDATE tblW2PMerge 
	SET [Output Path] = REPLACE([Output Path], 'D:HOM', 'S:HOM')
	WHERE productBack IS NULL
	OR productBack = ''

	--// Ready for export

	UPDATE tblW2PMerge
	SET exportStatus = 'Ready for Export'

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH