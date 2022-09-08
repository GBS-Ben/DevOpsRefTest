-- =============================================
-- Author:		MESSERLY
-- Create date: 20211129
-- Description:	BHHS SALES REPORT. Modified version of dbo.Report_Customer365
-- =============================================
CREATE PROCEDURE [dbo].[ReportTrailing2Year_BHHS]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#OrderData') IS NOT NULL
		DROP TABLE tempdb.#OrderData
	CREATE TABLE TEMPDB.#OrderData(CustomerID bigint, ParentID bigint, ParentMCID varchar(100), MCID varchar(100), MCName varchar(200), email varchar(100), OrderID int, OrderDate datetime, PaymentMethod varchar(100), ProductCode varchar(100), OrderTotal money, calcOrderTotal money)

	INSERT INTO TEMPDB.#OrderData(CustomerID, ParentID, ParentMCID, MCID, MCName, email, OrderID, OrderDate, PaymentMethod, ProductCode, OrderTotal, calcOrderTotal)
	SELECT cu.CustomerID
		,ParentID=ptc.Id
		,ParentMCID=ptc.GbsCompanyId
		,MCID=tc.GbsCompanyId
		,MCName=tc.name
		,email=cu.email
		,o.orderid
		,o.orderDate
		,o.paymentMethod
		,p.productCode		
		,OrderTotal=o.orderTotal
		,calcOrderTotal
			--select top 10 *
	FROM dbo.tblOrders_Products op
	INNER JOIN dbo.tblOrders o ON o.orderID=op.orderID --WHERE O.ORDERID=14
	INNER JOIN dbo.tblCustomers cu ON cu.customerID=o.customerID and cu.email not like '%gogbs.com' and cu.email not like '%markful.com'
	INNER JOIN dbo.tblCompany tc ON tc.GbsCompanyId=op.GbsCompanyId and tc.Published=1 and tc.deleted=0
	INNER JOIN dbo.tblCompany ptc ON ptc.Id=tc.ParentCompanyId
	INNER JOIN dbo.tblProducts p on p.Productid=op.productID
	WHERE ptc.id=54419--Berkshire Hathaway HomeServices/BK-500-00000
	AND orderStatus NOT IN ('Failed', 'Cancelled')
	AND o.orderDate >= dateadd(day, -365*2, getdate())
	--AND CU.CUSTOMERID=571202231--TEST/COMPARE

	--SELECT * from  TEMPDB.#OrderData order by orderdate

	IF OBJECT_ID('tempdb..#ReportData') IS NOT NULL
		DROP TABLE TEMPDB.#ReportData
	CREATE TABLE TEMPDB.#ReportData(
		customerID	bigint
		,parentID bigint
		,parentMCID varchar(100)
		,MCID varchar(100)
		,MCName varchar(200)	
		,email varchar(100)	
		,numOrders_last2Year int
		,numOrders_last365 int	
		,avgOrdersPerMonth int	
		,lastOrderDate datetime
		,codesUsed int
		,MonthlyBilling varchar(100)	
		,lessThan30 int	
		,between31and60 int	
		,between61and90 int	
		,between91and365 int	
		,revenue_last365 int	
		,revenue_YOY MONEY	
		,BP_last365 int	
		,NB_last365 int	
		,CM_last365 int	
		,SN_last365 int	
		,AP_last365 int	
		,NC_last365 int	
		,FD_last365 int	
		,other_last365 int		
		,BP_lastOrder DATETIME	
		,NB_lastOrder DATETIME	
		,CM_lastOrder DATETIME	
		,SN_lastOrder DATETIME	
		,AP_lastOrder DATETIME	
		,NC_lastOrder DATETIME	
		,FD_lastOrder DATETIME	
		,other_lastOrder DATETIME
		)
		--SELECT * FROM TEMPDB.#ReportData

		INSERT INTO TEMPDB.#ReportData(CustomerID, parentID, parentMCID, MCID, MCName, email, numOrders_last2Year, numOrders_last365, avgOrdersPerMonth, lastOrderDate
			,codesUsed 
			,MonthlyBilling	
			,lessThan30	
			,between31and60	
			,between61and90	
			,between91and365	
			,revenue_last365	
			,revenue_YOY	
			,BP_last365	
			,NB_last365	
			,CM_last365	
			,SN_last365	
			,AP_last365	
			,NC_last365	
			,FD_last365	
			,other_last365		
			,BP_lastOrder	
			,NB_lastOrder 	
			,CM_lastOrder	
			,SN_lastOrder	
			,AP_lastOrder	
			,NC_lastOrder	
			,FD_lastOrder	
			,other_lastOrder
			)
		SELECT distinct 
			CustomerID, parentID, parentMCID, MCID
			, MCName=max(MCName)
			, email
			,numOrders_last2Year=(select count(distinct orderid) from TEMPDB.#OrderData o where o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -365*2, GETDATE()) AND GETDATE())
			,numOrders_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -365, GETDATE()) AND GETDATE())
			,avgOrdersPerMonth=cast(count(distinct orderid)*1.00/(datediff(month, min(orderdate), getdate())+1.00) as decimal(12,2))
			,lastOrderDate=max(orderdate)
			,codesUsed=0--wth?
			,MonthlyBilling=isnull((select top 1 1 from TEMPDB.#OrderData o where o.email=od.email and paymentMethod = 'Monthly Billing'), 0)
			,lessThan30=(select count(distinct orderid) from TEMPDB.#OrderData o where o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -30, GETDATE()) AND GETDATE())
			,between31and60=(select count(distinct orderid) from TEMPDB.#OrderData o where o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -60, GETDATE()) AND DATEADD(DD, -31, GETDATE()))
			,between61and90=(select count(distinct orderid) from TEMPDB.#OrderData o where o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -90, GETDATE()) AND DATEADD(DD, -61, GETDATE()))	
			,between91and365=(select count(distinct orderid) from TEMPDB.#OrderData o where o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -365, GETDATE()) AND DATEADD(DD, -91, GETDATE()))	
			,revenue_last365=(SELECT sum(totalRev) from (SELECT DISTINCT email, OrderID, totalRev=isnull(calcOrderTotal, OrderTotal) FROM TEMPDB.#OrderData where orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE()) a where a.email=od.email)
			,revenue_YOY=(SELECT sum(totalRev) from (SELECT DISTINCT email, OrderID, totalRev=isnull(calcOrderTotal, OrderTotal) FROM TEMPDB.#OrderData where orderDate BETWEEN DATEADD(DD, -731, GETDATE()) AND DATEADD(DD, -366, GETDATE())) a where a.email=od.email)
			
			,BP_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('BP') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())
			,NB_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('NB') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())
			,CM_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('CM') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,SN_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('SN') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,AP_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('AP') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,NC_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('NC') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,FD_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) IN('FD') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,other_last365=(select count(distinct orderid) from TEMPDB.#OrderData o where left(ProductCode,2) NOT IN('BP','NB','CM','SN','AP','NC','FD') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			
			,BP_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('BP') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,NB_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('NB') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	
			,CM_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('CM') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())		
			,SN_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('SN') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())		
			,AP_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('AP') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())		
			,NC_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('NC') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())		
			,FD_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) IN('FD') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())		
			,other_lastOrder=(select MAX(orderDate) from TEMPDB.#OrderData o where left(ProductCode,2) NOT IN('BP','NB','CM','SN','AP','NC','FD') and o.email=od.email and o.orderDate BETWEEN DATEADD(DD, -366, GETDATE()) AND GETDATE())	

		FROM TEMPDB.#OrderData od	
		GROUP BY CustomerID, parentID, parentMCID, MCID, email
		


		SELECT * 
		FROM TEMPDB.#ReportData
END