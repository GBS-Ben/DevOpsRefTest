CREATE  proc [dbo].[usp_sendFailedTRANX_Report]
as
declare 
@tranx int,
@orderNo varchar(255),
@subjecttext varchar(255),
@bodytext varchar(8000)

set @tranx=
(select count(*) from tblTransactions where orderno not in (select orderno from tblOrders where orderNo is not NULL)
 and cardName not like '%Clint Treadway%'
 and cardName not like '%Ken Hamilton%'
 and cardName not like '%Mike Atkinson%'
 and paymentDate <> '')

-- IF @tranx IS NULL
-- BEGIN
-- 	set @tranx=0
-- END


IF @tranx<>0

BEGIN

set @subjecttext='SQL Alert - Order Missing in DB'

set @bodytext='Clint & Jeremy,

Check the DB.  We''ve received '+convert(varchar(255),@tranx)+' order(s) that we have received transactional data for, but the order does not exist in the DB.

Run this code to check it out:

--**********************************************************

	select count(*) from tblTransactions 
	where orderno not in 
	(select orderno from tblOrders where orderNo is not NULL)
	and cardName not like ''%Clint Treadway%''
	and cardName not like ''%Ken Hamilton%''
	and cardName not like ''%Mike Atkinson%''
	and paymentDate <> ''''

--**********************************************************

Thanks.'


--exec sp_send_cdosysmailtxt 'jeremy@gogbs.com','jeremy@gogbs.com,clint@gogbs.com',@subject,@body

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Markful',
				@recipients = 'jeremy@gogbs.com;clint@gogbs.com;bobby@gogbs.com',
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText




END