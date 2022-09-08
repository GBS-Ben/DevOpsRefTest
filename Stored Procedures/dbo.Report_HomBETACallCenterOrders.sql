CREATE PROCEDURE [dbo].[Report_HomBETACallCenterOrders] 
AS 
SET NOCOUNT ON;

SELECT Email, OrderDate, OrderCount, 
	(SELECT Stuff(
		 (SELECT N', ' + GbsOrderID  
					FROM dbo.nopcommerce_tblNOPOrder   o
					INNER JOIN    dbo.nopcommerce_Customer c ON c.Id = o.impersonator 
					WHERE impersonator IS NOT NULL  	
						AND Email = a.Email
						AND  CONVERT(varchar(20),CreateDate,112) = a.OrderDate
					FOR XML PATH(''),TYPE)
				  .value('text()[1]','nvarchar(max)'),1,2,N''
			 )) AS Orders
FROM (
SELECT  Email, CONVERT(varchar(20),CreateDate,112) AS OrderDate, COUNT(*)  AS OrderCount
FROM dbo.nopcommerce_tblNOPOrder   o
INNER JOIN    dbo.nopcommerce_Customer c ON c.Id = o.impersonator 
WHERE impersonator IS NOT NULL
AND o.CreateDate > DATEADD(dd,-10,GETDATE())
GROUP BY Email, CONVERT(varchar(20),CreateDate,112)
          ) a
ORDER BY OrderDate, OrderCount DESC