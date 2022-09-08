CREATE PROC [dbo].[SearchSproc]  @onlyLogical VARCHAR(MAX)
AS
SET NOCOUNT ON;

-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/16/18
-- Purpose     Search all sprocs for a given string of text
-- Example		EXEC [SearchSprocs] 'phaser'
-------------------------------------------------------------------------------
-- Modification History
-- 7/16/18	created, jf.
-- 8/16/18	changed name, jf.
-------------------------------------------------------------------------------

SELECT DISTINCT
o.name AS OBJECT_NAME,
o.type_desc
FROM sys.sql_modules m 
INNER JOIN sys.objects o 
	ON m.object_id = o.object_id
WHERE m.definition LIKE '%'+@onlyLogical+'%'