














CREATE PROC [dbo].[InsertMigrationData]
@orderId INT,
@orderNo VARCHAR(50),
@Status VARCHAR(255) OUTPUT,
@ErrMsg NVARCHAR(4000) OUTPUT
AS 
BEGIN 
	BEGIN TRY
				--SELECT * INTO #tblCustomersgbs_BillingAddress_Stage FROM gbsstage.dbo.tblCustomers_BillingAddress_Stage WHERE 1=0
				--SELECT * INTO #tblCustomers_ShippingAddress_Stage FROM gbsstage.dbo.tblCustomers_ShippingAddress_Stage WHERE 1=0
				--SELECT * INTO #tblCustomers_Stage FROM gbsstage.dbo.tblCustomers_Stage WHERE 1=0
				--SELECT * INTO #tbl_Notes_Stage FROM gbsstage.dbo.tbl_Notes_Stage WHERE 1=0
				--SELECT * INTO #tblOrders_Products_Stage FROM gbsstage.dbo.tblOrders_Products_Stage WHERE 1=0
				--SELECT * INTO #tblOrders_Stage FROM gbsstage.dbo.tblOrders_Stage WHERE 1=0
				--SELECT * INTO #tblOrdersProducts_productOptions_NOP_ProductMove_Stage FROM gbsstage.dbo.tblOrdersProducts_productOptions_NOP_ProductMove_Stage WHERE 1=0
				--SELECT * INTO #tblOrdersProducts_ProductOptions_Stage FROM gbsstage.dbo.tblOrdersProducts_ProductOptions_Stage WHERE 1=0
				--SELECT * INTO #tblTransactions_Stage FROM gbsstage.dbo.tblTransactions_Stage WHERE 1=0
				--SELECT * INTO #tblVouchers_Stage FROM gbsstage.dbo.tblVouchers_Stage WHERE 1=0
				--SELECT * INTO #tblVouchersSales_Stage FROM gbsstage.dbo.tblVouchersSales_Stage WHERE 1=0
				--SELECT * INTO #tblVouchersSalesUse_Stage FROM gbsstage.dbo.tblVouchersSalesUse_Stage WHERE 1=0
				--SELECT * INTO #tblVoucherUse_Stage FROM gbsstage.dbo.tblVoucherUse_Stage WHERE 1=0


		SET IDENTITY_INSERT dbo.tblCustomers ON

		INSERT INTO [dbo].[tblCustomers]
           ([CustomerID],[firstName],[surname],[company],[street],[street2],[suburb],[postCode],[state],[country],[phone],[fax],[mobilePhone],[email],[website],[login],[customerPassword],[newsletter]
           ,[dnc],[po],[monthlyBill],[membershipType],[membershipNo],[title],[coordID],[CID],[shipping],[legit],[beforeCutoff],[sUserDefined],[orderNoJF],[typeJF],[PSCID],[created_on]
           ,[modified_on],[dusa],[CustomerGuid])
		SELECT  [CustomerID],[firstName],[surname],[company],[street],[street2],[suburb],[postCode],[state],[country],[phone],[fax],[mobilePhone],[email],[website],[login],[customerPassword],[newsletter]
           ,[dnc],[po],[monthlyBill],[membershipType],[membershipNo],[title],[coordID],[CID],[shipping],[legit],[beforeCutoff],[sUserDefined],[orderNoJF],[typeJF],[PSCID],[created_on]
           ,[modified_on],[dusa],[CustomerGuid]
		FROM #tblCustomers_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCustomers] c WHERE s.CustomerId = c.CustomerId);

		SET IDENTITY_INSERT dbo.tblCustomers OFF

		UPDATE b
		SET Billing_FirstName = ISNULL(b.Billing_FirstName, c.FirstName)
		, Billing_Surname = ISNULL(b.Billing_Surname,c.Surname)
		FROM [#tblCustomers_BillingAddress_Stage] b
		INNER JOIN tblCustomers c ON b.customerId = c.customerID

		UPDATE b
		SET Shipping_FirstName = ISNULL(b.Shipping_FirstName, c.FirstName)
		, Shipping_Surname = ISNULL(b.Shipping_Surname,c.Surname)
		FROM [#tblCustomers_ShippingAddress_Stage] b
		INNER JOIN tblCustomers c ON b.customerId = c.customerID

		UPDATE #tblOrders_Stage
		SET 
		Billing_Company = LEFT(b.Billing_Company, 100),
		Billing_FirstName = LEFT(b.Billing_FirstName, 50),
		Billing_Surname = LEFT(b.Billing_Surname, 50),
		Billing_Street = LEFT(b.Billing_Street, 100),
		Billing_Street2 = LEFT(b.Billing_Street2, 100),
		Billing_Suburb = LEFT(b.Billing_Suburb, 50),
		Billing_State = LEFT(b.Billing_State,50),
		Billing_PostCode = LEFT(b.Billing_PostCode,15),
		Billing_Country = LEFT(b.Billing_Country,50),
		Billing_Phone = LEFT(b.Billing_Phone,10),
		shipping_Company = LEFT(s.shipping_Company, 100),
		shipping_FirstName = LEFT(s.shipping_FirstName, 50),
		shipping_Surname = LEFT(s.shipping_Surname, 50),
		shipping_Street = LEFT(s.shipping_Street, 100),
		shipping_Street2 = LEFT(s.shipping_Street2, 100),
		shipping_Suburb = LEFT(s.shipping_Suburb, 50),
		shipping_State = LEFT(s.shipping_State, 50),
		shipping_PostCode = LEFT(s.shipping_PostCode, 15),
		shipping_Country = LEFT(s.shipping_Country, 50),
		shipping_Phone = LEFT(s.shipping_Phone,10)--only update the shipping number if it is null
		FROM #tblOrders_Stage a
		INNER JOIN #tblNOP_Order_RIP c --CBFilter
			ON c.GBSOrderId = a.orderNo
		LEFT JOIN #tblCustomers_BillingAddress_Stage b
			ON a.orderNo = b.orderNo
		LEFT JOIN #tblCustomers_ShippingAddress_Stage s
			ON a.orderNo = s.orderNo


		INSERT INTO [dbo].[tblCustomers_BillingAddress]
           ([CustomerID],[Billing_NickName],[Billing_Company],[Billing_FirstName],[Billing_Surname],[Billing_Street],[Billing_Street2],[Billing_Suburb],[Billing_State],[Billing_PostCode]
           ,[Billing_Country],[Billing_Phone],[Billing_FullName],[NameOnCard],[CardNumber],[CardExpMonth],[CardExpYear],[CardCCV],[Primary_Address],[orderNo],[deletex])
		SELECT [CustomerID],[Billing_NickName],[Billing_Company],[Billing_FirstName],[Billing_Surname],[Billing_Street],[Billing_Street2],[Billing_Suburb],[Billing_State],[Billing_PostCode]
           ,[Billing_Country],[Billing_Phone],[Billing_FullName],[NameOnCard],[CardNumber],[CardExpMonth],[CardExpYear],[CardCCV],[Primary_Address],[orderNo],[deletex]
		  FROM [dbo].[#tblCustomers_BillingAddress_Stage] s
		  WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCustomers_BillingAddress] ba WHERE s.orderNo = ba.orderNo);


		INSERT INTO [dbo].[tblCustomers_ShippingAddress]
           ([ShippingAddressID_Remote],[CustomerID],[Shipping_NickName],[Shipping_Company],[Shipping_FirstName],[Shipping_Surname],[Shipping_Street],[Shipping_Street2],[Shipping_Suburb]
           ,[Shipping_State],[Shipping_PostCode],[Shipping_Country],[Shipping_Phone],[Shipping_FullName],[Primary_Address],[Address_Type],[orderNo],[szip_trim],[created_on],[modified_on]
           ,[isValidated],[rdi],[returnCode],[addrExists],[UPSRural])
		SELECT  [ShippingAddressID_Remote],[CustomerID],[Shipping_NickName],[Shipping_Company],[Shipping_FirstName],[Shipping_Surname],[Shipping_Street],[Shipping_Street2],[Shipping_Suburb]
           ,[Shipping_State],[Shipping_PostCode],[Shipping_Country],[Shipping_Phone],[Shipping_FullName],[Primary_Address],[Address_Type],[orderNo],[szip_trim],[created_on],[modified_on]
           ,[isValidated],[rdi],[returnCode],[addrExists],[UPSRural]
		FROM #tblCustomers_ShippingAddress_Stage s	
		  WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCustomers_ShippingAddress] sa WHERE s.orderNo = sa.orderNo);


		INSERT INTO [dbo].[tbl_Notes]([orderID],[jobNumber],[notes],[noteDate],[author],[proofNote_ref_PKID],[notesType],[deleteX],[systemNote],[ordersProductsID],[switch_NoteType])
		SELECT [orderID],[jobNumber],[notes],[noteDate],[author],[proofNote_ref_PKID],[notesType],[deleteX],[systemNote],[ordersProductsID],[switch_NoteType]
		FROM #tbl_Notes_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tbl_Notes] n WHERE s.orderID = n.orderID);

		SET IDENTITY_INSERT tblOrders_Products ON

		INSERT INTO dbo.tblOrders_Products ([ID],[ordersProductsGUID],[orderID],[productID],[optionID],[productName],[productCodeOLD],[productIndex],[productPrice],[productQuantity],[gluonName],[dateInput],[inStock],[delivered],[deliveredDate],[deliveryTrackingNumber],[status],[deletex],[OSID],[NBPRINT],[productType],[switch_create],[switch_createDate],[stream],[streamPrintDate],[groupID],[created_on],[modified_on],[fastTrak],[fastTrak_productType],[fastTrak_newQTY],[fastTrak_resubmit],[fastTrak_reimage],[fastTrak_imageFile_exported],[fastTrak_imageFile_exportedOn],[fastTrak_preventImposition],[fastTrak_preventLabel],[fastTrak_preventTicket],[fastTrak_labelGeneratedOn],[fastTrak_ticketGeneratedOn],[fastTrak_imposed],[fastTrak_imposedOn],[fastTrak_completed],[fastTrak_completedOn],[fastTrak_status],[fastTrak_status_lastModified],[fastTrak_shippingLabelOption1],[fastTrak_shippingLabelOption2],[fastTrak_shippingLabelOption3],[fastTrak_imprintName],[proofVersion],[processType],[pnp_create],[pnp_createDate],[switchMerge_create],[NOP_productCode_ALT],[CustomerEmail],[AgentName],[isValidated],[GbsCompanyId],[isPrinted],[productCode])
		SELECT [id],[ordersProductsGUID],[orderID],[productID],[optionID],[productName],[productCodeOLD],[productIndex],[productPrice],[productQuantity],[gluonName],[dateInput],[inStock],[delivered],[deliveredDate],[deliveryTrackingNumber],[status],[deletex],[OSID],[NBPRINT],[productType],[switch_create],[switch_createDate],[stream],[streamPrintDate],[groupID],[created_on],[modified_on],[fastTrak],[fastTrak_productType],[fastTrak_newQTY],[fastTrak_resubmit],[fastTrak_reimage],[fastTrak_imageFile_exported],[fastTrak_imageFile_exportedOn],[fastTrak_preventImposition],[fastTrak_preventLabel],[fastTrak_preventTicket],[fastTrak_labelGeneratedOn],[fastTrak_ticketGeneratedOn],[fastTrak_imposed],[fastTrak_imposedOn],[fastTrak_completed],[fastTrak_completedOn],[fastTrak_status],[fastTrak_status_lastModified],[fastTrak_shippingLabelOption1],[fastTrak_shippingLabelOption2],[fastTrak_shippingLabelOption3],[fastTrak_imprintName],[proofVersion],[processType],[pnp_create],[pnp_createDate],[switchMerge_create],[NOP_productCode_ALT],[CustomerEmail],[AgentName],[isValidated],[GbsCompanyId],[isPrinted],[productCode]
		FROM #tblOrders_Products_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM  dbo.tblOrders_Products op WHERE s.ID = op.ID)
		  AND s.ID IS NOT null;
		
		--EXEC Migration_Patcher @Status OUTPUT, @ErrMsg OUTPUT

		SET IDENTITY_INSERT tblOrders_Products OFF

		INSERT INTO dbo.tblOrders_Products ([ordersProductsGUID],[orderID],[productID],[optionID],[productName],[productCodeOLD],[productIndex],[productPrice],[productQuantity],[gluonName],[dateInput],[inStock],[delivered],[deliveredDate],[deliveryTrackingNumber],[status],[deletex],[OSID],[NBPRINT],[productType],[switch_create],[switch_createDate],[stream],[streamPrintDate],[groupID],[created_on],[modified_on],[fastTrak],[fastTrak_productType],[fastTrak_newQTY],[fastTrak_resubmit],[fastTrak_reimage],[fastTrak_imageFile_exported],[fastTrak_imageFile_exportedOn],[fastTrak_preventImposition],[fastTrak_preventLabel],[fastTrak_preventTicket],[fastTrak_labelGeneratedOn],[fastTrak_ticketGeneratedOn],[fastTrak_imposed],[fastTrak_imposedOn],[fastTrak_completed],[fastTrak_completedOn],[fastTrak_status],[fastTrak_status_lastModified],[fastTrak_shippingLabelOption1],[fastTrak_shippingLabelOption2],[fastTrak_shippingLabelOption3],[fastTrak_imprintName],[proofVersion],[processType],[pnp_create],[pnp_createDate],[switchMerge_create],[NOP_productCode_ALT],[CustomerEmail],[AgentName],[isValidated],[GbsCompanyId],[isPrinted],[productCode])
		SELECT [ordersProductsGUID],[orderID],[productID],[optionID],[productName],[productCodeOLD],[productIndex],[productPrice],[productQuantity],[gluonName],[dateInput],[inStock],[delivered],[deliveredDate],[deliveryTrackingNumber],[status],[deletex],[OSID],[NBPRINT],[productType],[switch_create],[switch_createDate],[stream],[streamPrintDate],[groupID],[created_on],[modified_on],[fastTrak],[fastTrak_productType],[fastTrak_newQTY],[fastTrak_resubmit],[fastTrak_reimage],[fastTrak_imageFile_exported],[fastTrak_imageFile_exportedOn],[fastTrak_preventImposition],[fastTrak_preventLabel],[fastTrak_preventTicket],[fastTrak_labelGeneratedOn],[fastTrak_ticketGeneratedOn],[fastTrak_imposed],[fastTrak_imposedOn],[fastTrak_completed],[fastTrak_completedOn],[fastTrak_status],[fastTrak_status_lastModified],[fastTrak_shippingLabelOption1],[fastTrak_shippingLabelOption2],[fastTrak_shippingLabelOption3],[fastTrak_imprintName],[proofVersion],[processType],[pnp_create],[pnp_createDate],[switchMerge_create],[NOP_productCode_ALT],[CustomerEmail],[AgentName],[isValidated],[GbsCompanyId],[isPrinted],[productCode]
		FROM #tblOrders_Products_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM  dbo.tblOrders_Products op WHERE s.ID = op.ID)
		  AND s.ID IS NULL;

		UPDATE oppo
		SET ordersProductsId = op.ID
		FROM #tblOrdersProducts_ProductOptions_Stage oppo
		INNER JOIN dbo.tblOrders_Products op ON oppo.ordersProductsGUID = op.ordersProductsGUID
		WHERE oppo.ordersProductsID IS NULL
		

		SET IDENTITY_INSERT tblOrders ON

		INSERT INTO [dbo].[tblOrders]([orderId],[orderNo],[orderAck],[orderForPrint],[orderJustPrinted],[orderBatchedDate],[orderPrintedDate],[orderCancelled],[customerID],[membershipID],[membershipType],[sessionID],[orderDate],[orderTotal],[taxAmountInTotal],[taxAmountAdded],[taxDescription],[shippingAmount],[shippingMethod],[shippingDesc],[shipDate],[feeAmount],[paymentAmountRequired],[paymentMethod],[paymentMethodID],[paymentMethodRDesc],[paymentMethodIsCC],[paymentMethodIsSC],[cardNumber],[cardExpiryMonth],[cardExpiryYear],[cardName],[cardType],[cardCCV],[cardStoreInfo],[shipping_Company],[shipping_FirstName],[shipping_Surname],[shipping_Street],[shipping_Street2],[shipping_Suburb],[shipping_State],[shipping_PostCode],[shipping_Country],[shipping_Phone],[blindShip],[specialInstructions],[paymentProcessed],[paymentProcessedDate],[paymentSuccessful],[ipAddress],[referrer],[archived],[messageToCustomer],[reasonforpurchase],[status],[statusTemp],[orderStatus],[statusDate],[orderType],[emailStatus],[actMigStatus],[tabStatus],[importFlag],[specialOffer],[storeID],[coordIDUsed],[brokerOwnerIDUsed],[importDate],[invRefDate],[repName],[grpOrder],[lastStatusUpdate],[promoName],[sampler],[shipZone],[ResCom],[orderWeight],[com],[res],[aReg],[bReg],[a1],[stockShipFirst],[calcOrderTotal],[calcTransTotal],[calcProducts],[calcOPPO],[calcVouchers],[calcCredits],[calcBadges],[displayPaymentStatus],[created_on],[modified_on],[billingAddressID],[billing_Company],[billing_FirstName],[billing_Surname],[billing_Street],[billing_Street2],[billing_Suburb],[billing_State],[billing_PostCode],[billing_Country],[billing_Phone],[cartVersion],[shippingAddressID],[a1_expediteShipFlag],[billingReference],[a1_carrier],[a1_mailClass],[a1_mailPieceShape],[a1_processed],[a1_printed],[cubic],[a1_conditionID],[R2P],[NOP],[ArrivalDate])
		SELECT [orderId],[orderNo],[orderAck],[orderForPrint],[orderJustPrinted],[orderBatchedDate],[orderPrintedDate],[orderCancelled],[customerID],[membershipID],[membershipType],[sessionID],[orderDate],[orderTotal],[taxAmountInTotal],[taxAmountAdded],[taxDescription],[shippingAmount],[shippingMethod],[shippingDesc],[shipDate],[feeAmount],[paymentAmountRequired],[paymentMethod],[paymentMethodID],[paymentMethodRDesc],[paymentMethodIsCC],[paymentMethodIsSC],[cardNumber],[cardExpiryMonth],[cardExpiryYear],[cardName],[cardType],[cardCCV],[cardStoreInfo],[shipping_Company],[shipping_FirstName],[shipping_Surname],[shipping_Street],[shipping_Street2],[shipping_Suburb],[shipping_State],[shipping_PostCode],[shipping_Country],[shipping_Phone],[blindShip],[specialInstructions],[paymentProcessed],[paymentProcessedDate],[paymentSuccessful],[ipAddress],[referrer],[archived],[messageToCustomer],[reasonforpurchase],[status],[statusTemp],[orderStatus],[statusDate],[orderType],[emailStatus],[actMigStatus],[tabStatus],[importFlag],[specialOffer],[storeID],[coordIDUsed],[brokerOwnerIDUsed],[importDate],[invRefDate],[repName],[grpOrder],[lastStatusUpdate],[promoName],[sampler],[shipZone],[ResCom],[orderWeight],[com],[res],[aReg],[bReg],[a1],[stockShipFirst],[calcOrderTotal],[calcTransTotal],[calcProducts],[calcOPPO],[calcVouchers],[calcCredits],[calcBadges],[displayPaymentStatus],[created_on],[modified_on],[billingAddressID],[billing_Company],[billing_FirstName],[billing_Surname],[billing_Street],[billing_Street2],[billing_Suburb],[billing_State],[billing_PostCode],[billing_Country],[billing_Phone],[cartVersion],[shippingAddressID],[a1_expediteShipFlag],[billingReference],[a1_carrier],[a1_mailClass],[a1_mailPieceShape],[a1_processed],[a1_printed],[cubic],[a1_conditionID],[R2P],[NOP],[ArrivalDate]
		FROM #tblOrders_Stage s
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblOrders] o WHERE s.orderID = o.orderID);

		SET IDENTITY_INSERT tblOrders OFF


		INSERT INTO [dbo].[tblOrdersProducts_ProductOptions]([ordersProductsID],[ordersProductsGUID],[optionID],[optionCaption],[optionPrice],[optionGroupCaption],[textValue],[deletex],[optionQty],[created_on],[modified_on])
		SELECT  [ordersProductsID],[ordersProductsGUID],[optionID],[optionCaption],[optionPrice],[optionGroupCaption],[textValue],[deletex],[optionQty],[created_on],[modified_on]
		FROM #tblOrdersProducts_ProductOptions_Stage s
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM  tblOrdersProducts_ProductOptions oppo WHERE s.ordersProductsID = oppo.ordersProductsID and s.optionID = oppo.optionID and s.deletex = oppo.deletex);


		-- assign workflow if there is one
		UPDATE op
		SET workflowID = w.workflowID
		FROM #tblOrders_Products_stage ops
		INNER JOIN tblOrders_products op on ops.ordersProductsGUID = op.ordersProductsGUID
		INNER JOIN OPIDSwitchFlow osf on op.id = osf.OPID
		INNER JOIN gbsController_workFlow w on osf.switchflow = w.workflowName

		INSERT INTO [dbo].[tblTransactions]([orderID],[orderNo],[paymentAmount],[paymentDate],[responseCode],[responseDesc],[responseSummary],[responseAmount],[responseRRN],[responseDate],[responseOrderNo],[responseErrorDesc],[responseErrorNo],[responseOtherInfo],[ipAddress],[cardNumber],[cardExpiry],[cardName],[cardType],[processTime],[checkNumber],[paymentType],[batchDate],[AuthorizationCode],[AddressVerificationStatus],[InvoiceDescription],[ActionCode],[deletex],[dupe],[verify],[mUpdated],[PSU_status],[traceNumber],[responseFullCode])
		SELECT [orderID],[orderNo],[paymentAmount],[paymentDate],[responseCode],[responseDesc],[responseSummary],[responseAmount],[responseRRN],[responseDate],[responseOrderNo],[responseErrorDesc],[responseErrorNo],[responseOtherInfo],[ipAddress],[cardNumber],[cardExpiry],[cardName],[cardType],[processTime],[checkNumber],[paymentType],[batchDate],[AuthorizationCode],[AddressVerificationStatus],[InvoiceDescription],[ActionCode],[deletex],[dupe],[verify],[mUpdated],[PSU_status],[traceNumber],[responseFullCode]
		FROM #tblTransactions_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblTransactions] t WHERE s.orderID = t.orderID ) ;


		SET IDENTITY_INSERT tblVouchers ON

		INSERT INTO [dbo].[tblVouchers]([voucherID],[voucherCode],[voucherRecipient],[initialAmount],[remainingAmount],[dateCreated],[orderID],[customerID],[isDeleted],[isPaid])
		SELECT DISTINCT [voucherID],[voucherCode],[voucherRecipient],[initialAmount],[remainingAmount],[dateCreated],[orderID],[customerID],[isDeleted],[isPaid]
		FROM #tblVouchers_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblVouchers] v WHERE s.voucherID = v.voucherID) ;

		SET IDENTITY_INSERT tblVouchers OFF


		SET IDENTITY_INSERT tblVouchersSales ON

		INSERT INTO [dbo].[tblVouchersSales]([sVoucherID],[sVoucherCode],[sVoucherDiscountType],[sVoucherAmount],[sVoucherComment],[dateCreated],[activationDate],[expiryDate],[sVoucherMinSpend],[isDeleted])
		SELECT DISTINCT [sVoucherID],[sVoucherCode],[sVoucherDiscountType],[sVoucherAmount],[sVoucherComment],[dateCreated],[activationDate],[expiryDate],[sVoucherMinSpend],[isDeleted]
		FROM #tblVouchersSales_Stage s		
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblVouchersSales] vs WHERE s.sVoucherID = vs.sVoucherID) ;

		SET IDENTITY_INSERT tblVouchersSales OFF

		INSERT INTO [dbo].[tblVouchersSalesUse]([sVoucherID],[sVoucherCode],[orderID],[sVoucherAmountApplied],[DiscountAmount],[vDateTime],[isDeleted])
		SELECT [sVoucherID],[sVoucherCode],[orderID],[sVoucherAmountApplied],[DiscountAmount],[vDateTime],[isDeleted]
		FROM #tblVouchersSalesUse_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblVouchersSalesUse su WHERE s.sVoucherID = su.sVoucherID AND s.orderID = su.orderID) ;

		INSERT INTO [dbo].[tblVoucherUse]([voucherID],[orderID],[valueApplied],[valueRemaining],[vDateTime])
		SELECT [voucherID],[orderID],[valueApplied],[valueRemaining],[vDateTime]
		FROM #tblVoucherUse_Stage s	
		WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblVoucherUse vu WHERE s.voucherID = vu.voucherID AND s.orderID = vu.orderID) ;

		EXECUTE [dbo].[usp_PaymentStatus] @orderNo

		--	successful tranx
		UPDATE a
		SET orderStatus = 'In House', 
				tabStatus = 'Valid'
		FROM  dbo.tblOrders a
		WHERE paymentProcessed = 1 
			AND paymentSuccessful = 1 
			and a.orderNo = @orderNo

		--2. WFP
		UPDATE a
		SET orderStatus = 'Waiting For Payment' 
			, tabStatus = 'Offline'
		FROM  dbo.tblOrders a
		WHERE paymentProcessed = 0 
			AND paymentSuccessful = 0 
			AND paymentMethodID <> 8
			AND paymentMethodID <> 9
			and a.orderNo = @orderNo

		--3. Failures
		UPDATE a
		SET orderStatus = 'Failed' , tabStatus = 'Failed'
		FROM  dbo.tblOrders a
		WHERE paymentProcessed = 1 
			AND paymentSuccessful = 0 
			AND a.OrderTotal > 0
			and a.orderNo = @orderNo

		--3.5. Misc Failures
		;WITH fcte
		AS 
		(
		SELECT DISTINCT orderNo
			FROM dbo.tblTransactions
			WHERE responseCode IN ('43', '05', 'PB', 'M1', '74', '43', '14', '04')
				AND orderNo = @orderNo
		)
		UPDATE a
		SET orderStatus = 'Failed', 
			tabStatus = 'Failed'
		FROM  dbo.tblOrders a
		INNER JOIN dbo.tblTransactions t on a.orderNo = t.orderNo
		WHERE responseCode IN ('43', '05', 'PB', 'M1', '74', '43', '14', '04')
				AND a.orderNo = @orderNo

		--4. MB
		UPDATE a
		SET orderStatus = 'In House'
			, tabStatus = 'Valid'
		FROM  dbo.tblOrders a
		WHERE  paymentMethod = 'Monthly Billing'
			and a.orderNo = @orderNo

		--4.5. PO\MB
		UPDATE a
		SET orderStatus = 'In House', tabStatus = 'Valid',
			paymentProcessed = 1, paymentSuccessful = 1
		FROM  dbo.tblOrders a
		WHERE  orderStatus <> 'cancelled' 
			AND orderStatus <> 'failed'
			AND (paymentMethod LIKE '%Purchase%' OR paymentMethod LIKE '%PO%' or paymentMethod = 'Monthly Billing')
			and a.orderNo = @orderNo

		UPDATE a
		SET orderStatus = 'In House', tabStatus = 'Valid'
		FROM  dbo.tblOrders a
		WHERE  paymentMethod = 'Monthly Billing'
			and a.orderNo = @orderNo
		
		UPDATE a
		SET orderStatus = 'In House', tabStatus = 'Valid',
		paymentProcessed = 1, paymentSuccessful = 1
		FROM  dbo.tblOrders a
		WHERE orderStatus <> 'cancelled' AND orderStatus <> 'failed'
			AND (paymentMethod LIKE '%Purchase%' OR paymentMethod LIKE '%PO%' or paymentMethod = 'Monthly Billing')
			and a.orderNo = @orderNo

		--_________________________________________________________________________________________ UPDATE ArrivalDate
		--main update:

		---REMOVE AND ADD TO ANOTHER BATCH 
		UPDATE a
		SET ArrivalDate = (SELECT TOP 1 [DATE] 
		FROM dateDimension 
		WHERE DateKey IN (
					SELECT TOP 5 DateKey 
					FROM dateDimension 
					WHERE [DATE] > (SELECT orderDate
									FROM tblOrders
									WHERE orderNo = a.orderNo)
					AND isWeekend = 0
					AND isHoliday = 0)
		ORDER BY [DATE] DESC)
		FROM dbo.tblOrders a
		INNER JOIN dbo.tblOrders_Products op ON a.orderID = op.orderID
		INNER JOIN dbo.tblOrdersProducts_productOptions oppo ON op.ID = oppo.ordersProductsID
		WHERE oppo.deleteX <> 'yes'
		AND oppo.optionCaption = 'Express Production'
		AND oppo.textValue LIKE 'Yes%'
		AND a.ArrivalDate IS NULL
		AND a.orderNo = @orderNo

		--if there is a hiccup in the system, sometimes arrivalDate gets set 30 days in advance. This resets arrivaldate for another chance to get it right on next run:
		UPDATE dbo.tblOrders
		SET ArrivalDate = NULL
		WHERE DATEDIFF(DD, orderDate, CONVERT(DATETIME, ArrivalDate)) > 13
		AND ArrivalDate IS NOT NULL
		AND OrderStatus NOT IN ('Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
		AND orderNo = @orderNo

		----Finish Up - TODO fix this
		UPDATE a
		SET orderStatus = 'In House', tabStatus = 'Valid'
		FROM  dbo.tblOrders a
		WHERE a.orderStatus = 'MIGZ'
		AND a.NOP = 1
		AND OrderId = @orderId

		----MIG MISC SHOULD RUN
		EXECUTE Setting_Update 'Run MigMisc' , '1'  --MIGMISC NEEDS TO RUN.

		--EXEC Migration_InsertOrderView @OrderId, @Status OUTPUT, @ErrMsg OUTPUT	


		--- INSERT OPIDs INTO ORDERFOLDER CREATION QUEUE
		INSERT INTO [dbo].[tblOrderFolderQueue] (orderId, orderNo, ordersProductsID,optionJSON)
		SELECT DISTINCT o.orderId, o.orderNo, op.ID, (SELECT oppo.optioncaption,textvalue 
														FROM #tblOrdersProducts_ProductOptions_Stage oppo
														LEFT JOIN tblproductoptions po ON oppo.optionid = po.optionID
														WHERE (po.displayonjobticket = 1 or oppo.optionid = 577) and oppo.deletex <> 'yes'
														AND oppo.ordersProductsId = op.id and (select count(*) 
																							   from #tblOrdersProducts_ProductOptions_Stage 
																							   where (optionCaption = 'design fee' and textValue <> 'no')
																							      or (optionCaption = 'Previous Order Number')
																								  or (optionCaption = 'Change Fee' and textValue = 'Yes')
																							  ) > 0
														FOR JSON PATH)
		FROM tblOrders o
		INNER JOIN tblOrders_Products op on o.orderID = op.orderID
		WHERE o.orderNo = @orderNo

		SELECT IDENTITY(INT,1,1) as ID,s.ID AS opid,op.workflowID
		INTO #tempwork
		FROM #tblOrders_Products_Stage s	
		INNER JOIN tblOrders_Products  op on s.id = op.id
		WHERE op.workFlowID IS NOT NULL

		-- start next steps
		DECLARE @StepCount INT = 0;
		DECLARE @CurrStep INT = 1;
		DECLARE @CurrID INT;
		DECLARE @OPID INT;
		DECLARE @SQL NVARCHAR(2000);

		SET @StepCount = (SELECT count(*) FROM #tempwork);


		WHILE @CurrStep <= @StepCount  
		BEGIN
			
			SET @OPID = (SELECT OPID FROM #tempwork WHERE id = @CurrStep);
			
			IF @OPID IS NOT NULL
			BEGIN
				SET @SQL = 'EXEC gbsController_Workflow_Start @OPID=' + cast(@OPID as varchar(10));
				EXEC (@SQL);
			END

			SET @SQL ='';
			SET @OPID = 0;
			SET @CurrStep = @CurrStep+ 1;
		END

			--- FINALIZE
		SET @Status = 'Success'

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;  

		SELECT @Status = 'Fail', @ErrMsg = 'InsertMigrationData - '  +  ERROR_MESSAGE();
		RAISERROR (@ErrMsg,11,1);
	END CATCH



END