CREATE PROC [dbo].[usp_AMZ_getShipped]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/11/10
-- Purpose     This process is called as Step #3 from the SSIS_AMZ scheduled job.
--					Inserts new AMZ shipment records from tblJobTrack and AMZ
--					for pushback of shipment data to the AMZ server.

--					Ron''s postAmazonShipments app gets its input from this select statement on tblAMZ_getShipped:
--					select * from tblAMZ_getShipped where amz_update = '0' order by [order-id], [tracking-number]
--					Only selected rows are used to update AMAZON orders with the tracking number

-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Cleaned up.
-- 11/10/16		Added second INSERT statement to grab A1 orders, jf.
-- 11/17/16		Changed tblAMZ_orderShip.a1_mailRate to tblAMZ_orderShip.a1_mailPieceShape, jf.
-- 11/28/16		Added date modification code at end of sproc, jf.
-- 12/09/16		Removed date modification code set above. Changed shipDate to GETDATE() as per KH comments on 12/8/16 in Strat Mtg, jf.
-- 4/4/17		updated to include UPS Marketplace section, jf.
-- 4/5/17		updated carrier code fix towards end of sproc, jf.
-- 9/11/20		adjusted ship-date (+8 hours) to account for PST/PDT to UTC
-- 04/27/21		CKB, Markful

-------------------------------------------------------------------------------
SET NOCOUNT ON;

BEGIN TRY
	-- Non-A1 orders
	INSERT INTO tblAMZ_getShipped ([order-id], [order-item-id], quantity, [ship-date], [carrier-code], [carrier-name], [tracking-number], [ship-method])
	SELECT a.[order-id] AS 'order-id', 
	a.[order-item-id] AS 'order-item-id', 
	a.[quantity-purchased] AS 'quantity', 
	--b.[pickup date] AS 'ship-date', 
	dateadd(hour,8,GETDATE()) AS 'ship-date', 
	SUBSTRING(RTRIM(b.trackSource), 1, 4) AS 'carrier-code',
	SUBSTRING(RTRIM(b.trackSource), 1, 4) AS 'carrier-name',
	b.trackingNumber AS 'tracking-number', 
	b.mailClass AS 'ship-method'
	FROM tblAMZ_orderValid a 
	INNER JOIN tblJobTrack b
		ON a.orderNo = b.jobNumber
	INNER JOIN tblAMZ_orderShip c
		ON a.orderNo = c.orderNo
	WHERE 
	(c.orderStatus IN ('ON HOM Dock','ON MRK Dock') OR c.orderStatus = 'Shipped' OR c.orderStatus = 'Delivered')
	AND b.trackingNumber IS NOT NULL
	AND b.trackingNumber <> ''
	AND a.[order-item-id] NOT IN 
			(SELECT [order-item-id] 
			FROM tblAMZ_getShipped)

	-- A1 orders
	INSERT INTO tblAMZ_getShipped ([order-id], [order-item-id], quantity, [ship-date], [carrier-code], [carrier-name], [tracking-number], [ship-method])
	SELECT a.[order-id] AS 'order-id', 
	a.[order-item-id] AS 'order-item-id', 
	a.[quantity-purchased] AS 'quantity', 
	--b.getLabelDate AS 'ship-date', 
	dateadd(hour,8,GETDATE()) AS 'ship-date', 
	'USPS' AS 'carrier-code',
	'USPS' AS 'carrier-name',
	b.trackingNumber AS 'tracking-number', 
	A1_mailClass + ' ' + c.a1_mailPieceShape AS 'ship-method'
	FROM tblAMZ_orderValid a 
	INNER JOIN tblShippingLabels b
		ON a.orderNo = b.referenceID
	INNER JOIN tblAMZ_orderShip c
		ON a.orderNo = c.orderNo
	WHERE 
	(c.orderStatus IN ('ON HOM Dock','ON MRK Dock') OR c.orderStatus = 'Shipped' OR c.orderStatus = 'Delivered')
	AND b.trackingNumber IS NOT NULL
	AND b.trackingNumber <> ''
	AND a.[order-item-id] NOT IN 
			(SELECT [order-item-id] 
			FROM tblAMZ_getShipped)

	--UPS Marketplace Orders
	INSERT INTO tblAMZ_getShipped ([order-id], [order-item-id], quantity, [ship-date], [carrier-code], [carrier-name], [tracking-number], [ship-method])
	SELECT a.[order-id] AS 'order-id', 
	a.[order-item-id] AS 'order-item-id', 
	a.[quantity-purchased] AS 'quantity', 
	dateadd(hour,8,GETDATE()) AS 'ship-date', 
	'UPS' AS 'carrier-code',
	'UPS' AS 'carrier-name',
	b.trackingNumber AS 'tracking-number', 
	CASE
		WHEN b.upsServiceCode = '01' THEN 'UPS Next Day Air'
		WHEN b.upsServiceCode = '02' THEN 'UPS 2nd Day Air'
		WHEN b.upsServiceCode = '03' THEN 'UPS Ground'
		WHEN b.upsServiceCode = '07' THEN 'UPS Express'
		WHEN b.upsServiceCode = '08' THEN 'UPS Expedited'
		WHEN b.upsServiceCode = '11' THEN 'UPS Standard'
		WHEN b.upsServiceCode = '12' THEN 'UPS 3 Day Select'
		WHEN b.upsServiceCode = '14' THEN 'UPS Next Day Air Early'
		ELSE b.upsServiceCode
	END AS 'ship-method'
	FROM tblAMZ_orderValid a 
	INNER JOIN tblUPSLabel b
		ON a.orderNo = b.orderNo
	INNER JOIN tblAMZ_orderShip c
		ON a.orderNo = c.orderNo
	WHERE 
	(c.orderStatus IN ('ON HOM Dock','ON MRK Dock') OR c.orderStatus = 'Shipped' OR c.orderStatus = 'Delivered')
	AND b.trackingNumber IS NOT NULL
	AND b.trackingNumber <> ''
	AND a.[order-item-id] NOT IN 
			(SELECT [order-item-id] 
			FROM tblAMZ_getShipped)

	-- fix any incorrect carrier details
	UPDATE tblAMZ_getShipped
	SET [carrier-code] = 'UPS',
		[carrier-name] = 'UPS'
	WHERE [tracking-number] LIKE '1Z%'
	AND [carrier-code] = 'USPS'

	-- fix qtys
	UPDATE tblAMZ_getShipped
	SET quantity = b.[quantity-purchased]
	FROM tblAMZ_getShipped a
	INNER JOIN  tblAMZ_orderValid b ON a.[order-item-id] = b.[order-item-id]
	AND a.[order-id] = b.[order-id] 

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH