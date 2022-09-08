CREATE VIEW [dbo].[v_AMZ_shippingOutbound]
AS
SELECT 
a.[order-id], 
a.[order-item-id], 
a.[quantity-purchased], 
CONVERT(NVARCHAR(50), SUBSTRING(b.[pickup date], 7, 4) +'/'+ SUBSTRING(b.[pickup date], 1, 2) +'/'+ SUBSTRING(b.[pickup date], 4, 2)) AS 'ship-date', 
CASE b.trackSource
   WHEN 'UPS Quantum View' THEN CONVERT(NVARCHAR(50), 'UPS')
   WHEN 'UPS WorldShip' THEN CONVERT(NVARCHAR(50), 'UPS')
   WHEN 'USPS Endicia' THEN CONVERT(NVARCHAR(50), 'USPS')
   ELSE CONVERT(NVARCHAR(50),'USPS')
END AS 'carrier-code',
CASE b.trackSource
   WHEN 'UPS Quantum View' THEN CONVERT(NVARCHAR(50), 'UPS')
   WHEN 'UPS WorldShip' THEN CONVERT(NVARCHAR(50), 'UPS')
   WHEN 'USPS Endicia' THEN CONVERT(NVARCHAR(50), 'USPS')
   ELSE CONVERT(NVARCHAR(50), 'USPS')
END AS 'carrier-name',
b.trackingNumber AS 'tracking-number',
b.mailClass
FROM tblAMZ_orderValid a 
JOIN tblJobTrack b
	ON a.orderNo = b.jobNumber
JOIN tblAMZ_orderShip x
	ON a.orderNo = x.orderNo
WHERE (x.orderStatus = 'Shipped' 
		OR x.orderStatus IN ('On HOM Dock','On MRK Dock' )
		OR x.orderStatus = 'Delivered')
AND b.trackSource IS NOT NULL