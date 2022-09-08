CREATE PROCEDURE [dbo].[Setting_GetValue]	
	@name nvarchar(500),
	@return nvarchar(max) output
AS


SELECT  @return = [Value] 
FROM SETTING 
WHERE [Name] = @Name