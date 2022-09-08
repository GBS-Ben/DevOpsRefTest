CREATE PROCEDURE "dbo"."dashboard_getNotes"
AS
SELECT top 100000 PKID, jobNumber as orderNo, ordersProductsID as OPID, orderID, notes, noteDate, author, notesType FROM tbl_Notes WHERE author = 'switch' ORDER BY NoteDate DESC