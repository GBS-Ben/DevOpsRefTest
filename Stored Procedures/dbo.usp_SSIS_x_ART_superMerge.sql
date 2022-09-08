CREATE PROC [dbo].[usp_SSIS_x_ART_superMerge]

AS


EXEC msdb..sp_start_job N'SSIS_x_ART_superMerge'