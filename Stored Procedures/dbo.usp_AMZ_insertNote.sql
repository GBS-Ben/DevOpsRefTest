/*
-------------------------------------------------------------------------------
Author		Jonathan Stafford-Bentley
Created		05/16/22
Purpose		Inserts notes for Amazon Orders, post flow.
			Also, now inserts log record that associates an AMZID with its corresponding
			imposition number.

-------------------------------------------------------------------------------
Modification History

05/16/22	JSB, Created SP to account for AMZ Switch Flow
-------------------------------------------------------------------------------
*/
CREATE PROC [dbo].[usp_AMZ_insertNote]
@AMZID NVARCHAR(30), 
@orderNo VARCHAR(30)= '',
@productCode VARCHAR(255) = '',
@process VARCHAR(255) = '',
@status VARCHAR(255) = '',
@notesType VARCHAR(255) = '',
@imposeName VARCHAR(255) ='',
@imposeType VARCHAR(255) = ''

AS
SET NOCOUNT ON;

BEGIN TRY

	SET @AMZID = CONVERT(INT,@AMZID)
	--insert notes
	INSERT INTO tbl_notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID, switch_NoteType)
	SELECT @AMZID, @orderNo, 
	(@productCode + ' ' + @process + ' ' + @status + ' ' + CONVERT(VARCHAR(50), @AMZID) + ' ' + @imposeName),
	GETDATE(), 'Switch', @notesType, @AMZID, @imposeType

	--insert logs
	INSERT INTO impoLog (opid, impoName, impoType, impoStatus)
	SELECT @AMZID, @imposeName, @imposeType, @status


END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH