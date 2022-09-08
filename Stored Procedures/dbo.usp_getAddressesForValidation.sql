CREATE PROC [dbo].[usp_getAddressesForValidation]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     09/27/16
-- Purpose     Used by Endicia Dial-A-Zip API to poll new address records that need to be validated.
-------------------------------------------------------------------------------
-- Modification History
--
-- 09/27/16		Created.
--10/22/18		JF, Qual'd joins
--05/29/19		JF, replaced 'ND' situation that was causing labelserver errors
-------------------------------------------------------------------------------
SELECT 
a.PKID, a.mailClass, a.weightOz, a.mailpieceShape, a.shipDate, a.shipTime, a.referenceID, a.storeID, 
x.Shipping_FullName AS 'toName', x.Shipping_Company AS 'toCompany', x.Shipping_Street AS 'toAddress1', x.Shipping_Street2 AS 'toAddress2', 
x.Shipping_Suburb AS 'toCity', x.Shipping_State AS 'toState', SUBSTRING(x.Shipping_PostCode, 1, 5) AS 'toPostalCode', 
CASE
		WHEN x.Shipping_PostCode LIKE '%-%' AND x.Shipping_PostCode NOT LIKE '%ND%' THEN SUBSTRING(x.Shipping_PostCode, 7, 4)
		ELSE ' '
END AS 'toZip4', 
b.company, b.address1, b.address2, b.city, b.[state], b.zip, b.zip4, b.phone, b.email
FROM tblShippingLabels a 
INNER JOIN tblShipping_From b ON a.storeID = b.storeID
INNER JOIN tblCustomers_ShippingAddress x ON a.referenceID = x.orderNo
WHERE a.getLabel = 0
AND x.isValidated = 1