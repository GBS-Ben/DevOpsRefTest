CREATE procedure [dbo].[Report_2021FootballBuyers]
		AS
--2021 Football Customers
SELECT  DISTINCT c.email, c.firstName +  ISNULL(' ' + NULLIF(c.surname,''),'') AS [Name]
	--first, last, email, company
	FROM tblorders d 
	inner join tblorders_products op ON op.Orderid = d.orderid
	inner join tblcustomers c On c.customerid = d.customerid
	WHERE orderDate BETWEEN '3/1/2021' AND '12/1/2021'
		AND LEFT(productcode,2) = 'FB'
		AND orderStatus NOT IN ('Cancelled')