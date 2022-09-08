CREATE PROCEDURE [dbo].[dashboard_ProcessedProducts]
AS
SELECT o.orderNo , el.* 
FROM vwEntityLog el 
INNER JOIN tblOrders_Products op 
	ON el.entityID = op.ID 
INNER JOIN tblOrders o 
	ON o.orderID = op.orderID 
WHERE el.Logtype = 'Process and Print'
AND logDateTime > DATEADD(day, -30, GETDATE()) ORDER BY logDateTime ASC