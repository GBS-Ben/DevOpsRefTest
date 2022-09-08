-- =============================================
-- exec dbo.[ReportMCMasterSales]

/*
	
*/
-- =============================================
CREATE PROCEDURE [dbo].[ReportMCMasterSales_SpecifiedShops]
	
AS
BEGIN
	
	SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#MC') IS NOT NULL
	DROP TABLE #MC
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

INTO #MC
FROM dbo.tblOrders_Products op
INNER JOIN dbo.tblOrders o ON o.orderID=op.orderID
INNER JOIN dbo.tblProducts p ON p.productID=op.productID
LEFT JOIN dbo.tblCompany tc ON tc.GbsCompanyId=op.GbsCompanyId and tc.Published=1 and tc.deleted=0
--LEFT JOIN dbo.tblCustomers cu ON cu.customerID=o.customerID and cu.email not like '%gogbs.com'
WHERE o.orderDate>='1/1/2019' AND orderStatus NOT IN ('Cancelled','Failed') AND o.orderTotal IS NOT NULL
	AND tc.GbsCompanyId IS NOT NULL
GROUP BY
	--tc.id
	tc.GBSCompanyID, tc.name
--ORDER BY CAST(SUM(CASE WHEN YEAR(o.OrderDate)=YEAR(GETDATE()) THEN o.orderTotal ELSE 0 END)  AS MONEY) DESC


CREATE INDEX IX_TMC_GBSCompanyID ON #MC(GBSCompanyID)

--get customer count
IF OBJECT_ID('tempdb..#MCCust') IS NOT NULL
	DROP TABLE #MCCust
SELECT tc.GbsCompanyId, CompanyName=tc.Name, CUCount=COUNT(DISTINCT cu.customerID)
into #MCCust
--select distinct tc.id, tc.gbscompanyid, cu.customerid
FROM dbo.tblOrders_Products op
INNER JOIN dbo.tblOrders o ON o.orderID=op.orderID
INNER JOIN dbo.tblProducts p ON p.productID=op.productID
INNER JOIN dbo.tblCompany tc ON tc.GbsCompanyId=op.GbsCompanyId and tc.Published=1 and tc.deleted=0
INNER JOIN dbo.tblCustomers cu ON cu.customerID=o.customerID and cu.email not like '%gogbs.com'
INNER JOIN #MC mc ON mc.GBSCompanyID=tc.GBSCompanyID
WHERE o.orderDate>='1/1/2019' AND orderStatus NOT IN ('Cancelled','Failed') AND o.orderTotal IS NOT NULL
AND DATEDIFF(day, o.orderDate, getdate())<=30 AND tc.GbsCompanyId IS NOT NULL
--and tc.gbscompanyid='TH-100-01326'
GROUP BY tc.GbsCompanyId,tc.Name


SELECT 
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
	,PercentOfMCPie=CAST(mc.LifeTimeSales/(SELECT SUM(LifeTimeSales) FROM #MC WHERE GbsCompanyId IS NOT NULL) * 100.00 AS DECIMAL(12,2))
	,mc.FiscalSales
	,mc.LifeTimeSales
	,FiscalPercentofPie=CAST(mc.FiscalSales/(SELECT SUM(FiscalSales) FROM #MC) * 100.00 AS DECIMAL(12,2))
	,LifetimePercentofPie=CAST(mc.LifeTimeSales/(SELECT SUM(LifeTimeSales) FROM #MC) * 100.00 AS DECIMAL(12,2))

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

FROM #MC mc
LEFT JOIN #MCCust cu ON cu.GbsCompanyId=mc.GbsCompanyId
WHERE mc.GbsCompanyId IS NOT NULL

--This is a list of Shops that Brian requested as a separate PMI, 27AUG21, JF.
AND mc.GBSCompanyID IN ('TH-100-04451', 'TH-100-04445', 'TH-100-04468', 'TH-100-04460', 'TH-100-04443', 'TH-100-04444', 'TH-100-04461', 'TH-100-04466', 'TH-100-04469', 'TH-100-04482', 'TH-100-04467', 'TH-100-04440', 'TH-100-04415', 'TH-100-04470', 'TH-100-04480', 'TH-100-04493', 'TH-100-04474', 'TH-100-04477', 'TH-100-04452', 'TH-100-04494', 'TH-100-04506', 'TH-100-04499', 'TH-100-04507', 'TH-100-04496', 'TH-100-04508', 'TH-100-04513', 'TH-100-04456', 'TH-100-04511', 'TH-100-04512', 'TH-100-04519', 'TH-100-04485', 'TH-100-04515', 'TH-100-00682', 'TH-100-04479', 'TH-100-04514', 'TH-100-04489', 'TH-100-04510', 'TH-100-04523', 'TH-100-04437', 'TH-100-04521', 'TH-100-04500', 'TH-100-04525', 'TH-100-04524', 'TH-100-04517', 'TH-100-04516', 'TH-100-04527', 'TH-100-04529', 'TH-100-04486', 'TH-100-04535', 'TH-100-04533', 'TH-100-04531', 'TH-100-04520', 'TH-100-04532', 'TH-100-04540', 'TH-100-04502', 'TH-100-04542', 'TH-100-04541', 'TH-100-04534', 'TH-100-04539', 'TH-100-04497', 'TH-100-04484', 'TH-100-04536', 'TH-100-04518', 'TH-100-04554', 'TH-100-04561', 'TH-100-04553', 'TH-100-04544', 'TH-100-04530', 'TH-100-04557', 'TH-100-04543', 'TH-100-04560', 'TH-100-04549', 'TH-100-04555', 'TH-100-04548', 'TH-100-04453', 'TH-100-04547', 'TH-100-04545', 'TH-100-04574', 'TH-100-04584', 'TH-100-04578', 'TH-100-04579', 'TH-100-04546', 'TH-100-04550', 'TH-100-02800', 'TH-100-04581', 'TH-100-04576', 'TH-100-04583', 'TH-100-04552', 'TH-100-04559', 'TH-100-04475', 'TH-100-04590', 'TH-100-04580', 'TH-100-04462', 'TH-100-04487', '0T-500-00999', 'TH-100-04589', '21-210-20084', 'TH-100-04599', 'TH-100-04556', 'TH-100-04588', 'TH-100-04605', 'TH-100-04602', 'TH-100-04600', 'TH-100-04606', 'TH-100-04601', 'TH-100-04009', 'TH-100-04609', 'TH-100-04608', 'TH-100-04612', 'TH-100-04615', 'TH-100-04603', 'TH-100-04614', 'TH-100-04613', 'TH-100-04607', 'TH-100-04523', 'TH-100-04509', 'TH-100-04626', 'TH-100-04610', 'TH-100-04528', 'TH-100-04621', 'TH-100-04635', 'TH-100-04634', 'TH-100-03832', 'TH-100-04620', 'TH-100-04629', 'TH-100-04628', 'TH-100-04611', 'TH-100-04504', 'TH-100-04625', 'TH-100-04633', 'TH-100-04630', 'TH-100-04648', 'TH-100-04616', 'TH-100-04624', 'TH-100-04647', 'TH-100-04632', 'TH-100-04649', 'TH-100-04646', 'TH-100-04656', 'TH-100-04645', 'TH-100-04585', 'TH-100-04644', 'TH-100-04643', 'TH-100-04651', 'TH-100-01187', 'TH-100-04654', 'TH-100-04618', 'TH-100-04657', 'TH-100-04617', 'TH-100-04660', 'TH-100-04659', 'TH-100-04627', 'TH-101-00003', 'TH-100-04658', 'TH-100-04653', 'TH-100-04650', 'TH-100-04655', 'TH-100-04623', '21-200-21228', 'TH-100-04637', 'TH-100-04664', 'TH-100-04446', 'TH-100-04465', 'TH-100-04652', 'TH-100-04661', 'TH-100-04665', 'TH-100-04663', 'TH-100-04582', 'E3-100-00000', 'TH-100-04695', 'TH-100-04691', 'TH-100-04699', 'TH-100-04662', 'TH-100-04619', 'TH-100-04700', 'TH-100-04692', 'TH-100-04666', 'TH-100-04701', 'TH-100-04703', 'TH-100-04689', 'TH-100-04702', 'TH-100-04690', 'TH-100-04669', 'TH-100-04675', 'TH-100-04677', 'TH-100-04674', 'TH-100-04679', 'TH-100-04678', 'TH-100-04668', 'TH-100-04704', 'TH-100-04705', 'TH-100-04670', 'TH-100-04706', 'TH-100-04696', 'TH-100-04558', 'TH-100-04698', 'TH-100-04712', 'TH-100-04713', 'TH-100-04708', 'TH-100-04707', 'TH-100-04711', 'TH-100-04710', 'TH-100-04709', 'TH-100-04722', 'TH-100-04725', 'TH-100-04724', 'TH-100-04720', 'TH-100-04718', 'TH-100-04719', 'TH-100-04714', 'TH-100-04716', 'TH-100-04721', 'TH-100-04723', 'TH-100-04727', 'TH-100-04604', 'TH-100-04717', 'TH-100-04728', 'TH-100-02631', 'TH-100-04694', 'TH-100-04726', 'TH-100-04697', 'TH-100-04715', 'TH-100-04732', 'TH-100-04729', 'TH-100-04749', 'TH-100-04736', 'TH-100-04746', 'TH-100-04743', 'TH-100-04737', 'TH-100-04730', 'TH-100-04750', 'TH-100-04747', 'TH-100-02208', 'TH-100-04734', 'TH-100-04733', 'TH-100-04735', 'TH-100-04739')
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