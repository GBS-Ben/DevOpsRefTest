CREATE PROC [dbo].[usp_FT_IMPO_postSSIS]
AS

-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		01/01/2015
-- Purpose		Runs post IMPO, PSLIPS, TIX, LABELS. Update products so that they are not re-imposed, unless manually initiated
-------------------------------------------------------------------------------
-- Modification History
-- 08/03/16		Created.
-- 02/03/18		Updated entire procedure, jf.
-- 03/24/18		Updated notes written to accomodate Canvas badges, which do not reference the image db, jf.
--03/12/21		Added impolog write, jf.
-------------------------------------------------------------------------------


--// OVAL ----------------------------------------------------------------------------------------------------
UPDATE tblOrders_Products
SET fastTrak_preventImposition = 1,
fastTrak_imposed = 1,
fastTrak_imposedOn = GETDATE(),
fastTrak_status_lastModified = GETDATE(),
fastTrak_status = 'In Production',
fastTrak_newQTY = 0
WHERE [ID] IN 
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_OVAL
	WHERE ordersProductsID IS NOT NULL)
OR [ID] IN 
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_OVAL_Frameless
	WHERE ordersProductsID IS NOT NULL)

INSERT INTO FT_eventLog (eventType, eventTime, ordersProductsID)
SELECT DISTINCT 'Imposition File Created - Oval', GETDATE(), ordersProductsID
FROM tblFT_Badges_OVAL
WHERE ordersProductsID IS NOT NULL

INSERT INTO FT_eventLog (eventType, eventTime, ordersProductsID)
SELECT DISTINCT 'Imposition File Created - Oval', GETDATE(), ordersProductsID
FROM tblFT_Badges_OVAL_Frameless
WHERE ordersProductsID IS NOT NULL

--// REC --------------------------------------------------------------------------------------------------------
UPDATE tblOrders_Products
SET fastTrak_preventImposition = 1,
fastTrak_imposed = 1,
fastTrak_imposedOn = GETDATE(),
fastTrak_status_lastModified = GETDATE(),
fastTrak_status = 'In Production',
fastTrak_newQTY = 0
WHERE [ID] IN 
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_REC
	WHERE ordersProductsID IS NOT NULL)
OR [ID] IN 
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_REC_Frameless
	WHERE ordersProductsID IS NOT NULL)

INSERT INTO FT_eventLog (eventType, eventTime, ordersProductsID)
SELECT DISTINCT 'Imposition File Created - Rec', GETDATE(), ordersProductsID
FROM tblFT_Badges_REC
WHERE ordersProductsID IS NOT NULL

INSERT INTO FT_eventLog (eventType, eventTime, ordersProductsID)
SELECT DISTINCT 'Imposition File Created - Rec', GETDATE(), ordersProductsID
FROM tblFT_Badges_REC_Frameless
WHERE ordersProductsID IS NOT NULL

--// Write notes ----------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
SELECT a.orderID, a.orderNo, 
'The following product''s imposition file has been created: ' + CONVERT(VARCHAR(50), b.[ID]) + '.',
GETDATE(), 'SQL', 'product', b.[ID]
FROM tblOrders a 
INNER JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE b.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_OVAL
	WHERE ordersProductsID IS NOT NULL)
OR b.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_REC
	WHERE ordersProductsID IS NOT NULL)
OR b.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_OVAL_Frameless
	WHERE ordersProductsID IS NOT NULL)
OR b.[ID] IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_REC_Frameless
	WHERE ordersProductsID IS NOT NULL)

--// Impolog, baby -----------------------------------------------------------------------------------------------------------------

--insert logs
INSERT INTO impoLog (opid, impoName, impoType, impoStatus)
SELECT op.id
		,'NB-ALPHA-' + CONVERT(VARCHAR(50), DATEPART(DY, GETDATE())) + ' | ' + CONVERT(VARCHAR(50), DATEPART(MM, GETDATE())) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, GETDATE())) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY, GETDATE())) + ' | ' 	+ CONVERT(VARCHAR(50), DATEPART(HH, GETDATE())) + ':' + CONVERT(VARCHAR(50), DATEPART(N, GETDATE())) + ':' + CONVERT(VARCHAR(50), DATEPART(S, GETDATE())) 
		,'NB'
		,'Successful'
FROM tblOrders_Products op
WHERE op.id IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_OVAL
	WHERE ordersProductsID IS NOT NULL)
OR op.id  IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_REC
	WHERE ordersProductsID IS NOT NULL)
OR op.id  IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_OVAL_Frameless
	WHERE ordersProductsID IS NOT NULL)
OR op.id  IN
	(SELECT DISTINCT ordersProductsID
	FROM tblFT_Badges_REC_Frameless
	WHERE ordersProductsID IS NOT NULL)




--// Label / pSlips -------------------------------------------------------------------------------------------------------------------
UPDATE tblOrders_Products
SET fastTrak_preventLabel = 1,
fastTrak_labelGeneratedOn = GETDATE()
WHERE orderID IN
	(SELECT DISTINCT orderID
	FROM tblOrders
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblFT_Badges_Labels
		WHERE orderNo IS NOT NULL))
OR orderID IN
	(SELECT DISTINCT orderID
	FROM tblOrders
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblFT_Badges_pSlips
		WHERE orderNo IS NOT NULL))

INSERT INTO FT_eventLog (eventType, eventTime, orderNo)
SELECT DISTINCT 'Label Generated', GETDATE(), orderNo
FROM tblFT_Badges_Labels
WHERE orderNo IS NOT NULL

--// Reset label choices now that we are done using them.  --------------------------------------------------------------------------------
UPDATE tblOrders_Products 
SET fastTrak_shippingLabelOption1 = 0
WHERE fastTrak_shippingLabelOption1 = 1

UPDATE tblOrders_Products 
SET fastTrak_shippingLabelOption2 = 0
WHERE fastTrak_shippingLabelOption2 = 1

UPDATE tblOrders_Products 
SET fastTrak_shippingLabelOption3 = 0
WHERE fastTrak_shippingLabelOption3 = 1

--// Tickets ----------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblOrders_Products
SET fastTrak_preventTicket = 1,
fastTrak_ticketGeneratedOn = GETDATE()
WHERE orderID IN
	(SELECT DISTINCT orderID
	FROM tblOrders
	WHERE orderNo IN
		(SELECT DISTINCT orderNo
		FROM tblFT_Badges_Tickets
		WHERE orderNo IS NOT NULL)
	)

INSERT INTO FT_eventLog (eventType, eventTime, orderNo)
SELECT DISTINCT 'Ticket Generated', GETDATE(), orderNo
FROM tblFT_Badges_Tickets
WHERE orderNo IS NOT NULL