CREATE PROCEDURE [dbo].[Report_RecentFailedOrders] 
AS

SELECT
c.Email,
o.GBSOrderID AS FailedOrderID,
Errors,
CreatedOn,
OrderTotal,
0 AS Corrected
FROM dbo.nopcommerce_tblFailedOrders o
INNER JOIN dbo.nopcommerce_Customer c ON c.id = o.CustomerId
WHERE CreatedOn > DATEADD(dd, -5,GETDATE())