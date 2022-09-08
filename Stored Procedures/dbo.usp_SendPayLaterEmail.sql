CREATE PROCEDURE [dbo].[usp_SendPayLaterEmail] @NumberToSend int = 100
AS
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @tableHTML  NVARCHAR(MAX),  @OPID int, @PaymentLink varchar(500),	@Recipient varchar(255), @OrderNo varchar(100), @intFlag int, @counter int,@Subject varchar(500), @name varchar(1000)

	DECLARE @Orders TABLE (
		rownum int IDENTITY(1,1), 
		OrderNo varchar(50), 
		OrderId int,
		OrderEmail varchar(500), 
		PaymentLink varchar(500),
		OrderName varchar(500)
	)


	--Load the orders we will send emails for
	INSERT @Orders (OrderNo,
			OrderId ,
			OrderEmail,
			PaymentLink,
			OrderName
			)
	SELECT TOP (@NumberToSend) pl.OrderNo, --we limit records to send
			pl.OrderId ,
			LastEmailRecipient,
			PaymentLink,
			OrderName
	FROM tblPayLater pl
	INNER JOIN tblOrders o ON o.orderNo = pl.OrderNo
	WHERE LastEmailRecipient IS NOT NULL 
		AND PaymentLink IS NOT NULL
		AND o.orderStatus LIKE ('%Waiting For Payment')
		AND o.orderStatus <> 'Cancelled'


	SET @intFlag = 1
	SET @counter = (SELECT COUNT(*) FROM @Orders)

	WHILE (@intFlag <= @counter)
	BEGIN

			SELECT @PaymentLink = PaymentLink ,
				@Recipient = OrderEmail, 
				@OrderNo = OrderNo,
				@Subject = 'Are you ready for your football schedules? (' + ISNULL(OrderNo,'') +  ')' ,
				@Name = ISNULL(OrderName,'')
			FROM @Orders 
			WHERE rownum = @intFlag 

		IF @PaymentLink IS NOT NULL
		BEGIN

			SET @tableHTML = '
		<p>Hi ' + @Name + ',&nbsp;</p>
		<p>Thank you for your 2020 Football Schedule Order. The NFL and many Collegiate Conferences have finalized their schedules and we are following up with you to collect payment and get your order into production. Please note that we have updated the scheduled dates and times and have removed any collegiate teams that have cancelled or postponed their football season.&nbsp;</p>
		<p>Please click the secure link to provide payment and we''ll get your order right into production!&nbsp;</p>
		<p>'+ @PaymentLink + '&nbsp;&nbsp;</p>
		<p>As your marketing partner, know that we are here to help. If you have any questions, concerns, or updates to your order prior to production, please reply to this email or call us at 800-789-6247.&nbsp;&nbsp;</p>
		<p>Thank you!&nbsp;</p>
		<p>Your Client Success Team&nbsp;</p>
		<p><a href="mailto:info@markful.com">info@markful.com</a>&nbsp;| 800.789.6247&nbsp;</p>'
	
		EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'Markful',  
		@recipients = @Recipient,
		@blind_copy_recipients ='info@markful.com',
		@reply_to= 'info@markful.com',
		@subject = @subject, --'Don’t run out! Reorder your business cards today.' ,
		@body = @tableHTML,
		@body_format = 'HTML';

		INSERT tbl_Notes (OrderId, jobNumber, notes, noteDate, author, proofNote_ref_PKID, notesType, deleteX, systemNote, ordersProductsID, switch_NoteType)
		SELECT OrderId, pl.OrderNo AS jobNumber, 'Pay Later Email Sent to ' + @Recipient AS notes, GETDATE() AS noteDate, 'SQL' AS author, NULL AS proofNote_ref_PKID, 'order' AS notesType, '0' AS deleteX, NULL AS systemNote, 0 AS ordersProductsID, NULL AS switch_NoteType
		FROM dbo.tblPayLater pl
		WHERE OrderNo = @OrderNo


			 --Extra Safe: Remove the row from our process table...also would remove duplicates that shouldnt exist
			 DELETE @Orders WHERE  OrderNo = @OrderNo 

			END

			SET @intFlag = @intFlag + 1
			SET @PaymentLink = ''
			SET @Recipient = ''
			SET @OPID = NULL
			SET @OrderNo = ''
			SET @name = ''
	
END
END TRY

BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH