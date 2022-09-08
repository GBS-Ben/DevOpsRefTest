CREATE PROCEDURE [dbo].[usp_ProductNotificationEmail] @NumberToSend int = 10
AS
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @tableHTML  NVARCHAR(MAX),  @OPID int, @IntranetOrderLink varchar(255),	@Recipient varchar(255), @OrderNo varchar(100), @intFlag int, @counter int, @Subject varchar(500)

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
	SELECT TOP (10) o.OrderNo, --we limit records to send
			o.OrderId ,
			'http://intranet/gbs/admin/orderView.asp?i=' + convert(varchar(100),o.OrderId) + '&o=orders.asp&OrderNum=' + o.OrderNo + '&p=1' AS IntranetOrderLink
	FROM tblOrders_Products p
	INNER JOIN [dbo].[tblOrders] o ON o.orderID = p.orderID  
	LEFT JOIN tblThirdPartyProductAlertEmailLog l on l.orderNo = o.OrderNo --only send email once
	WHERE p.productCode IN ('SN00ST-003','SN00ST-004','SN00ST-005','SN00ST-006') 
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
	<title>SN00ST Order</title>
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

<p>Heads up! OrderNo  ' + @OrderNo + '.  contains a product that needs to be ordered.  Please place an order with the appropriate vendor and update order notes when complete.
Here is the link to the order on the intranet - ' + @IntranetOrderLink + '</p>

<p>
	<br>
</p>
	</body>
	</html>

	'
		
						SET @Subject = @OrderNo + ': New order with 3rd Party Vendor Products'
	
						EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'SQLAlerts',  
						@recipients = 'brian@gogbs.com;Deanna@gogbs.com;bobby@gogbs.com',
						@reply_to= 'bobby@gogbs.com',
						@subject = @Subject,
						@body = @tableHTML,
						@body_format = 'HTML';

					--Log sending the email
					INSERT tblThirdPartyProductAlertEmailLog (DateEmailSent,HTMLBody, RecipientEmail, OrderNo	)
					SELECT GETDATE(), 
						 @tableHTML, 
						 @Recipient,
						 @OrderNo
						 
			 						 
				
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