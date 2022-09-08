CREATE PROCEDURE [dbo].[ReportAllOutstandingOPIDs] 
AS

IF OBJECT_ID('tempdb..#DetroitEscalatorCompany') IS NOT NULL DROP TABLE #DetroitEscalatorCompany
CREATE TABLE #DetroitEscalatorCompany(
	[Order No] VARCHAR(255),
	[Order Status] VARCHAR(255),
	[Order Type] VARCHAR(255),
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
	[FT Status LastMod] DATETIME)

INSERT INTO #DetroitEscalatorCompany ([Order No], [Order Status], [Order Type], [Payment Status], [Local Pickup], [Date], [OPID], [OPID Status], [Product Code], [Product Name], [Type], [Days], [Mailing], [FT Status LastMod])
SELECT o.orderNo AS 'Order No',
--'http://intranet/gbs/admin/orderView.asp?i=' + CONVERT(VARCHAR(50), o.orderID) + '&o=orders.asp&OrderNum=' + o.orderNo + '&p=1' AS Link,
o.orderStatus AS 'Order Status', o.orderType AS 'Order Type', o.displayPaymentStatus AS 'Payment Status',
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
op.fastTrak_status_lastModified
FROM tblOrders_Products op 
INNER JOIN tblOrders o ON o.orderID = op.orderID
WHERE fastTrak_status NOT IN ('Cancelled', 'Completed')
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment', 'On Proof', 'In Art')
AND DATEDIFF(MM, o.orderDate, GETDATE()) < 5
AND op.productCode NOT LIKE 'VC%'
AND op.productCode NOT LIKE 'ADJ%'
AND op.productCode NOT LIKE 'MS01%'
AND DATEDIFF(DD,o.orderDate,GETDATE()) > 3
AND op.processType <> 'Custom'
AND op.productCode NOT IN ('NB00SU-001','MC00SU-001')
AND NOT EXISTS
	(SELECT TOP 1 1 
	FROM tblOrders ox
	INNER JOIN tblOrders_Products opx ON ox.orderID = opx.orderID
	INNER JOIN tblOrdersProducts_productOptions oppx ON opx.id = oppx.ordersProductsID
	WHERE oppx.textValue LIKE 'TBD%' 
	AND oppx.deleteX <> 'yes'
	AND o.orderID = ox.orderID)
AND o.shippingDesc <> 'Pickup at GBS'
AND o.shipping_firstName <> 'LOCAL' 
AND o.shipping_SurName <> 'PICKUP'
ORDER BY o.orderDate

UPDATE a
SET Mailing = 'Y'
FROM #DetroitEscalatorCompany a
INNER JOIN tblOrders o ON a.[Order No] = o.orderNo
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE op.productCode = 'MS01'
AND op.deleteX <> 'yes'

UPDATE a
SET Mailing = 'Y'
FROM #DetroitEscalatorCompany a
INNER JOIN tblOrdersProducts_productOptions oppx ON a.OPID = oppx.ordersProductsID
WHERE oppx.optionCaption = 'Magnetic Postcard'
AND oppx.deleteX <> 'yes'

SELECT [Order No], [Order Status], [Order Type], [Payment Status], [Local Pickup], [Mailing], [Date], [OPID], [OPID Status], [Product Code], [Product Name], [Type], [Days], [FT Status LastMod]
FROM #DetroitEscalatorCompany
ORDER BY [Date] DESC