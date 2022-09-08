CREATE PROC [dbo].[usp_Switch_expediteOPID]
@OPID INT = 0
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/03/18
-- Purpose     Allows OPID to be expedited by assigning "expressProduction" to OPPO for OPID.
--                   Sproc fires from button on orderView.asp, at OPID line item location.

-------------------------------------------------------------------------------
-- Modification History
--07/03/18	created, jf.
--01/05/21	modified for iframe conversion
-------------------------------------------------------------------------------

--Insert
INSERT INTO tblOrdersProducts_ProductOptions (ordersProductsID, optionID, optionCaption, optionPrice, optionGroupCaption, optionQTY, textValue)
	SELECT @OPID, 252, 'Express Production', '12.00', 'Description', 1, 'Yes'		-- modified for iFrame conversion

--Notes
INSERT INTO tbl_notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
SELECT a.orderID, a.orderNo,
'something',
GETDATE(), 'SQL', 'order', @OPID
FROM tblOrders a
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.ID = @OPID