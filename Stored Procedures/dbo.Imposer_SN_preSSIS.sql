




CREATE PROCEDURE [dbo].[Imposer_SN_preSSIS]
AS

/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     05/03/19	
Purpose     Signs Alpha
-------------------------------------------------------------------------------
Modification History

05/03/19	Created, jf.
05/07/19	Added iteration section, jf.
07/09/19	Added non-iterative section, jf.
07/23/19		Added DDN section at end, jf.
11/12/19		JF, added the "SNFA" code to the initial query. This should help with Furnished Art. When a CSR "Good to Go's" the sign which is processType = 'custom', the G2G changes the processType to 'fasTrak'. This is essentially, a QA GATE prior to building sign.
11/14/19		JF, added readyForSwitch check.
01/29/20	CB, Added code to populate tables for sign labels and batch data to track sign label printing
03/09/20	JF, made a bunch of changes to the ShipsWith section, see inline notes.
03/10/20	CB, Added logic for material Polycomb (B)
03/18/20	CB, Added logic to exlude the GBSCompanyId oppo from the statement that assigns the value from the material oppo to the SN_ImposerExport table
03/30/20	CB, Added logic to include the fastTrak_newQTY instead of opid quantity for fastTrak resubs
04/23/20	BS, Y2k work CONVERT(INT, STUFF(orderNo, 1, PATINDEX('%[0-9]%', orderNo)-1,''))
04/30/20	CB, changed the n of n field to 3 digits instead of 2 since there were over 100 signs in an order.
06/18/20	CB, added logic to handle inconsistent and multiple material oppos
06/25/20	CB, Added logic for new substrate/material for PolyComb
07/01/20	CB, Added logic for substrate/material for ACM = A, ACM-R = R
09/09/20	JF, Added fileExists fix to init query.
11/23/20	JF, LEN(orderNo) IN (9,10)
01/06/21	BS, iframe conversion material upgrade handling 
02/08/21	BS, removed description in the material oppo update
02/09/21	CKB, Added new grommet textValues
03/12/21 JF, Added SN_ImpEx section.
03/18/21 JF, Added ULYA line in section #2 of the init query.
03/25/21 BJS Added space for more sizes 5th Char to the first dash
08/03/21	CKB, added validatefile and changed file exist logic to match logic in other flows
08/05/21	CKB, removed priority update so all priority = 9 per Deanna's email
-------------------------------------------------------------------------------
*/

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'SN Switch SP', @lastRunDate;

EXEC usp_OPPO_validateFile 'SN'

--Timestamp for sign batch
declare @batchTimestamp datetime = getdate()

TRUNCATE TABLE SN_ImposerExport
INSERT INTO SN_ImposerExport (jobnumber, opid, material, size, shape)

SELECT DISTINCT
STUFF(orderNo, 1, PATINDEX('%[0-9]%', orderNo)-1,'') + '_' + CONVERT(VARCHAR(50), op.ID) AS jobNumber, 
op.id AS opid,
'material' AS material,
s.size, 
s.shape
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
--INNER JOIN SignMeta s ON SUBSTRING(op.productCode, 5, 2) = s.char_52
INNER JOIN SignMeta s ON SUBSTRING(op.productCode, 5,ISNULL(CHARINDEX('-', op.productCode),0)-5)  = s.char_52  --BJS 03/25/21 Added space for more sizes 5th Char to the first dash
WHERE productcode like 'SN__%-%'

--1. Order Qualification ----------------------------------
AND DATEDIFF(MI, o.created_on, GETDATE()) > 10
AND o.orderDate > CONVERT(DATETIME, '02/01/2019')
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND o.displayPaymentStatus = 'Good'

--2. Product Qualification --------------------------------
AND SUBSTRING(op.productCode, 1, 2) = 'SN' 
AND (op.productCode NOT LIKE 'SNFA%' AND op.processType <> 'fasTrak' 
			OR op.productCode LIKE 'SNFA%' AND op.processType = 'Custom' AND op.fastTrak_status = 'Good to Go' --allows G2G'd ULYAs 3/18/21 jf.
			OR op.productCode LIKE 'SNFA%' AND op.processType = 'fasTrak') 

--3. OPID Qualification -----------------------------------
AND op.deleteX <> 'yes'
AND op.processType IN ('fasTrak', 'custom') --this will eventually be just ft.
AND (
		--4.a
		op.fastTrak_status = 'In House'
		AND op.[ID] IN
				(SELECT ordersProductsID
				FROM tblOrdersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionCaption = 'OPC')		
		--4.b
		OR op.fastTrak_status = 'Good to Go'
		--4.
		OR op.fastTrak_resubmit = 1
		)
--4. Logic Unique to Signs ----------------------------------
AND (op.stream IS NULL OR op.stream = 0) --stream is a previously unused bit field that will be marked 1 when OPID submitted to hot folder --------------------------

--5.Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND EXISTS			--must have a file	
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.OPID = op.id)

AND NOT EXISTS		-- none of the files can be missing/broken		
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.id)

--update material value
UPDATE x
SET material = textValue
FROM SN_ImposerExport x
INNER JOIN tblOrdersProducts_productOptions oppx ON oppx.ordersProductsID = x.opid
WHERE oppx.optionCaption LIKE '%Material%Upgrade%'  --BJS 01/06/2021 iframe conversion
AND oppx.optionCaption NOT LIKE 'Info%'
AND oppx.optionCaption NOT LIKE 'File%'
AND oppx.optionCaption NOT LIKE '%PDF'
AND oppx.optionCaption NOT LIKE '%preview%'
AND oppx.optionCaption NOT LIKE '%name%'
AND oppx.optionCaption NOT LIKE '%grom%'
AND oppx.optionCaption NOT LIKE '%cc%'
AND oppx.optionCaption NOT IN ('OPC', '10 Digit Company Code', 'canvas', 'GBSCompanyId')
and oppx.deletex <> 'yes'

--update for missing aluminum reflective 
update x set material = 'ACM Reflective'
from SN_ImposerExport x
where exists
(
select top 1 1
from dbo.tblOrdersProducts_ProductOptions oppo
where oppo.optionCaption = 'Aluminum Reflective Upgrade'
       and oppo.ordersProductsID = x.opid
	   and oppo.deletex <> 'yes'
)
--update for missing pvc
update x set material = 'PVC'
from SN_ImposerExport x
where exists
(
select top 1 1
from dbo.tblOrdersProducts_ProductOptions oppo
where oppo.optionCaption = 'PVC Upgrade'
       and oppo.ordersProductsID = x.opid
	   and oppo.deletex <> 'yes'
)
--update for missing PolyComb
update x set material = 'PolyComb'
from SN_ImposerExport x
where exists
(
select top 1 1
from dbo.tblOrdersProducts_ProductOptions oppo
where oppo.optionCaption = 'Polycomb Upgrade'
       and oppo.ordersProductsID = x.opid
	   and oppo.deletex <> 'yes'
)
--massage
UPDATE SN_ImposerExport SET material = 'ACM' WHERE material LIKE '%aluminum%' and material NOT LIKE '%reflective%'
UPDATE SN_ImposerExport SET material = 'ACM Reflective' WHERE material LIKE '%aluminum%' and material LIKE '%reflective%'
UPDATE SN_ImposerExport SET material = 'PVC' WHERE material LIKE '%pvc%'
UPDATE SN_ImposerExport SET material = 'PolyComb' WHERE material LIKE '%PolyComb%'
UPDATE SN_ImposerExport SET material = 'Corrugated Plastic' WHERE material LIKE 'Corrugated Plastic%'
UPDATE SN_ImposerExport SET material = 'Failure' WHERE material NOT IN ('ACM', 'ACM Reflective', 'PVC', 'PolyComb','Corrugated Plastic') --default value

--iteration section ------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE SN_ImposerExport_Iterate

IF OBJECT_ID('tempdb..#SNQTY') IS NOT NULL DROP TABLE #SNQTY
CREATE TABLE #SNQTY
	(RowID INT IDENTITY(1, 1), 
	OPID INT, 
	QTY INT)
DECLARE @NumberRecords INT, @RowCount INT
DECLARE @OPID INT
DECLARE @QTY INT

--work table
TRUNCATE TABLE #SNQTY
INSERT INTO #SNQTY (OPID, QTY)
SELECT DISTINCT sn.OPID
,productQuantity = case 
	when op.fastTrak_resubmit <> 0 and op.fastTrak_newQTY is not null then op.fastTrak_newQTY 
	else op.productQuantity end 
FROM SN_ImposerExport sn
INNER JOIN tblOrders_Products op ON sn.OPID = op.ID
 
--get the number of records in the temp table
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

--get loopy
WHILE @RowCount < = @NumberRecords
BEGIN
	
	SELECT @OPID = OPID, 
	@QTY = QTY
	FROM #SNQTY
	WHERE RowID = @RowCount
	
			WHILE @QTY > 0
			BEGIN
	
			INSERT INTO SN_ImposerExport_Iterate (jobnumber, opid, material, size, shape)
			SELECT sn.jobnumber, sn.opid, sn.material, sn.size, sn.shape
			FROM SN_ImposerExport sn
			WHERE sn.OPID = @OPID

			SET @QTY = @QTY - 1
			END

	SET @RowCount = @RowCount + 1
END
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--finalize data for export - Iterative
TRUNCATE TABLE SN_ImposerExport
INSERT INTO SN_ImposerExport (jobnumber, opid, material, size, shape)
SELECT jobnumber, opid, material, size, shape 
FROM SN_ImposerExport_Iterate
ORDER BY jobnumber

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--finalize data for export - Non-iterative
TRUNCATE TABLE SN_ImposerExportNoIteration 
INSERT INTO SN_ImposerExportNoIteration (jobNumber, opid, material, size, shape, qty)
SELECT DISTINCT jobNumber, opid, material, size, shape, COUNT(i.opid) OVER(PARTITION BY i.opid) AS qty
FROM SN_ImposerExport i
ORDER BY jobnumber

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--finalize data for export - Non-iterative - DDN
--first update the DieDesignName value in SN_ImposerExportNoIteration, for easier join below
UPDATE sn
SET DieDesignName = ISNULL(sn.material, 'MISSING_MATERIAL') + ' ' + ISNULL(sn.size, 'MISSING_SIZE') + ' ' + ISNULL(sn.shape, 'MISSING_SHAPE') 
FROM SN_ImposerExportNoIteration sn
WHERE sn.DieDesignName IS NULL

TRUNCATE TABLE SN_ImposerExportNoIteration_DDN
INSERT INTO SN_ImposerExportNoIteration_DDN ([Name], ArtworkFile, BackArtworkFile, Ordered, Width, Height, Bleed, Stock, GrainDirection, Grade, MaxOverruns, BleedType, SpacingType, DieDesignName, CADFile, DieDesignSource)
SELECT
'', 
'/Volumes/print/Sign Singles/' + ISNULL(sn.jobNumber, 'MISSING') + '-s1.pdf' AS ArtworkFile,
'/Volumes/print/Sign Singles/' + ISNULL(sn.jobNumber, 'MISSING') + '-s2.pdf' AS BackArtworkFile,
sn.QTY, sm2.Width, sm2.Height, sm2.Bleed, sn.material, 'Vertical', '', '', '', 'Bleed', 
sm2.DieDesignName, '', 'DieDesignLibrary'
FROM SN_ImposerExportNoIteration sn
INNER JOIN SignMeta2 sm2 ON sm2.SignName = sn.DieDesignName 

 ------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------

 --finalize data for export - Non-iterative - DDN - With 4 new columns (8/1/19)
TRUNCATE TABLE [SN_ImposerExportNoIteration_DDN_wPriority]
INSERT INTO [SN_ImposerExportNoIteration_DDN_wPriority] ([Name], ArtworkFile, BackArtworkFile, Ordered, Width, Height, Bleed, Stock, GrainDirection, Grade, MaxOverruns, BleedType, SpacingType, DieDesignName, CADFile, DieDesignSource, Resubmit, Expedited, [Description], Marks)
SELECT
'', 
'/Volumes/print/Sign Singles/' + ISNULL(sn.jobNumber, 'MISSING') + '-s1.pdf' AS ArtworkFile,
'/Volumes/print/Sign Singles/' + ISNULL(sn.jobNumber, 'MISSING') + '-s2.pdf' AS BackArtworkFile,
sn.QTY, sm2.Width, sm2.Height, sm2.Bleed, sn.material, 'Vertical', '', '', '', 'Bleed', 
sm2.DieDesignName, '', 'DieDesignLibrary',
0,0, sn.jobNumber,
CASE sn.shape
	WHEN 'Rectangle' THEN 'Product ID'
	ELSE 'Product ID ' + sn.shape
END AS Marks
FROM SN_ImposerExportNoIteration sn
INNER JOIN SignMeta2 sm2 ON sm2.SignName = sn.DieDesignName 
INNER JOIN tblOrders_Products op ON sn.opid = op.id

UPDATE a
SET Resubmit = 1
FROM [SN_ImposerExportNoIteration_DDN_wPriority] a
INNER JOIN SN_ImposerExportNoIteration sn ON a.[Description] = sn.jobNumber
INNER JOIN SignMeta2 sm2 ON sm2.SignName = sn.DieDesignName 
INNER JOIN tblOrders_Products op ON sn.opid = op.id
WHERE op.fastTrak_resubmit = 1

UPDATE a
SET Expedited = 1
FROM [SN_ImposerExportNoIteration_DDN_wPriority] a
INNER JOIN SN_ImposerExportNoIteration sn ON a.[Description] = sn.jobNumber
INNER JOIN SignMeta2 sm2 ON sm2.SignName = sn.DieDesignName 
INNER JOIN tblOrders_Products op ON sn.opid = op.id
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
INNER JOIN tblOrders o ON o.orderID = op.orderID
WHERE (oppx.optionCaption = 'Express Production' 
		AND oppx.textValue LIKE 'Yes%'--Shreck, iframe conversions
		AND oppx.deleteX <> 'yes')
OR o.orderID IN (SELECT ox.orderID
				FROM tblOrders ox
				WHERE shippingDesc LIKE '%2%'
				OR shippingDesc LIKE '%3%'
				OR shippingDesc LIKE '%next%')

 ------------------------------------------------------------------------------------------------------------------------------BEGIN
 ------------------------------------------------------------------------------------------------------------------------------

 --finalize data for export - [SN_ImpEx] - Removing Nigel from the equation (03/12/21)

TRUNCATE TABLE SN_ImpEx
INSERT INTO SN_ImpEx ([Name], [ArtworkFile], [BackArtworkFile], [Ordered], [Width], [Height], [Bleed], [Stock], [GrainDirection], [Grade], [MaxOverruns], [BleedType], [SpacingType], [DieDesignName], [CADFile], [DieDesignSource], [Priority], [Description], [Marks], [Template], [Sheet], [MACArtworkFile], [MACBackArtworkFile])
SELECT
		'' AS [Name]
		, 'z:\Sign Singles\' + ISNULL(sn.jobNumber, 'MISSING') + '-s1.pdf' AS ArtworkFile
		, 'z:\Sign Singles\' + ISNULL(sn.jobNumber, 'MISSING') + '-s2.pdf' AS BackArtworkFile
		, sn.QTY AS Ordered
		, sm2.Width AS Width
		, sm2.Height AS Height
		, sm2.Bleed AS Bleed
		, CASE sn.material WHEN 'Corrugated Plastic' THEN 'Coroplast' ELSE sn.material END AS Stock
		, sm2.Grain AS [Grain]
		, '' AS Grade
		, '' AS [Max Overruns]
		, '' AS [Bleed Type]
		, 'Bleed'  AS [Spacing Type]
		, sm2.DieDesignName AS [Die Design Name]
		, '' AS [CAD File]
		, 'DieDesignLibrary' AS [Die Design Source]
		, 9 AS [Priority] --updated below
		, sn.jobNumber AS [Description]
		, CASE sn.shape WHEN 'Rectangle' THEN 'Product ID' ELSE 'Product ID ' + sn.shape END AS Marks
		, sm2.template AS Template
		, sm2.sheet AS Sheet
		, '/Volumes/print/Sign Singles/' + ISNULL(sn.jobNumber, 'MISSING') + '-s1.pdf' AS MACArtworkFile
		, '/Volumes/print/Sign Singles/' + ISNULL(sn.jobNumber, 'MISSING') + '-s2.pdf' AS MACBackArtworkFile
FROM SN_ImposerExportNoIteration sn
INNER JOIN SignMeta2 sm2 ON sm2.SignName = sn.DieDesignName 
INNER JOIN tblOrders_Products op ON sn.opid = op.id

--fix missing materials
UPDATE SN_ImpEx
SET stock = 'ACM'
WHERE DieDesignName LIKE '%ACM%'
AND stock IS NULL

UPDATE SN_ImpEx
SET stock = 'PolyComb'
WHERE DieDesignName LIKE '%Poly%'
AND stock IS NULL

UPDATE SN_ImpEx
SET stock = 'Coroplast'
WHERE DieDesignName LIKE '%Coro%'
AND stock IS NULL

-- leave all priorities as "9" per Deanna 8/5/21

--update priority column
--UPDATE x
--SET [priority] = 1
--FROM SN_ImpEx x
--INNER JOIN tblOrders_Products op ON RIGHT(x.Description, 9) = op.id
--WHERE op.fastTrak_resubmit = 1

--UPDATE x
--SET [priority] = 1
--FROM SN_ImpEx x
--INNER JOIN tblOrders_Products op ON RIGHT(x.Description, 9) = op.id
--INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
--INNER JOIN tblOrders o ON o.orderID = op.orderID
--WHERE (oppx.optionCaption = 'Express Production' 
--		AND oppx.textValue LIKE 'Yes%'
--		AND oppx.deleteX <> 'yes')
--OR o.orderID IN (SELECT ox.orderID
--				FROM tblOrders ox
--				WHERE shippingDesc LIKE '%2%'
--				OR shippingDesc LIKE '%3%'
--				OR shippingDesc LIKE '%next%')

 ------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------END

/**** New code to populate table for printing sign labels *****/
declare @BaseSignsForExportLabels table
(
	[PKID] int identity(1,1) not null,
	[batchTimestamp] datetime not null,
	[orderNo] [nvarchar](50) NULL,
	[orderID] int null,
	[opid] [int] NULL,
	[orderDate] [varchar](20) NULL,
	[orderPrintedDate] [varchar](10) NULL,
	[orderStatus] [varchar](50) NULL,
	[BatchImpo] [varchar](50) NULL,
	[shipping_Company] [nvarchar](100) NULL,
	[shipping_FirstName] [nvarchar](50) NULL,
	[shipping_Surname] [nvarchar](50) NULL,
	[shipping_Street] [nvarchar](100) NULL,
	[shipping_Suburb] [nvarchar](50) NULL,
	[shipping_State] [nvarchar](50) NULL,
	[shipping_PostCode] [nvarchar](15) NULL,
	[productCode] [nvarchar](50) NULL,
	[productQuantity] [int] NULL,
	[FrontPdf] [nvarchar](1000) NULL,
	[BackPdf] [nvarchar](1000) NULL,
	[size] [nvarchar](255) NULL,
	[signXofX] [varchar](50) NULL,
	[jobNumber] [nvarchar](255) NULL,
	[shipsWith] [varchar](50)  NULL,
	[shipType] [varchar](50) NULL,
	[bottomLabel1] [varchar](255) NULL,
	[bottomLabel2] [varchar](255) NULL,
	[squareLabel] [char](1) NULL,
	[circleLabel] [char](1) NULL,
	[material] [varchar](255) NULL,
	[grommets] [varchar](255) NULL,
	[stockProducts] [varchar](255) NULL,
	[fastTrackResubmit] [bit] NULL
)
insert into @BaseSignsForExportLabels
([batchTimestamp]
,[orderNo]
,[orderID]
,[opid]
,[orderDate]
,[orderPrintedDate]
,[orderStatus]
,[BatchImpo]
,[shipping_Company]
,[shipping_FirstName]
,[shipping_Surname]
,[shipping_Street]
,[shipping_Suburb]
,[shipping_State]
,[shipping_PostCode]
,[productCode]
,[productQuantity]
,[FrontPdf]
,[BackPdf]
,[size]
,[signXofX]
,[jobNumber]
,[shipsWith]
,[shipType]
,[bottomLabel1]
,[bottomLabel2]
,[squareLabel]
,[circleLabel]
,[material]
,[grommets]
,[stockProducts]
,[fastTrackResubmit])
select 
batchTimestamp = @batchTimestamp
,o.orderNo
,o.orderID
,opid = op.ID
,orderDate = rtrim(convert(varchar(20),o.orderDate,22))
,orderPrintedDate = rtrim(convert(varchar(10),o.orderPrintedDate,1))
,o.orderStatus
,[BatchImpo] = '1814-4'
,nullif(o.shipping_Company,'')
,nullif(o.shipping_FirstName,'')
,nullif(o.shipping_Surname,'')
,o.shipping_Street
,o.shipping_Suburb
,o.shipping_State
,o.shipping_PostCode
,op.productCode
,op.productQuantity
--,FrontPdf = 'https:' + (select top 1 textValue from dbo.tblOrdersProducts_ProductOptions where ordersProductsID = op.ID and optionCaption IN ( 'Web Preview','CanvasPreviewFront')) 
--,BackPdf = 'https:' + (select top 1 textValue from dbo.tblOrdersProducts_ProductOptions where ordersProductsID = op.ID and optionCaption IN ( 'Back Web Preview','CanvasPreviewBack'))
,FrontPdf = (select top 1 textValue = case when CHARINDEX('https:',textValue) > 0 then textValue else 'https:' + textValue end from dbo.tblOrdersProducts_ProductOptions where ordersProductsID = op.ID and optionCaption IN ( 'Web Preview','CanvasPreviewFront') and deletex <> 'yes') 
,BackPdf = (select top 1 textValue = case when CHARINDEX('https:',textValue) > 0 then textValue else 'https:' + textValue end from dbo.tblOrdersProducts_ProductOptions where ordersProductsID = op.ID and optionCaption IN ( 'Back Web Preview','CanvasPreviewBack') and deletex <> 'yes')
,size = ie.[size]
,signXofX = right('000' + rtrim(cast(ROW_NUMBER() over (partition by o.orderNo order by op.ID) as varchar(3))),3) + ' of ' + right('000' + rtrim(cast(count(op.ID) over (partition by o.orderNo) as varchar(3))),3)
,jobNumber = rtrim(o.orderNo) + '_' + rtrim(cast(op.ID as varchar(10)))
,shipsWith = 'Ship'
,shipType = 'Ship'
,bottomLabel1 = ''
,bottomLabel2 = ''
,squareLabel = '' 
,circleLabel = ''
,material = 
	(select max(
		case
		when (oppo.optionCaption like '%pvc%' or oppo.optionGroupCaption like '%pvc%' or oppo.textValue like '%pvc%')
			then 'PVC'
		when (oppo.optionCaption like '%reflective%' or oppo.optionGroupCaption like '%reflective%' or oppo.textValue like '%reflective%')
			then 'ACM Reflective'
		when (oppo.optionCaption like '%aluminum%' or oppo.optionGroupCaption like '%aluminum%' or oppo.textValue like '%aluminum%')
			then 'ACM'
		when (oppo.optionCaption like '%polycomb%' or oppo.optionGroupCaption like '%polycomb%' or oppo.textValue like '%polycomb%')
			then 'Polycomb'
		else 'Corrugated Plastic' end) as material	
		from dbo.tblOrdersProducts_ProductOptions oppo
		where op.ID = oppo.ordersProductsID 
			and oppo.deletex <> 'yes'
			and (oppo.optionCaption like '%material%' or oppo.optionGroupCaption like '%material%' or oppo.textValue like '%material%')
		group by oppo.ordersProductsID
	)
--,material = (select top 1 optionCaption from dbo.tblOrdersProducts_ProductOptions where ordersProductsID = op.ID 
--	and (optionCaption in ('Directional Signs Material Upgrade','Rider Signs Material Upgrade','Yard Signs Material Upgrade') or optionID in (511,565,576)) and deletex <> 'yes')
--,grommets = (select top 1 optionCaption from dbo.tblOrdersProducts_ProductOptions where ordersProductsID = op.ID and optionCaption like '%grommet%' and deletex <> 'yes')
,grommets = 
	(select max(
		case 
		when (oppo.optionCaption like '%Add 2 Grommets%' or oppo.optionGroupCaption like '%Add 2 Grommets%' or oppo.textValue like '%Add 2 Grommets%' or oppo.textValue like '%Add top grommet holes%')	-- added new values for iframe conversion
			then 'Add 2 Grommets'
		when (oppo.optionCaption like '%Add 4 Grommets%' or oppo.optionGroupCaption like '%Add 4 Grommets%' or oppo.textValue like '%Add 4 Grommets%' or oppo.textValue like '%Add top and bottom grommet holes%')	-- added new values for iframe conversion
			then 'Add 4 Grommets'
		else null end) as material
		from dbo.tblOrdersProducts_ProductOptions oppo
		where op.ID = oppo.ordersProductsID 
			and oppo.deletex <> 'yes'
			and (oppo.optionCaption like '%grommet%' or oppo.optionGroupCaption like '%grommet%' or oppo.textValue like '%grommet%')
		group by oppo.ordersProductsID
	)
,stockProducts = (select stuff(
					(select '|' + opsub.processType + '(' + rtrim(cast(opsub.productCount as char(2))) + '):' +
						(stuff(
							(select distinct ',' + left(opp.productCode,4)
							from dbo.tblOrders_Products opp
							where opp.orderID = opsub.orderid
								and opp.processType = opsub.processType
								and opp.id <> op.ID
							for xml path('')),1,1,''))
					from (
							select opin.orderID, opin.processType, count(*) productCount
							from dbo.tblOrders_Products opin
							where opin.orderID = op.orderID 
								and opin.id <> op.ID
							group by opin.orderID, opin.processType) opsub	
					where op.orderID = o.orderID
					for xml path('')),1,1,''))
,fastTrackResubmit = op.fastTrak_resubmit
from dbo.tblOrders o
inner join dbo.tblOrders_Products op
	on o.orderID = op.orderID
inner join SN_ImposerExport ie
	on op.id = ie.opid
--inner join dbo.tblProducts p
--	on op.productID = p.productID

/******************************************************* ShipsWith stuff from other flows ***********************************************************************/
/* 
--// Custom = (1/2) If a custom product is with order (excluding pens and paper business cards)
UPDATE a
SET shipsWith = 'Custom'
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE
a.opid <> b.[ID]
AND b.deleteX <> 'yes'
AND b.processType = 'Custom'
AND a.shipsWith <> 'Custom'
AND (b.productName NOT LIKE '%envelope%' OR b.productName LIKE '%Custom Envelope%')
AND SUBSTRING(b.productCode, 1, 2) <> 'PN' --pens

--// Custom = (2/2) If a CACX product is ALSO in the order and it is NOT an OPC CACX item
UPDATE a
SET shipsWith = 'Custom'
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE
a.opid <> b.[ID]
AND b.deleteX <> 'yes'
AND b.processType = 'Custom'
AND a.shipsWith <> 'Custom'
AND (SUBSTRING(b.productCode, 3, 2) = 'CH' OR SUBSTRING(b.productCode, 3, 2) = 'CC')
AND b.[ID] NOT IN
		(SELECT DISTINCT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'OPC')

--// FasTrak = (1/1) If another FasTrak product is with order (excluding OPC CACX)
UPDATE a
SET shipsWith = 'FasTrak'
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE a.opid <> b.[ID]
AND b.deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND a.shipsWith <> 'Custom'

--// Local pickup, will call
UPDATE @BaseSignsForExportLabels
SET shipsWith = 'Local Pickup'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE 
	LEN(orderNo) IN (9,10) 
	AND (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
		OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will%')
	OR 
	LEN(orderNo) IN (9,10) 
	AND (CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')
	)

update @BaseSignsForExportLabels
set shipsWith = 'Stock'
where orderID in
(SELECT a.orderID
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND b.productID IN
	(SELECT DISTINCT productID
	FROM tblProducts
	WHERE SUBSTRING(productCode, 1, 2) <> 'FM'
	AND productType = 'Stock')
group by a.orderID
having count(*) > 5)

*/
--SHIPS WITH -------------
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ JEREMY'S CODE STARTS HERE 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (this replaces lines 352 thru 424 above)

--// Custom = (1/2) If ANOTHER custom product is with order (excluding pens and paper business cards).
UPDATE a
SET shipsWith = 'Custom'
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE a.opid <> b.[ID]
AND b.deleteX <> 'yes'
AND b.processType = 'Custom'
AND a.shipsWith <> 'Custom'
AND (b.productName NOT LIKE '%envelope%' OR b.productName LIKE '%Custom Envelope%')
AND LEFT(b.productCode, 2) <> 'PN' --pens

--// Custom = (2/2) If ANOTHER SN product is ALSO in the order and it is NOT an OPC SN item (therefore, it is not a fastrak opid)
UPDATE a
SET shipsWith = 'Custom'
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE a.opid <> b.[ID]
AND b.deleteX <> 'yes'
AND b.processType = 'Custom'
AND a.shipsWith <> 'Custom'
AND LEFT(b.productCode, 2) = 'SN'
AND b.[ID] NOT IN
		(SELECT DISTINCT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'OPC')

--// FasTrak = (1/1) If ANOTHER FasTrak product is with order (excluding any OPC SN), and the shipsWith isn't already set to Custom.
UPDATE a
SET shipsWith = 'FasTrak'
FROM @BaseSignsForExportLabels a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE a.opid <> b.[ID]
AND b.deleteX <> 'yes'
AND b.processType = 'fasTrak'
AND a.shipsWith <> 'Custom'

--// Local pickup, will call
UPDATE a
SET shipsWith = 'Local Pickup'
FROM @BaseSignsForExportLabels a
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrders o
	WHERE (CONVERT(VARCHAR(255), o.shippingDesc) LIKE '%local%' 
			OR CONVERT(VARCHAR(255), o.shippingDesc) LIKE '%will%'
			OR CONVERT(VARCHAR(255), o.shipping_firstName) LIKE '%local%')
	AND o.orderNo = a.orderNo)

IF OBJECT_ID('tempdb..#SNQTY24518') IS NOT NULL DROP TABLE #SNQTY24518
CREATE TABLE #SNQTY24518
	(RowID INT IDENTITY(1, 1), 
	orderID INT, 
	stockCount INT)

INSERT INTO #SNQTY24518 (orderID, stockCount)
SELECT DISTINCT a.orderID, b.[ID]
FROM tblSwitch_CACX a
INNER JOIN tblOrders_Products b ON a.orderID = b.orderID
WHERE b.deleteX <> 'yes'
AND EXISTS
	(SELECT TOP 1 1
	FROM tblProducts p
	WHERE LEFT(p.productCode, 2) <> 'FM'
	AND p.productCode = 'Stock'
	AND b.productID = p.productID)

UPDATE a
SET shipsWith = 'Stock'
FROM @BaseSignsForExportLabels a
WHERE EXISTS
	(SELECT TOP 1 1
	FROM #SNQTY24518 o
	WHERE a.orderID = o.orderID
	GROUP BY orderID
	HAVING COUNT(o.orderID) > 5)

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ JEREMY'S CODE ENDS HERE





/****** shipType stuff ********************************************************************/
/*
Custom = If ANOTHER custom product is with order (excluding pens and paper business cards)
FasTrak = if ANOTHER FasTrak product is with order (excluding OPC CACX)
Stock = if more than 6 stock line items with order (excluding NameBadge accessories)
Ship = all else (already default)
*/

--// default
UPDATE @BaseSignsForExportLabels
SET shipType = 'Ship'
WHERE shipType IS NULL

--// 3 day
UPDATE @BaseSignsForExportLabels
SET shipType = '3 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

--// 2 day
UPDATE @BaseSignsForExportLabels
SET shipType = '2 Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

--// Next day
UPDATE @BaseSignsForExportLabels
SET shipType = 'Next Day'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) IN (9,10)
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

--// Local pickup, will call
UPDATE @BaseSignsForExportLabels
SET shipType = 'Local Pickup'
WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE 
	LEN(orderNo) IN (9,10) 
	AND (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' 
		OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will%')
	OR  
	LEN(orderNo) IN (9,10) 
	AND (CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local%')
	)

update @BaseSignsForExportLabels
set squareLabel = case when material = 'Corrugated Plastic' then 'C' 
					when material = 'PVC' then 'P'
					when material = 'ACM' then 'A'
					when material = 'ACM Reflective' then 'R'
					when material = 'Polycomb' then 'B'
					else 'C' end
,circleLabel = case when grommets is null then 'X'
					when grommets = 'Add 2 Grommets' then '2'
					when grommets = 'Add 4 Grommets' then '4'
					else 'X' end
,bottomLabel1 = shipsWith
,bottomLabel2 = case when shipType in ('3 Day','2 Day','Next Day') then 'Expedited' 
					else 'Ship' end

INSERT INTO [dbo].[SN_ImposerExport_Label]
([batchTimestamp]
,[PKID]
,[orderNo]
,[orderID]
,[opid]
,[orderDate]
,[orderPrintedDate]
,[orderStatus]
,[BatchImpo]
,[shipping_Company]
,[shipping_FirstName]
,[shipping_Surname]
,[shipping_Street]
,[shipping_Suburb]
,[shipping_State]
,[shipping_PostCode]
,[productCode]
,[productQuantity]
,[FrontPdf]
,[BackPdf]
,[size]
,[signXofX]
,[jobNumber]
,[bottomLabel1]
,[bottomLabel2]
,[squareLabel]
,[circleLabel]
,[stockProducts]
,[fastTrackResubmit])
select --top 10
[batchTimestamp]
,[PKID]
,[orderNo]
,[orderID]
,[opid]
,[orderDate]
,[orderPrintedDate]
,[orderStatus]
,[BatchImpo]
,[shipping_Company]
,[shipping_FirstName]
,[shipping_Surname]
,[shipping_Street]
,[shipping_Suburb]
,[shipping_State]
,[shipping_PostCode]
,[productCode]
,[productQuantity]
,[FrontPdf]
,[BackPdf]
,[size]
,[signXofX]
,[jobNumber]
,[bottomLabel1]
,[bottomLabel2]
,[squareLabel]
,[circleLabel]
,[stockProducts]
,[fastTrackResubmit]
from @BaseSignsForExportLabels a

--Add to BatchPrintStatus
insert into dbo.BatchPrintStatus(flowName,batchTimestamp)
values ('SN',@batchTimestamp)

--************************************************************************************************************************
/*
--resetter
UPDATE op
SET op.stream = 1,
	op.fastTrak_resubmit = 0 --select o.orderno, o.orderstatus, o.orderdate
FROM tblOrders_Products op
INNER JOIN SN_ImposerExport s ON op.ID = s.opid
INNER JOIN tblOrders o ON op.orderID = o.orderID
WHERE o.orderStatus = 'Delivered' 
*/
--************************************************************************************************************************