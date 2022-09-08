CREATE PROCEDURE [dbo].[GBSReports_GetCreditsByDate] 
@StartDate datetime = NULL, @EndDate datetime = NULL
AS 

SET @StartDate = ISNULL(@StartDate, DATEADD(dd,-7,GETDATE()))
SET @EndDate = ISNULL(@EndDate, GETDATE()+1)

SELECT [creditID]
      ,[creditOrderID]
      ,[creditDesc]
      ,[creditAmount] 
      ,[DateTime] AS CreditDateTime
	  , o.*
  FROM [tblCredits] c
  LEFT JOIN [tblOrders] o ON o.OrderId = c.creditOrderID
  WHERE [DateTime] BETWEEN @StartDate and @EndDate