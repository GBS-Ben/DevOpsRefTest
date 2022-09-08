--04/27/2021		CKB, Markful


CREATE PROCEDURE [dbo].[ReportAllOutstandingOPIDs_AllTime_StuckInHouse_NoBB] 
AS

--All orders - no setup, no local, no in art and no on proof


IF OBJECT_ID('tempdb..#StuckInHouse') IS NOT NULL DROP TABLE #StuckInHouse
CREATE TABLE #StuckInHouse(
	[Order No] VARCHAR(255),
	[Order Status] VARCHAR(255),
	[Order Type] VARCHAR(255),
	[Payment Method] VARCHAR(255),
	[Payment Status] VARCHAR(255),
	[Local Pickup] VARCHAR(255),
	[Date] VARCHAR(255),
	[OPID] INT,
	[OPID Status] VARCHAR(255),
	[Product Code] VARCHAR(255),
	[Product Name] VARCHAR(255),
	[Type] VARCHAR(255),
	[Days] INT,
	[Mailing] VARCHAR(255),
	[FT Status LastMod] DATETIME,
	[tblOrders LastMod] DATETIME)

INSERT INTO #StuckInHouse ([Order No], [Order Status], [Order Type], [Payment Method], [Payment Status], [Local Pickup], [Date], [OPID], [OPID Status], [Product Code], [Product Name], [Type], [Days], [Mailing], [FT Status LastMod], [tblOrders LastMod])
SELECT o.orderNo AS 'Order No',
--'http://intranet/gbs/admin/orderView.asp?i=' + CONVERT(VARCHAR(50), o.orderID) + '&o=orders.asp&OrderNum=' + o.orderNo + '&p=1' AS Link,
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
op.productCode AS 'Product Code', op.productName AS 'Product Name', op.processType AS 'Type',
DATEDIFF(DD,o.orderDate,GETDATE()) AS 'Days',
'N' AS 'Mailing',
op.fastTrak_status_lastModified,
o.modified_On
FROM tblOrders_Products op 
INNER JOIN tblOrders o ON o.orderID = op.orderID
WHERE fastTrak_status NOT IN ('Cancelled', 'Completed')
AND o.orderStatus NOT IN ('Delivered', 'In Transit', 'In Transit USPS', 'Failed', 'Cancelled', 'ON HOM DOCK', 'ON MRK DOCK')
AND o.displayPaymentStatus = 'Good'
AND (SELECT COUNT(DateKey)
	FROM dateDimension
	WHERE isWeekend = 0
	AND isHoliday = 0
	AND [Date] > o.orderDate
	AND [Date] < CONVERT(DATE,GETDATE())) > 2
AND op.productCode NOT LIKE 'VC%'
AND op.productCode NOT LIKE 'ADJ%'
AND op.productCode NOT LIKE 'MS01%'
AND op.productCode NOT LIKE '%BB%'
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products opx
	INNER JOIN tblOrdersProducts_productOptions oppx ON opx.id = oppx.ordersProductsID
	WHERE oppx.deleteX <> 'yes'
	AND oppx.optionID = 687
	AND op.orderID = opx.orderID)
AND op.productCode NOT IN ('NB00SU-001','MC00SU-001')
AND o.shippingDesc <> 'Pickup at GBS'
AND o.shipping_firstName <> 'LOCAL' 
AND o.shipping_SurName <> 'PICKUP'
ORDER BY o.orderDate

UPDATE a
SET Mailing = 'Y'
FROM #StuckInHouse a
INNER JOIN tblOrders o ON a.[Order No] = o.orderNo
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE op.productCode = 'MS01'
AND op.deleteX <> 'yes'

UPDATE a
SET Mailing = 'Y'
FROM #StuckInHouse a
INNER JOIN tblOrdersProducts_productOptions oppx ON a.OPID = oppx.ordersProductsID
WHERE oppx.optionCaption = 'Magnetic Postcard'
AND oppx.deleteX <> 'yes'

SELECT [Order No], [Order Status], [Order Type], [Payment Method], [Payment Status], [Local Pickup], [Mailing], [Date], [OPID], [OPID Status], [Product Code], [Product Name], [Type], [Days], [FT Status LastMod], [tblOrders LastMod]
FROM #StuckInHouse
ORDER BY [Order Status] DESC, [tblOrders LastMod] DESC