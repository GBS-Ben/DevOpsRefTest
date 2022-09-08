CREATE PROCEDURE "dbo"."getOrderNotes"
@orderID INT
AS

SELECT
	n.PKID as [id],
	n.notes as [noteContent],
	n.notesType as [noteType],
	n.author as [noteAuthor],
	n.noteDate as [authoredOn],
	n.deleteX as [deleted]
FROM tbl_Notes n
where n.jobnumber = (SELECT orderNo from tblOrders where orderID = @orderID)