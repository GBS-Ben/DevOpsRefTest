CREATE PROC [dbo].[usp_MarketPlace_getShipmentDetails]
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     09/01/16
-- Purpose     Retrieves shipping data for http://sbs/gbs/admin/orderViewMarketplace.asp
-------------------------------------------------------------------------------
-- Modification History
-- 12/15/16		Updated with union statement to include jobTrack shipment info, jf
-- 4/4/17		Added Union Statement that brings shipping in, jf.
-------------------------------------------------------------------------------
@orderNo VARCHAR(50)

AS

--(test) DECLARE @orderNo VARCHAR(50)= 'WEB192478'
SELECT DISTINCT mailClass, mailpieceShape, 
CONVERT(VARCHAR(50), DATEPART(MM, getLabelDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(DD, getLabelDate)) + '/' + CONVERT(VARCHAR(50), DATEPART(YY, getLabelDate)) AS 'getLabelDate', 
trackingNumber,
weightOz
FROM tblShippingLabels 
WHERE referenceID = @orderNo

UNION

SELECT
CASE
	WHEN upsServiceCode = '01' THEN 'UPS Next Day Air'
	WHEN upsServiceCode = '02' THEN 'UPS 2nd Day Air'
	WHEN upsServiceCode = '03' THEN 'UPS Ground'
	WHEN upsServiceCode = '07' THEN 'UPS Express'
	WHEN upsServiceCode = '08' THEN 'UPS Expedited'
	WHEN upsServiceCode = '11' THEN 'UPS Standard'
	WHEN upsServiceCode = '12' THEN 'UPS 3 Day Select'
	WHEN upsServiceCode = '14' THEN 'UPS Next Day Air Early'
	ELSE upsServiceCode
END AS 'mailClass',
CASE
	WHEN packageTypeCode = '02' THEN 'Customer Supplied'
	ELSE packageTypeCode
END AS 'mailpieceShape',
insertDate AS 'getLabelDate',
trackingNumber, x.weightOz
FROM tblUPSLabel a
JOIN tblAMZ_orderValid x
	ON a.orderNo = x.orderNo
WHERE a.orderNo = @orderNo
AND a.orderNo NOT IN
	(SELECT referenceID
	FROM tblShippingLabels)
AND a.orderNo NOT IN
	(SELECT jobNumber
	FROM tblJobTrack)

UNION

SELECT 
CASE
	WHEN SUBSTRING(b.mailClass, 1, 8) = 'Priority' THEN 'Priority'
	WHEN SUBSTRING(b.mailClass, 1, 11) = 'First Class' THEN 'First Class'
	ELSE ''
END AS 'mailClass',
REPLACE(REPLACE(b.mailClass, 'Priority ', ''), 'First Class ', '') AS 'mailpieceShape', 
b.[pickup date] AS 'getLabelDate', 
b.trackingNumber, b.[weight]
FROM tblJobTrack b
WHERE 
b.jobNumber = @orderNo
AND b.jobNumber NOT IN
	(SELECT referenceID
	FROM tblShippingLabels)