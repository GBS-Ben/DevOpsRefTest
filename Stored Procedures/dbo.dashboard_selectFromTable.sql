CREATE PROCEDURE "dbo"."dashboard_selectFromTable"
@tableName VARCHAR(50)
AS
EXEC('SELECT top 10000 * FROM ' + @tableName)