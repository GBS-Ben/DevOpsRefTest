CREATE proc [dbo].[usp_GetOppos_JobTicket]
@ordersProductsId int
as

--declare @ordersProductsId int = 556075272

declare @productId int = (select top 1 productID from tblOrders_Products where ID = @ordersProductsId)

SELECT oppo.optionID
,optionCaption = coalesce(ppo.jobTicketDisplayText,po.jobTicketDisplayText,po.optionCaption,oppo.optionCaption)
,oppo.optionprice
,oppo.optionQty
,oppo.optionGroupCaption
,textValue = case 
			when po.isHyperlink = 0 then oppo.textValue
			else 'View' end
,link = case when po.isHyperlink = 1 then 			
				CASE WHEN oppo.optionCaption = 'CanvasEditorLogo' THEN 
					CASE WHEN oppo.textValue LIKE 'https://img%' THEN 
						REPLACE(oppo.textValue,'.pdf','.png') --05132021 Shreck: job tickets need the png so we just convert it here.
					ELSE
						(--this nonsense is needed to fix odd data coming from some CanvasEditorLogo oppos
						 SELECT 'https://img.houseofmagnets.com/content/images/companyLogo/' + REPLACE(textvalue,'.pdf' , '')  + '.png'
									  FROM tblOrdersProducts_ProductOptions oppo2 
									  WHERE oppo2.ordersProductsID = @ordersProductsId
										AND oppo2.optionCaption LIKE 'Apparel Logo%'
              							AND textValue NOT LIKE '\\GBS1\printfiles%'
										AND deletex <> 'yes'
										)
					END
			ELSE
				oppo.textValue 
			END
			else null end
FROM tblOrdersProducts_ProductOptions oppo
left join tblProduct_ProductOptions ppo
	on ppo.productID = @productId
		and oppo.optionID = ppo.optionID
left join tblProductOptions po
	on oppo.optionCaption = po.optionCaption
WHERE oppo.ordersproductsID = @ordersProductsId 
	AND oppo.deletex <> 'yes' 
	and po.displayOnJobTicket = 1
	--and ppo.displayOnJobTicket = 1