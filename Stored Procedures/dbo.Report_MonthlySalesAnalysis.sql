/*
Script Purpose:
*/
    
CREATE PROCEDURE Report_MonthlySalesAnalysis
AS

	;With Months
	AS
	(
	SELECT DateKey, [Date], FirstDayOfMonth, [MonthName], MonthYear
	FROM DateDimension
	WHERE FirstDayOfMonth =[Date]
	),
	Orders
	AS
	(
		SELECT OrderId, CustomerId, convert(int,convert(varchar(8),OrderDate,112)) AS orderDateKey, OrderDate, calcOrderTotal, calcVouchers, calcOPPO, 
			(SELECT TOP 1 GbsCompanyId FROM tblOrders_Products t WHERE t.orderID = o.OrderId AND GbsCompanyId IS NOT NULL) AS GBSCompanyId
		FROM tblOrders o --ON  d.DateKey = convert(int,convert(varchar(8),OrderDate,112))
		WHERE o.OrderStatus NOT IN ('Cancelled', 'Waiting For Payment','Failed')
			AND ORDERDate >= '1/1/2019'
	),
	NeverOrdered 
	AS
	(
		SELECT FirstDayOfMonth, COUNT(DISTINCT GbsCompanyId) AS NeverOrderedMcCount
		FROM gbsWarehouse.dbo.DimCompany c 
		INNER JOIN DateDimension d ON d.[Date] >= SetupDate   --The company was created before th
			AND d.[Date] <= ISNULL(FirstOrderDate,'1/1/2999') --but had no orders
		WHERE SetupDate IS NOT NULL
			AND d.[Date] <= GETDATE()
		GROUP BY FirstDayOfMonth
	),
	NewCompany 
	AS
	(
		SELECT FirstDayOfMonth, COUNT(DISTINCT GbsCompanyId) AS NewSetup
		FROM gbsWarehouse.dbo.DimCompany c 
		INNER JOIN DateDimension d ON d.DateKey = SetupDateKey   --The company was created
		WHERE SetupDate IS NOT NULL
			AND d.[Date] <= GETDATE()
			--AND ISNULL(c.FirstOrderDate,'1/1/2999') > FirstDayOfMonth 
		GROUP BY FirstDayOfMonth
	),
	Sales AS
	(
	SELECT 
		m.FirstDayOfMonth, 
		m.MonthYear,
		COUNT(DISTINCT  o.GBSCompanyId) AS Active_MC,
		COUNT(Distinct o.OrderId) AS OrderCount,
		COUNT(Distinct o.customerID) AS CustomerCount,
		SUM(calcOrderTotal) AS TotalSales,
		--FORMAT((SUM(calcVouchers)),'C' ) AS Vouchers,
		FORMAT((SUM(calcOrderTotal)/COUNT (DISTINCT  o.GBSCompanyId)),'C' ) Avg_MC_Value,
		MIN(n.NeverOrderedMcCount) AS NeverOrdered_MC_Count,
		MIN(nw.NewSetup) AS NewSetup_MC_Count
	FROM Months m
	INNER JOIN DateDimension d ON d.FirstDayOfMonth = m.FirstDayOfMonth
	LEFT JOIN Orders o ON  d.DateKey = convert(int,convert(varchar(8),OrderDate,112))
	LEFT JOIN NeverOrdered n ON n.FirstDayOfMonth = m.FirstDayOfMonth
	LEFT JOIN NewCompany nw ON nw.FirstDayOfMonth = m.FirstDayOfMonth ---setup in the month and never ordered
	--LEFT JOIN tblOrders_Products p On o.orderId = p.OrderId
	--INNER JOIN DateDimension d On d.DateKey = convert(int,convert(varchar(8),OrderDate,112)) 
	WHERE  ORDERDate >= '1/1/2019'
	  	--AND GbsCompanyId IS NOT NULL
	GROUP BY  m.FirstDayOfMonth, m.MonthYear
	--ORDER BY m.FirstDayOfMonth DESC
	) 

	SELECT FirstDayOfMonth, 
		MonthYear,
		--Active_MC,
		OrderCount,
		CustomerCount,
		FORMAT(TotalSales,'C') AS TotalSales,
		--Vouchers,
		--Avg_MC_Value,
		--NeverOrdered_MC_Count,
		--NewSetup_MC_Count,
		FORMAT((LAG(TotalSales,  1) OVER(Order BY FirstDayOfMonth)),'C') AS prev_month_sales,
		FORMAT(
			(TotalSales - LAG(TotalSales,  1) OVER(Order BY FirstDayOfMonth))  / LAG(TotalSales,  1) OVER(Order BY FirstDayOfMonth),
			'P'
		) vs_previous_month,
		FORMAT((LAG(TotalSales,  12) OVER(Order BY FirstDayOfMonth)),'C') AS prev_year_sales,
		FORMAT(
			(TotalSales - LAG(TotalSales,  12) OVER(Order BY FirstDayOfMonth))  / LAG(TotalSales,  12) OVER(Order BY FirstDayOfMonth),
			'P'
		) vs_previous_year
	FROM Sales s
	ORDER BY FirstDayOfMonth DESC