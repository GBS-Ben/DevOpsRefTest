







CREATE VIEW [dbo].[vwOPIDView]
AS
SELECT DISTINCT op.*, o.[orderNo] ,o.[orderStatus],o.[lastStatusUpdate],o.[orderDate],o.company as GBSCompany, c.customerID
    ,tblOrders_billing_FirstName as firstName
	,tblOrders_billing_Surname as surName
    ,tblOrders_billing_Company as company
    ,tblOrders_billing_Street as street
    ,tblOrders_billing_Street2 as street2
    ,tblOrders_billing_Suburb as suburb
    ,tblOrders_billing_PostCode as postCode
    ,tblOrders_billing_State as state
    ,tblOrders_billing_Country as country
    ,tblOrders_billing_Phone as phone
	,c.fax
	,c.email
FROM vwOPIDWorkflowAll owf
INNER JOIN tblOrders_products op on op.ID = owf.OPID
LEFT JOIN tblOrderview o on op.orderId = o.orderID
LEFT JOIN tblCustomers c 
	ON o.customerID = c.customerID