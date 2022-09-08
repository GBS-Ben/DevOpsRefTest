-- =============================================
-- exec dbo.[ReportMCNoOrders]

/*
	
*/
-- =============================================
CREATE PROCEDURE [dbo].[ReportMCNoOrders]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT tc.GbsCompanyId, tc.Name, StartDate=CONVERT(VARCHAR(12),tc.CreatedOnUtc, 111)
FROM dbo.tblCompany tc
LEFT JOIN (
	SELECT tc.GbsCompanyId, tc.Name, TCOUNT=count(*)
	FROM dbo.tblOrders_Products op
	INNER JOIN dbo.tblOrders o ON o.orderID=op.orderID
	INNER JOIN dbo.tblProducts p ON p.productID=op.productID
	INNER JOIN dbo.tblCompany tc ON tc.GbsCompanyId=op.GbsCompanyId and tc.Published=1 and tc.deleted=0
	GROUP BY tc.GbsCompanyId, tc.Name
	) o ON o.GbsCompanyId=tc.GbsCompanyId
WHERE o.GbsCompanyId IS NULL--NO ORDERS
AND tc.published=1
AND tc.deleted=0
--AND (tc.name like '%re%max%' or tc.GbsCompanyId like 'RM%')
ORDER BY 1,2



/*
	--select * from [gbsCore].[dbo].[dashboard_pageList]
INSERT INTO [gbsCore].[dbo].[dashboard_pageList]
           ([PKID]
           ,[displayName]
           ,[storedProcedure]
           ,[categoryID]
           ,[dataEditable]
           ,[hidden]
           ,[contentType])
select
		   [PKID]=(select max(pkid)+1 from [gbsCore].[dbo].[dashboard_pageList])
           ,[displayName]=r.reportname
           ,[storedProcedure]=r.procname
           ,[categoryID]=1
           ,[dataEditable]=0
           ,[hidden]=0
           ,[contentType]='table'
		from 
		(
			select reportname='MCs without orders', procname='dbo.ReportMCNoOrders'
		) r
		left join [gbsCore].[dbo].[dashboard_pageList] d on d.displayName=r.reportname
		where d.pkid is null--doesn't exist yet
*/			
     
END