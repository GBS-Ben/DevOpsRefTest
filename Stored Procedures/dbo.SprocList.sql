CREATE PROC [dbo].[SprocList]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/24/16
-- Purpose     Returns all sprocs, orderd by last modified date desc.
-------------------------------------------------------------------------------
-- Modification History
--	8/17/18	created, jf.
-------------------------------------------------------------------------------
SELECT LAST_ALTERED AS 'DATE', * 
FROM information_schema.routines 
WHERE routine_type = 'PROCEDURE'
ORDER BY LAST_ALTERED DESC