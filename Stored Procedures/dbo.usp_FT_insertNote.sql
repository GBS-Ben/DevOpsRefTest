/*
-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		11/06/15
Purpose		Inserts notes, post flow.
			Also, now inserts log record that associates an OPID with its corresponding
			imposition number.

-------------------------------------------------------------------------------
Modification History

11/06/15	JF, hello world.
09/21/20	JF, added logging portion of code
0928/20		JF, modified @extraData for better logging.
-------------------------------------------------------------------------------
*/

CREATE PROC [dbo].[usp_FT_insertNote]
@ID INT,
@productGroup VARCHAR(255) = '',
@process VARCHAR(255) = '',
@status VARCHAR(255) = '',
@notesType VARCHAR(255) = '',
@extraData VARCHAR(255) = '',
@switch_NoteType VARCHAR(255) = ''

AS
SET NOCOUNT ON;

BEGIN TRY

	--declare variables
	DECLARE @orderID INT,
			@orderNo VARCHAR(10),
			@productCode VARCHAR(50)

	--set variables
	SET @orderID = (SELECT orderID
					FROM tblOrders_Products
					WHERE ID = @ID
					AND ID IS NOT NULL)

	IF @orderID IS NULL
		BEGIN
			SET @orderID = 0
		END

	SET @orderNo = (SELECT orderNo
					FROM tblOrders
					WHERE orderID = @orderID
					AND orderID IS NOT NULL)

	SET @productCode = (SELECT productCode
						FROM tblOrders_Products
						WHERE [ID] = @ID
						AND productCode IS NOT NULL)

	--insert notes
	INSERT INTO tbl_notes (orderID, jobNumber, notes, noteDate, author, notesType, ordersProductsID, switch_NoteType)
	SELECT @orderID, @orderNo, 
	(@productGroup + ' ' + @process + ' ' + @status + ' ' + CONVERT(VARCHAR(50), @ID) + ' ' + @extraData),
	GETDATE(), 'Switch', @notesType, @ID, @switch_NoteType

	--insert logs
	INSERT INTO impoLog (opid, impoName, impoType, impoStatus)
	SELECT @ID, REPLACE(REPLACE(ISNULL(@extraData,' '), 'on ', ''), '.pdf', ''), @productGroup, @status


END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH