CREATE PROCEDURE [dbo].[ReportAllOutstandingOPIDs_AllTime_NoBaseball] 
AS

--All orders - no setup, no local, no in art and no on proof


IF OBJECT_ID('tempdb..#WingedVictory') IS NOT NULL DROP TABLE #WingedVictory
CREATE TABLE #WingedVictory(
	[Order No] VARCHAR(50),
	[Order Status] VARCHAR(255),
	[Order Type] VARCHAR(1000),
	[Payment Method] VARCHAR(1000),
	[Payment Status] VARCHAR(1000),
	[Local Pickup] VARCHAR(400),
	[Date] VARCHAR(50),
	[OPID] INT,
	[OPID Status] VARCHAR(255),
	[IMPO] VARCHAR (1000),
	[Product Code] VARCHAR(100),
	[Product Name] VARCHAR(1000),
	[Type] VARCHAR(100),
	[Days] INT,
	[FinalizedSchedule] NVARCHAR(255), 
	[Mailing] VARCHAR(50),
	[FT Status LastMod] DATETIME)

;WITH CTE AS(
SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), a.impoName), '; ') AS Imposition,
a.id AS OPID
FROM (
	SELECT DISTINCT op.Id, impoName 
	FROM tblOrders_products op
	LEFT  JOIN impolog i ON op.id = i.opid
	INNER JOIN tblOrders o ON o.orderID = op.orderID
	WHERE i.impoName <> ''
	AND i.impoName NOT LIKE '%//%'
	AND o.orderDate > GETDATE() - 50 
	) a
GROUP BY a.id)

INSERT INTO #WingedVictory ([Order No], [Order Status], [Order Type], [Payment Method], [Payment Status], [Local Pickup], [Date], [OPID], [OPID Status], [IMPO], [Product Code], [Product Name], [Type], [Days], [Mailing], [FT Status LastMod])
SELECT o.orderNo AS 'Order No',
o.orderStatus AS 'Order Status', o.orderType AS 'Order Type', 
o.paymentMethod AS 'Payment Method',
o.displayPaymentStatus AS 'Payment Status',
CASE o.shipping_FirstName
	WHEN 'Local Pickup' THEN 'Yes'
	WHEN 'Local' THEN 'Yes'
	WHEN 'LOCAL PICK UP' THEN 'Yes'
	WHEN 'Local Pickup at Booth' THEN 'Yes'
	ELSE 'No'
	END AS 'Local Pickup',
CONVERT(VARCHAR(50), DATEPART(MM, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, o.orderDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY, o.orderDate)) AS Date,
op.ID AS OPID, 
op.fastTrak_status AS 'OPID Status',
CASE
	WHEN CTE.Imposition IS NULL THEN '...'
	ELSE CTE.Imposition 
	END AS 'Imposition',
op.productCode AS 'Product Code', op.productName AS 'Product Name', op.processType AS 'Type',
DATEDIFF(DD,o.orderDate,GETDATE()) AS 'Days',
'N' AS 'Mailing',
op.fastTrak_status_lastModified
FROM tblOrders_Products op 
INNER JOIN tblOrders o ON o.orderID = op.orderID
LEFT JOIN CTE ON CTE.OPID = op.ID
WHERE fastTrak_status NOT IN ('Cancelled', 'Completed')
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'In Art')
AND op.productCode NOT LIKE 'VC%'
AND op.productCode NOT LIKE 'ADJ%'
AND op.productCode NOT LIKE 'MS01%'
AND op.productCode NOT IN ('NB00SU-001','MC00SU-001')
AND o.shippingDesc <> 'Pickup at GBS'
AND o.shipping_firstName <> 'LOCAL' 
AND o.shipping_SurName <> 'PICKUP'
AND o.shipping_street <> 'LOCAL' 
AND o.shipping_street <> 'PICKUP'
AND o.OrderID NOT IN (SELECT DISTINCT o.orderID FROM tblOrders o INNER JOIN tblOrders_Products op ON op.orderID = o.orderID WHERE op.productCode LIKE 'BB%' AND op.deletex <> 'yes')
ORDER BY o.orderDate

UPDATE a
SET Mailing = 'Y'
FROM #WingedVictory a
INNER JOIN tblOrders o ON a.[Order No] = o.orderNo
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE (op.productCode = 'MS01'
	   OR SUBSTRING(op.productCode, 3, 2) = 'PM')
AND op.deleteX <> 'yes'

UPDATE a
SET Mailing = 'Y'
FROM #WingedVictory a
INNER JOIN tblOrdersProducts_productOptions oppx ON a.OPID = oppx.ordersProductsID
WHERE oppx.optionCaption = 'Magnetic Postcard'
AND oppx.deleteX <> 'yes'

UPDATE a
SET [FinalizedSchedule] = 'Y'
FROM #WingedVictory a
INNER JOIN tblOrdersProducts_productOptions oppx ON a.OPID = oppx.ordersProductsID
INNER JOIN tblOrders_Products opa ON opa.id = oppx.ordersProductsID
WHERE EXISTS
	(SELECT TOP 1 1
	FROM tblOrdersProducts_productOptions oppx2 
	INNER JOIN tblOrders_products opb ON opb.id = oppx2.ordersproductsid
	WHERE oppx2.deleteX <> 'yes'
	AND oppx2.optionID = 687
	AND opa.orderID = opb.orderID)

SELECT [Order No], [Order Status], [Order Type], [Payment Method], [Payment Status], [Local Pickup], [Mailing], [Date], [OPID], [OPID Status], [IMPO], [Product Code], [Product Name], [Type], [Days], [FinalizedSchedule], [FT Status LastMod]
FROM #WingedVictory
ORDER BY [Date] DESC