CREATE PROCEDURE [dbo].[CheckForOrdersNotMigrated]
AS
BEGIN
SET NOCOUNT ON;

			DECLARE @count int

			;WITH cte
			AS(
			select gbsorderid, createdonpst from dbo.nopCommerce_Order o
			inner join [dbo].[nopCommerce_tblNOPOrder] tn on tn.nopid = o.id 
			--order by o.createdonpst desc
			)
			SELECT @count = COUNT(*)
			 FROM cte c
			 LEFT JOIN tblOrders o ON o.OrderNo = gbsorderid
			 WHERE o.OrderNo IS NULL
 
		 IF @count > 0
			BEGIN

			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Email',
					@recipients = 'sqlalerts@gogbs.com',
					@subject = 'FIX IT - Order Not Migrated',
					@body = 'There is an order on NOP that has not been migrated successfully to the intranet.  Please Fix It.'

			END	
		
END