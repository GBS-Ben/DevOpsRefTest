

CREATE proc [dbo].[FindMissingOrders]
as
begin
	declare @emailbody varchar(500) = 'Run this sql to find the orders

	select * from sql01.nopcommerce.dbo.tblnoporder where gbsorderid not in (select orderno from tblOrders) and createdate > ''1/1/2021'' and datediff(minute,createdate,getdate()) > 60'

	select * from sql01.nopcommerce.dbo.tblnoporder where gbsorderid not in (select orderno from tblOrders) and createdate > '1/1/2021' and datediff(minute,createdate,getdate()) > 60

	if @@ROWCOUNT > 0 
	begin
		EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'Markful'
		,@recipients = 'cbrowne@gogbs.com;jonathan@markful.com'
		,@subject = 'There are orders older than an hour that have not migrated'
		,@body=@emailbody;
	end
END