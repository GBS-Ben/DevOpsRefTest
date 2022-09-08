










CREATE VIEW [dbo].[vwOPIDViewAll]
AS
-- base fields for intranet tabs
SELECT DISTINCT op.id
	,owf.workflowid
	,op.productCode
	,op.productQuantity
	,o.[orderNo] 
	,o.[orderID]
	,o.[orderStatus]
	,o.[lastStatusUpdate]
	,o.[orderDate]
	,o.company as GBSCompany
	,c.customerID
    ,tblOrders_billing_FirstName as firstName
	,tblOrders_billing_Surname as surName
FROM vwOPIDCurrWorkflowAll owf
INNER JOIN tblOrders_products op on op.ID = owf.OPID
LEFT JOIN tblOrderview o on op.orderId = o.orderID
LEFT JOIN tblCustomers c 
	ON o.customerID = c.customerID