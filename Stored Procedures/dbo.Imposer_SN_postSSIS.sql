CREATE PROCEDURE [dbo].[Imposer_SN_postSSIS]
AS

/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     05/03/19	
Purpose     Signs Alpha
-------------------------------------------------------------------------------
Modification History

05/03/19	Created.

-------------------------------------------------------------------------------
*/

--update sign data to prevent future export
UPDATE op
SET op.stream = 1,
	op.fastTrak_resubmit = 0,
	op.fastTrak_status = 'In Production',
	op.fastTrak_status_lastModified = GETDATE()
FROM tblOrders_Products op
INNER JOIN SN_ImposerExport s ON op.ID = s.opid

--write notes
INSERT INTO tbl_Notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID)
SELECT op.orderID, o.orderNo, 
'Signs Imposer Alpha has successfully exported the following OPID: ' + CONVERT(VARCHAR(50), op.[ID]) + ' to the hotfolder.',
GETDATE(), 'SQL', 'product', op.[ID]
FROM tblOrders_Products op
INNER JOIN SN_ImposerExport s ON op.ID = s.opid
INNER JOIN tblOrders o ON op.orderID = o.orderID

--insert logs
INSERT INTO impoLog (opid, impoName, impoType, impoStatus)
SELECT op.id
		,'SN-ALPHA-' + CONVERT(VARCHAR(50), DATEPART(DY, GETDATE())) + ' | ' + CONVERT(VARCHAR(50), DATEPART(MM, GETDATE())) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, GETDATE())) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY, GETDATE())) + ' | ' 	+ CONVERT(VARCHAR(50), DATEPART(HH, GETDATE())) + ':' + CONVERT(VARCHAR(50), DATEPART(N, GETDATE())) + ':' + CONVERT(VARCHAR(50), DATEPART(S, GETDATE())) 
		,'SN'
		,'Successful'
FROM tblOrders_Products op
INNER JOIN SN_ImposerExport s ON op.ID = s.opid
INNER JOIN tblOrders o ON op.orderID = o.orderID