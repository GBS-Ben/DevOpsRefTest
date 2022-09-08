



CREATE PROCEDURE [dbo].[usp_PaymentStatus] 
	 @orderNo VARCHAR(255)
AS

/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     01/26/08
Purpose     Calcs payment values so that all post-web changes to an order and its contents are reflected.
Example  	exec [usp_PaymentStatus] 'HOM1107530'
------------------------------------------------------------------------------
Modification History

03/23/17		clean up, jf.
01/12/18		Failed Order exclusions; prevent payment status from becoming "good" on failed orders, BS.
11/01/18		updated throughout. see [usp_PaymentStatus_110118_01BAKJF] for safe reversion, jf.
11/05/18		Added @calcOPPO_Bling section, jf.
12/13/18		BS, changed to a table variable and 1 tblOrders update at the end
02/18/19		JF, pulled ":" out of "Partial Payment:" checks below, because NOP doesn't have the colon. Neat.
03/23/21		JF, added paylog at end of proc
04/27/21		CKB, Markful
-------------------------------------------------------------------------------
*/

BEGIN TRY

	IF @orderNo IS NULL
	BEGIN
	SET @orderNo = 'MRK999999'
	END

	DECLARE @OrderRecord TABLE (
		[orderID] [int] NOT NULL,
		[orderNo] [nvarchar](50) NULL,
		[calcOrderTotal] [money] NULL,
		[calcTransTotal] [money] NULL,
		[calcProducts] [money] NULL,
		[calcOPPO] [money] NULL,
		[calcVouchers] [money] NULL,
		[calcCredits] [money] NULL,
		[calcBadges] [int] NULL,
		[displayPaymentStatus] [varchar](50) NULL,
		[paymentMethod] [nvarchar](50) NULL,
		[orderStatus] [varchar](50) NULL,
		[statusDate] [datetime] NULL,
		[shippingAmount] [money] NULL,
		[taxAmountAdded] [money] NULL,
		[created_on] [datetime] NULL,
		[modified_on] [datetime] NULL
		) 

	INSERT @OrderRecord (	[orderID],[orderNo],[calcOrderTotal],[calcTransTotal],[calcProducts],[calcOPPO],
	[calcVouchers],[calcCredits],[calcBadges],[displayPaymentStatus],[created_on],[modified_on],[paymentMethod],[orderStatus],	[statusDate], [taxAmountAdded], [shippingAmount]) 
	SELECT [orderID],[orderNo],[calcOrderTotal],[calcTransTotal],[calcProducts],[calcOPPO],
		[calcVouchers],[calcCredits],[calcBadges],[displayPaymentStatus],[created_on],[modified_on],[paymentMethod],[orderStatus],	[statusDate], [taxAmountAdded], [shippingAmount]
	FROM tblOrders WHERE OrderNo = @orderNo


	DECLARE @calcProducts MONEY
	SET @calcProducts = (SELECT ISNULL(SUM(op.productPrice * op.productQuantity), 0) 
									FROM tblOrders_Products op WITH (NOLOCK)
									INNER JOIN tblOrders o WITH (NOLOCK) ON o.orderID = op.orderID
									WHERE op.deleteX <> 'yes' 
									AND o.orderNo = @orderNo)





	UPDATE @OrderRecord
	SET calcProducts = @calcProducts

	UPDATE @OrderRecord
	SET calcProducts = 0
	WHERE calcProducts < 0


	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--calcOPPO

	DECLARE @calcOPPO MONEY
			 ,@calcOPPO_PostCardQTY MONEY
			 ,@calcOPPO_Bling MONEY

	SET @calcOPPO = (SELECT ISNULL(SUM(CASE WHEN oppo.optionID = 617 and oppo.textValue like 'Yes%' and oppo.optionQTY < 100 THEN 5.00 ELSE oppo.optionPrice * oppo.optionQTY END), 0)
									FROM tblOrdersProducts_productOptions oppo 
									INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
									INNER JOIN tblOrders o ON op.orderID = o.orderID
									WHERE oppo.deleteX <> 'yes' 
									AND oppo.optionCaption <> 'Bling'
									AND oppo.optionID <> 529
									AND o.orderNo = @orderNo)


	SET @calcOPPO_PostCardQTY = (SELECT ISNULL(SUM(oppo.optionPrice * oppo.textValue), 0)
									FROM tblOrdersProducts_productOptions oppo 
									INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
									INNER JOIN tblOrders o ON op.orderID = o.orderID
									WHERE oppo.deleteX <> 'yes' 
									AND oppo.optionID = 529
									AND o.orderNo = @orderNo)

	SET @calcOPPO_Bling = (SELECT ISNULL(SUM(oppo.optionPrice * oppo.optionQTY), 0)
									FROM tblOrdersProducts_productOptions oppo 
									INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
									INNER JOIN tblOrders o ON op.orderID = o.orderID
									WHERE oppo.deleteX <> 'yes' 
									AND oppo.optionCaption = 'Bling'
									AND (oppo.textValue = '' OR oppo.textValue IS NULL)
									AND o.orderNo = @orderNo)

	UPDATE @OrderRecord
	SET calcOPPO =  @calcOPPO + @calcOPPO_PostCardQTY + @calcOPPO_Bling
	WHERE orderNo = @orderNo

	UPDATE @OrderRecord
	SET calcOPPO = 0
	WHERE calcOPPO < 0
	AND orderNo = @orderNo

	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--calcCredit

	DECLARE @calcCredits MONEY

	SET @calcCredits = (SELECT ISNULL(SUM(c.creditAmount), 0)
								  FROM tblCredits c
								  INNER JOIN tblOrders o ON c.creditOrderID = o.orderID 
								  WHERE o.orderNo = @orderNo)

	UPDATE @OrderRecord
	SET calcCredits = @calcCredits
	WHERE orderNo = @orderNo

	UPDATE @OrderRecord
	SET calcCredits = 0
	WHERE calcCredits < 0
	AND orderNo = @orderNo

	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--Vouchers

	DECLARE @calcVouchers MONEY
			 ,@valueApplied MONEY
			 ,@calcGiftCodes MONEY


	SET @calcVouchers = (SELECT ISNULL(SUM(ABS(vsu.sVoucherAmountApplied)), 0) 
								  FROM tblVouchersSalesUse vsu
								  INNER JOIN tblOrders o ON vsu.orderID = o.orderID
								  WHERE o.orderNo = @orderNo
								    AND isDeleted = 0)


	SET @valueApplied = (SELECT ISNULL(SUM(ABS(vu.valueApplied)), 0)  
								  FROM tblVoucherUse vu
								  INNER JOIN tblOrders o ON vu.orderID = o.orderID
								  WHERE o.orderNo = @orderNo)

	SET @calcGiftCodes = (SELECT ISNULL(SUM(ABS(op.productPrice * op.productQuantity)), 0)  
									FROM tblOrders_Products op
									INNER JOIN tblOrders o ON o.orderID = op.orderID
									WHERE op.productID = '-50' 
									AND op.deleteX <> 'yes' 
									AND o.orderNo = @orderNo)

	UPDATE @OrderRecord
	SET calcVouchers = @calcVouchers + @valueApplied + @calcGiftCodes
	WHERE orderNo = @orderNo

	UPDATE @OrderRecord
	SET calcVouchers = 0
	WHERE calcVouchers < 0
	AND orderNo = @orderNo

	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--calcOrderTotal

	UPDATE @OrderRecord
	SET calcOrderTotal = calcProducts + calcOPPO + shippingAmount + taxAmountAdded - calcCredits - calcVouchers
	WHERE orderNo = @orderNo
	AND orderNo = @orderNo

	UPDATE @OrderRecord
	SET calcOrderTotal = 0
	WHERE calcOrderTotal < 0
	AND orderNo = @orderNo

	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--calcTransTotal

	DECLARE @calcTransTotal MONEY

	SET @calcTransTotal = (SELECT ISNULL(SUM(t.paymentAmount), 0)
									 FROM tblTransactions t
									 WHERE t.actionCode NOT IN ('Void', 'Expired')
									 AND t.deleteX <> 'yes' 
									 AND (t.responseCode = '1' OR t.responseCode = '00')
									 AND t.orderNo = @orderNo)

	UPDATE @OrderRecord
	SET calcTransTotal = @calcTransTotal,
		 displayPaymentStatus = ISNULL(displayPaymentStatus, '')

	UPDATE @OrderRecord
	SET calcTransTotal = calcOrderTotal,
		 displayPaymentStatus = 'Good'
	WHERE paymentMethod = 'Monthly Billing'
	AND ISNULL(displayPaymentStatus, '') <> 'Good'

	UPDATE @OrderRecord
	SET calcTransTotal = calcOrderTotal,
		 displayPaymentStatus = 'Good'
	WHERE ISNULL(displayPaymentStatus, 0) <> 'Good'
		AND paymentMethod LIKE 'Purchase Order%'

	UPDATE @OrderRecord
	SET calcTransTotal = 0
	WHERE ISNULL(calcTransTotal, 0) <= 0

	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--displayPaymentStatus

	UPDATE @OrderRecord
	SET displayPaymentStatus = 'Waiting For Payment'
	WHERE  displayPaymentStatus <> 'Waiting For Payment'
		AND ROUND(calcTransTotal, 2) = 0.01
		AND paymentMethod NOT LIKE 'Purchase Order%'
		AND paymentMethod <> 'Monthly Billing' 

	UPDATE @OrderRecord
	SET displayPaymentStatus = 'Good'
	WHERE displayPaymentStatus <> 'Good'
	AND ROUND(calcOrderTotal, 2) = ROUND(calcTransTotal, 2)
	AND ROUND(calcOrderTotal, 2) <> 0.01
	AND orderStatus <> 'Failed'

	UPDATE @OrderRecord
	SET displayPaymentStatus = 'Credit Due'
	WHERE displayPaymentStatus <> 'Credit Due'
	AND ROUND(calcOrderTotal, 2) < ROUND(calcTransTotal, 2)
	AND paymentMethod NOT LIKE 'Purchase Order%'
	AND paymentMethod <> 'Monthly Billing'
	AND orderStatus <> 'Failed'

	UPDATE @OrderRecord
	SET displayPaymentStatus = 'Partial Payment Received'
	WHERE ROUND(calcOrderTotal, 2) > ROUND(calcTransTotal, 2)
	AND ROUND(calcTransTotal, 2) <> 0.01
		AND displayPaymentStatus <> 'Partial Payment Received'
		AND paymentMethod NOT LIKE 'Purchase Order%'
		AND paymentMethod <> 'Monthly Billing'
		AND orderStatus <> 'Failed'

	--Adjusted status for orders one penny off
	update @OrderRecord
	set displayPaymentStatus = 'Good'
	where abs(calcOrderTotal-calcTransTotal) < 0.02

	DECLARE @CurrentDate datetime2 = GETDATE();

	DECLARE @changePayment TABLE(
		oldPaymentStatus VARCHAR(30),
		newPaymentStatus VARCHAR(30))
	DECLARE @oldPaymentStatus VARCHAR(30)
	DECLARE @newPaymentStatus VARCHAR(30)
	
 
	UPDATE ord
	SET [calcOrderTotal] = o.[calcOrderTotal],
		[calcTransTotal] = o.[calcTransTotal],
		[calcProducts] = o.[calcProducts],
		[calcOPPO]  = o.[calcOPPO],
		[calcVouchers]  = o.[calcVouchers],
		[calcCredits] = o.[calcCredits],
		[displayPaymentStatus]  = o.[displayPaymentStatus],
		[paymentMethod] = o.[paymentMethod],
		[modified_on] = @CurrentDate
	OUTPUT deleted.displayPaymentStatus,
		   inserted.displayPaymentStatus
	INTO @changePayment
	FROM @OrderRecord o
	INNER JOIN tblOrders ord 
		ON ord.Orderid = o.orderID

	SELECT @oldPaymentStatus = oldpaymentStatus, @newPaymentStatus = newPaymentStatus FROM @changePayment

	IF (@oldPaymentStatus <> @newPaymentStatus AND @newPaymentStatus = 'Good')
	BEGIN
		EXEC Workflow_StartByOrderNo @orderNo
	END

		/*
	--log the payment status if it has changed from most recent payment status in log
	DECLARE @lastPayLog VARCHAR(50),

					 @displayPaymentStatus VARCHAR(50)

	SET @lastPayLog = (SELECT TOP 1 ISNULL(p.displayPaymentStatus, '')
									FROM payLog p
									INNER JOIN @OrderRecord o ON p.orderID = o.orderID

									ORDER BY p.logDate DESC)

	IF @lastPayLog IS NULL
		BEGIN
			SET @lastPayLog = '0'
		END

	SET @displayPaymentStatus = (SELECT TOP 1 o.displayPaymentStatus FROM @OrderRecord o)

	IF @lastPayLog <> @displayPaymentStatus
	BEGIN

	*/
		INSERT INTO payLog (orderid, displayPaymentStatus, logdate)
		SELECT o.orderID, o.displayPaymentStatus, @CurrentDate
		FROM @OrderRecord o
	--END

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH