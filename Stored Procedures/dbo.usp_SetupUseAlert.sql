CREATE PROCEDURE [dbo].[usp_SetupUseAlert] @NumberToSend int = 20
AS
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @tableHTML  NVARCHAR(MAX),  @OPID int, @IntranetOrderLink varchar(255),	@SpecifiedOptions varchar(4000),	@Recipient varchar(255), @subject nvarchar(500),
		@OrderNo varchar(100), @intFlag int, @counter int
		, @AlertType nvarchar(100)

	DECLARE @Orders TABLE (
		rownum int IDENTITY(1,1), 
		OrderNo varchar(50), 
		OrderId int,
		OrderEmail varchar(500), 
		BusinessCardEmail varchar(500),
		IntranetOrderLink varchar(500),
		SpecifiedOptions VARCHAR(4000),
		LastOrderDate datetime, 
		DaysSinceLastOrder int, 
		ImageUrl varchar(500)
	)
	
	--Load the orders we will send emails for
	INSERT @Orders (OrderNo,
			OrderId ,
			IntranetOrderLink,
			SpecifiedOptions
			)
	SELECT TOP (@NumberToSend) o.OrderNo, --we limit records to send
			o.OrderId ,
			'http://intranet/gbs/admin/orderView.asp?i=' + convert(varchar(100),o.OrderId) + '&o=orders.asp&OrderNum=' + o.OrderNo + '&p=1' AS IntranetOrderLink,
			STUFF((SELECT '; '  + oppx.optionCaption + ': ' + ISNULL(oppx.textValue, '')
					FROM tblOrdersProducts_productOptions oppx
					WHERE op.id = oppx.ordersProductsID
					AND oppx.optionCaption <> 'Upload Vector File'
					ORDER BY oppx.optionCaption DESC
					FOR XML PATH('')), 1, 2, '')
	FROM [dbo].[tblOrders] o 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	LEFT JOIN tblSetupAlertEmailLog l on l.orderNo = o.OrderNo --only send email once
	WHERE l.OrderNo IS NULL
		AND o.OrderDate > GETDATE()-1
		AND DATEDIFF(MI, o.orderDate, GETDATE()) > 60  --increase the time so OPPOs can get in
		AND orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered')
		AND op.productCode = 'NB00SU-001'
--		AND EXISTS (SELECT TOP 1 1 FROM tblOrders_Products op WHERE op.orderId = o.OrderId AND op.ProductCode IN ('NB00SU-001') )

	SET @intFlag = 1
	SET @counter = (SELECT MAX(rownum) FROM @Orders)

	WHILE (@intFlag <= @counter)
	BEGIN

			SELECT @OrderNo = OrderNo, 
				@IntranetOrderLink = IntranetOrderLink,
				@SpecifiedOptions = SpecifiedOptions
			FROM @Orders 
			WHERE rownum = @intFlag 

IF @OrderNo IS NOT NULL
BEGIN

	SET @tableHTML = 
	'<!doctype html>
	<html>
	<head>
	<meta charset="utf-8">
	<title>Set Up Order</title>
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


<p>I hope you are having an amazing day.</p>

<p>I found a NAME BADGE SET UP order and wanted to alert you right away. &nbsp;The OrderNo is ' + @OrderNo + '. &nbsp;Here is the link to the order on the intranet - ' + @IntranetOrderLink + '</p>

<p>
	Here are the options the customer requested:&nbsp;' + @SpecifiedOptions + '
</p>

<p>You are the best. &nbsp;Love,&nbsp;</p>

<p><strong>Buttons</strong></p>

<p>
	<br>
</p>
	</body>
	</html>

	'
	---Dont send more than 1 email to the same 
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSetupAlertEmailLog WHERE RecipientEmail = @Recipient AND OrderNo = @OrderNo AND AlertType = 'Name Badge Setup')
	BEGIN

	SET @subject = @OrderNo + ' ' +  'Name Badge Setup'
	/*
    original Bobby Code
        Problem: cant have reply_to set to bobby@gogbs.com
        Fix: use an alias associated to svc_sql@gogbs.com,
            added CC Users: @copy_recipients


						EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'SQLAlerts',  
						@recipients =  'brian@gogbs.com;ian@gogbs.com;NameBadgeSchedule@gogbs.com',
						@reply_to= 'bobby@gogbs.com',
						@subject = @subject ,
						@body = @tableHTML,
						@body_format = 'HTML';
    */
    
    
    --Charles Code

    Set @recipient = 'brian@gogbs.com;ian@gogbs.com;NameBadgeSchedule@gogbs.com;jeremy@gogbs.com'
						EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'SQLAlerts',  
						@recipients =  @recipient,
                        @reply_to = 'sqlNotification@gogbs.com',
						@copy_recipients = 'bobby@gogbs.com',
						@subject = @subject ,
						@body = @tableHTML,
						@body_format = 'HTML';

					--Log sending the email
					INSERT tblSetupAlertEmailLog (DateEmailSent,HTMLBody, RecipientEmail, OrderNo	)
					SELECT GETDATE(), 
						@tableHTML, 
						@Recipient,
						@OrderNo
						
						
			END 						 
				
			---Extra Safe: Remove the row from our process table...also would remove duplicates that shouldnt exist
			DELETE @Orders WHERE OrderNo = @OrderNo

			END

			SET @intFlag = @intFlag + 1
			SET @IntranetOrderLink = ''
			SET @OrderNo = ''
	END


	--------------------------------------NOW SEND MARKET CENTER SETUPS-------------------------------------------------------
	------'MC00SU-001',
	-------------------------------------------------------------------------------------------------------------------------

	--Clean the table
	DECLARE @MCOrders TABLE (
		rownum int IDENTITY(1,1), 
		OrderNo varchar(50), 
		OrderId int,
		OrderEmail varchar(500), 
		BusinessCardEmail varchar(500),
		IntranetOrderLink varchar(500),
		SpecifiedOptions VARCHAR(4000),
		LastOrderDate datetime, 
		DaysSinceLastOrder int, 
		ImageUrl varchar(500)
	)

	
	--Load the orders we will send emails for
	INSERT @MCOrders (OrderNo,
			OrderId ,
			IntranetOrderLink,
			SpecifiedOptions
			)

	SELECT TOP (@NumberToSend) o.OrderNo, --we limit records to send
			o.OrderId ,
			'http://intranet/gbs/admin/orderView.asp?i=' + convert(varchar(100),o.OrderId) + '&o=orders.asp&OrderNum=' + o.OrderNo + '&p=1' AS IntranetOrderLink,
			STUFF((SELECT '; '  + oppx.optionCaption + ': ' + ISNULL(oppx.textValue, '')
						FROM tblOrdersProducts_productOptions oppx
						WHERE op.id = oppx.ordersProductsID
						AND oppx.optionID <> 701
						ORDER BY oppx.optionCaption DESC
						FOR XML PATH('')), 1, 2, '') --JF added on 14APR2021
	FROM [dbo].[tblOrders] o 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	LEFT JOIN tblSetupAlertEmailLog l on l.orderNo = o.OrderNo --only send email once
	WHERE l.OrderNo IS NULL
		AND o.OrderDate > GETDATE()-1
		AND DATEDIFF(MI, o.orderDate, GETDATE()) > 60  --increase the time so OPPOs can get in
		AND orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered')
		AND op.productCode = 'MC00SU-001'
--		AND EXISTS (SELECT TOP 1 1 FROM tblOrders_Products op WHERE op.orderId = o.OrderId AND op.ProductCode IN ('MC00SU-001') )

	SET @intFlag = 1
	SET @counter = (SELECT MAX(rownum) FROM @MCOrders)

	WHILE (@intFlag <= @counter)
	BEGIN

			SELECT @OrderNo = OrderNo, 
				@IntranetOrderLink = IntranetOrderLink,
				@SpecifiedOptions = SpecifiedOptions
			FROM @MCOrders 
			WHERE rownum = @intFlag 

IF @OrderNo IS NOT NULL
BEGIN

	SET @tableHTML = 
	'<!doctype html>
	<html>
	<head>
	<meta charset="utf-8">
	<title>Set Up Order</title>
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


<p>I hope you are having an amazing day.</p>

<p>I found a Market Center SET UP order and wanted you to know right away. &nbsp;The OrderNo is ' + @OrderNo + '. &nbsp;Here is the link to the order on the intranet - ' + @IntranetOrderLink + '</p>

<p>
	Here are the options the customer requested:&nbsp;' + @SpecifiedOptions + '
</p>

<p>Go Make us proud! &nbsp;Love,&nbsp;</p>

<p><strong>Buttons</strong></p>

<p>
	<br>
</p>
	</body>
	</html>

	'


	---Dont send more than 1 email to the same 
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSetupAlertEmailLog WHERE RecipientEmail = @Recipient AND OrderNo = @OrderNo AND AlertType = 'Market Center Setup')
	BEGIN



    /* 
        original Bobby Code
        Problem: cant have reply_to set to bobby@gogbs.com
        Fix: use an alias associated to svc_sql@gogbs.com,
            added CC Users: @copy_recipients
					EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'SQLAlerts',  
						@recipients =  'brian@gogbs.com;ian@gogbs.com;Abe@gogbs.com;marketcenterschedule@gogbs.com',
						@copy_recipients= 'bobby@gogbs.com',
						@subject = @subject ,
						@body = @tableHTML,
						@body_format = 'HTML';

    */
					SET @subject = @OrderNo + ' ' +  'Market Center Setup'
                   -- Set @recipient = 'jeremy@gogbs.com'
					Set @recipient = 'brian@gogbs.com;ian@gogbs.com;Abe@gogbs.com;marketcenterschedule@gogbs.com;jeremy@gogbs.com'
						EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'SQLAlerts',  
						@recipients =  @recipient,
						@reply_to = 'sqlNotification@gogbs.com',
                        @copy_recipients = 'bobby@gogbs.com',
						@subject = @subject ,
						@body = @tableHTML,
						@body_format = 'HTML';

					--Log sending the email
					INSERT tblSetupAlertEmailLog (DateEmailSent,HTMLBody, RecipientEmail, OrderNo	)
					SELECT GETDATE(), 
						 @tableHTML, 
						 @Recipient,
						 @OrderNo
						
						 
			END 						 
				
			 ---Extra Safe: Remove the row from our process table...also would remove duplicates that shouldnt exist
			 DELETE @MCOrders WHERE OrderNo = @OrderNo

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