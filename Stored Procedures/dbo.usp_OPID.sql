CREATE PROCEDURE [dbo].[usp_OPID] @OPID INT = 0
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/13/18
-- Purpose     Find info about OPID
-------------------------------------------------------------------------------
-- Modification History
--
--07/13/18	    Created, jf.
-------------------------------------------------------------------------------

SELECT 'pUNIT', * FROM tblSwitch_pUnit_TRON WHERE OPID = @OPID
SELECT 'OPID', * FROM tblOrders_Products WHERE ID = @OPID
SELECT 'OPPO', * FROM tblOrdersProducts_productOptions WHERE ordersProductsID = @OPID
SELECT 'tblSwitch_BCD_ThresholdDiff_TRON', * FROM tblSwitch_BCD_ThresholdDiff_TRON WHERE ordersProductsID = @OPID
SELECT 'tblSwitch_BC_LOG_TRON', * FROM tblSwitch_BC_LOG_TRON WHERE ordersProductsID = @OPID
EXEC usp_getEverything @OPID