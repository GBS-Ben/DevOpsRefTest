--04/27/2021		CKB, Markful

CREATE PROC [dbo].[getNopAttributeXml] @orderno VARCHAR(20)
AS
BEGIN
	DROP TABLE

	IF EXISTS ##CTgetNopAttributeXML
		,##CTgetNopAttributeXMLTemp
		,##CTGetNopAttributeCCID
		DECLARE @OPID VARCHAR(20)
			,@x AS XML
			,@orderID INT
			,@offset INT

	SET @offset = 555444333

	IF Left(@orderNo, 1) = 5
	BEGIN
		SET @OPID = @orderno
		SET @orderID = (
				SELECT TOP 1 orderID
				FROM tblOrders_Products
				WHERE id = @OPID
				)
		SET @orderNo = (
				SELECT o.orderNo
				FROM tblorders o
				WHERE orderid = @orderId
				)
	END

	IF LEN(@orderNo) = 6
	BEGIN
		SET @orderNo = 'HOM' + @orderNo
	END
	IF LEN(@orderNo) = 7
	BEGIN
		SET @orderNo = 'MRK' + @orderNo
	END

	IF Left(@orderNo, 1) IN (
			'H'
			,'N'
			,'A'
			)
	BEGIN
		SET @orderID = (
				SELECT TOP 1 orderID
				FROM tblOrders
				WHERE orderNo = @orderNo
				)
		SET @OPID = (
				SELECT TOP 1 op.id
				FROM tblOrders_Products op
				WHERE op.orderID = @orderID
				)
	END

	SET @x = (
			SELECT TOP 1 AttributesXml
			FROM dbo.nopCommerce_orderitem oi
			WHERE id = @OPID - 555444333
			)

	CREATE TABLE ##CTgetNopAttributeXML (
		pkid INT IDENTITY(1, 1) PRIMARY KEY
		,ordersproductsID INT NULL
		,optionid INT NULL
		,[optionCaption] NVARCHAR(max) NULL
		,[optionGroupCaption] NVARCHAR(49) NULL
		,[Data] NVARCHAR(max) NULL
		,Deletex VARCHAR(10) NULL
		,optionQty INT NULL
		,CanvasDesignID INT
		)

	SELECT x.i.value('@ID', 'varchar(255)') AS [ID]
		,x.i.value('ProductAttributeValue[1]', 'varchar(255)') AS [Data]
	INTO ##CTgetNopAttributeXMLTemp
	FROM @x.nodes('*/*') x(i)

	INSERT INTO ##CTgetNopAttributeXML (
		[optionCaption]
		,Data
		,CanvasDesignID
		)
	SELECT pa.[Name]
		,xmldata.[Data]
		,CASE 
			WHEN pa.[name] = 'CCID'
				THEN XMLData.[data]
			END
	--,if (pa.[Name] = 'Artwork',string_split([xmldata.[data],','),'False') as new
	--INTO ##CTtempGetNopAttributeXML
	FROM [dbo].[nopCommerce_Product_ProductAttribute_Mapping] pam
	INNER JOIN [dbo].[nopCommerce_ProductAttribute] pa ON pa.Id = pam.productattributeid
	LEFT JOIN ##CTgetNopAttributeXMLTemp AS XMLData ON xmlData.ID = pam.Id
	WHERE pam.id IN (
			SELECT ID
			FROM ##CTgetNopAttributeXMLTemp
			)

	UPDATE ctgna
	SET optionid = 252
		,Deletex = '0'
		,ordersproductsID = try_convert(INT, @OPID)
		,optionQty = 0
		,optionGroupCaption = 'Description'
	FROM ##CTgetNopAttributeXML ctgna

	SELECT ordersproductsID
		,optionid
		,CASE 
			WHEN ctnax.optionCaption = 'CCID'
				THEN ctnax.Data
			END AS canvasDesignID
		,optionCaption
		,optionGroupCaption
		,Data AS TextValue
	--,Deletex
	--,optionQty
	INTO ##CTGetNopAttributeCCID
	FROM ##CTgetNopAttributeXML ctnax

	SELECT 'NOP-OrderItem' as OrderItem,*
	FROM ##CTGetNopAttributeCCID

	--CCDesign
	BEGIN
		SELECT 'NOP-CCDesign' as CCDesign
			--json_value(json_query(ccd.data,'$[0]'),'$')
			,replace(ccdjsondata.[key], '-stateId' COLLATE SQL_Latin1_General_Cp1_CI_AS, '') + CASE 
				WHEN downloadurls.[value] LIKE '%0_-0.pdf'
					THEN '-CF1'
				WHEN downloadurls.[value] LIKE '%0_0.pdf'
					THEN '-CF1'
				WHEN downloadurls.[value] LIKE '%0_-1.pdf'
					THEN '-CF1'
				WHEN downloadurls.[value] LIKE '%1_0.pdf'
					THEN '-G1'
				WHEN downloadurls.[value] LIKE '%1_-1.pdf'
					THEN '-G1'
				WHEN downloadurls.[value] LIKE '%2_0.pdf'
					THEN '-CB1'
				WHEN downloadurls.[value] LIKE '%2_0.pdf'
					THEN '-CB1'
				WHEN downloadurls.[value] LIKE '%2_-1.pdf'
					THEN '-CB1'
				END AS idType
			,substring(convert(NVARCHAR(255), newid()), 1, 24) + 's' + convert(NVARCHAR(25), downloadurls.[key] + 1) + '.pdf' AS filename
			--,ccdjsondata.[value] as stateID
			--,downloadurls.[key]    as DownloadURLSKey
			,downloadurls.[value] AS DownloadURLS
			,getdate()
		FROM [dbo].[nopCommerce_tblNOPOrderItem] nOi
		INNER JOIN [dbo].[nopCommerce_CCDesign] ccD ON ccD.Id = nOI.ccid
		--INNER JOIN ##CTGetNopAttributeCCID ctgnax on ccd.id = ctgnax.canvasDesignID
		CROSS APPLY openjson(ccd.data) AS ccdjsonData
		CROSS APPLY openjson(ccd.downloadurlsJson) AS downloadurls
		WHERE ccd.id IN (
				SELECT CanvasDesignID
				FROM ##CTGetnopAttributexml
				WHERE CanvasDesignID IS NOT NULL
				)
	END

	--DROP TABLE if exists ##CTgetNopAttributeXML
	--	,##CTgetNopAttributeXMLTemp,##CTGetNopAttributeCCID
	BEGIN
		SELECT 'Local-tblNOPProductionFiles' as tblNopProductionFiles,*
		FROM tblNOPProductionFiles npf
		WHERE npf.nopOrderItemID = @OPID
	END
END