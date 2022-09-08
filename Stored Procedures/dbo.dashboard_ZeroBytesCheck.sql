CREATE proc dashboard_ZeroBytesCheck
as
begin
Select fe.OPID,dbo.fn_getOrderViewMarkdownLink(o.orderNo, o.orderNo) AS orderNo_link, OP.fastTrak_status,
 o.orderStatus,op.productCode, npf.CanvasURL,fe.filePath, npf.ProductType, npf.Surface,op.created_on,o.orderNo,o.orderDate
 ,o.orderTotal, o.paymentSuccessful,o.displayPaymentStatus,op.fastTrak_newQTY, op.fastTrak_resubmit,
fe.fileExists,fe.zeroBytes, fe.isFlattened,fe.isCustomInsert, fe.zeroBytesCheckedOn, fe.readyForSwitch,
      op.productID,op.productName, op.productQuantity
       from tblOPPO_fileExists fe
join tblOrders_Products op on op.id = fe.opid
join tblNOPProductionFiles npf on npf.nopOrderItemID = fe.OPID
join tblOrders o on op.orderID = o.orderID
where o.created_on > Getdate() -90 
and fe.zeroBytes = 1
And o.orderstatus not in  ('Cancelled')
and op.fasttrak_status not in ('Completed')
order by op.fastTrak_resubmit desc ,o.created_on asc
end