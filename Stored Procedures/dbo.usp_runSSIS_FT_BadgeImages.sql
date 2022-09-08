--EXEC [usp_runSSIS_FT_BadgeImages]

CREATE PROC [dbo].[usp_runSSIS_FT_BadgeImages]

AS

EXEC msdb..sp_start_job N'SSIS_x_FT_Badges_Images'

--DECLARE @execution_id bigint  
--EXEC [SSISDB].[catalog].[create_execution] @package_name=N'x_FastTrak_Badges_ImageFiles.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'GBS', @project_name=N'GBSCoreSSIS', @use32bitruntime=False, @reference_id=Null  
----Select @execution_id  
--DECLARE @var2 smallint = 1  
--EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var2  
--EXEC [SSISDB].[catalog].[start_execution] @execution_id  


/*
DECLARE @ssisstr VARCHAR(8000), 
@packagename VARCHAR(200), 
@servername VARCHAR(100)

SET @packagename = 'x_FastTrak_Badges_ImageFiles'
SET @servername = 'DRAGONSTONE'

SET @ssisstr = 'dtexec /sq ' + @packagename + ' /ser ' + @servername + ' '
SET @ssisstr = @ssisstr

DECLARE @returncode INT
EXEC @returncode = xp_cmdshell @ssisstr
SELECT @returncode
*/
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--



/* ORIG CODE
DECLARE @ssisstr VARCHAR(8000), @packagename VARCHAR(200), @servername VARCHAR(100)
DECLARE @params VARCHAR(8000)
----my package name
SET @packagename = 'ImportItemFile'
----my server name
SET @servername = 'myserver\sql2k5'

---- please make this line in single line, I have made this line in multiline 
----due to article format.
----package variables, which we are passing in SSIS Package.
SET @params = '/SET \package.variables[FileName].Value;"\"\\127.0.0.1\Common
           \SSIS\NewItem.xls\"" /SET \package.variables[CreatedBy].Value;
           "\"Chirag\"" /SET \package.variables[ContractDbConnectionString].Value;
           "\"Data Source=myserver\SQL2K5;User ID=sa;Password=sapass;
           Initial Catalog=Items;Provider=SQLNCLI.1;Persist Security Info=True;
           Auto Translate=False;\"" /SET \package.variables[BatchID].Value;"\"1\"" 
           /SET \package.variables[SupplierID].Value;"\"22334\""'

----now making "dtexec" SQL from dynamic values
SET @ssisstr = 'dtexec /sq ' + @packagename + ' /ser ' + @servername + ' '
SET @ssisstr = @ssisstr + @params
-----PRINT line for verification 
--PRINT @ssisstr

----
----now execute dynamic SQL by using EXEC. 
DECLARE @returncode int
EXEC @returncode = xp_cmdshell @ssisstr
SELECT @returncode

--The @returncode variable will be returned by the "dtexec" command and it will be two record sets:

--the first table will describe all the processes that happened during execution of the SSIS package.
--the second table will return the code from the following possible value which will indicate the SSIS package status.

--Value	Description
--0	The package executed successfully.
--1	The package failed.
--3	The package was cancelled by the user.
--4	The utility was unable to locate the requested package. The package could not be found.
--5	The utility was unable to load the requested package. The package could not be loaded.
--6	The utility encountered an internal error of syntactic or semantic errors in the command line.

*/