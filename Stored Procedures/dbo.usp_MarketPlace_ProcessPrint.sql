CREATE PROCEDURE [dbo].[usp_MarketPlace_ProcessPrint]
@pnp BIT,
@orderNo VARCHAR(20)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     12/16/16
-- Purpose     This sproc updates selected orders during "process and print" operations on:
--					http://intranet/gbs/admin/orders_marketPlace.asp
-- Example Use:
--					EXEC usp_MarketPlace_ProcessPrint 1, 'WEB184898'
-------------------------------------------------------------------------------
-- Modification History
--
-- 12/16/16		created; jf.
--04/27/21		CKB, Markful
-------------------------------------------------------------------------------

--// PNP (process and print)
--	  A value of "0", means that the "Print Selection" button was selected.
--	  A value of "1", means that the "Process & Print Selection" button was selected.

IF @pnp = 1
	BEGIN
		-- if @orderNo is an A1 order:
		UPDATE tblAMZ_orderShip 
		SET orderAck = 1, 
			 A1_processed = 1, 
			 A1_printed = 1, 
			 orderBatchedDate = GETDATE(),
			 orderPrintedDate = GETDATE(),
			 orderStatus = 'ON MRK Dock'
		WHERE orderNo = @orderNo
		AND A1 = 1

		-- if @orderNo is an X1 order:
		UPDATE tblAMZ_orderShip 
		SET orderAck = 1, 
			 orderBatchedDate = GETDATE(),
			 orderPrintedDate = GETDATE(),
			 orderStatus = 'ON MRK Dock'
		WHERE orderNo = @orderNo
		AND A1 = 0
	END
IF @pnp = 0
	BEGIN
		-- if @orderNo is an A1 order:
		UPDATE tblAMZ_orderShip 
		SET orderBatchedDate = GETDATE(),
			 orderPrintedDate = GETDATE()
		WHERE orderNo = @orderNo
		AND A1 = 1

		-- if @orderNo is an X1 order:
		UPDATE tblAMZ_orderShip 
		SET orderBatchedDate = GETDATE(),
			 orderPrintedDate = GETDATE()
		WHERE orderNo = @orderNo
		AND A1 = 0
	END