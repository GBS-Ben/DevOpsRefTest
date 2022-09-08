
  CREATE PROCEDURE Report_PossibleGroupOrderCustomers
  AS
  SET NOCOUNT ON;
  BEGIN
	;WITH Candidate 
	AS 
	(
		SELECT email,  COUNT(DISTINCT OrderNo) As OrderCount , max(c.customerid) AS maxCustomerID
		FROM tblorders o
		INNER JOIN tblCustomers c on c.CustomerId = o.customerID
		WHERE orderDate > dateadd(d,-365,getdate())
			AND orderStatus NOT IN ('Cancelled', 'Failed', 'Waiting For Payment')
			AND email <> ''
		GROUP BY email 
		HAVING COUNT(DISTINCT OrderNo) >= 12
	) 
	--Email | name | address | phone | # of orders | last order #
	--select top 1000 * from tblCustomers
	SELECT c.email as Email, 
		c.FirstName + ISNULL(' ' + NULLIF(c.Surname,''),'') AS [Name], 
		Street AS [Street],
		Street2 AS Street2,
		Suburb AS City,
		[State] AS [State],
		postCode AS Zip,
		ISNULL(NULLIF(phone,''),(SELECT TOP 1 Billing_Phone FROM tblCustomers_BillingAddress WHERE customerID = c.customerID ORDER BY BillingAddressID DESC)) AS Phone,
		OrderCount AS [# of orders],
		(SELECT TOP 1 OrderNo FROM tblOrders o WHERE o.customerID = c.CustomerId AND orderStatus NOT IN ('Cancelled', 'Failed', 'Waiting For Payment') ORDER BY OrderDate DESC) AS [Last Order #]
	FROM  Candidate ca
	INNER JOIN tblCustomers c ON  ca.maxCustomerID = c.customerID
	ORDER BY email
END