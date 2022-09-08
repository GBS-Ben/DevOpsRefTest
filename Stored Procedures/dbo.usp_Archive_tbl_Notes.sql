CREATE PROCEDURE [dbo].[usp_Archive_tbl_Notes] 
	@LastName nvarchar(50) = NULL, 
	@FirstName nvarchar(50) = NULL
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/3/15
-- Purpose    Archive records older than 24 months from tbl_Notes to tbl_NotesArchive based on noteDate column. 
-------------------------------------------------------------------------------
-- Modification History
--
--10/3/15		TL, created.
--08/10/18		JF, added LEFT JOIN to initial query.

-------------------------------------------------------------------------------

BEGIN TRY
SET NOCOUNT ON;

-- Insert notes into archive that are older than 2 years.
SET IDENTITY_INSERT tbl_NotesArchive ON

	INSERT INTO tbl_NotesArchive (PKID, orderID, jobNumber, notes, noteDate, author, proofNote_ref_PKID, notesType, deleteX, systemNote, ordersProductsID, switch_NoteType)
	SELECT n.PKID, n.orderID, n.jobNumber, n.notes, n.noteDate, n.author, n.proofNote_ref_PKID, n.notesType, n.deleteX, n.systemNote, n.ordersProductsID, n.switch_NoteType
	FROM tbl_Notes n
	LEFT JOIN tbl_NotesArchive a
		ON n.PKID = a.PKID
	WHERE a.PKID IS NULL
	AND DATEDIFF(MM, n.noteDate, GETDATE()) >= 24

SET IDENTITY_INSERT tbl_NotesArchive OFF

-- Delete notes from tbl_Notes that were just archived
DELETE FROM tbl_Notes
WHERE DATEDIFF(MM, noteDate, GETDATE()) >= 24
AND PKID IN
       (SELECT PKID
       FROM tbl_NotesArchive)

END TRY
BEGIN CATCH
		--Capture errors if they happen
		 EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH