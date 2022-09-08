CREATE PROCEDURE [dbo].[Report_ShopSyncQueueStatus]
	AS
BEGIN
	SELECT TOP 10000 q.CompanyID, q.GBSCompanyID, cl.companyName, ShopOnly, q.CreateDate AS [Added To Queue], SyncStart, SyncEnd, QueuePriority, DATEDIFF(S,SyncStart,SyncEnd) AS [Sync Time Seconds]
	FROM sql01.nopcommerce.dbo.MarketCenter_SyncLIVE_QUEUE q
	INNER JOIN sql01.nopcommerce.dbo.CompanyList cl ON cl.GbsCompanyId = q.GBSCompanyID 
	ORDER BY q.CreateDate DESC

END