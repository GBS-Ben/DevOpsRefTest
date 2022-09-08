



CREATE PROCEDURE [dbo].[ProcessStatus_Notify]
AS
BEGIN
SET NOCOUNT ON;

			DECLARE @count int

			select [processName], datediff(mi,lastrundatetime,getdate()) as MinutesSinceLastRun,intervalMinutes,lastRunDateTime
			into #temp
			from ProcessStatus p
			cross apply (select * from DateDimension  where [date] = cast(getdate()as date)) dd
			where case when baseTime is null and datediff(mi,lastrundatetime,getdate()) > intervalMinutes then 1 
					   when basetime is not null and datediff(mi,cast(cast(getdate() as date) as varchar(10)) + ' ' + baseTime,lastrundatetime) > intervalMinutes and lastRunDateTime < cast(cast(cast(getdate() as date) as varchar(10)) + ' ' + baseTime as datetime)  then 1 else 0 end = 1
			and case when p.weekdayOnly = 1 and (dd.isweekend = 1 or dd.isHoliday = 1) then 0 else 1 end = 1

		 IF (select count(*) from #temp) > 0
			BEGIN

				DECLARE @xml NVARCHAR(MAX)
				DECLARE @body NVARCHAR(MAX)

				SET @xml = CAST(( SELECT processname AS 'td','',MinutesSinceLastRun AS 'td','', intervalMinutes AS 'td','', lastRunDateTime as 'td'
				FROM #temp 
				ORDER BY processname,MinutesSinceLastRun,intervalMinutes,lastRunDateTime
				FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))


				SET @body ='<html><body><H3>Overdue Process Info</H3>
				<table border = 1> 
				<tr>
				<th> Process Name </th> <th> Minutes Since Last Run </th> <th> Expected Interval </th><th> Last Run Date Time </th></tr>'    
 
				SET @body = @body + @xml +'</table></body></html>'
				select @body



			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Markful',
					@recipients = 'cbrowne@markful.com',
					@subject = 'Overdue Processes',
					@body = @body,
					@body_format ='HTML'


			END	
		
END