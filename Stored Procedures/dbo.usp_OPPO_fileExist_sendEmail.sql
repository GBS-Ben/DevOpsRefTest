CREATE PROCEDURE [dbo].[usp_OPPO_fileExist_sendEmail] 
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
--09/19/19		CT, changed variable @imagePath from select 'textValue' to select 'filePath'
-------------------------------------------------------------------------------

DECLARE @orderNo NVARCHAR(20),
				 @orderID INT = 0,
				 @emailSent INT = 0,
				 @subjecttext NVARCHAR(100),
				 @bodytext NVARCHAR(MAX),
				 @email NVARCHAR(255),
				 @imagePath NVARCHAR(255)

IF @OPID <> 0 
BEGIN
	SET @emailSent = (SELECT TOP 1 1
					FROM tblOPPO_fileExists_EmailLog
					WHERE OPID =  @OPID
					AND emailSent = 1)
END

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

	SET @email = 'jeremy@gogbs.com; brian@gogbs.com; bobby@gogbs.com; cbrowne@gogbs.com'
	SET @subjecttext = 'Missing Image for Switch (' + @orderNo + '/' + CONVERT(NVARCHAR(20), @OPID) + ')'
	SET @imagePath = (SELECT CONVERT(NVARCHAR(255), textValue)
									  FROM tblOPPO_fileExists
									  WHERE OPID =  @OPID
									  AND rowID = @PKID)

	SET @bodytext = 'There is a missing image for OPID #' + CONVERT(NVARCHAR(20), @OPID) + ' which is in ' + @orderNo + '.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'This OPID will not make the switch flow until the image is put in the directory.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'Here''s where the image should be located: ' + @imagePath + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'And here''s a link to the order: http://intranet/gbs/admin/orderView.asp?i=' + CONVERT(NVARCHAR(20), @orderID) + '&o=orders.asp&OrderNum=' + @orderNo + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + 'If you have any questions, see Jeremy.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodytext = @bodytext + '~ SQL'

	EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLAlerts',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText

	INSERT INTO tblOPPO_fileExists_EmailLog (rowID, OPID, emailSent, emailSentTo)
	SELECT @PKID, @OPID, 1, @email

END