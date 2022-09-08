CREATE PROC usp_FT_Imposition_Call
(
@FileLocation NVARCHAR(500)
)
AS

BEGIN

DECLARE @ServerName NVARCHAR(100)
DECLARE @cmd NVARCHAR(4000)
DECLARE @jid UNIQUEIDENTIFIER
DECLARE @jname NVARCHAR(128)
DECLARE @jobName NVARCHAR(128)

-- Create a unique job name
SET @ServerName = CONVERT(sysname, SERVERPROPERTY(N'DRAGONSTONE'))
--SET @ServerName = CONVERT(sysname, SERVERPROPERTY(N'servername'))
SET @jname = CAST(NEWID() AS CHAR(36))
SET @jobName = @jname

--set the name and location of the ssis package to run. In this case, the name of
--the package is LoadFile and exists in Sql Server
SET @cmd = '"C:\Program Files\Microsoft SQL Server\100\DTS\Binn\DTExec.exe" '
SET @cmd = @cmd + '/DTS "\MSDB\x_FastTrak_Badges_ImpositionFiles" '
--SET @cmd = @cmd + '/DTS "\MSDB\LoadFile" '
--\x_FastTrak_Badges_ImpositionFiles
SET @cmd = @cmd + '/SERVER ' + @ServerName + ' '
SET @cmd = @cmd + '/CHECKPOINTING OFF '

-- Specify ssis variable value in the package that represents the location of the input file to load
SET @cmd = @cmd + '/SET "\Package.Variables[User::varInputFile].Value";"' + @FileLocation + '" '
-- Create job
EXEC msdb.dbo.sp_add_job
@job_name = @jname,
@enabled = 1,
@category_name = 'MyApp',
--deletes the job when it is done, regardless of whether or not it was successful
@delete_level = 3,
@job_id = @jid OUTPUT

--Add the job to the Sql Server instance
EXEC msdb.dbo.sp_add_jobserver
@job_id = @jid,
@server_name = '(local)'

--Add the step to the job that invokes the ssis package
EXEC msdb.dbo.sp_add_jobstep
@job_id = @jid,
@step_name = 'Execute DTS',
@subsystem = 'CMDEXEC',
@command = @cmd

-- Start job
EXEC msdb.dbo.sp_start_job @job_id = @jid

END