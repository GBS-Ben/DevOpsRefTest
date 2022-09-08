CREATE PROC [dbo].[usp_Switch_updateToProduction]
@ordersProductsID INT = 0
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/3/17
-- Purpose     Business Card Threshold Work for Switch Automation - Duplex
-------------------------------------------------------------------------------
-- Modification History
--01/01/15		created, jf.
--04/12/18		added fastTrak_resubmit flag update. jf.
--04/25/18		added pUnit deletion statement, jf.
--07/16/18		removed update to tblorders.orderstatus = 'in production' as per KH/JF convo, jf.
--07/17/18		removed pUnit deletion statement, jf.
--08/17/18		added flag section, jf.
--02/16/21		added 'on proof' section, jf.
-------------------------------------------------------------------------------
UPDATE tblOrders_Products
SET fastTrak_status = 'In Production', 
fastTrak_imposedOn = GETDATE(),
fastTrak_resubmit = 0
WHERE [ID] = @ordersProductsID

----added this to get orders out of tblOrders.orderStatus = 'On Proof', when applicable; jf 02162021.
--UPDATE o
--SET orderStatus = 'In Production'
--FROM tblOrders o
--INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
--WHERE op.id = @ordersProductsID
--AND o.orderStatus = 'On Proof'

--Update Flags, where necessary
DECLARE @Flag INT = 0

SET @Flag = (SELECT FlagStatus 
					   FROM Flags
					   WHERE FlagName = 'Switch_BC_TRON')
					   
IF @Flag = 1
BEGIN
	UPDATE Flags
	SET FlagStatus = 0
	WHERE FlagName = 'Switch_BC_TRON'
END