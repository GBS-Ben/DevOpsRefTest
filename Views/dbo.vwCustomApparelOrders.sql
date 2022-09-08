CREATE VIEW [dbo].[vwCustomApparelOrders]
AS 

	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP ,
	case when unp.textvalue is null 
				and substring(op.productcode,5,2) not in ('S1','S2','S3','S4','S5','S7','S8','SA','SB','SC','SD','SE','SF','SG','SH','T1') then 0 else 1 end as 'digitized'
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	LEFT JOIN tblOrdersProducts_ProductOptions oppo on op.id = oppo.ordersProductsID and optionCaption = 'CanvasEditorLogo'
	left join ApparelProductThreadColorUnpivot unp
		on substring(reverse(substring(reverse(oppo.textvalue),1,charindex('/',reverse(oppo.textvalue))-1)),1,charindex('.pdf',reverse(substring(reverse(oppo.textvalue),1,charindex('/',reverse(oppo.textvalue))-1)))-1) + '.pdf' = unp.APLogo
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'AP%' 
	AND op.processType = 'Custom'