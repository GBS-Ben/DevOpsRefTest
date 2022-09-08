CREATE proc [dbo].[dashboard_SalesReportWithProducts] as
begin


SELECT 
o.orderNo
,o.orderDate
,o.paymentMethod
,o.paymentSuccessful
,op.ID as OPID
,op.productCode
,op.productName
,op.productPrice
,op.productQuantity
,MIN(tc.Name) as CompanyName
,CompanyStartDate=CONVERT(VARCHAR(12), MIN(tc.CreatedOnUtc), 101)
,c.firstName
,c.surname
,c.company
,c.street
,c.suburb
,c.postCode
,c.state
,c.country
,c.phone
,c.email

FROM dbo.tblOrders o
inner join dbo.tblOrders_Products op
	on o.orderID = op.orderID
inner join dbo.tblCustomers c
	on o.customerID = c.customerID

LEFT JOIN dbo.tblCompany tc 
	ON tc.GbsCompanyId=op.GbsCompanyId 
	and tc.Published=1 
	and tc.deleted=0

where o.orderStatus not in ('Cancelled','Failed')
	and op.deletex <> 'yes'
	and o.orderDate > getdate() - 180
Group by o.orderNo
,o.orderDate
,o.paymentMethod
,o.paymentSuccessful
,op.ID
,op.productCode
,op.productName
,op.productPrice
,op.productQuantity
,c.firstName
,c.surname
,c.company
,c.street
,c.suburb
,c.postCode
,c.state
,c.country
,c.phone
,c.email

end