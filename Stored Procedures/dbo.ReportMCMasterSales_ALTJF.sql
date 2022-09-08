-- =============================================

/*
	MCJF
*/
-- =============================================
CREATE PROCEDURE [dbo].[ReportMCMasterSales_ALTJF]
	
AS
BEGIN
	
	SET NOCOUNT ON;




IF OBJECT_ID('tempdb..#MCJF') IS NOT NULL
	DROP TABLE #MCJF
SELECT 
	--CompanyID=tc.id
	tc.GBSCompanyID
	,CompanyName=tc.name
	,Active=CASE WHEN DATEDIFF(day,MAX(o.OrderDate),GETDATE())<=30 THEN 1 ELSE 0 END
	,NewMC=CASE WHEN DATEDIFF(day,MAX(tc.CreatedOnUtc),GETDATE())<=30 THEN 1 ELSE 0 END
	,CompanyStartDate=CONVERT(VARCHAR(12), MIN(tc.CreatedOnUtc), 101)
	,LastOrder=CONVERT(VARCHAR(12), MAX(o.OrderDate), 101)
	,FirstOrder=CONVERT(VARCHAR(12), MIN(o.OrderDate), 101)
	,FirstOrderDays=DATEDIFF(day,MIN(tc.CreatedOnUtc), MIN(o.OrderDate))
	,[30DaySales]=CAST(SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 THEN o.orderTotal ELSE 0.00 END) AS MONEY)
	,[60DaySales]=CAST(SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 THEN o.orderTotal ELSE 0.00 END) AS MONEY)
	,[90DaySales]=CAST(SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 THEN o.orderTotal ELSE 0.00 END) AS MONEY)
	,FiscalSales=CAST(SUM(CASE WHEN YEAR(o.OrderDate)=YEAR(GETDATE()) THEN o.orderTotal ELSE 0 END)  AS MONEY)
	,LifeTimeSales=CAST(SUM(o.orderTotal) AS MONEY)
	,BP30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='BP' THEN o.orderTotal ELSE 0 END)
	,BP60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='BP' THEN o.orderTotal ELSE 0 END)
	,BP90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='BP' THEN o.orderTotal ELSE 0 END)
	,SN30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='SN' THEN o.orderTotal ELSE 0 END)
	,SN60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='SN' THEN o.orderTotal ELSE 0 END)
	,SN90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='SN' THEN o.orderTotal ELSE 0 END)

	,AP30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='AP' THEN o.orderTotal ELSE 0 END)
	,AP60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='AP' THEN o.orderTotal ELSE 0 END)
	,AP90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='AP' THEN o.orderTotal ELSE 0 END)

	,CM30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='CM' THEN o.orderTotal ELSE 0 END)
	,CM60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='CM' THEN o.orderTotal ELSE 0 END)
	,CM90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='CM' THEN o.orderTotal ELSE 0 END)

	,PN30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='PN' THEN o.orderTotal ELSE 0 END)
	,PN60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='PN' THEN o.orderTotal ELSE 0 END)
	,PN90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='PN' THEN o.orderTotal ELSE 0 END)

	,NB30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='NB' THEN o.orderTotal ELSE 0 END)
	,NB60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='NB' THEN o.orderTotal ELSE 0 END)
	,NB90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='NB' THEN o.orderTotal ELSE 0 END)

	,MK30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='MK' THEN o.orderTotal ELSE 0 END)
	,MK60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='MK' THEN o.orderTotal ELSE 0 END)
	,MK90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='MK' THEN o.orderTotal ELSE 0 END)

	,NC30=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=30 AND LEFT(p.productCode, 2) ='NC' THEN o.orderTotal ELSE 0 END)
	,NC60=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=60 AND LEFT(p.productCode, 2) ='NC' THEN o.orderTotal ELSE 0 END)
	,NC90=SUM(CASE WHEN DATEDIFF(day, o.OrderDate, GETDATE())<=90 AND LEFT(p.productCode, 2) ='NC' THEN o.orderTotal ELSE 0 END)

INTO #MCJF
FROM dbo.tblOrders_Products op
INNER JOIN dbo.tblOrders o ON o.orderID=op.orderID
INNER JOIN dbo.tblProducts p ON p.productID=op.productID
LEFT JOIN dbo.tblCompany tc ON tc.GbsCompanyId=op.GbsCompanyId and tc.Published=1 and tc.deleted=0
--LEFT JOIN dbo.tblCustomers cu ON cu.customerID=o.customerID and cu.email not like '%gogbs.com'
WHERE o.orderDate>='1/1/2019' 
AND orderStatus NOT IN ('Cancelled','Failed') 
AND o.orderTotal IS NOT NULL
AND tc.GbsCompanyId IS NOT NULL
AND tc.GBSCompanyID = 'E3-100-00000'
GROUP BY tc.GBSCompanyID, tc.name


CREATE INDEX IX_TMC_JF_GBSCompanyID ON #MCJF(GBSCompanyID)

--get customer count
IF OBJECT_ID('tempdb..#MCJFCust') IS NOT NULL
	DROP TABLE #MCJFCust
SELECT tc.GbsCompanyId, CompanyName=tc.Name, CUCount=COUNT(DISTINCT cu.customerID)
into #MCJFCust
FROM dbo.tblOrders_Products op
INNER JOIN dbo.tblOrders o ON o.orderID=op.orderID
INNER JOIN dbo.tblProducts p ON p.productID=op.productID
INNER JOIN dbo.tblCompany tc ON tc.GbsCompanyId=op.GbsCompanyId and tc.Published=1 and tc.deleted=0
INNER JOIN dbo.tblCustomers cu ON cu.customerID=o.customerID and cu.email not like '%gogbs.com'
INNER JOIN #MCJF mc ON mc.GBSCompanyID=tc.GBSCompanyID
WHERE o.orderDate>='1/1/2019' 
AND orderStatus NOT IN ('Cancelled','Failed') 
AND o.orderTotal IS NOT NULL
AND DATEDIFF(day, o.orderDate, getdate())<=30 
AND tc.GbsCompanyId IS NOT NULL
AND tc.GBSCompanyID = 'E3-100-00000'
GROUP BY tc.GbsCompanyId,tc.Name

SELECT DISTINCT
	-- mc.CompanyID
	mc.GbsCompanyId
	,mc.CompanyName
	,mc.Active
	,mc.NewMC
	,mc.CompanyStartDate
	,mc.FirstOrder
	,mc.LastOrder
	,mc.FirstOrderDays
	,[30DayCustCount]=ISNULL(cu.CUCount, 0)
	,mc.[30DaySales]
	,mc.[60DaySales]
	,mc.[90DaySales]
	,PercentOfMCPie=CAST(mc.LifeTimeSales/(SELECT SUM(LifeTimeSales) FROM #MCJF WHERE GbsCompanyId IS NOT NULL) * 100.00 AS DECIMAL(12,2))
	,mc.FiscalSales
	,mc.LifeTimeSales
	,FiscalPercentofPie=CAST(mc.FiscalSales/(SELECT SUM(FiscalSales) FROM #MCJF) * 100.00 AS DECIMAL(12,2))
	,LifetimePercentofPie=CAST(mc.LifeTimeSales/(SELECT SUM(LifeTimeSales) FROM #MCJF) * 100.00 AS DECIMAL(12,2))

	,BP30
	,BP60=BP60-BP30
	,BP90=BP90-BP60
	,[BP30_60%]=CAST(CASE WHEN BP30=0 THEN 0 ELSE (((BP60-BP30)/BP30) * 100.00) END AS DECIMAL(12,2))
	,[BP60_90%]=CAST(CASE WHEN (BP60-BP30)=0 THEN 0 ELSE (((BP90-BP60)/(BP60-BP30)) * 100.00) END AS DECIMAL(12,2))

	,SN30
	,SN60=SN60-SN30
	,SN90=SN90-SN60
	,[SN30_60%]=CAST(CASE WHEN SN30=0 THEN 0 ELSE (((SN60-SN30)/SN30) * 100.00) END AS DECIMAL(12,2))
	,[SN60_90%]=CAST(CASE WHEN (SN60-SN30)=0 THEN 0 ELSE (((SN90-SN60)/(SN60-SN30)) * 100.00) END AS DECIMAL(12,2))

	,AP30
	,AP60=AP60-AP30
	,AP90=AP90-AP60
	,[AP30_60%]=CAST(CASE WHEN AP30=0 THEN 0 ELSE (((AP60-AP30)/AP30) * 100.00) END AS DECIMAL(12,2))
	,[AP60_90%]=CAST(CASE WHEN (AP60-AP30)=0 THEN 0 ELSE (((AP90-AP60)/(AP60-AP30)) * 100.00) END AS DECIMAL(12,2))

	,CM30
	,CM60=CM60-CM30
	,CM90=CM90-CM60
	,[CM30_60%]=CAST(CASE WHEN CM30=0 THEN 0 ELSE (((CM60-CM30)/CM30) * 100.00) END AS DECIMAL(12,2))
	,[CM60_90%]=CAST(CASE WHEN (CM60-CM30)=0 THEN 0 ELSE (((CM90-CM60)/(CM60-CM30)) * 100.00) END AS DECIMAL(12,2))

	,PN30
	,PN60=PN60-PN30
	,PN90=PN90-PN60
	,[PN30_60%]=CAST(CASE WHEN PN30=0 THEN 0 ELSE (((PN60-PN30)/PN30) * 100.00) END AS DECIMAL(12,2))
	,[PN60_90%]=CAST(CASE WHEN (PN60-PN30)=0 THEN 0 ELSE (((PN90-PN60)/(PN60-PN30)) * 100.00) END AS DECIMAL(12,2))

	,NB30
	,NB60=NB60-NB30
	,NB90=NB90-NB60
	,[NB30_60%]=CAST(CASE WHEN NB30=0 THEN 0 ELSE (((NB60-NB30)/NB30) * 100.00) END AS DECIMAL(12,2))
	,[NB60_90%]=CAST(CASE WHEN (NB60-NB30)=0 THEN 0 ELSE (((NB90-NB60)/(NB60-NB30)) * 100.00) END AS DECIMAL(12,2))

	,MK30
	,MK60=MK60-MK30
	,MK90=MK90-MK60
	,[MK30_60%]=CAST(CASE WHEN MK30=0 THEN 0 ELSE (((MK60-MK30)/MK30) * 100.00) END AS DECIMAL(12,2))
	,[MK60_90%]=CAST(CASE WHEN (MK60-MK30)=0 THEN 0 ELSE (((MK90-MK60)/(MK60-MK30)) * 100.00) END AS DECIMAL(12,2))

	,NC30
	,NC60=NC60-NC30
	,NC90=NC90-NC60
	,[NC30_60%]=CAST(CASE WHEN NC30=0 THEN 0 ELSE (((NC60-NC30)/NC30) * 100.00) END AS DECIMAL(12,2))
	,[NC60_90%]=CAST(CASE WHEN (NC60-NC30)=0 THEN 0 ELSE (((NC90-NC60)/(NC60-NC30)) * 100.00) END AS DECIMAL(12,2))

FROM #MCJF mc
LEFT JOIN #MCJFCust cu ON cu.GbsCompanyId=mc.GbsCompanyId
WHERE mc.GbsCompanyId IS NOT NULL
AND mc.GBSCompanyID = 'E3-100-00000'
order by PercentOfMCPie desc



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
			select reportname='MC Master Sales Report', procname='dbo.ReportMCMasterSales'
		) r
		left join [gbsCore].[dbo].[dashboard_pageList] d on d.displayName=r.reportname
		where d.pkid is null--doesn't exist yet
*/			
     
END