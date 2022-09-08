
CREATE PROC usp_insertProducts_carMagnet_local

@productID int

AS

--STEP 1: INSERT PRODUCT OPTIONS------------------------

insert into tblProduct_ProductOptions (tblProduct_ProductOptions.productID, tblProduct_ProductOptions.optionID, tblProduct_ProductOptions.optionGroupID, tblProduct_ProductOptions.optionPrice, tblProduct_ProductOptions.optionDiscountApplies)
select tblProducts.productID, 320, 32, 0, 0 from tblProducts where tblProducts.productID = @productID

insert into tblProduct_ProductOptions (tblProduct_ProductOptions.productID, tblProduct_ProductOptions.optionID, tblProduct_ProductOptions.optionGroupID, tblProduct_ProductOptions.optionPrice, tblProduct_ProductOptions.optionDiscountApplies)
select tblProducts.productID, 336, 32, 0, 0 from tblProducts where tblProducts.productID = @productID


--STEP 2: INSERT PRODUCT CATEGORIES------------------------

insert into tblProducts_Categories (tblProducts_Categories.productID, tblProducts_Categories.categoryID, tblProducts_Categories.hiddenInSearch)
select productID,'2','0' from tblProducts where tblProducts.productID = @productID