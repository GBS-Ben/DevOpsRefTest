--select * from tblEmailStatus
--04/27/21		CKB, Markful


CREATE PROCEDURE [dbo].[usp_sendEmailReport]
as
declare @e2 varchar(255),
@e3 varchar(255),
@e4 varchar(255),
@subjecttext varchar(255),
@bodytext varchar(8000)

set @e2=
(select 'Email 2: '+convert(varchar(255),count(emailStatus))  from tblEmailStatus
where emailStatus='2'
and datediff(dd,emailDate,getdate())<2
AND emailDate <> '2999-12-31 00:00:00.000')

set @e3=
(select 'Email 3: '+convert(varchar(255),count(emailStatus))  from tblEmailStatus
where emailStatus='3'
and datediff(dd,emailDate,getdate())<2 AND emailDate <> '2999-12-31 00:00:00.000')

set @e4=
(select 'Email 4: '+convert(varchar(255),count(emailStatus))  from tblEmailStatus
where emailStatus='4'
and datediff(dd,emailDate,getdate())<2 AND emailDate <> '2999-12-31 00:00:00.000')

set @subjecttext='Email Status Report for: '+convert(varchar(255),getdate())

set @bodytext=convert(varchar(255),getdate())+'

'+@e2+'
'+@e3+'
'+@e4

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Markful',
				@recipients = 'mike@gogbs.com',
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Markful',
				@recipients = 'sqlalerts@gogbs.com' ,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText