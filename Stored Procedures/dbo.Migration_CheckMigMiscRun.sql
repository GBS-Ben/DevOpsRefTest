CREATE PROCEDURE Migration_CheckMigMiscRun	
	@return nvarchar(max) output
AS


SELECT @return = [Value] 
FROM SETTING 
WHERE [Name] = 'Run MigMisc'