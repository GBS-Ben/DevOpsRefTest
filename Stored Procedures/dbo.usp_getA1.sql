CREATE PROC [dbo].[usp_getA1]
@orderNo varchar(255)
AS

UPDATE tblOrders
SET orderForPrint = 0, 
orderJustPrinted = 1,
orderPrintedDate = GETDATE()
WHERE orderNo = @orderNo

SELECT a.orderNo as 'orderNo', 
x.shipping_firstName as 'shippingFirstName', x.shipping_surName as 'shippingSurName', x.shipping_Street as 'shippingStreet1', 
x.shipping_Street2 as 'shippingStreet2', x.shipping_Suburb as 'shippingCity', x.shipping_State as 'shippingState',
x.shipping_PostCode as 'shippingZip',
a.orderDate as 'orderDate',
replace((c.firstName + ' ' + c.surName), '  ', ' ') as 'billingName',
c.street as 'billingStreet1', c.street2 as 'billingStreet2',
c.suburb as 'billingCity', c.[state] as 'billingState', c.postCode as 'billingZip',
p.productCode as 'productCode', p.productName as 'productName', p.productQuantity as 'quantity', p.productPrice as 'unitCost',
p.productQuantity * p.productPrice as 'lineTotal', a.calcVouchers as 'discounts',
a.shippingAmount as 'shippingAmount', a.orderTotal as 'calcOrderTotal', a.taxAmountAdded as 'tax',
a.storeID as 'storeID'
FROM
tblOrders a join tblCustomers c on a.customerID = c.customerID
join tblCustomers_shippingAddress x on a.orderNo = x.orderNo
join tblOrders_Products p on a.orderID = p.orderID
WHERE a.orderNo = @orderNo
AND a.orderStatus <> 'Failed' and a.orderStatus <> 'Cancelled'
AND p.deleteX <> 'Yes'
AND a.orderType = 'Stock'