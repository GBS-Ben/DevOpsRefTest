CREATE PROC [dbo].[FurnishedArt_sendEmail]
@OrderID INT,
@ProductCode NVARCHAR(50)

AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/28/18
-- Purpose     Send email to necessary party to inspect FA art as it comes into system.
-------------------------------------------------------------------------------
-- Modification History
--
--08/28/18		JF, created.
--05/25/19		BS db mail
-------------------------------------------------------------------------------

DECLARE @emailSent INT = 0,
				 @subjecttext NVARCHAR(100),
				 @bodytext NVARCHAR(MAX),
				 @email NVARCHAR(255),
				 @OrderNo NVARCHAR(20)

IF @OrderID <> 0 
BEGIN
	SET @emailSent = (SELECT TOP 1 1
									 FROM FurnishedArtEmailLog
									 WHERE OrderID =  @OrderID
									 AND emailSent = 1)
END

IF @emailSent IS NULL
BEGIN
	SET @emailSent = 0
END

IF @emailSent = 0
BEGIN

	SET @OrderNo = (SELECT orderNo FROM tblOrders WHERE orderID = @OrderID)
	SET @email = 'info@houseofmagnets.com'
	SET @subjecttext = 'INSPECT ART: ' + SUBSTRING(@ProductCode, 1 , 4) + ' ('+ @OrderNo + ')'


	SET @bodyText = 'Please Inspect the furnished art for order:  ' + @OrderNo + '.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodyText = @bodyText + 'Here''s a link to the order: http://sbs/gbs/admin/orderView.asp?i=' + CONVERT(NVARCHAR(20), @orderID) + '&o=orders.asp&OrderNum=' + @orderNo + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodyText = @bodyText + '~ SQL'

	--EXEC sp_send_cdosysmailtxt 'GBS.SQL@gogbs.com', @email, @subject, @body

	EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLAlerts',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText


	INSERT INTO FurnishedArtEmailLog (OrderID, OrderNo, emailSent, emailSentTo, emailSentOn)
	SELECT @OrderID, @OrderNo, 1, @email, GETDATE()

END