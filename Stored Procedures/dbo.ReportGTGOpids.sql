CREATE PROC [dbo].[ReportGTGOpids]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/3/18
Purpose     used by SSRS to display Good To Go "GTG" opids that have not moved in 48 biz hours
-------------------------------------------------------------------------------
Modification History

11/02/18	   Created, jf.
11/05/18		Added displayPaymentStatus = 'good' check, jf.
04/27/21		CKB, Markful
-------------------------------------------------------------------------------
*/

SELECT op.ID
	 ,op.productCode
	 ,op.productName
	 ,op.fastTrak_status
	 ,op.modified_on
	 ,o.orderID
	 ,o.orderNo
	 ,o.orderDate
	 ,o.orderStatus
	 ,ISNULL(CONVERT(VARCHAR(100), 'http://intranet/gbs/admin/orderView.asp?i=' + CONVERT(VARCHAR(50), o.orderID) + '&o=orders.asp&OrderNum=' + o.orderNo), 'http://sbs/gbs/admin/orders.asp') AS intranetUrl
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE op.deleteX <> 'yes'
AND op.fastTrak_status = 'Good to Go'
AND o.displayPaymentStatus = 'Good'
AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'ON HOM Dock', 'ON MRK Dock', 'In Transit', 'In Transit USPS', 'Delivered')
AND op.modified_on < (SELECT TOP (1) CONVERT(DATETIME,[Date]) AS x
								FROM DateDimension
								WHERE isWeekend = 0
								AND isHoliday = 0
								AND DATEDIFF(HH,[Date], GETDATE()) >= 48
								ORDER BY x DESC)
ORDER BY op.modified_on DESC