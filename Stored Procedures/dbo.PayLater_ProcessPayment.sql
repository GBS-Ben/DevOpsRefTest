








CREATE PROCEDURE [dbo].[PayLater_ProcessPayment]
AS
/*
-------------------------------------------------------------------------------
Author      Bobby 
Created     06/25/20
Purpose     Process Pay Laters
-------------------------------------------------------------------------------
Modification History

09/04/20	BJS changed to use @PaidOrders table
09/11/20	BJS made the order status in house
03/25/21	CKB, modifications for paymentrequestid and paymentstatus_queue
-------------------------------------------------------------------------------*/
BEGIN
		DECLARE @OrderOffset INT; 
		EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;

		DECLARE @PaidOrders TABLE (
			rownum int IDENTITY(1,1), 
			OrderNo varchar(50),
			PaymentRequestID uniqueidentifier
		)

		DECLARE @PaymentProcessDate DATETIME = GETDATE();


		INSERT @PaidOrders (OrderNo,PaymentRequestID)
		SELECT p.OrderNo ,p.PaymentRequestID
		FROM NopCommerce_tblPayLater p
		INNER JOIN dbo.tblPayLater gp ON gp.PaymentRequestID = p.PaymentRequestID
		WHERE ISNULL(p.AuthorizationTransactionCode,'') <> ISNULL(gp.AuthorizationTransactionCode,'')
			  OR ISNULL(p.AuthorizationTransactionID,'') <> ISNULL(gp.AuthorizationTransactionID,'')
			  OR ISNULL(p.AuthorizationTransactionResult,'') <> ISNULL(gp.AuthorizationTransactionResult,'')
			  OR ISNULL(p.PaidDateUtc,'') <> ISNULL(gp.PaidDateUtc,'')
		
		IF (SELECT COUNT(*) FROM @PaidOrders) = 0 RETURN;

		UPDATE  gp
		SET gp.AuthorizationTransactionCode = p.AuthorizationTransactionCode
		  , gp.AuthorizationTransactionID = p.AuthorizationTransactionID
		  , gp.AuthorizationTransactionResult = p.AuthorizationTransactionResult
		  , gp.PaidDateUtc = p.PaidDateUtc  
		  , gp.PaymentProcessDate = @PaymentProcessDate   
		FROM NopCommerce_tblPayLater p
		INNER JOIN dbo.tblPayLater gp ON gp.PaymentRequestID = p.PaymentRequestID -- AND gp.CustomerId = p.CustomerId
		INNER JOIN @PaidOrders po ON po.OrderNo = gp.OrderNo and po.PaymentRequestID = gp.PaymentRequestID

		INSERT INTO dbo.tblTransactions ( orderID, orderNo, paymentAmount, paymentDate, responseCode, responseDesc, 
		responseSummary, responseAmount, responseRRN, responseDate, responseOrderNo, responseFullCode, responseErrorDesc, responseErrorNo, 
		responseOtherInfo, ipAddress, cardNumber, cardExpiry, cardName, cardType, processTime, 
		paymentType, ActionCode, verify, traceNumber, InvoiceDescription)
		SELECT 
			pl.OrderId + @OrderOffset AS 'orderID', 
			pl.OrderNo AS 'orderNo', 
			pl.PaymentAmountRequired AS 'paymentAmount', 
			pl.PaymentProcessDate AS 'paymentDate', 
			1 AS 'responseCode', --placeholder value until we receive proper transactional data
			pl.AuthorizationTransactionResult AS 'responseDesc',
			CASE pl.AuthorizationTransactionResult
				WHEN NULL THEN 0
				ELSE 1
			END AS 'responseSummary',
			0 AS 'responseAmount', 0 AS 'responseRRN',  pl.PaymentProcessDate AS 'responseDate',
			SUBSTRING(pl.authorizationTransactionCode, CHARINDEX(',', pl.authorizationTransactionCode)+1, LEN(pl.authorizationTransactionCode) - CHARINDEX(',', pl.authorizationTransactionCode)) AS 'responseOrderNo', 
			pl.AuthorizationTransactionCode AS 'responseFullCode', 
			'' AS 'responseErrorDesc', '' AS 'responseErrorNo',
			--pl.CaptureTransactionID ,
			NULL	AS 'responseOtherInfo',
			NULL AS 'ipAddress', 
			NULL AS 'cardNumber', 
			NULL AS 'cardExpiry',
			NULL AS 'cardName', 
			pl.CardType AS 'cardType', 
			1 AS 'processTime',
			'Credit Card' AS 'paymentType',
			'AUTH_CAPTURE', 'S', 
			NULL AS 'traceNumber',
			'Pay Later'   --SELECT *
		FROM tblPayLater pl	
		INNER JOIN @PaidOrders po ON po.OrderNo = pl.OrderNo and po.PaymentRequestID = pl.PaymentRequestID
		LEFT JOIN tblTransactions t ON t.orderNo = pl.OrderNo and pl.AuthorizationTransactionCode = t.responseFullCode
		WHERE t.paymentID IS NULL
	
		UPDATE o
		SET paymentProcessed  = 1, 
			paymentSuccessful = 1 ,
			orderStatus = CASE WHEN o.orderStatus = 'Waiting For Payment' THEN  'In House' ELSE o.orderStatus END ,
			tabstatus = 'valid',
			paymentMethod='Credit Card'
		FROM tblOrders o
		INNER JOIN tblPayLater pl ON pl.OrderNo = o.orderNo
		INNER JOIN @PaidOrders po ON po.OrderNo = pl.OrderNo and po.PaymentRequestID = pl.PaymentRequestID



		--CREATE NOTE FOR PAYMENTS WE PROCESSED
		INSERT tbl_Notes (OrderId, jobNumber, notes, noteDate, author, proofNote_ref_PKID, notesType, deleteX, systemNote, ordersProductsID, switch_NoteType)
		SELECT OrderId, pl.OrderNo AS jobNumber, 'Pay Later Payment Processed' AS notes, GETDATE() AS noteDate, 'SQL' AS author, NULL AS proofNote_ref_PKID, 'order' AS notesType, '0' AS deleteX, NULL AS systemNote, 0 AS ordersProductsID, NULL AS switch_NoteType
		FROM dbo.tblPayLater pl
		INNER JOIN @PaidOrders po ON po.OrderNo = pl.OrderNo and po.PaymentRequestID = pl.PaymentRequestID

		INSERT INTO tblPaymentStatus_Queue (OrderNo)
		SELECT DISTINCT orderNo FROM @PaidOrders


		--EXEC msdb.dbo.sp_send_dbmail  
		--@profile_name = 'House of Magnets',  
		--@recipients = 'bobby@gogbs.com', -- @Recipient,
		--@reply_to= 'info@houseofmagnets.com',
		--@subject = @subject, --'Don’t run out! Reorder your business cards today.' ,
		--@body = @tableHTML,
		--@body_format = 'HTML';

		----Send an email for each Payment made

END



/****** Object:  StoredProcedure [dbo].[Dashboard_PayLaterOrders]    Script Date: 3/11/2021 12:02:44 PM ******/
SET ANSI_NULLS ON