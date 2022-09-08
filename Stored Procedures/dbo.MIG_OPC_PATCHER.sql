CREATE PROC [dbo].[MIG_OPC_PATCHER]
AS
/*
-------------------------------------------------------------------------------
Author      Bobby
Created     02/11/21
Purpose     Removes OPC from orders that shouldnt have OPC
-------------------------------------------------------------------------------
Modification History

02/11/21		New; hopefully this dies quickly

-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;

BEGIN TRY


		--no opc on 
		UPDATE oppo
		SET deletex = 'yes', 
			modified_on = getdate()  --select *
		FROM tblOrdersProducts_ProductOptions oppo
		WHERE optionCaption = 'OPC' 
			   AND deletex <> 'yes'
			   AND EXISTS (SELECT top 1 1 
			   FROM tblOrdersProducts_ProductOptions 
			   WHERE (textValue LIKE '%32%pt%card%' OR textValue LIKE '%42%pt%card%' OR textValue LIKE '%52%pt%card%')
					 AND ordersProductsID = oppo.ordersProductsID 
					 AND deletex <>'yes')
			   AND oppo.created_on > DATEADD(dd,-5,GETDATE())


		---no OPC for design fee
		UPDATE oppo
		SET deletex = 'yes', modified_on = getdate()  --select *
		FROM tblOrdersProducts_ProductOptions oppo
		WHERE optionCaption = 'OPC' 
			   AND deletex <> 'yes'
			   AND EXISTS (SELECT top 1 1 
			   FROM tblOrdersProducts_ProductOptions 
			   WHERE optionCaption = 'Design Fee'
					AND (textValue LIKE 'Yes%')
					 AND ordersProductsID = oppo.ordersProductsID 
					 AND deletex <>'yes')
			   AND oppo.created_on > DATEADD(dd,-5,GETDATE())


		--- Previous Order Number
		UPDATE oppo
		SET deletex = 'yes', 
			modified_on = getdate()  --select *
		FROM tblOrdersProducts_ProductOptions oppo
		WHERE optionCaption = 'OPC' 
			   AND deletex <> 'yes'
			   AND EXISTS (SELECT top 1 1 
			   FROM tblOrdersProducts_ProductOptions 
			   WHERE optionCaption = 'Previous Order Number'
					 AND ordersProductsID = oppo.ordersProductsID 
					 AND deletex <>'yes')
			  AND oppo.created_on > DATEADD(dd,-5,GETDATE())


		--SKUs that should never HAVE OPC
		UPDATE oppo
		SET deletex = 'yes', 
			modified_on = getdate()  --select *
		FROM tblOrders o 
		INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
		INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
		WHERE orderStatus NOT IN ('cancelled','failed')
			AND (LEFT(op.Productcode,4) IN  ('CAIN', 'BBIN', 'FBIN', 'CAEV', 'BBEV', 'FBEV', 'FAEV', 'FAIN', 'EVKW')
				OR op.productCode LIKE '__PM%' -- Postcards
				OR op.productCode LIKE '__FA%' --Furnished Art
				OR op.ProductCode like 'PL%')
			AND optionCaption = 'OPC' 
			AND oppo.deletex <> 'yes' 
			AND oppo.created_on > DATEADD(dd,-5,GETDATE())
		   --    AND EXISTS (SELECT top 1 1 
					--FROM tblOrdersProducts_ProductOptions 
					--WHERE optionCaption = 'Previous Order Number'
		   --          AND ordersProductsID = op.ordersProductsID 
		   --          AND deletex <>'yes')
     


		--ALT J should never HAVE OPC
		UPDATE oppo
		SET deletex = 'yes', 
			modified_on = getdate()  --select *
		FROM tblOrders o 
		INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
		INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
		WHERE orderStatus NOT IN ('cancelled','failed','Delivered')
			AND optionCaption = 'OPC' 
			AND oppo.deletex <> 'yes' 
			AND oppo.created_on > DATEADD(dd,-5,GETDATE())
			AND EXISTS (SELECT top 1 1 
					FROM tblOrdersProducts_ProductOptions 
					WHERE optioncaption = 'Default Layout' 
							AND TextValue LIKE '%_J'
							AND ordersProductsID = op.id 
							AND deletex <>'yes')
     

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH