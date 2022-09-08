CREATE PROCEDURE [dbo].[Report_HomClassicCallCenterOrders] 
AS 
SET NOCOUNT ON;


SELECT  repname, CONVERT(varchar(20),a.OrderDate,112) AS OrderDate, COUNT(*)  AS OrderCount,
(SELECT Stuff(
		 (SELECT N', ' + OrderNo  
					FROM dbo.homlive_tblOrders   o
					WHERE repname IS NOT NULL and repname <> ''  	
						AND CONVERT(varchar(20),o.OrderDate,112) = CONVERT(varchar(20),a.OrderDate,112)
						AND o.repName = a.repName
					FOR XML PATH(''),TYPE)
				  .value('text()[1]','nvarchar(max)'),1,2,N''
			 )) AS Orders
FROM dbo.homlive_tblOrders   a
WHERE repname IS NOT NULL
AND a.OrderDate > DATEADD(dd,-10,GETDATE())
AND repname <> ''
GROUP BY repname, CONVERT(varchar(20),a.OrderDate,112)
        
ORDER BY OrderDate DESC, OrderCount DESC