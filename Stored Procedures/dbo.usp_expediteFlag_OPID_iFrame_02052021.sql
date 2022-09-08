CREATE PROCEDURE[dbo].[usp_expediteFlag_OPID_iFrame_02052021] @OPID INT = 0
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/03/17
Purpose     Toggles expediteProduction flag for OPID on orderView.asp
-------------------------------------------------------------------------------
Modification History

07/06/18	JF, created
10/24/18	JF, syntax
-------------------------------------------------------------------------------
*/

DECLARE @currentExpressProductionStatus INT = 0

SET @currentExpressProductionStatus = (SELECT ISNULL(COUNT(oppo.PKID), 0)
									FROM tblOrdersProducts_productOptions oppo
									INNER JOIN tblOrders_Products p ON p.ID = oppo.ordersProductsID
									WHERE oppo.deleteX <> 'yes'
									AND oppo.optionID = 490
									AND (p.switch_create = 0 OR p.fastTrak_resubmit = 1)
									AND oppo.ordersProductsID = @OPID)
																  
--ENABLE expressProduction --+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
IF @currentExpressProductionStatus = 0
BEGIN
	--Insert new expressProduction option for OPID
	INSERT INTO tblOrdersProducts_productOptions (ordersProductsID, optionID, optionCaption, optionPrice, optionGroupCaption, optionQty, textValue, deleteX)
	SELECT @OPID, 490, 'Express Production', 0, 'Add Ons', 1, '', 0

	--Write notes
	INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType, ordersProductsID)
	SELECT o.orderNo, 'Express production added for OPID: ' + CONVERT(NVARCHAR(50), @OPID) + '.', GETDATE(), 'SQL', 'order', @OPID
	FROM tblOrders_Products op
	INNER JOIN tblOrders o
		ON op.orderID = o.orderID
	WHERE op.ID = @OPID
END

--DISABLE expressProduction --+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
IF @currentExpressProductionStatus = 1
BEGIN
	--Remove expressProduction option from OPID
	UPDATE tblOrdersProducts_productOptions
	SET deleteX = 'yes'
	WHERE optionID = 490
	AND ordersProductsID = @OPID

	--Write notes
	INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType, ordersProductsID)
	SELECT o.orderNo, 'Express production removed for OPID: ' + CONVERT(NVARCHAR(50), @OPID) + '.', GETDATE(), 'SQL', 'order', @OPID
	FROM tblOrders_Products op
	INNER JOIN tblOrders o ON op.orderID = o.orderID
	WHERE op.ID = @OPID
END