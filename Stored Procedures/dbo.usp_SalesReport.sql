CREATE PROCEDURE [dbo].[usp_SalesReport]
  @From AS DATETIME
  ,@To AS DATETIME
  ,@MbType AS VARCHAR(30)
AS 
BEGIN
  SELECT o.orderNo AS 'Job Number'
    , o.orderDate AS 'Order Date'
    , c.customerID AS 'Customer ID'
    , c.company AS 'Company'
    , c.firstName AS 'First Name'
    , c.surname AS 'Last Name'
    , c.email AS 'Email'
    , c.state AS 'State'
    , c.postCode AS 'Zip'
    , o.orderStatus AS 'Status'
    , o.displayPaymentStatus AS 'Payment Status'
    , o.orderTotal AS 'Order Total'
    , o.orderType AS 'Order Type'
    , op.productCode AS 'Product Code'
    , p.productName AS 'Product Name'
    , p.shortName
    , o.membershipType 
    FROM tblOrders AS o 
    INNER JOIN tblOrders_Products AS op ON op.orderID = o.orderID 
    INNER JOIN tblCustomers AS c ON c.customerID = o.customerID 
    INNER JOIN tblProducts AS p ON p.productID = op.productID 
    WHERE (o.orderStatus NOT IN ('Cancelled', 'Failed')) 
		AND (op.deletex <> 'yes') 
		AND (o.orderDate BETWEEN @From AND @To ) 
		AND o.membershipType Like @MbType
    ORDER BY o.orderDate
END