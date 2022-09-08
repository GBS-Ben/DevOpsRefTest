CREATE PROC [dbo].[usp_getPNP]
AS

/*
Created by: JF
Created on: 3/7/16
Last updated on: 3/7/16
Use: A pick and print is anything that 'is a custom order' and 'has a value for the "Previous Job Info" field on the intranet' and 'has no "change Fee"'. This SPROC pulls
	 records into Switch for processing.
*/

SELECT
o.orderNo,
x.ordersProductsID,
op.productCode,
op.productQuantity,
x.textValue AS 'previousOrderNo'
FROM tblOrders o
JOIN tblOrders_Products op
	ON o.orderID = op.orderID
JOIN tblOrdersProducts_productOptions x
	ON op.ID = x.ordersProductsID
WHERE op.deleteX <> 'yes'
AND op.pnp_create = 0
AND x.deleteX <> 'yes'
AND (x.optionID = 346
	OR (x.optionID = 252 and x.optionCaption = 'Previous Order Number'))	--added for iFrame conversion
AND o.orderStatus <> 'cancelled' 
AND o.orderStatus <> 'failed' 
AND o.orderStatus <> 'MIGZ'
AND o.orderStatus NOT LIKE '%Waiting%'
AND o.displayPaymentStatus = 'Good'
AND DATEDIFF(MI, o.created_on, GETDATE()) > 10