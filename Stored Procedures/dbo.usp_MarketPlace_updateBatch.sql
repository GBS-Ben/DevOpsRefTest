CREATE PROCEDURE [dbo].[usp_MarketPlace_updateBatch]
@orderNo VARCHAR(50)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     Updates AMZ orders for batch processing and printing.

-- Example:		EXEC usp_MarketPlace_updateBatch @orderNo
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/20/16		Created.
-------------------------------------------------------------------------------

UPDATE tblAMZ_orderShip
SET orderAck = 1,
orderBatchedDate = GETDATE(),
orderPrintedDate = GETDATE()
WHERE orderNo = @orderNo