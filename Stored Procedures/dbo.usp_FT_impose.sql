--EXEC usp_FT_impose

CREATE PROC [dbo].[usp_FT_impose]
AS
SET NOCOUNT ON;

DECLARE @execution_id bigint  
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'x_FastTrak_Badges_ImpositionFiles.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'GBS', @project_name=N'GBSCoreSSIS', @use32bitruntime=False, @reference_id=Null  
--Select @execution_id  
DECLARE @var2 smallint = 1  
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var2  
EXEC [SSISDB].[catalog].[start_execution] @execution_id