CREATE PROCEDURE [dbo].[dashboard_betaNotInSwitch]
AS
DROP TABLE


IF EXISTS ##TTSwitchProblem
	,##ttSwitchProblemFT
	,##ttSwitchProblemCU
	,##ttSwitchProblemPR
	SELECT DISTINCT op.ID
		,op.processType
	INTO ##TTSwitchProblem
	FROM tblOrders_Products op
	INNER JOIN tblorders a
		ON op.orderid = a.orderID
	LEFT JOIN tblNOPProductionFiles npf
		ON npf.nopOrderItemID = op.id
	WHERE op.productcode LIKE 'BB__00%'
		AND a.orderStatus NOT IN (
			'Failed'
			,'Cancelled'
			,'MIGZ'
			)
		AND a.displayPaymentStatus IN (
			'Good'
			,'Credit Due'
			)
		AND a.orderStatus NOT LIKE 'Waiting%'
		AND op.deleteX <> 'yes'
		AND Left(op.productcode, 4) NOT IN (
			'BBES'
			,'BBPM'
			)
		AND op.fastTrak_status != 'Completed'
		AND NOT EXISTS (
			SELECT TOP 1 1
			FROM tblswitchReportLog rl
			WHERE rl.ordersProductsID = op.id
			)
		AND NOT EXISTS (
			SELECT TOP 1 1
			FROM tblSwitchBatchLog bl
			WHERE bl.ordersProductsID = op.id
				AND batchTimestamp > GETDATE() - 1
			)


SELECT id
INTO ##ttSwitchProblemCU
FROM ##TTSwitchProblem
WHERE processtype = 'Custom'


SELECT id
INTO ##ttSwitchProblemFT
FROM ##TTSwitchProblem
WHERE processtype = 'FasTrak'


IF (
		SELECT TOP 1 1
		FROM ##ttSwitchProblemFT
		) IS NOT NULL
BEGIN
	SELECT DISTINCT
		a.orderno,
		dbo.fn_getOrderViewMarkdownLink(a.orderNo, a.orderNo) AS orderNo_link
		,op.ID AS OrdersProductsID
		,op.processType
		,a.orderDate
		,a.orderTotal
		,a.orderStatus
		,op.fastTrak_status
		,CASE 
			WHEN (
					SELECT TOP 1 1
					FROM tblOrdersProducts_productOptions oppo
					WHERE RIGHT(oppo.textValue, 2) = '_J'
						AND oppo.ordersProductsID = op.ID
						AND oppo.deletex != 'yes'
					) = 1
				THEN '_J'
			ELSE ''
			END AS Jcheck
		,op.productCode
		,npf.FileName
		,a.orderType
		,op.fastTrak_status_lastModified
		,a.lastStatusUpdate AS lastOrderStatusUpdate
		,op.productName
		,op.productPrice
		,a.paymentSuccessful
		,op.productQuantity
		,op.delivered
		,op.deliveredDate
		,op.productType
		,op.switch_create
		,op.switch_createDate
		,op.created_on
		,op.modified_on
		,op.fastTrak
		,op.fastTrak_productType
		,op.fastTrak_newQTY
		,op.fastTrak_imposed
		,op.fastTrak_imposedOn
		,op.fastTrak_completed
		,op.fastTrak_completedOn
		,op.switchMerge_create
		,op.proofVersion
	FROM tblOrders_Products op
	INNER JOIN tblorders a
		ON op.orderid = a.orderID
	LEFT JOIN tblNOPProductionFiles npf
		ON npf.nopOrderItemID = op.id
	WHERE op.ID IN (
			SELECT ttft.ID
			FROM ##ttSwitchProblemFT ttft
			WHERE ttft.id = op.ID
			)
	ORDER BY fastTrak_status_lastModified
END


DROP TABLE


IF EXISTS ##TTSwitchProblem
	,##ttSwitchProblemFT
	,##ttSwitchProblemCU
	,##ttSwitchProblemPR