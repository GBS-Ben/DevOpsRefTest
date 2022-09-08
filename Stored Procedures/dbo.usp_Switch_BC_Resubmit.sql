﻿CREATE PROCEDURE [dbo].[usp_Switch_BC_Resubmit] @OPID INT= 0
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/3/17
-- Purpose     Resubmit Business Cards
-------------------------------------------------------------------------------
-- Modification History
--
-- 07/02/18    Created, jf.
-------------------------------------------------------------------------------

UPDATE tblOrders_Products
SET switch_create = 0,
fastTrak_resubmit = 1
WHERE ID IN (0)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--UNSUB
UPDATE tblOrders_Products
SET switch_create = 1,
fastTrak_resubmit = 0
WHERE ID IN (0)