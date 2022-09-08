









CREATE VIEW [dbo].[vwOPIDViewWithOppoInv]
AS
SELECT DISTINCT 
	 ov.*
	,oi.Color
	,oi.GTIN
	,oi.catalogNo
	,oi.sanmarqty
	,oi.pendingQuantity
	,oi.availableQuantity
FROM vwOPIDViewWithOppo ov
LEFT JOIN dbo.vwOPIDInventory oi on ov.id = oi.opid