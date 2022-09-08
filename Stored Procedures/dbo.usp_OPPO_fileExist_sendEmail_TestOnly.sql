CREATE PROC [dbo].[usp_OPPO_fileExist_sendEmail_TestOnly]
@PKID INT = 0,
@OPID INT = 0

AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/10/18
-- Purpose     Send email to necessary party when image is missing on fasTrak product, preventing its creation in Switch. 
--					   Accepts two variables: OPID and PKID, both from OPPO.
-------------------------------------------------------------------------------
-- Modification History
--
--08/10/18		JF, created.
--08/13/18		JF, changed 'from' email address.


 --THIS IS FOR TESTING PURPOSES ONLY, LOOK FOR ASTERISKS THAT DESCRIBE WHAT HAS BEEN REMOVED/CHANGED.
 --THIS IS FOR TESTING PURPOSES ONLY, LOOK FOR ASTERISKS THAT DESCRIBE WHAT HAS BEEN REMOVED/CHANGED.
 --THIS IS FOR TESTING PURPOSES ONLY, LOOK FOR ASTERISKS THAT DESCRIBE WHAT HAS BEEN REMOVED/CHANGED.
 --THIS IS FOR TESTING PURPOSES ONLY, LOOK FOR ASTERISKS THAT DESCRIBE WHAT HAS BEEN REMOVED/CHANGED.
 --THIS IS FOR TESTING PURPOSES ONLY, LOOK FOR ASTERISKS THAT DESCRIBE WHAT HAS BEEN REMOVED/CHANGED.

-------------------------------------------------------------------------------

DECLARE @orderNo NVARCHAR(20),
				 @orderID INT = 0,
				 @emailSent INT = 0,
				 @subjecttext NVARCHAR(100),
				 @bodytext NVARCHAR(MAX),
				 @email NVARCHAR(255),
				 @imagePath NVARCHAR(255)

--IF @OPID <> 0 -- this whole section commented out for testing purposes ******************************************************************
--BEGIN
--	SET @emailSent = (SELECT TOP 1 1
--									 FROM tblOPPO_fileExists_EmailLog
--									 WHERE OPID =  @OPID
--									 AND emailSent = 1)
--END

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;


IF @emailSent IS NULL
BEGIN
	SET @emailSent = 0
END

IF @emailSent = 0
BEGIN

	SET @orderNo  = (SELECT o.orderNo
									FROM tblOrders o
									INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
									WHERE op.ID = @OPID)

	SET @orderID = (SELECT o.orderID
								 FROM tblOrders o
								 WHERE orderNo = @orderNo)

	SET @email = 'jeremy@gogbs.com' -- just me ***********************************************************************************************
	SET @subjecttext = '[TEST] Missing Image for Switch (' + @orderNo + '/' + CONVERT(NVARCHAR(20), @OPID) + ')'-- edited for test **************
	SET @imagePath = (SELECT CONVERT(NVARCHAR(255), textValue)
									  FROM tblOPPO_fileExists
									  WHERE OPID =  @OPID
									  AND rowID = @PKID)

	SET @bodytext = 'Dark Knight of Gotham: There is a missing image for OPID #' + CONVERT(NVARCHAR(20), @OPID) + ' which is in ' + @orderNo + '.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'This OPID will not make the switch flow until the image is put in the directory.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'Here''s where the image should be located:  ' + @UncBasePath + LOWER(REPLACE(@imagePath, 'JPG', 'pdf')) + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'And here''s a link to the order: http://sbs/gbs/admin/orderView.asp?i=' + CONVERT(NVARCHAR(20), @orderID) + '&o=orders.asp&OrderNum=' + @orderNo + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'If you have any questions, please contact JF or AC.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + '~ SQL'


EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'House of Magnets',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText

	--INSERT INTO tblOPPO_fileExists_EmailLog (rowID, OPID, emailSent, emailSentTo) -- no inserts during test *************************************
	--SELECT @PKID, @OPID, 1, @email

END