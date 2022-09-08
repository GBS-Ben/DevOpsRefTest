CREATE VIEW [dbo].[vwtblOrdersProducts_ProductOptions_Trans]
as
SELECT [PKID]
      ,[PKID_Remote]
      ,[ordersProductsID]
      ,isnull(newoptionID,oppo.optionid) as OptionID
      ,isnull(newoptionCaption,oppo.optionCaption) as  [optionCaption]
      ,optionPrice
	  ,[optionGroupCaption]
      ,isnull(cast(newtextValue as nvarchar(4000)),textValue) as  [textValue]
      ,oppo.[deletex]
      ,[optionQty]
      ,oppo.[created_on]
      ,oppo.[modified_on]
  FROM [dbo].[tblOrdersProducts_ProductOptions] oppo
  inner join [dbo].[tblOrders_Products] op on op.ID = oppo.ordersProductsID
  LEFT JOIN tblOPPO_Translations ot on op.productCode like ot.producttype  and ot.legacyOptionID = oppo.optionid and ot.legacyOptionCaption = oppo.optionCaption and isnull(ot.legacyTextValue,'') = isnull(oppo.textValue,'') 
  where oppo.deletex <> 'yes'