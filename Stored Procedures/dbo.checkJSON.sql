CREATE PROCEDURE [dbo].[checkJSON]
AS

/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     03/10/21
Purpose    Reviews the JSON that passes thru with Signs (and other products eventually)
				 Disqualifies OPIDs for production that have default text on their design
				 SELECT * FROM magicwords
-------------------------------------------------------------------------------
Modification History

03/10/21	Created, jf.

-------------------------------------------------------------------------------
*/

--work table
IF OBJECT_ID('dbo.OPIDsToCheck') IS NOT NULL DROP TABLE OPIDsToCheck
CREATE TABLE OPIDsToCheck
	(RowID INT IDENTITY(1, 1), 
	OPID INT,
	JSONtoCheck VARCHAR(1500))
DECLARE @NumberRecords INT, @RowCount INT
DECLARE @OPID INT
DECLARE @textValue VARCHAR(MAX)

TRUNCATE TABLE OPIDsToCheck
INSERT INTO OPIDsToCheck (OPID, JSONtoCheck)
SELECT op.ID, oppx.textValue
FROM tblOrders_Products op
INNER JOIN tblOrders o ON op.orderID = o.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON oppx.ordersProductsID = op.id
WHERE SUBSTRING(op.productCode, 1, 2) = 'SN' 
AND (op.productCode NOT LIKE 'SNFA%' AND op.processType <> 'fasTrak'
		OR op.productCode LIKE 'SNFA%' AND op.processType = 'fasTrak') 
AND oppx.modified_on > GETDATE() - 2
AND oppx.optionCaption = 'CanvasUserItemsJson'
AND oppx.deleteX <> 'yes'
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM logCheckJSON n
	WHERE n.opid  = op.id)

--get baddies
;WITH CTE
AS
(SELECT o.OPID, o.JSONtoCheck
FROM OPIDsToCheck o
CROSS APPLY 
	(SELECT xvalue 
	FROM MagicWords) m
WHERE o.JSONtoCheck LIKE '%:"' + m.xvalue + '"%')

--fail 'em
UPDATE op
SET fastTrak_status = 'Failed'
FROM tblOrders_Products op
INNER JOIN CTE ON op.ID = CTE.OPID
WHERE fastTrak_status <> 'Failed'