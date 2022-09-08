CREATE PROC [dbo].[SearchAgent]  @onlyLogical VARCHAR(MAX)
AS
SET NOCOUNT ON;

-------------------------------------------------------------------------------
-- Author      Bobby the Great
-- Created     8/17/18
-- Purpose     Search all Agent Jobs for a given string of text
-- Example	    EXEC [[SearchAgent]] 'phaser'
-------------------------------------------------------------------------------
-- Modification History
-- 8/17/18	created, bS.
-------------------------------------------------------------------------------

-- search the jobs for a specific text 
SELECT SERVERPROPERTY('SERVERNAME') as [InstanceName],
	j.job_id,
	j.name,
	js.step_id,
	js.command,
	j.enabled 
FROM	msdb.dbo.sysjobs j
JOIN	msdb.dbo.sysjobsteps js
	ON	js.job_id = j.job_id 
WHERE	js.command LIKE '%'+@onlyLogical+'%'