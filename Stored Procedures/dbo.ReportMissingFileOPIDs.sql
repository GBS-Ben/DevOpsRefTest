CREATE PROC [dbo].[ReportMissingFileOPIDs] AS
;WITH CTE AS(
SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), a.impoName), '; ') AS Imposition,
a.id AS OPID
FROM (
	SELECT DISTINCT op.Id, impoName 
	FROM tblOrders_products op
	LEFT  JOIN impolog i ON op.id = i.opid
	INNER JOIN tblOrders o ON o.orderID = op.orderID
	WHERE i.impoName <> ''
	AND i.impoName NOT LIKE '%/%'
	AND o.orderDate > GETDATE() - 50 
	) a
GROUP BY a.id)

	SELECT DISTINCT o.orderNo, o.orderDate, o.orderStatus, op.ID, op.productCode, 
	op.productName, op.fasttrak_status, op.processType, op.deleteX, 
	CASE
	WHEN CTE.Imposition IS NULL THEN '...'
	ELSE CTE.Imposition 
	END AS 'Imposition',
	fx.fileExists, fx.filePath, fx.readyForSwitch, fx.CreateDate
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	INNER JOIN tblOPPO_fileExists fx ON op.ID = fx.OPID
	LEFT JOIN CTE ON CTE.OPID = op.ID
	WHERE o.orderStatus NOT IN ('failed', 'cancelled')
	AND op.deleteX <> 'yes'
	AND fx.readyForSwitch = 0
	AND op.id IN 
					(SELECT OPID FROM tblOPPO_fileExists s
					WHERE readyForSwitch = 1
					AND EXISTS
								(SELECT TOP 1 1
								FROM tblOPPO_fileExists x
								WHERE x.readyForSwitch = 0
								AND s.OPID = x.OPID)
					AND DATEPART(YY, s.CreateDate) = '2021'
					AND EXISTS
								(SELECT TOP 1 1
								FROM tblOrders_Products op
								INNER JOIN tblOrders o ON op.orderID = o.orderID
								WHERE op.deleteX <> 'yes'
								AND o.orderStatus NOT IN ('delivered', 'failed', 'cancelled', 'in transit', 'in transit usps', 'ON HOM Dock', 'ON MRK Dock', 'Waiting On Customer', 'Waiting For Payment')
								AND op.ID = s.OPID)
							--ORDER BY s.CreateDate DESC
					)
	ORDER BY fx.createDate DESC