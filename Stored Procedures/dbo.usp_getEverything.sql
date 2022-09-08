-----------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/25/15
-- Purpose     Praise the sun!
-------------------------------------------------------------------------------
-- Modification History

-- 10/25/15		Created.
-------------------------------------------------------------------------------

CREATE PROC [dbo].[usp_getEverything] @orderNo VARCHAR(20)
AS
BEGIN
PRINT 'XXX'
END
IF @@ERROR <> 0 SET NOEXEC ON