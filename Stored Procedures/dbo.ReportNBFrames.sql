CREATE PROCEDURE [dbo].[ReportNBFrames]
	
AS
BEGIN
	
SET NOCOUNT ON;

DROP TABLE IF EXISTS #tempFrames

SELECT CASE WHEN oppo.textValue = 'Bling [+$12.00]' THEN 'Bling ' + SUBSTRING(op.ProductCode,5,1) 
			WHEN oppo.textValue = 'Shape [+$12.00]' THEN 'Shape ' + SUBSTRING(op.ProductCode,5,1)
			WHEN LEFT(oppo.TextValue, 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'Unknown ' + SUBSTRING(op.ProductCode,5,1)
			WHEN oppo.optionCaption = 'Blank Name Badges' THEN oppo.optionCaption
			WHEN oppo.PKID IS NOT NULL THEN oppo.textValue + ' ' + SUBSTRING(op.ProductCode,5,1)
			WHEN op.productCode = 'NB00MB-001' THEN op.productName
			ELSE 'Unknown ' + SUBSTRING(op.ProductCode,5,1) END AS FrameStyle
		,op.ID
INTO #tempFrames
FROM tblOrders_products op 
LEFT JOIN dbo.tblOrdersProducts_ProductOptions oppo 
	ON oppo.ordersProductsID = op.ID AND (oppo.optionCaption = 'Frame Style' OR oppo.optionCaption = 'Blank Name Badges')
	AND oppo.deletex <> 'yes'
WHERE op.productCODE LIKE 'NB%'
	AND op.deletex <> 'yes'


SELECT tf.FrameStyle
,[TotalOrdered] = SUM(op.ProductQuantity)
,[14DayOrdered]=SUM(CASE WHEN DATEDIFF(DAY, op.created_on, GETDATE())<=14 THEN op.productQuantity ELSE 0 END) 
,[30DayOrdered]=SUM(CASE WHEN DATEDIFF(DAY, op.created_on, GETDATE())<=30 THEN op.productQuantity ELSE 0 END) 
,[60DayOrdered]=SUM(CASE WHEN DATEDIFF(DAY, op.created_on, GETDATE())<=60 THEN op.productQuantity ELSE 0 END) 
,[90DayOrdered]=SUM(CASE WHEN DATEDIFF(DAY, op.created_on, GETDATE())<=90 THEN op.productQuantity ELSE 0 END)
,[LastYearTotal]  =SUM(CASE WHEN op.created_on BETWEEN DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0)) AND DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0)) THEN op.productQuantity ELSE 0 END) 
,[LastYearQ1]  =SUM(CASE WHEN op.created_on BETWEEN DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0)) AND DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 1, 0) THEN op.productQuantity ELSE 0 END) 
,[LastYearQ2]  =SUM(CASE WHEN op.created_on BETWEEN DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 1, 0) AND DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 2, 0) THEN op.productQuantity ELSE 0 END) 
,[LastYearQ3]  =SUM(CASE WHEN op.created_on BETWEEN DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 2, 0) AND DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 3, 0) THEN op.productQuantity ELSE 0 END) 
,[LastYearQ4]  =SUM(CASE WHEN op.created_on BETWEEN DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 3, 0) AND DATEADD(qq, DATEDIFF(qq, 0, DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) + 4, 0) THEN op.productQuantity ELSE 0 END) 
FROM dbo.tblOrders_Products op 
INNER JOIN #tempFrames tf 
	ON tf.ID = op.ID
INNER JOIN tblOrders o
	ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('Failed', 'Cancelled')
GROUP BY FrameStyle


END