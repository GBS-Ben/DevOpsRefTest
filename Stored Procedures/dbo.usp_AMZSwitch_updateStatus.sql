CREATE PROC [dbo].[usp_AMZSwitch_updateStatus]
@AMZID NVARCHAR(30),
@new_AMZ_Status VARCHAR(50) = ' '
AS
SET NOCOUNT ON;

	BEGIN TRY
			SET @AMZID = CONVERT(INT, @AMZID)
				UPDATE tblAMZ_orderValid
				SET orderStatus = @new_AMZ_Status, 
				modified_on = GETDATE()
				WHERE [ID] = @AMZID

	END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH