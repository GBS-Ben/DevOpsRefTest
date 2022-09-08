CREATE PROCEDURE [dbo].[Maintenanance_CheckMIGJobTime]
AS
SET NOCOUNT ON;
BEGIN TRY

	DECLARE @jobname VARCHAR(100)

	SET @jobname='MIG'

	IF OBJECT_ID('tempdb..#jobs') IS NOT NULL DROP TABLE #jobs

	CREATE TABLE #jobs (JOB_ID UNIQUEIDENTIFIER, LAST_RUN_DATE INT, LAST_RUN_TIME INT, NEXT_RUN_DATE INT, NEXT_RUN_TIME INT, NEXT_RUN_SCHEDULE_ID INT, REQUESTED_TO_RUN INT, REQUEST_SOURCE INT, REQUEST_SOURCE_ID VARCHAR(100), RUNNING INT, CURRENT_STEP INT, CURRENT_RETRY_ATTEMPT INT, STATE INT)       

	INSERT INTO #jobs EXEC MASTER.DBO.XP_SQLAGENT_ENUM_JOBS 1,NOTHING 

	IF( 
			SELECT TOP 1 RUNNING
			FROM #jobs e
			JOIN MSDB..SYSJOBS j ON e.JOB_ID=j.JOB_ID
			WHERE RUNNING=1
			AND j.name=@jobname
			ORDER BY LAST_RUN_DATE, LAST_RUN_TIME
		) = 1
	BEGIN

		IF (
			SELECT TOP 1 --j.name as Running_Jobs,  ja.Start_execution_date As Starting_time, 
					   datediff(ss, ja.Start_execution_date,getdate()) as [Has_been_running(in Sec)]--, *
			FROM 
				msdb.dbo.sysjobactivity ja
			JOIN 
				msdb.dbo.sysjobs j
			ON
				j.job_id=ja.job_id
			JOIN
				msdb.dbo.syssessions sess
			ON
				sess.session_id = ja.session_id
			JOIN
			(
				SELECT
					MAX( agent_start_date ) AS max_agent_start_date
				FROM
					msdb.dbo.syssessions
			) sess_max
			ON
				sess.agent_start_date = sess_max.max_agent_start_date
			WHERE job_history_id is null
				  AND start_execution_date is NOT NULL
				  AND  j.[name] = 'MIG'
			ORDER BY start_execution_date DESC
			) > 500  --This means the job has been running for 5 minutes
			
			BEGIN

				EXEC msdb.dbo.sp_stop_job  N'MIG'

								EXEC msdb.dbo.sp_send_dbmail  
								@profile_name = 'SQLAlerts',  
								@recipients = 'sqlalerts@gogbs.com',
								@reply_to= 'sqlalerts@gogbs.com',
								@subject = 'MIG needs your attention!' ,
								@body = 'ALERT! ALERT! ALERT!
										<br><br>
								Migration has been running for more than 5 minutes.  I stopped the job for you and it should start on its own.  This behavior is odd and could indicate a possible issue with the VPN, data, or the database.  Don''t ignore me.  Be a good guy and look into it!
								<br><br>
								',
								@body_format = 'HTML';
						 
			END 						 
				
		
	END

END TRY

BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH