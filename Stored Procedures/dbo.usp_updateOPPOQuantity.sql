CREATE PROCEDURE [dbo].[usp_updateOPPOQuantity]
@ordersProductsId INT 
AS
/*
-------------------------------------------------------------------------------------
 Author     CBrowne
Created     04/15/21
Purpose     Updates quantity on oppos based on productQuantity
-------------------------------------------------------------------------------------
Modification History
*/
SET NOCOUNT ON;

UPDATE oppo
SET optionQty = 
 	CASE WHEN ISNULL(oppo.optionPrice,0) = 0.00 THEN 0 
			 WHEN oppo.optionCaption IN (
								'Express Production', 
								'Custom Artwork',  --These are a per order charge
								'Change Fee',
								'Custom Art Fee',
								'Design Fee',
								'Setup Charges',
								'Electronic Proof',
								'Receive an Electronic Proof',
								'Photo and Logo x 3',
								'Photo and Logo x 5',
								'Photo and Logo x 4'
					) THEN 1 
				WHEN op.productcode like 'bp%' or op.productcode like 'GNNC%' or op.productCode like 'FANC%' then op.productQuantity * 100 
				ELSE op.productQuantity 
			 END 
FROM tblOrdersProducts_ProductOptions oppo
INNER JOIN tblOrders_Products op on op.id = oppo.OrdersProductsID
WHERE op.id = @ordersProductsId