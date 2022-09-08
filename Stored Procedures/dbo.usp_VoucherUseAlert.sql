CREATE PROCEDURE [dbo].[usp_VoucherUseAlert] @NumberToSend int = 10
AS
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @tableHTML  NVARCHAR(MAX),  @OPID int, @IntranetOrderLink varchar(255),	@Recipient varchar(255), @OrderNo varchar(100), @intFlag int, @counter int

	DECLARE @Orders TABLE (
		rownum int IDENTITY(1,1), 
		OrderNo varchar(50), 
		OrderId int,
		OrderEmail varchar(500), 
		BusinessCardEmail varchar(500),
		IntranetOrderLink varchar(500),
		LastOrderDate datetime, 
		DaysSinceLastOrder int, 
		ImageUrl varchar(500)
	)
	
	--Load the orders we will send emails for
	INSERT @Orders (OrderNo,
			OrderId ,
			IntranetOrderLink
			)
	SELECT TOP (@NumberToSend) o.OrderNo, --we limit records to send
			o.OrderId ,
			'http://intranet/gbs/admin/orderView.asp?i=' + convert(varchar(100),o.OrderId) + '&o=orders.asp&OrderNum=' + o.OrderNo + '&p=1' AS IntranetOrderLink
	FROM [dbo].[tblVouchersSales] s--voucher info
	INNER JOIN [dbo].[tblVouchersSalesUse] vsu ON vsu.sVoucherID = s.sVoucherID --link to order
	INNER JOIN [dbo].[tblOrders] o ON o.orderID = vsu.orderID  
	LEFT JOIN tblVoucherAlertEmailLog l on l.orderNo = o.OrderNo --only send email once
	WHERE s.svoucherCode = 'SCOUTPACK'
		AND l.OrderNo IS NULL
		AND o.OrderDate > GETDATE()-1
		AND orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered')
		
	SET @intFlag = 1
	SET @counter = (SELECT MAX(rownum) FROM @Orders)

	WHILE (@intFlag <= @counter)
	BEGIN

			SELECT @OrderNo = OrderNo, 
				@IntranetOrderLink = IntranetOrderLink
			FROM @Orders 
			WHERE rownum = @intFlag 

IF @OrderNo IS NOT NULL
BEGIN

	SET @tableHTML = 
	'<!doctype html>
	<html>
	<head>
	<meta charset="utf-8">
	<title>SCOUTPACK Order</title>
	<style>
	#outlook a {
		padding: 0;
	} /* Force Outlook to provide a "view in browser" menu link. */
	body {
		width: 100% !important;
		-webkit-text-size-adjust: 100%;
		-ms-text-size-adjust: 100%;
		margin: 0;
		padding: 0;
	}

	@media only screen and (max-width: 480px) {
	*.width160 {
		width: 160px !important;
	}
	*.width270 {
		width: 270px !important;
	} /* 25px margins */
	*.width280 {
		width: 280px !important;
	} /* 20px margins */
	*.width300 {
		width: 300px !important;
	} /* 10px margins */
	*.width320 {
		width: 320px !important;
	}
	*.heightauto {
		height: auto !important;
	}
	*.fluid {
		width: 100% !important;
		height: auto !important;
	}
	*.hide {
		display: none !important;
	}
	/* CAMPAIGN CSS */
	*.block {
		display: block !important;
	}
	*.padbtm {
		padding-bottom: 30px !important;
	}
	}
	</style>
	</head>

	<body>
	<h1>Hey Buddy</h1>

<p>I hope you are having an amazing day.</p>

<p>I found a SCOUTPACK voucher order and wanted to alert you right away. &nbsp;The OrderNo is ' + @OrderNo + '. &nbsp;Here is the link to the order on the intranet - ' + @IntranetOrderLink + '</p>

<p>
	<br>
</p>

<p>See you soon. &nbsp;Love,&nbsp;</p>

<p><strong>Buttons</strong></p>

<p>
	<br>
</p>
	</body>
	</html>

	'
	---Dont send more than 1 email to the same 
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblBusinessCardReorderEmailLog WHERE RecipientEmail = @Recipient AND OPID = @OPID AND OrderNo = @OrderNo)
	BEGIN

						EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'SQLAlerts',  
						@recipients = 'brian@gogbs.com;bobby@gogbs.com',
						@reply_to= 'bobby@gogbs.com',
						@subject = 'New SCOUTPACK Order' ,
						@body = @tableHTML,
						@body_format = 'HTML';

					--Log sending the email
					INSERT tblVoucherAlertEmailLog (DateEmailSent,HTMLBody, RecipientEmail, OrderNo, VoucherCode	)
					SELECT GETDATE(), 
						 @tableHTML, 
						 @Recipient,
						 @OrderNo,
						 'SCOUTPACK'
						 
			END 						 
				
			 ---Extra Safe: Remove the row from our process table...also would remove duplicates that shouldnt exist
			 DELETE @Orders WHERE OrderNo = @OrderNo

			END

			SET @intFlag = @intFlag + 1
			SET @IntranetOrderLink = ''
			SET @OrderNo = ''
	END

END TRY

BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH