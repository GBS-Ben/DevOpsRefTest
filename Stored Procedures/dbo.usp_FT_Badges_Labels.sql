--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::
--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::
--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::
--::::::::::::::--::::::::::::::--:ADDRESS LABEL PREPARATION::::--::::::::::::::--::::::::::::::
--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::
--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::
--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::--::::::::::::::


--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.--NOT USED.


CREATE PROC [dbo].[usp_FT_Badges_Labels]

AS
SET NOCOUNT ON;

BEGIN TRY

	--// first grab all resubbed labels from the Intranet (orderview.asp) resubmit button (with 3 prompts)

	UPDATE tblOrders_Products
	SET fastTrak_preventLabel = 1 --// prevents label to be reprinted (because this selection is "NO LABEL" on the Intranet)
	WHERE fastTrak_shippingLabelOption1 = 1

	UPDATE tblOrders_Products
	SET fastTrak_preventLabel = 0 --// allows label to be reprinted (which will get set back to 1 at IMPO_POST_SSIS)
	WHERE fastTrak_shippingLabelOption2 = 1

	UPDATE tblOrders_Products
	SET fastTrak_preventLabel = 0 --// allows label to be reprinted (which will get set back to 1 at IMPO_POST_SSIS)
	WHERE fastTrak_shippingLabelOption3 = 1

	--// Now Grab Data
	-- EXEC sp_columns 'tblFT_Badges_Labels'
	DECLARE @stamp varchar(255)
	SET @stamp = (SELECT CONVERT(VARCHAR(10), DATEPART(MM, getDate())) + 
					CONVERT(VARCHAR(10), DATEPART(DD, getDate())) + 
					CONVERT(VARCHAR(10), DATEPART(YY, getDate())) + 
					CONVERT(VARCHAR(10), DATEPART(HH, getDate())) + 
					CONVERT(VARCHAR(10), DATEPART(SS, getDate())) + 
					CONVERT(VARCHAR(10), DATEPART(MS, getDate())))

	DELETE FROM tblFT_Badges_Labels

	INSERT INTO tblFT_Badges_Labels (sortNo, 
	template, DDFname, outputPath, logFilePath, outputStyle, outputFormat,
	shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, 
	orderNo, badgeName, badgeQTY, OPPO_ordersProductsID)

	--SELECT TOP 5  '999999999' AS 'sortNo', 
	SELECT DISTINCT  '999999999' AS 'sortNo', 
	'Macintosh HD:Name Badge Central:Impo Templates:Badge.Labels.barcode.qxp' AS 'template', 
	'NB_labels' AS 'DDFname', 
	'MERGE CENTRAL:Badge Automation:NAME BADGE IMPOSED:' + @stamp + '_L.pdf' as 'outputPath', 
	'ART DEPARTMENT-NEW:For SQL:FastTrak:Badges:Logs:' + @stamp + '_L.log' as 'logFilePath', 
	'Graphic Business Solutions' as 'outputStyle', 
	'PDF' as 'outputFormat',
	REPLACE(a.shipping_firstName + ' ' + a.shipping_surName, ' ', ' ') AS 'shipName', 
	REPLACE(a.shipping_Company,'-','') AS 'shipCompany', 
	a.shipping_Street AS 'shippingAddress', a.shipping_Street2 AS 'shipping_Address2', 
	a.shipping_suburb AS 'shipping_City', a.shipping_State AS 'shipping_State', a.shipping_postCode AS 'shipping_Zip', 
	a.orderNo AS 'orderNo', 
	SUBSTRING(z.textValue, 1, 30) AS 'badgeName',
	--REPLACE(SUBSTRING(z.textValue, 1, 30), '"', '''') AS 'badgeName', 
	SUM(p.productQuantity) AS 'badgeQTY', p.[ID] AS 'OPPO_ordersProductsID'
	--INTO tblFT_Badges_Labels
	FROM tblCustomers_ShippingAddress a INNER JOIN tblOrders o ON a.orderNo = o.orderNo
	INNER JOIN tblOrders_Products p ON o.orderID = p.orderID
	INNER JOIN tblOrdersProducts_ProductOptions z ON p.[ID] = z.ordersProductsID
	WHERE p.deleteX <> 'yes'
	AND (z.optionCaption LIKE '%Name:%' OR z.optionCaption = 'Agent Name')
	AND z.deleteX <> 'yes'
							--AND p.productCode LIKE 'NB%'
							--AND o.orderStatus <> 'cancelled' AND o.orderStatus <> 'failed' AND o.orderStatus <> 'waiting for payment'
							----// this value is changed upon resubmission in the intranet
	AND p.fastTrak_preventLabel = 0
							----// added the following 4 criteria which were pulled from IMPO_PRE_SSIS, because labels should only always print alongside IMPO.
							--AND p.fastTrak_imageFile_exported = 1
							--AND p.fastTrak_imposed = 0
							--AND p.fastTrak_preventImposition = 0
							--AND p.fastTrak_resubmit = 0
	AND p.[ID] IN
		(SELECT DISTINCT ordersProductsID
		FROM tblFT_Badges
		WHERE ordersProductsID IS NOT NULL)
	GROUP BY a.shipping_firstName, a.shipping_surName, a.shipping_Company, a.shipping_Street, a.shipping_Street2, 
	a.shipping_suburb, a.shipping_State, a.shipping_postCode, a.orderNo, z.textValue, p.[ID]
	ORDER BY p.[ID] ASC

	/*
	--// Drop and recreate index for PSU later
	DROP INDEX [IX_orderNo] ON tblFT_Badges_Labels 
	WITH ( ONLINE = OFF )

	CREATE NONCLUSTERED INDEX [IX_orderNo] ON tblFT_Badges_Labels
	(orderNo ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) 
	ON [PRIMARY]
	*/

	--// Grab total QTY per orderNo
	DELETE FROM tblFT_Badges_Labels_PKIDMIRROR

	INSERT INTO tblFT_Badges_Labels_PKIDMIRROR (badgeQTY, orderNo)
	SELECT SUM(badgeQTY) AS 'badgeQTY', orderNo
	--INTO tblFT_Badges_Labels_PKIDMIRROR
	FROM tblFT_Badges_Labels
	GROUP BY orderNo

	--// Update QTYs
	UPDATE tblFT_Badges_Labels
	SET badgeQTY = b.badgeQTY
	FROM tblFT_Badges_Labels a
	INNER JOIN tblFT_Badges_Labels_PKIDMIRROR b
		ON a.orderNo = b.orderNo

	--// Move towards single row per orderNo by pulling out OPPO_ordersProductsID
	DELETE FROM tblFT_Badges_Labels_Clean
	INSERT INTO tblFT_Badges_Labels_Clean (sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, badgeQTY)

	SELECT DISTINCT sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, badgeQTY
	--INTO tblFT_Badges_Labels_Clean
	FROM tblFT_Badges_Labels
	ORDER BY orderNo ASC

	--// Push back clean data
	DELETE FROM tblFT_Badges_Labels

	SET IDENTITY_INSERT tblFT_Badges_Labels ON

	INSERT INTO tblFT_Badges_Labels (sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, badgeQTY, PKID)
	SELECT DISTINCT sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, 
	badgeQTY, PKID
	FROM tblFT_Badges_Labels_Clean
	ORDER BY PKID ASC

	SET IDENTITY_INSERT tblFT_Badges_Labels OFF

	--// Modify sort order
	DECLARE @maxA INT, @countA INT

	SET @maxA = (SELECT TOP 1 PKID 
				FROM tblFT_Badges_Labels 
				ORDER BY PKID DESC)
	IF @maxA = 0
	BEGIN
	 SET @maxA = 0
	END

	SET @countA = (SELECT count(*) 
				  FROM tblFT_Badges_Labels)

	IF @countA = 0
	BEGIN
		SET @countA = 0
	END

	UPDATE tblFT_Badges_Labels
	SET sortNo = @countA - (@maxA - PKID)

	--// Reorder data per sortNo
	DELETE FROM tblFT_Badges_Labels_Bounce

	SET IDENTITY_INSERT tblFT_Badges_Labels_Bounce ON

	INSERT INTO tblFT_Badges_Labels_Bounce (sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, 
	badgeQTY, PKID)
	SELECT sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, 
	badgeQTY, PKID
	--INTO tblFT_Badges_Labels_Bounce
	FROM tblFT_Badges_Labels
	ORDER BY CONVERT(INT, sortNo) ASC

	SET IDENTITY_INSERT tblFT_Badges_Labels_Bounce OFF

	--// Push back clean data
	DELETE FROM tblFT_Badges_Labels

	SET IDENTITY_INSERT tblFT_Badges_Labels ON

	INSERT INTO tblFT_Badges_Labels (sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, 
	badgeQTY, PKID)
	SELECT sortNo, template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, 
	badgeQTY, PKID
	FROM tblFT_Badges_Labels_Bounce
	ORDER BY CONVERT(INT, sortNo) ASC

	SET IDENTITY_INSERT tblFT_Badges_Labels OFF

	--// Update CSZ to read "Ship with orderNo HOMXXX" IF said order has other products IN it besides name badges.
	UPDATE tblFT_Badges_Labels
	SET shipping_City = '<b><cM>Ship with orderNo: <z24>' + orderNo
	WHERE orderNo IN
	 (SELECT DISTINCT orderNo 
	 FROM tblOrders 
	 WHERE 
 
	 -- (1)
	 orderNo IS NOT NULL 
	 AND orderID IN
		 (SELECT DISTINCT orderID 
		 FROM tblOrders_Products 
		 WHERE orderID IS NOT NULL
		 AND deleteX <> 'yes'
		 AND productCode NOT LIKE 'NB%')
		 AND orderID IN
			 (SELECT DISTINCT orderID 
			 FROM tblOrders_Products 
			 WHERE orderID IS NOT NULL
			 AND deleteX <> 'yes'
			 AND productCode LIKE 'NB%')
	  )
	  -- (2)
	  OR OPPO_ordersProductsID IN
		(SELECT DISTINCT [ID] FROM tblOrders_Products
		WHERE fastTrak_shippingLabelOption2 = 1 
		AND [ID] IS NOT NULL)

	 -- The above code only runs (1) ON NEW ORDERS OR (2) WHERE fastTrak_shippingLabelOption2 = 1, (ship badge all) otherwise it ignores this "Ship with order" modification

	UPDATE tblFT_Badges_Labels
	SET shippingAddress = NULL, shipping_Address2 = NULL, shipping_State = NULL, shipping_Zip = NULL
	WHERE shipping_City LIKE '%Ship with orderNo%'

	--------------------------------------------------------------------------------------------------------
	--// Find the first sortNo per orderNo, so that the others can be deleted.
	IF OBJECT_ID(N'tempPSU_FTLabel01', N'U') IS NOT NULL 
	DROP TABLE tempPSU_FTLabel01

	CREATE TABLE tempPSU_FTLabel01 (
	 RowID INT IDENTITY(1, 1), 
	 sortNo INT,
	 orderNo VARCHAR(255)
	)
	DECLARE @NumberRecords INT, @RowCount INT
	DECLARE @orderNo VARCHAR(255), @sortNo INT
	DECLARE @sortNoCompare INT

	--// Create subset of orderNo's that have multi-counts
	DELETE FROM tblFT_Badges_Labels_orderNo_Count

	INSERT INTO tblFT_Badges_Labels_orderNo_Count (orderNo, QTY)
	SELECT orderNo, COUNT(orderNo) as 'QTY'
	--INTO tblFT_Badges_Labels_orderNo_Count
	FROM tblFT_Badges_Labels
	GROUP BY orderNo
	HAVING COUNT(orderNo) > 1
	ORDER BY orderNo ASC

	--// Drop and recreate index
	DROP INDEX [IX_orderNo] ON tblFT_Badges_Labels_orderNo_Count 
	WITH ( ONLINE = OFF )

	CREATE NONCLUSTERED INDEX [IX_orderNo] ON tblFT_Badges_Labels_orderNo_Count
	(orderNo ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) 
	ON [PRIMARY]

	--// Create result set for loop
	INSERT INTO tempPSU_FTLabel01 (sortNo, orderNo)
	SELECT DISTINCT sortNo, orderNo
	FROM tblFT_Badges_Labels
	WHERE orderNo IN
		(SELECT DISTINCT orderNo 
		FROM tblFT_Badges_Labels_orderNo_Count
		WHERE orderNo IS NOT NULL)
	ORDER BY orderNo ASC

	--// Run count
	SET @NumberRecords = @@ROWCOUNT
	SET @RowCount = 1

	--// Begin loop
	WHILE @RowCount <= @NumberRecords
	BEGIN
		SELECT @sortNo = sortNo,
		@orderNo = orderNo
		FROM tempPSU_FTLabel01
		WHERE RowID = @RowCount

		SELECT @sortNoCompare = (SELECT TOP 1 sortNo
								FROM tblFT_Badges_Labels
								WHERE orderNo = @orderNo
								ORDER BY sortNo ASC)

		IF @sortNo = @sortNoCompare
		BEGIN
			SET @RowCount = @RowCount + 1
			CONTINUE
		END

		ELSE
		BEGIN
			DELETE FROM tblFT_Badges_Labels WHERE sortNo = @sortNo
		END

		SET @RowCount = @RowCount + 1
	END

	--// Drop the temporary table
	IF OBJECT_ID(N'tempPSU_FTLabel01', N'U') IS NOT NULL 
	DROP TABLE tempPSU_FTLabel01



	--// Create final table, used for SSIS export
	IF OBJECT_ID(N'tblFT_Badges_Labels_forExport', N'U') IS NOT NULL 
	DROP TABLE tblFT_Badges_Labels_forExport

	CREATE TABLE tblFT_Badges_Labels_forExport(
		[sortNo] [int] IDENTITY(1,1) NOT NULL,
		[template] [nvarchar](255) NULL,
		[DDFname] [nvarchar](255) NULL,
		[outputPath] [nvarchar](255) NULL,
		[logFilePath] [nvarchar](255) NULL,
		[outputStyle] [nvarchar](255) NULL,
		[outputFormat] [nvarchar](255) NULL,
		[shipName] [nvarchar](255) NULL,
		[shipCompany] [nvarchar](255) NULL,
		[shippingAddress] [nvarchar](255) NULL,
		[shipping_Address2] [nvarchar](255) NULL,
		[shipping_City] [nvarchar](255) NULL,
		[shipping_State] [nvarchar](255) NULL,
		[shipping_Zip] [nvarchar](255) NULL,
		[orderNo] [nvarchar](255) NULL,
		[badgeName] [nvarchar](255) NULL,
		[badgeQTY] [int] NULL,
		[OPPO_ordersProductsID] [int] NULL
	) ON [PRIMARY]

	INSERT INTO tblFT_Badges_Labels_forExport (template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, 
	shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, badgeQTY)
	SELECT DISTINCT template, DDFname, outputPath, logFilePath, outputStyle, outputFormat, shipName, shipCompany, shippingAddress, 
	shipping_Address2, shipping_City, shipping_State, shipping_Zip, orderNo, badgeName, badgeQTY
	FROM tblFT_Badges_Labels
	ORDER BY orderNo ASC

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH