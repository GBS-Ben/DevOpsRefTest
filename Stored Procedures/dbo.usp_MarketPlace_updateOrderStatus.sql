CREATE PROC [dbo].[usp_MarketPlace_updateOrderStatus]
@orderNo VARCHAR(100),
@newOrderStatus VARCHAR(100)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/26/16
-- Purpose     This sproc updates orderStatus for a given @orderNo.
--					http://intranet/gbs/admin/orderView_MarketPlace.asp
-- Variables	This sproc accepts orderNos like "WEB123456' for @orderNo. See below.
-- Example:		usp_MarketPlace_updateOrderStatus 'WEB171341'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/26/16		Created.
-------------------------------------------------------------------------------

UPDATE tblAMZ_orderValid
SET orderStatus = @newOrderStatus,
	 lastStatusUpdate = GETDATE()
WHERE orderNo = @orderNo

UPDATE tblAMZ_orderShip
SET orderStatus = @newOrderStatus
WHERE orderNo = @orderNo