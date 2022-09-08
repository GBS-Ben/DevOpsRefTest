CREATE PROCEDURE [dbo].[Report_BusinessCardOrderSummary]
	@BeginDateKey DATETIME = NULL, 
	 @EndDateKey DATETIME = NULL,
	 @OrderBy varchar(100)
AS 
SET NOCOUNT ON;

BEGIN

DECLARE @BEGIN int, @End int

SET @BEGIN =  CASE  WHEN @BeginDateKey IS NULL THEN (SELECT MIN(OrderDateKey) FROM gbsWarehouse.[dbo].[mvOrderSummary] ) 
	ELSE CONVERT(varchar(8), @BeginDateKey,112) 
	END 
SET @End =  CASE  WHEN @EndDateKey IS NULL THEN (SELECT MAX(OrderDateKey) FROM gbsWarehouse.[dbo].[mvOrderSummary] ) 
	ELSE CONVERT(varchar(8), @EndDateKey,112) 
	END 



	SELECT  ParentCode, 
		ParentName, 
		ParentCode + ' - ' + ParentName AS Parent, 
		OrderDateKey, 
		[Date],
		OrderMonthName, 
		CONVERT(int, LEFT(OrderDateKey,4)) AS OrderYear, 
		OrderMonthName + ' ' + CONVERT(varchar(10), LEFT(OrderDateKey,4))  AS [Order Month Year], 
		OrderCount, 
		BusinessCardTotal, 
		OrderTotal,  
		BusinessCardProductCount, 
		NewHireKitCount, 
		AgentPackCount
	FROM gbsWarehouse.[dbo].[mvOrderSummary] mv
	INNER JOIN dbo.DateDimension dd ON dd.DateKey = mv.OrderDateKey
	WHERE OrderDateKey BETWEEN @Begin AND @End
		AND NULLIF(ParentName,'') IS NOT NULL
	ORDER BY CASE WHEN @OrderBy =    'Alphabetical' THEN ParentName END , 
			CASE  WHEN @OrderBy =      'New Hire Kit' THEN NewHireKitCount END DESC,
			CASE  WHEN @OrderBy =      'Agent Pack' THEN AgentPackCount END DESC,
			CASE  WHEN @OrderBy =      'Orders' THEN OrderCount END DESC
			


END