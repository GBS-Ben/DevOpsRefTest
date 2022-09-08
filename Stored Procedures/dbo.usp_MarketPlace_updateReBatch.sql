CREATE PROCEDURE [dbo].[usp_MarketPlace_updateReBatch]
@orderNo VARCHAR(50)
AS
-------------------------------------------------------------------------------
-- Author      Clint Treadway
-- Created     08/22/16
-- Purpose     Sends AMZ orders back into the stream for batch processing and printing.

-- Example:		EXEC usp_MarketPlace_updateReBatch @orderNo
-------------------------------------------------------------------------------
-- Modification History
--
-- 8/22/16		Created.
-------------------------------------------------------------------------------

UPDATE tblAMZ_orderShip
SET orderAck = 0,
orderStatus = 'In House',
orderBatchedDate = GETDATE(),
orderPrintedDate = GETDATE()
WHERE orderNo = @orderNo

UPDATE tblAMZ_orderValid
SET orderStatus = 'In House',
	 lastStatusUpdate = GETDATE()
WHERE orderNo = @orderNo