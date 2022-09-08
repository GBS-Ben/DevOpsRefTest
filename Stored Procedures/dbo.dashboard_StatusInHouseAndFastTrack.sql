CREATE proc [dbo].[dashboard_StatusInHouseAndFastTrack]
as
BEGIN
	SELECT DISTINCT
		a.orderno,
		dbo.fn_getOrderViewMarkdownLink(a.orderNo, a.orderNo) AS orderNo_link
		,op.ID AS OrdersProductsID
		,op.processType
		,op.fastTrak_status
		,a.orderDate
		,a.orderStatus
		,a.orderTotal
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
	WHERE op.processType = 'fastrak'
		and op.fastTrak_status = 'In House'
		and a.orderstatus not in ('Cancelled','Waiting For Payment')
		and op.created_on > getdate() - 30
		and op.Created_on < getdate() -1
	ORDER BY fastTrak_status_lastModified


	END