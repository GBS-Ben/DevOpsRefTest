--//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  --//  BEGIN  

CREATE PROCEDURE [dbo].[usp_jobJacket]
AS

SET NOCOUNT ON;

BEGIN TRY

	--// determine what line items may have had updates of any kind
	--   select * From tblJobJacket where orderNo LIKE '%362867%' order by productCode
	UPDATE tblJobJacket
	SET productQuantity=b.productQuantity, 
	productName=b.productName,
	productCode=b.productCode,
	groupID=b.groupID,
	mo_orders_Products=b.modified_on
	FROM tblJobJacket a
	INNER JOIN tblOrders_Products b
		ON a.ordersProductsID=b.[ID] 
	--AND a.mo_orders_Products<>b.modified_on
	--AND a.mo_orders_Products<>b.created_on
	--AND a.mo_orders_Products IS NOT NULL
	--AND b.modified_on IS NOT NULL

	--// tblCustomers
	UPDATE tblJobJacket
	SET billCompany=b.company,
	billFirstName=b.firstName,
	billLastName=b.surName,
	billAddress1=street,
	billAddress2=street2,
	billCity=b.suburb,
	billState=b.[state],
	billZip=b.postCode,
	billCountry=b.country,
	billPhone=b.phone,
	billEmail=b.email,
	mo_customers=b.modified_on
	FROM tblJobJacket a
	INNER JOIN tblCustomers b
	ON a.customerID=b.customerID
	WHERE a.mo_customers<>b.modified_on
	AND a.mo_customers<>b.created_on
	AND a.mo_customers IS NOT NULL
	AND b.modified_on IS NOT NULL

	--// tblCustomers_ShippingAddress
	UPDATE tblJobJacket
	SET shipCompany=b.shipping_company,
	shipFirstName=b.shipping_firstName,
	shipLastName=b.shipping_surName,
	shipAddress1=shipping_street,
	shipAddress2=shipping_street2,
	shipCity=b.shipping_suburb,
	shipState=b.shipping_state,
	shipZip=b.shipping_postCode,
	shipCountry=b.shipping_country,
	shipPhone=b.shipping_phone,
	mo_customers_ShippingAddress=b.modified_on
	FROM tblJobJacket a
	INNER JOIN tblCustomers_ShippingAddress b
	ON a.shippingAddressID=b.shippingAddressID
	WHERE a.mo_customers_ShippingAddress<>b.modified_on
	AND a.mo_customers_ShippingAddress<>b.created_on
	AND a.mo_customers_ShippingAddress IS NOT NULL
	AND b.modified_on IS NOT NULL

	--// insert new records into tblJobJacket
	INSERT INTO tblJobJacket (orderID, orderNo, orderDate, samplerRequest, customerID,
	billCompany, billFirstName, billLastName, billAddress1, billAddress2, billCity, billState,  billZip, billCountry, billPhone, billEmail,
	shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone,
	ordersProductsID, productID, productCode, productName, productQuantity, groupID, 
	mo_orders_products, mo_orders, mo_customers, mo_customers_shippingAddress, 
	switch_create, switch_import)

	SELECT
	a.orderID, a.orderNo, a.orderDate, a.sampler, a.customerID,
	b.company, b.firstName, b.surName,
	b.street, b.street2, b.suburb, b.[state],
	b.postCode, b.country, b.phone, b.email,
	s.shippingAddressID, s.shipping_Company, s.shipping_Firstname, s.shipping_surName,
	s.shipping_Street, s.shipping_Street2,
	s.shipping_Suburb, s.shipping_State, s.shipping_PostCode,
	s.shipping_Country, s.shipping_Phone,
	p.[ID], p.productID, p.productCode, p.productName, p.productQuantity, p.groupID,
	p.modified_on, a.modified_on, b.modified_on, s.modified_on,
	1, 1
	FROM tblOrders a
	INNER JOIN tblCustomers b ON a.customerID=b.customerID
	INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo=s.orderNo
	INNER JOIN tblOrders_Products p ON a.orderID=p.orderID
	WHERE
	a.orderStatus<>'cancelled' AND a.orderStatus<>'failed' AND a.orderStatus<>'delivered'
	AND a.orderStatus<>'in transit' AND a.orderStatus NOT LIKE '%waiting%'
	AND p.deleteX<>'yes'
	AND p.productID IN (SELECT DISTINCT productID FROM tblProducts_Categories WHERE (categoryID=59 OR categoryID=61 OR categoryID=63 OR categoryID=67 OR categoryID=68) AND productID IS NOT NULL)
	AND p.[ID] NOT IN (SELECT DISTINCT ordersProductsID FROM tblJobJacket WHERE ordersProductsID IS NOT NULL)
	AND DATEDIFF(MI,a.orderDate,getDate())>30

	-- clean phone numbers
	UPDATE tblJobJacket
	SET billPhone='('+SUBSTRING(billPhone,1,3)+')'+SUBSTRING(billPhone,4,3)+'-'+SUBSTRING(billPhone,7,4)
	WHERE billPhone NOT LIKE '(%'

	UPDATE tblJobJacket
	SET shipPhone='('+SUBSTRING(shipPhone,1,3)+')'+SUBSTRING(shipPhone,4,3)+'-'+SUBSTRING(shipPhone,7,4)
	WHERE shipPhone NOT LIKE '(%'

	-- clean sampler request text
	UPDATE tblJobJacket
	SET samplerRequest='NCC Sampler Pack'
	WHERE samplerRequest='yes'

	UPDATE tblJobJacket
	SET samplerRequest=NULL
	WHERE samplerRequest='no'

	--// update custom option fields per line item
	-- bring in new cause
	UPDATE tblJobJacket
	SET option_cause=b.textValue
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID=b.ordersProductsID
	WHERE a.option_cause IS NULL
	AND b.optionCaption='Cause'
	AND b.deleteX<>'yes'

	-- update cause if changed
	UPDATE tblJobJacket
	SET option_cause=b.textValue
	FROM tblJobJacket a 
	INNER JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID=b.ordersProductsID
	WHERE a.option_cause IS NOT NULL
	AND a.option_cause<>CONVERT(VARCHAR(4000),b.textValue)
	AND b.optionCaption='Cause'
	AND b.deleteX<>'yes'

	--//CUSTOM INSIDE WORK ---------------------------------------------------------------------------------------------------------------

	-- bring in new customInside (edit, JF 10/29/15)
	UPDATE tblJobJacket
	SET option_customInside=b.textValue
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE (a.option_customInside IS NULL OR a.option_customInside = 'Blank_inside.pdf')
	AND (b.textValue LIKE '%-INSIDE-%' OR b.textValue LIKE '%.inside%' OR b.textValue LIKE '%GRT%')
	AND b.deleteX<>'yes'

	-- update customInside if changed (edit, JF 11/26/13)
	UPDATE tblJobJacket
	SET option_customInside=b.textValue
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE a.option_customInside IS NOT NULL
	AND replace(a.option_customInside, '.pdf','')<>CONVERT(VARCHAR(4000),b.textValue)
	AND (b.textValue LIKE '%-INSIDE-%' OR b.textValue LIKE '%.inside%')
	AND b.deleteX<>'yes'

	-- update customInside if changed (***NEW*** edit, JF 10/23/15)
	UPDATE tblJobJacket
	SET option_customInside = REPLACE(b.textValue, '/InProduction/NoteCards/Greetings/', '')
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE a.option_customInside IS NOT NULL
	AND REPLACE(a.option_customInside, '.pdf','') <> CONVERT(VARCHAR(4000), b.textValue)
	AND (b.textValue LIKE '%GRT%' OR b.textValue LIKE '%inside%')
	AND (b.optionCaption = 'File Name 3' OR b.optionCaption = 'File Name 4')
	AND b.textValue NOT LIKE '%.jpg'
	AND b.deleteX <> 'yes'

	--// END CUSTOM INSIDE WORK ---------------------------------------------------------------------------------------------------------------

	-- bring in new .cov
	UPDATE tblJobJacket
	SET option_cov=b.textValue
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE a.option_cov IS NULL
	AND b.textValue LIKE '%.cov'
	AND b.deleteX<>'yes'

	-- update .cov if changed
	UPDATE tblJobJacket
	SET option_cov=b.textValue
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE a.option_cov IS NOT NULL
	AND a.option_cov<>CONVERT(VARCHAR(4000),b.textValue)
	AND b.textValue LIKE '%.cov'
	AND b.deleteX<>'yes'

	--// Update option_cov with a custom Cov, if applicable
	UPDATE tblJobJacket
	SET option_cov=b.textValue
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID=b.ordersProductsID
	WHERE a.option_cov IS NULL
	AND b.textValue LIKE '%.pdf%'
	AND b.optionCaption = 'File Name 2'
	AND b.deleteX<>'yes'
	AND (SUBSTRING(a.productCode, 1, 4) = 'NCPC'
		OR SUBSTRING(a.productCode, 1, 4) = 'NCLC')



	--// ENVELOPES BEGIN:
	-- bring in related envelope product information (edit, JF 11/26/13)
	UPDATE tblJobJacket
	SET env_productCode=b.productCode,
	env_productName=b.productName,
	env_productQuantity=b.productQuantity
	FROM tblJobJacket a
	INNER JOIN tblOrders_Products b
		ON a.orderID=b.orderID
	WHERE (b.productCode LIKE '%NCEV%' OR b.productName LIKE '%envelope%')
	AND b.deleteX<>'yes'
	AND a.groupID=b.groupID
	AND a.env_productCode IS NULL
	AND a.env_productName IS NULL
	AND a.env_productQuantity IS NULL

	-- bring in new envelope custom info (edit, JF 11/26/13)
	UPDATE tblJobJacket
	SET option_envelope=b.textValue
	FROM tblJobJacket a INNER JOIN tblOrdersProducts_productOptions b
	ON SUBSTRING(a.option_customInside,1,14)=SUBSTRING(b.textValue,1,14)
	INNER JOIN tblOrders_Products x
	ON a.ordersProductsID=x.[ID]
	WHERE (b.textValue LIKE '%NCEV%' OR b.textValue LIKE '%.env')
	--AND a.option_envelope IS NULL
	AND b.deleteX<>'yes'

	-- update envelope custom info if changed (edit, JF 11/26/13)
	UPDATE tblJobJacket
	SET option_envelope=b.textValue
	--select a.option_envelope, b.textValue, a.orderNo
	FROM tblJobJacket a
	INNER JOIN tblOrdersProducts_productOptions b
		ON SUBSTRING(a.option_envelope,1,14)=SUBSTRING(b.textValue,1,14)
	WHERE a.option_envelope IS NOT NULL
	AND replace(a.option_envelope, '.pdf', '')<>CONVERT(VARCHAR(4000),b.textValue)
	AND (b.textValue LIKE '%NCEV%' OR b.textValue LIKE '%.env')
	AND b.deleteX<>'yes'


	-- New section that accounts for orders that have no custom product, but still have custom envelope(s)
	UPDATE tblJobJacket
	SET option_envelope=b.textValue
	FROM tblJobJacket a INNER JOIN tblOrders o
	ON a.orderNo = o.orderNo
	INNER JOIN tblOrders_Products p
	ON o.orderID = p.orderID
	INNER JOIN tblOrdersProducts_productOptions b
	ON p.[ID] = b.ordersProductsID
	WHERE (a.option_customInside IS NULL OR a.option_customInside LIKE '%Blank_inside%')
	AND ((a.option_envelope NOT LIKE '%NCEV%' AND a.option_envelope NOT LIKE '%NCENV%' AND a.option_envelope NOT LIKE '%.env') OR a.option_envelope IS NULL)
	AND (b.textValue LIKE '%NCEV%' OR b.textValue LIKE '%.env')
	AND b.deleteX<>'yes'
	AND a.env_productName = p.productName

	-- update related envelope color
	UPDATE tblJobJacket
	SET env_color='Red'
	WHERE env_productName LIKE '%Red%'
	AND env_color IS NULL

	UPDATE tblJobJacket
	SET env_color='Green'
	WHERE env_productName LIKE '%Green%'
	AND env_color IS NULL

	UPDATE tblJobJacket
	SET env_color='White'
	WHERE env_productName LIKE '%White%'
	AND env_color IS NULL

	UPDATE tblJobJacket
	SET env_color='Tan'
	WHERE env_productName LIKE '%Tan%'
	AND env_color IS NULL

	UPDATE tblJobJacket
	SET env_color='Kraft'
	WHERE env_productName LIKE '%Kraft%'
	AND env_color IS NULL

	UPDATE tblJobJacket
	SET env_color='Yellow'
	WHERE env_productName LIKE '%Yellow%'
	AND env_color IS NULL

	UPDATE tblJobJacket
	SET env_color='Gray'
	WHERE env_productName LIKE '%Gray%'
	AND env_color IS NULL

	-- update default "no image" value if option_envelope is still blank
	UPDATE tblJobJacket
	SET option_envelope='no.env.image.env.pdf'
	WHERE option_envelope IS NULL
	OR option_envelope=''

	--// determine shipsWith value (updated to include FT concepts on 12/10/15; jf)
	-- 1. if order contains at least one custom product, and any varying QTY of any other product types, label "Ships With Custom"
	UPDATE tblJobJacket
	SET shipsWith='Ships with Custom'
	WHERE orderID IN
		(SELECT DISTINCT orderID 
		FROM tblOrders_Products 
		WHERE deleteX<>'yes'
		AND orderID IS NOT NULL
		AND processType = 'Custom'
		 )

	-- 2. if order contains at least one FT product, no custom products, and any varying QTY of any other product types, label "Ships With fasTrak"
	UPDATE tblJobJacket
	SET shipsWith='Ships with fasTrak'
	--select * from tblJobJacket
	WHERE (shipsWith IS NULL OR shipsWith <> 'Ships with Custom')
	AND orderID IN
		(SELECT DISTINCT orderID 
		FROM tblOrders_Products 
		WHERE deleteX<>'yes'
		AND orderID IS NOT NULL
		AND processType = 'fasTrak'
		 )

	-- 3. finally, if order contains stock product(s) but no custom or FT product(s), label "Ships With Stock"
	UPDATE tblJobJacket
	SET shipsWith='Ships with Stock'
	WHERE shipsWith IS NULL
	AND orderID IN
	(SELECT DISTINCT orderID FROM tblOrders_Products WHERE deleteX<>'yes'AND orderID IS NOT NULL
	 AND productID NOT IN
		(SELECT DISTINCT productID FROM tblProducts_Categories WHERE categoryID=59 AND productID IS NOT NULL
		 OR categoryID=61 AND productID IS NOT NULL)
	 AND productID IN
		(SELECT DISTINCT productID FROM tblProducts WHERE productType='Stock' AND productName NOT LIKE '%envelope%' AND productID IS NOT NULL)
	 )

	-- 4. otherwise, if order contains only giving cards, then put the barcoded ONHOM123456 in
	UPDATE tblJobJacket
	SET shipsWith='ON'+orderNo
	WHERE shipsWith IS NULL

	--// Products
	UPDATE tblJobJacket
	SET parentProductID=b.parentProductID,
	numUnits=b.numUnits
	FROM tblJobJacket a
	INNER JOIN tblProducts b
		ON a.productID=b.productID

	--// Fix Quantities
	UPDATE tblJobJacket
	SET displayedQuantity=productQuantity*numUnits

	UPDATE tblJobJacket
	SET env_productQuantity=productQuantity*numUnits

	--select * from tblJobJacket

	--// Images
	-- option_cov
	UPDATE tblJobJacket
	SET option_cov=option_cov+'.pdf'
	WHERE option_cov LIKE '%.cov'

	--// the substring below had to change from 1,10 to 1,12 due to the productCode length change recently. JF, 072513
	UPDATE tblJobJacket
	SET option_cov=SUBSTRING(productCode,1,12)+'.pdf'
	WHERE option_cov IS NULL

	-- option_customInside (edit, JF 11/26/13)
	UPDATE tblJobJacket
	SET option_customInside=option_customInside+'.pdf'
	WHERE (option_customInside LIKE '%-INSIDE-%' OR option_customInside LIKE '%.inside%')
	AND option_customInside NOT LIKE '%.pdf'

	UPDATE tblJobJacket
	SET option_customInside='Blank_inside.pdf'
	WHERE option_customInside IS NULL

	-- option_envelope (edit, JF 12/13/13)
	UPDATE tblJobJacket
	SET option_envelope=option_envelope+'.pdf'
	WHERE (option_envelope LIKE '%NCEV%' OR option_envelope LIKE '%.env')
	AND option_envelope NOT LIKE '%.pdf'

	--WHITE
	UPDATE tblJobJacket
	SET option_envelope='Envelope.Front.m.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes White%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes White%'

	--RED
	UPDATE tblJobJacket
	SET option_envelope='EnvelopeRed.Front.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes Red%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes Red%'

	--GREEN
	UPDATE tblJobJacket
	SET option_envelope='EnvelopeGreen.Front.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes Green%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes Green%'

	--KRAFT
	UPDATE tblJobJacket
	SET option_envelope='EnvelopeKraft.Front.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes Kraft%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes Kraft%'

	--TAN
	UPDATE tblJobJacket
	SET option_envelope='EnvelopeTan.Front.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes Tan%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes Tan%'

	--YELLOW
	UPDATE tblJobJacket
	SET option_envelope='EnvelopeYellow.Front.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes Yellow%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes Yellow%'

	--GRAY
	UPDATE tblJobJacket
	SET option_envelope='EnvelopeGray.Front.pdf'
	WHERE option_envelope IS NULL AND env_productName LIKE 'Envelopes Gray%'
	OR option_envelope='no.env.image.env.pdf' AND env_productName LIKE 'Envelopes Gray%'

	-- option_cause
	UPDATE tblJobJacket
	SET option_cause='No Cause Selected'
	WHERE option_cause IS NULL

	-- option_bak
	UPDATE tblJobJacket SET option_bak='GC_AutismBack.H.pdf' WHERE option_bak IS NULL AND option_cause='The Autism Society of San Diego' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_AutismBack.V.pdf' WHERE option_bak IS NULL AND option_cause='The Autism Society of San Diego' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_BloodWaterBack.H.pdf' WHERE option_bak IS NULL AND option_cause='Blood:Water Mission' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_BloodWaterBack.V.pdf' WHERE option_bak IS NULL AND option_cause='Blood:Water Mission' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_BootBack.H.pdf' WHERE option_bak IS NULL AND option_cause='Boot Campaign' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_BootBack.V.pdf' WHERE option_bak IS NULL AND option_cause='Boot Campaign' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_EducationBack.H.pdf' WHERE option_bak IS NULL AND option_cause='Education' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_EducationBack.V.pdf' WHERE option_bak IS NULL AND option_cause='Education' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_erasepovertyBack.H.pdf' WHERE option_bak IS NULL AND option_cause='Erase Poverty' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_ErasePoverty.V.pdf' WHERE option_bak IS NULL AND option_cause='Erase Poverty' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_Love146Back.H.pdf' WHERE option_bak IS NULL AND option_cause='Love146' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_Love146Back.V.pdf' WHERE option_bak IS NULL AND option_cause='Love146' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_MosquitoNetsBack.H.pdf' WHERE option_bak IS NULL AND option_cause='Mosquito Nets' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_MosquitoNetsBack.V.pdf' WHERE option_bak IS NULL AND option_cause='Mosquito Nets' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_PlantPurposeBack.H.pdf' WHERE option_bak IS NULL AND option_cause='Plant With Purpose' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_PlantPurposeBack.V.pdf' WHERE option_bak IS NULL AND option_cause='Plant With Purpose' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_RedCrossBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='American Red Cross' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_RedCrossBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='American Red Cross' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='NCC_Back.H.pdf' WHERE option_bak IS NULL AND option_cause='No Cause Selected' AND SUBSTRING(productCode,5,1)='H' 
	UPDATE tblJobJacket SET option_bak='NCC_Back.H.pdf' WHERE option_bak IS NULL AND option_cause IS NULL AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='NCC_Back.V.pdf' WHERE option_bak IS NULL AND option_cause='No Cause Selected' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='NCC_Back.V.pdf' WHERE option_bak IS NULL AND option_cause IS NULL AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_CCFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='ccfoodbank' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_CCFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='ccfoodbank' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_CCFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='Clark County Food Bank' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_CCFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='Clark County Food Bank' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_BideaweeBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%bideawee%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_BideaweeBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%bideawee%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_LRMFBBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%lewis%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_LRMFBBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%lewis%' AND SUBSTRING(productCode,5,1)='V'

	-- (edit, JF 11/26/13)
	UPDATE tblJobJacket SET option_bak='GC_BBBSBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='Big Brothers Big Sisters of San Diego County' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_BBBSBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='Big Brothers Big Sisters of San Diego County' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_BBBSBack.X.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='Big Brothers Big Sisters of San Diego County 2' AND SUBSTRING(productCode,5,1)='X'

	UPDATE tblJobJacket SET option_bak='GC_JanusBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%Janus%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_JanusBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%Janus%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_MarthasPantryBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%martha%' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_MarthasPantryBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause) LIKE '%martha%' AND SUBSTRING(productCode,5,1)='V'
	UPDATE tblJobJacket SET option_bak='GC_NCCFoodBankBack.H.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='North County Community Food Bank' AND SUBSTRING(productCode,5,1)='H'
	UPDATE tblJobJacket SET option_bak='GC_NCCFoodBankBack.V.pdf' WHERE option_bak IS NULL AND RTRIM(option_cause)='North County Community Food Bank' AND SUBSTRING(productCode,5,1)='V'

	--// Populate shortName column where NULL (added: 11/04/2013, JF)

	UPDATE tblJobJacket
	SET shortName = rtrim(substring(productName,1,(SELECT CHARINDEX('(', productName)-1)))
	WHERE shortName is NULL
	OR shortName = ''

	UPDATE tblJobJacket
	SET shortName = replace(shortName,(substring(shortName,1,(SELECT CHARINDEX('-', productName)+1))),'')
	WHERE shortName like '%-%'
	AND shortName is NOT NULL

	--// Counts (do multiCount and totalCount with FOR WHILE Loop)

			IF OBJECT_ID(N'tempGC_Count', N'U') IS NOT NULL
			DROP TABLE tempGC_Count

			CREATE TABLE tempGC_Count (
			 RowID int IDENTITY(1, 1),
			 orderNo varchar(255),
			 ordersProductsID int,
			 multiCount int
			)
			DECLARE @NumberRecords int, @RowCount int
			DECLARE @orderNo varchar(255)
			DECLARE @ordersProductsID int
			DECLARE @totalCount int
			DECLARE @multiCount int

			-- Insert the resultset we want to loop through into the temporary table
			INSERT INTO tempGC_Count (orderNo, ordersProductsID, multiCount)
			SELECT DISTINCT orderNo, ordersProductsID,
			ROW_NUMBER() OVER (PARTITION BY orderNO ORDER BY ordersProductsID) AS 'multiCount'
			FROM tblJobJacket
			WHERE orderNo IS NOT NULL
			AND productName NOT LIKE '%Envelope%'
			ORDER BY orderNo, ordersProductsID

			-- Get the number of records in the temporary table
			SET @NumberRecords = @@ROWCOUNT
			SET @RowCount = 1

			-- loop through all records in the temporary table using the WHILE loop construct
			WHILE @RowCount <= @NumberRecords
			BEGIN

			SELECT @orderNo=orderNo, @ordersProductsID=ordersProductsID, @multiCount=multiCount
			FROM tempGC_Count
			WHERE RowID = @RowCount

			SET @totalCount=(SELECT COUNT(orderNo) FROM tblJobJacket WHERE orderNo=@orderNo)

			UPDATE tblJobJacket
			SET totalCount=@totalCount, multiCount=@multiCount
			WHERE ordersProductsID=@ordersProductsID

			SET @RowCount = @RowCount + 1
			END

			-- drop the temporary table
			IF OBJECT_ID(N'tempGC_Count', N'U') IS NOT NULL
			DROP TABLE tempGC_Count

	-- displayCount creation
	UPDATE tblJobJacket
	SET displayCount=CONVERT(varchar(50),multiCount)+' of '+CONVERT(varchar(50),totalCount)
	WHERE multiCount IS NOT NULL
	AND totalCount IS NOT NULL

	-- fix blank totalCounts and multiCounts (usually envelopes) so that they are not null.
	UPDATE tblJobJacket
	SET totalCount = 0
	WHERE totalCount IS NULL

	UPDATE tblJobJacket
	SET multiCount = 0
	WHERE multiCount IS NULL

	-- remove deleted products
	DELETE FROM tblJobJacket
	WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] FROM tblOrders_Products WHERE deleteX='yes')

	-- quick fix for PDF extensions (should these extensions still exist in the data)
	UPDATE tblJobJacket
	SET option_envelope=replace(option_envelope,'.jpg','.pdf')
	WHERE option_envelope like '%.jpg'

	UPDATE tblJobJacket
	SET option_cov=replace(option_cov,'.jpg','.pdf')
	WHERE option_cov like '%.jpg'

	UPDATE tblJobJacket
	SET option_bak=replace(option_bak,'.eps','.pdf')
	WHERE option_bak like '%.eps'

	-- set import flags and make new line items available to switch
	UPDATE tblJobJacket
	SET switch_create=0
	WHERE switch_create is NULL or switch_create=''

	UPDATE tblJobJacket
	SET switch_create=0
	WHERE switch_import=1

	UPDATE tblJobJacket
	SET switch_import=0
	WHERE switch_import=1


END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH