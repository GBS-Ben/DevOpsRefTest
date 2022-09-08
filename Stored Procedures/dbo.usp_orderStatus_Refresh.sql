CREATE PROC [dbo].[usp_orderStatus_Refresh]
AS
DELETE FROM dbo.HOMLIVE_tblOrderStatus_Refresh 
INSERT INTO dbo.HOMLIVE_tblOrderStatus_Refresh (orderNo, orderStatus)
SELECT DISTINCT orderNo, orderStatus 
FROM tblOrders 
WHERE DATEDIFF(HH, lastStatusUpdate, GETDATE()) < 5