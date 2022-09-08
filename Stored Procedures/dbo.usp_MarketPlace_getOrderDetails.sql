CREATE PROCEDURE [dbo].[usp_MarketPlace_getOrderDetails]
@orderNo VARCHAR(255)
AS

/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     07/12/16
Purpose     This sproc grabs general AMZ order data for a given @orderNo.
				http://intranet/gbs/admin/orderView_MarketPlace.asp
Variables	This sproc accepts orderNos like "WEB123456' for @orderNo. See below.
Example:		usp_MarketPlace_getOrderDetails 'WEB171341'
-------------------------------------------------------------------------------
Modification History

7/12/16		Created.
11/7/16		Added isValidated, rdi, returnCode, UPSRural
12/29/16		Added a.A1_conditionID to result set; jf.
10/08/18		JF, qualified join.
-------------------------------------------------------------------------------
*/

SELECT DISTINCT
a.[orderNo],
a.[buyer-name], a.[buyer-phone-number], a.[buyer-email], a.[order-id],
a.[recipient-name], a.[ship-address-1], a.[ship-address-2], a.[ship-address-3],
a.[ship-city], a.[ship-state], a.[ship-postal-code], a.[ship-country], 
a.[orderDate], 
b.[ship-service-level], b.[promise-date],

CASE 
	WHEN CONVERT(MONEY, b.[item-price]) IS NULL THEN 0
	ELSE SUM(CONVERT(MONEY, b.[item-price]))
END 
+ 
CASE
	WHEN CONVERT(MONEY, b.[item-tax]) IS NULL THEN 0
	ELSE SUM(CONVERT(MONEY, b.[item-tax]))
END
+ 
CASE
	WHEN CONVERT(MONEY, b.[shipping-price]) IS NULL THEN 0
	ELSE SUM(CONVERT(MONEY, b.[shipping-price]))
END AS 'orderTotal',

CASE
	WHEN CONVERT(MONEY, b.[item-price]) IS NULL THEN 0
	ELSE SUM(CONVERT(MONEY, b.[item-price]))
END AS 'itemPrice',
CASE
	WHEN CONVERT(MONEY, b.[item-tax]) IS NULL THEN 0
	ELSE SUM(CONVERT(MONEY, b.[item-tax]))
END AS 'itemTax',
CASE
	WHEN CONVERT(MONEY, b.[shipping-price]) IS NULL THEN 0
	ELSE SUM(CONVERT(MONEY, b.[shipping-price]))
END AS 'shippingPrice',

a.orderStatus,
b.lastStatusUpdate,
a.a1_mailPieceShape,

CASE 
	WHEN a.isValidated IS NULL THEN ''
	ELSE convert(varchar(255),a.isValidated)
END as 'isValidated',
CASE 
	WHEN a.rdi IS NULL THEN ''
	ELSE convert(varchar(255),a.rdi)
END as 'rdi',
CASE 
	WHEN a.returnCode IS NULL THEN ''
	ELSE convert(varchar(255),a.returnCode)
END as 'returnCode',
CASE 
	WHEN a.UPSRural IS NULL THEN ''
	ELSE convert(varchar(255),a.UPSRural)
END as 'UPSRural',
CASE 
	WHEN z.GBSZone IS NULL THEN ''
	ELSE REPLACE(convert(varchar(255),z.GBSZone), ' ', '')
END as 'GBSZone',
a.A1_conditionID,
a.A1,
a.a1_mailClass,
a1_carrier
FROM tblAMZ_orderShip a
LEFT JOIN tblAMZ_orderValid b ON a.orderNo = b.orderNo
INNER JOIN tblZone z ON SUBSTRING(a.[ship-postal-code], 1 , 3) = z.zip
WHERE a.orderNo = @orderNo
GROUP BY a.[orderNo],
a.[buyer-name], a.[buyer-phone-number], a.[buyer-email], a.[order-id],
a.[recipient-name], a.[ship-address-1], a.[ship-address-2], a.[ship-address-3],
a.[ship-city], a.[ship-state], a.[ship-postal-code], a.[ship-country], 
a.[orderDate], 
b.[ship-service-level], b.[promise-date], b.[item-price], b.[item-tax], b.[shipping-price],
a.orderStatus,
b.lastStatusUpdate,
a.a1_mailPieceShape,
a.isValidated, a.rdi, a.returnCode, a.UPSRural,
z.GBSZone,
a.A1_conditionID,
a.A1_conditionID,
a.A1,
a.a1_mailClass,
a1_carrier