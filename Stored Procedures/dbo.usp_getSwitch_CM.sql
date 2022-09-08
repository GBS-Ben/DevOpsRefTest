CREATE PROC [usp_getSwitch_CM]
AS
SELECT
orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, 
shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, 
shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, 
numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, 
totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, 
team5FileName, team6FileName, groupID, productID, parentProductID, switch_create, switch_createDate, 
switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, 
mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, 
customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, 
fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, 
stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, 
stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, 
stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV
FROM tblSwitch_CM
WHERE switch_create = 0
AND switch_import = 0