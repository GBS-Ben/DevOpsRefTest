create PROCEDURE [dbo].[usp_Switch_NBS_empty] 
AS
/*
-------------------------------------------------------------------------------
Author      Cherilyn Browne	
Created     03/07/22
Purpose     Pulls Shaped Name Badges into Switch for production.
-------------------------------------------------------------------------------
Modification History

03/07/22		New - modeled from usp_Switch_QM
-------------------------------------------------------------------------------
*/

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'NBS Switch SP', @lastRunDate;

DECLARE @UncBasePath VARCHAR(100); 
EXEC EnvironmentVariables_Get N'OPCDirectory',@VariableValue = @UncBasePath OUTPUT;

DECLARE @OrderOffset INT; 
EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;


BEGIN TRY


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CREATE MAIN QUERY
IF OBJECT_ID('tempdb..#ImposerNBS') IS NOT NULL 
DROP TABLE #ImposerNBS
CREATE TABLE #ImposerNBS (
	[orderID] [int] NULL,
	[orderNo] [nvarchar](255) NULL,
	[orderDate] [datetime] NULL,
	[customerID] [int] NULL,
	[shippingAddressID] [int] NULL,
	[shipCompany] [nvarchar](255) NULL,
	[shipFirstName] [nvarchar](255) NULL,
	[shipLastName] [nvarchar](255) NULL,
	[shipAddress1] [nvarchar](255) NULL,
	[shipAddress2] [nvarchar](255) NULL,
	[shipCity] [nvarchar](255) NULL,
	[shipState] [nvarchar](255) NULL,
	[shipZip] [nvarchar](255) NULL,
	[shipCountry] [nvarchar](255) NULL,
	[shipPhone] [nvarchar](255) NULL,
	[productCode] [nvarchar](50) NULL,
	[productName] [nvarchar](255) NULL,
	[shortName] [nvarchar](255) NULL,
	[productQuantity] [int] NULL,
	[packetValue] [nvarchar](50) NULL,
	[variableTopName] [nvarchar](255) NULL,
	[variableBottomName] [nvarchar](255) NULL,
	[variableWholeName] [nvarchar](255) NULL,
	[backName] [nvarchar](255) NULL,
	[numUnits] [int] NULL,
	[displayedQuantity] [int] NULL,
	[ordersProductsID] [int] NULL,
	[shipsWith] [nvarchar](255) NULL,
	[resubmit] [bit] NULL,
	[shipType] [nvarchar](50) NULL,
	[samplerRequest] [nvarchar](50) NULL,
	[multiCount] [int] NULL,
	[totalCount] [int] NULL,
	[displayCount] [nvarchar](50) NULL,
	[background] [nvarchar](255) NULL,
	[templateFile] [nvarchar](255) NULL,
	[team1FileName] [nvarchar](255) NULL,
	[team2FileName] [nvarchar](255) NULL,
	[team3FileName] [nvarchar](255) NULL,
	[team4FileName] [nvarchar](255) NULL,
	[team5FileName] [nvarchar](255) NULL,
	[team6FileName] [nvarchar](255) NULL,
	[groupID] [int] NULL,
	[productID] [int] NULL,
	[parentProductID] [int] NULL,
	[switch_create] [bit] NULL,
	[switch_createDate] [datetime] NULL,
	[switch_approve] [bit] NULL,
	[switch_approveDate] [datetime] NULL,
	[switch_print] [bit] NULL,
	[switch_printDate] [datetime] NULL,
	[switch_import] [bit] NULL,
	[mo_orders_Products] [datetime] NULL,
	[mo_orders] [datetime] NULL,
	[mo_customers] [datetime] NULL,
	[mo_customers_ShippingAddress] [datetime] NULL,
	[mo_oppo] [datetime] NULL,
	[customProductCount] [int] NULL,
	[customProductCode1] [nvarchar](50) NULL,
	[customProductCode2] [nvarchar](50) NULL,
	[customProductCode3] [nvarchar](50) NULL,
	[customProductCode4] [nvarchar](50) NULL,
	[fasTrakProductCount] [int] NULL,
	[fasTrakProductCode1] [nvarchar](50) NULL,
	[fasTrakProductCode2] [nvarchar](50) NULL,
	[fasTrakProductCode3] [nvarchar](50) NULL,
	[fasTrakProductCode4] [nvarchar](50) NULL,
	[stockProductCount] [int] NULL,
	[stockProductQuantity1] [int] NULL,
	[stockProductCode1] [nvarchar](50) NULL,
	[stockProductDescription1] [nvarchar](255) NULL,
	[stockProductQuantity2] [int] NULL,
	[stockProductCode2] [nvarchar](50) NULL,
	[stockProductDescription2] [nvarchar](255) NULL,
	[stockProductQuantity3] [int] NULL,
	[stockProductCode3] [nvarchar](50) NULL,
	[stockProductDescription3] [nvarchar](255) NULL,
	[stockProductQuantity4] [int] NULL,
	[stockProductCode4] [nvarchar](50) NULL,
	[stockProductDescription4] [nvarchar](255) NULL,
	[stockProductQuantity5] [int] NULL,
	[stockProductCode5] [nvarchar](50) NULL,
	[stockProductDescription5] [nvarchar](255) NULL,
	[stockProductQuantity6] [int] NULL,
	[stockProductCode6] [nvarchar](50) NULL,
	[stockProductDescription6] [nvarchar](255) NULL,
	[UV] [bit] NULL,
	[customBackground] [nvarchar](255) NULL,
	[templateJson] [nvarchar](4000) NULL)

INSERT INTO #ImposerNBS (orderID, orderNo, orderDate, customerID, 
shippingAddressID, shipCompany, shipFirstName, shipLastName, 
shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, 
productCode, productName, 
shortName, productQuantity, 
packetValue, 
variableTopName, 
variableBottomName, 
variableWholeName, 
backName, 
numUnits, 
displayedQuantity, 
ordersProductsID, 
shipsWith, 
resubmit, 
shipType, 
samplerRequest, 
multiCount, totalCount, 
displayCount, 
background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, 
productID, parentProductID, 
mo_orders_Products, mo_orders, mo_customers_ShippingAddress, 
switch_create, switch_import,
customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, 
fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, 
stockProductCount, 
stockProductQuantity1, stockProductCode1, stockProductDescription1, 
stockProductQuantity2, stockProductCode2, stockProductDescription2, 
stockProductQuantity3, stockProductCode3, stockProductDescription3, 
stockProductQuantity4, stockProductCode4, stockProductDescription4, 
stockProductQuantity5, stockProductCode5, stockProductDescription5, 
stockProductQuantity6, stockProductCode6, stockProductDescription6,
templateJson)

SELECT a.orderID, a.orderNo, a.orderDate, a.customerID, 
[dbo].[fn_BadCharacterStripper_noLower](s.shippingAddressID) AS shippingAddressID, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Company) AS shipping_Company, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Firstname) AS shipping_Firstname, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_surName) AS shipping_surName, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Street) AS shipping_Street, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Street2) AS shipping_Street2, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Suburb) AS shipping_Suburb, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_State) AS shipping_State, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_PostCode) AS shipping_PostCode, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Country) AS shipping_Country, [dbo].[fn_BadCharacterStripper_noLower](s.shipping_Phone) AS shipping_Phone, 
op.productCode, op.productName, 
'' AS 'shortName',
op.productQuantity, 
'1 of 1' AS 'packetValue',
'' AS 'variableTopName',
'' AS 'variableBottomName',
'' AS 'variableWholeName',
'' AS 'backName', 
p.numUnits,
op.productQuantity * p.numUnits AS 'displayedQuantity',
op.[ID],
'Ship' AS 'shipsWith',
0 AS 'resubmit',
'Ship' AS shipType,
'' AS samplerRequest,
'' AS 'multiCount', '' AS 'totalCount',
'' AS 'displayCount',
'' AS background, taj.template AS templateFile, '' AS team1FileName, '' AS team2FileName, '' AS team3FileName, '' AS team4FileName, '' AS team5FileName, '' AS team6FileName,
p.productID, p.parentProductID,
op.modified_on, a.modified_on, s.modified_on, 
0 AS 'switch_create', 0 AS 'switch_import',  
0 AS 'customProductCount', '' AS 'customProductCode1', '' AS 'customProductCode2', '' AS 'customProductCode3', '' AS 'customProductCode4', 
0 AS 'fasTrakProductCount', '' AS 'fasTrakProductCode1', '' AS 'fasTrakProductCode2', '' AS 'fasTrakProductCode3', '' AS 'fasTrakProductCode4', 
0 AS 'stockProductCount',
0 AS 'stockProductQuantity1', '' AS 'stockProductCode1', '' AS 'stockProductDescription1',
0 AS 'stockProductQuantity2', '' AS 'stockProductCode2', '' AS 'stockProductDescription2',
0 AS 'stockProductQuantity3', '' AS 'stockProductCode3', '' AS 'stockProductDescription3',
0 AS 'stockProductQuantity4', '' AS 'stockProductCode4', '' AS 'stockProductDescription4',
0 AS 'stockProductQuantity5', '' AS 'stockProductCode5', '' AS 'stockProductDescription5',
0 AS 'stockProductQuantity6', '' AS 'stockProductCode6', '' AS 'stockProductDescription6'
,templateJson
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
LEFT JOIN tblSkuGroup sg ON p.productCode LIKE sg.skuPattern
LEFT JOIN tblSkuGroupGate g ON sg.skuGroup = g.skuGroup
INNER JOIN nopcommerce_orderitem oi ON op.id - @OrderOffset = oi.id
INNER JOIN nopcommerce_product np on oi.productid = np.id
INNER JOIN nopcommerce_Product_SpecificationAttribute_Mapping m ON m.ProductId = np.Id AND SpecificationAttributeOptionId = 1127  
LEFT JOIN nopCommerce_vwTemplateAttributeJson taj on REPLACE(m.CustomValue, 'hires/', '') = taj.template
WHERE 1=0

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// INSERT DATA
--insert data into #tblSwitch_NBS based on file existence
DROP TABLE IF EXISTS #tblSwitch_NBS

SELECT DISTINCT IDENTITY(INT,1,1) AS PKID,
q.orderID, q.orderNo, q.orderDate, q.customerID, q.shippingAddressID, q.shipCompany, q.shipFirstName, q.shipLastName, 
q.shipAddress1, q.shipAddress2, q.shipCity, q.shipState, q.shipZip, q.shipCountry, q.shipPhone, q.productCode, q.productName, 
q.shortName, q.productQuantity, q.packetValue, q.variableTopName, q.variableBottomName, q.variableWholeName, q.backName, 
q.numUnits, q.displayedQuantity, q.ordersProductsID, q.shipsWith, q.resubmit, q.shipType, q.samplerRequest, q.multiCount, 
q.totalCount, q.displayCount, q.background, q.templateFile, q.team1FileName, q.team2FileName, q.team3FileName, 
q.team4FileName, q.team5FileName, q.team6FileName, q.productID, q.parentProductID, q.mo_orders_Products, q.mo_orders, 
q.mo_customers_ShippingAddress, q.switch_create, q.switch_import,customProductCount, q.customProductCode1, 
q.customProductCode2, q.customProductCode3, q.customProductCode4, q.fasTrakProductCount, q.fasTrakProductCode1, 
q.fasTrakProductCode2, q.fasTrakProductCode3, q.fasTrakProductCode4, q.stockProductCount, q.stockProductQuantity1, 
q.stockProductCode1, q.stockProductDescription1, q.stockProductQuantity2, q.stockProductCode2, q.stockProductDescription2, 
q.stockProductQuantity3, q.stockProductCode3, q.stockProductDescription3, q.stockProductQuantity4, q.stockProductCode4, 
q.stockProductDescription4, q.stockProductQuantity5, q.stockProductCode5, q.stockProductDescription5, 
q.stockProductQuantity6, q.stockProductCode6, q.stockProductDescription6, q.templateJson,
switch_approve = 0,
switch_print = 0,
switch_approveDate = GETDATE(),
switch_printDate = GETDATE(),
switch_createDate = GETDATE(),
cast(null as int) as groupID,
cast(null as datetime) as Mo_customers,
cast(null as datetime) as Mo_oppo,
cast(0 as bit) as Uv,
cast(null as nvarchar(255)) as Custombackground

INTO #tblSwitch_NBS
FROM #ImposerNBS q
DROP TABLE IF EXISTS #tblSwitch_NBS_ForOutput
SELECT top 1 IDENTITY(INT,1,1) AS PKID, s.orderID, orderNo, orderDate, customerID, shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, productCode, productName, shortName, productQuantity, packetValue, variableTopName, variableBottomName, variableWholeName, backName, numUnits, displayedQuantity, ordersProductsID, shipsWith, resubmit, shipType, samplerRequest, multiCount, totalCount, displayCount, background, templateFile, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, groupID, s.productID, parentProductID, switch_create, switch_createDate, switch_approve, switch_approveDate, switch_print, switch_printDate, switch_import, mo_orders_Products, mo_orders, mo_customers, mo_customers_ShippingAddress, mo_oppo, customProductCount, customProductCode1, customProductCode2, customProductCode3, customProductCode4, fasTrakProductCount, fasTrakProductCode1, fasTrakProductCode2, fasTrakProductCode3, fasTrakProductCode4, stockProductCount, stockProductQuantity1, stockProductCode1, stockProductDescription1, stockProductQuantity2, stockProductCode2, stockProductDescription2, stockProductQuantity3, stockProductCode3, stockProductDescription3, stockProductQuantity4, stockProductCode4, stockProductDescription4, stockProductQuantity5, stockProductCode5, stockProductDescription5, stockProductQuantity6, stockProductCode6, stockProductDescription6, UV, customBackground, templateJson
INTO #tblSwitch_NBS_ForOutput
FROM #tblSwitch_NBS s
where 1=0
ORDER BY orderID, displayCount, ordersProductsID, packetValue ASC

SELECT *
FROM #tblSwitch_NBS_ForOutput 
ORDER BY PKID, orderID, displayCount, ordersProductsID, packetValue ASC

END TRY
BEGIN CATCH
	EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH