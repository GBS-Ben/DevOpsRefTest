CREATE PROCEDURE [dbo].[usp_MarketPlace_updatePrint]
@orderNo VARCHAR(50)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     Updates AMZ orders for printing and reprinting.

-- Example:		EXEC [usp_MarketPlace_updatePrint] @orderNo
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/20/16		Created.
-------------------------------------------------------------------------------

UPDATE tblAMZ_orderShip
SET orderBatchedDate = GETDATE(),
orderPrintedDate = GETDATE()
WHERE orderNo = @orderNo