CREATE PROCEDURE [dbo].[ReportWFP_NoChecks] 
AS
/*
-------------------------------------------------------------------------------
Author			Jeremy Fifer
Created			08/05/19
Purpose			used in PMI report table.
-------------------------------------------------------------------------------
Modification History

08/05/19		New
04/27/21		CKB, Markful

-------------------------------------------------------------------------------
*/

SELECT DISTINCT orderNo,
dbo.fn_getOrderViewMarkdownLink(orderNo, orderNo) AS 'orderNo_link'
FROM tblOrders o
WHERE displayPaymentStatus IN ('waiting for payment', '', 'Partial Payment Received')
AND orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'in transit', 'in transit usps')
AND SUBSTRING(orderNo, 1, 3) IN ( 'HOM', 'NCC','MRK')
AND DATEDIFF(dd, orderDate, GETDATE()) < 90
AND paymentMethod <> 'check'