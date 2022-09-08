CREATE PROC [dbo].[usp_getDashboard_PROP_ALL_Nightly]
AS

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////// tblDashboard_Prop_Orders //////////////////////////////////////////////////////////////////////////////////

--//LOCAL 1
--//Find Differential updates for existing rows in tblDashboard_Prop_Orders; 
	--modDiff will communicate to webserver which records to propagate
UPDATE tblDashboard_Prop_Orders
SET modDiff = 1
FROM tblDashboard_Prop_Orders a
JOIN tblOrders o
	ON a.orderNo = o.orderNo
WHERE 
--a.tblOrders_modified_on < o.modified_on
--AND 
modDiff <> 1
AND DATEDIFF(DD, o.orderDate, GETDATE()) <= 365

--//LOCAL 2
--//Update records reflecting new modifications
UPDATE tblDashboard_Prop_Orders
SET orderStatus = b.orderStatus, 
	calcOrderTotal = b.calcOrderTotal, 
	calcTransTotal = b.calcTransTotal, 
	calcProducts = b.calcProducts, 
	calcOPPO = b.calcOPPO, 
	calcVouchers = b.calcVouchers, 
	taxAmountAdded = b.taxAmountAdded, 
	taxDescription = b.taxDescription, 
	shippingAmount = b.shippingAmount, 
	shippingMethod = b.shippingMethod, 
	paymentMethod = b.paymentMethod, 
	paymentMethodID = b.paymentMethodID, 
	displayPaymentStatus = b.displayPaymentStatus, 
	shipping_company = b.shipping_company, 
	shipping_firstName = b.shipping_firstName, 
	shipping_surName = b.shipping_surName, 
	shipping_street = b.shipping_street, 
	shipping_street2 = b.shipping_street2, 
	shipping_suburb = b.shipping_suburb, 
	shipping_state = b.shipping_state, 
	shipping_postCode = b.shipping_postCode, 
	shipping_country = b.shipping_country, 
	shipping_phone = b.shipping_phone, 
	billing_company = b.billing_company, 
	billing_firstName = b.billing_firstName, 
	billing_surName = b.billing_surName, 
	billing_street = b.billing_street, 
	billing_street2 = b.billing_street2, 
	billing_suburb = b.billing_suburb, 
	billing_state = b.billing_state, 
	billing_postCode = b.billing_postCode, 
	billing_country = b.billing_country, 
	billing_phone = b.billing_phone,
	tblOrders_modified_on = b.modified_on,
	paymentMethodRDesc = LEFT(b.paymentMethodRDesc, 100),
	paymentMethodIsCC = b.paymentMethodIsCC,
	cardNumber = b.cardNumber,
	cardType = b.cardType,
	paymentProcessed = b.paymentProcessed,
	paymentSuccessful = b.paymentSuccessful, 
	taxAmountInTotal = b.taxAmountInTotal,
	feeAmount = b.feeAmount,
	specialInstructions = LEFT(b.specialInstructions, 100),
	shippingDesc = LEFT(CONVERT(VARCHAR(100), b.shippingDesc), 100),
	readyForProp = 1
FROM tblDashboard_Prop_Orders a
JOIN tblOrders b
	ON a.orderID = b.orderID
WHERE a.modDiff = 1

--//LOCAL 3
--//Insert new records into tblDashboard_Prop_Orders
INSERT INTO tblDashboard_Prop_Orders (orderDate, orderID, orderNo, orderStatus, calcOrderTotal, calcTransTotal, calcProducts, 
calcOPPO, calcVouchers, taxAmountAdded, taxDescription, shippingAmount, 
shippingMethod, paymentMethod, paymentMethodID, displayPaymentStatus, 
tblOrders_modified_on, readyForProp, 
customerID, shipping_company, shipping_firstName, 
shipping_surName, shipping_street, shipping_street2, shipping_suburb, shipping_state, 
shipping_postCode, shipping_country, shipping_phone, billing_company, billing_firstName, 
billing_surName, billing_street, billing_street2, billing_suburb, billing_state, 
billing_postCode, billing_country, billing_phone,
paymentMethodRDesc, paymentMethodIsCC, cardNumber, cardType, paymentProcessed, paymentSuccessful, 
taxAmountInTotal, feeAmount, specialInstructions, shippingDesc)
SELECT DISTINCT
a.orderDate, a.orderID, a.orderNo, a.orderStatus, a.calcOrderTotal, a.calcTransTotal, a.calcProducts, 
a.calcOPPO, a.calcVouchers, a.taxAmountAdded, a.taxDescription, a.shippingAmount, 
a.shippingMethod, a.paymentMethod, a.paymentMethodID, a.displayPaymentStatus, 
a.modified_on, 1, 
a.customerID, a.shipping_company, a.shipping_firstName, 
a.shipping_surName, a.shipping_street, a.shipping_street2, a.shipping_suburb, a.shipping_state, 
a.shipping_postCode, a.shipping_country, a.shipping_phone, a.billing_company, a.billing_firstName, 
a.billing_surName, a.billing_street, a.billing_street2, a.billing_suburb, a.billing_state, 
a.billing_postCode, a.billing_country, a.billing_phone,
LEFT(a.paymentMethodRDesc, 100), a.paymentMethodIsCC, a.cardNumber, a.cardType, a.paymentProcessed, a.paymentSuccessful, 
a.taxAmountInTotal, a.feeAmount, LEFT(a.specialInstructions, 100), LEFT(CONVERT(VARCHAR(100), a.shippingDesc), 100)
FROM tblOrders a
WHERE
DATEDIFF(DD, a.orderDate, GETDATE()) <= 365
AND 
a.orderID NOT IN
	(SELECT DISTINCT orderID
	FROM tblDashboard_Prop_Orders
	WHERE orderID IS NOT NULL)

--//REMOTE 1
--//Now that all records have been updated or freshly imported, insert new records into remote version of tblDashboard_Prop_Orders
DELETE FROM [dbo].[HOMLive_tblDashboard_Prop_Orders]
INSERT INTO [dbo].[HOMLive_tblDashboard_Prop_Orders] (orderDate, orderID, orderNo, orderStatus, calcOrderTotal, calcTransTotal, calcProducts, 
calcOPPO, calcVouchers, taxAmountAdded, taxDescription, shippingAmount, 
shippingMethod, paymentMethod, paymentMethodID, displayPaymentStatus, 
tblOrders_modified_on,
customerID, shipping_company, shipping_firstName, 
shipping_surName, shipping_street, shipping_street2, shipping_suburb, shipping_state, 
shipping_postCode, shipping_country, shipping_phone, billing_company, billing_firstName, 
billing_surName, billing_street, billing_street2, billing_suburb, billing_state, 
billing_postCode, billing_country, billing_phone,
paymentMethodRDesc, paymentMethodIsCC, cardNumber, cardType, paymentProcessed, paymentSuccessful, 
taxAmountInTotal, feeAmount, specialInstructions, shippingDesc)
SELECT DISTINCT
a.orderDate, a.orderID, a.orderNo, a.orderStatus, a.calcOrderTotal, a.calcTransTotal, a.calcProducts, 
a.calcOPPO, a.calcVouchers, a.taxAmountAdded, a.taxDescription, a.shippingAmount, 
a.shippingMethod, a.paymentMethod, a.paymentMethodID, a.displayPaymentStatus, 
a.tblOrders_modified_on, 
a.customerID, a.shipping_company, a.shipping_firstName, 
a.shipping_surName, a.shipping_street, a.shipping_street2, a.shipping_suburb, a.shipping_state, 
a.shipping_postCode, a.shipping_country, a.shipping_phone, a.billing_company, a.billing_firstName, 
a.billing_surName, a.billing_street, a.billing_street2, a.billing_suburb, a.billing_state, 
a.billing_postCode, a.billing_country, a.billing_phone, 
a.paymentMethodRDesc, a.paymentMethodIsCC, a.cardNumber, a.cardType, a.paymentProcessed, a.paymentSuccessful, 
a.taxAmountInTotal, a.feeAmount, a.specialInstructions, a.shippingDesc
FROM tblDashboard_Prop_Orders a
WHERE a.readyForProp = 1
AND DATEDIFF(DD, orderDate, GETDATE()) <= 365

--//LOCAL 4
--//Cleanup
UPDATE tblDashboard_Prop_Orders
SET modDiff = 0,
readyForProp = 0

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////// tblDashboard_Prop_Orders_Products /////////////////////////////////////////////////////////////////////////

--//LOCAL 1
--//Find Differential updates for existing rows in tblDashboard_Prop_Orders_Products
UPDATE tblDashboard_Prop_Orders_Products
SET modDiff = 1
FROM tblDashboard_Prop_Orders_Products a
JOIN tblOrders_Products op
	ON a.ordersProductsID = op.[ID]
WHERE a.tblOrders_Products_modified_on < op.modified_on
AND modDiff <> 1

--//LOCAL 2
--//Update records reflecting new modifications
UPDATE tblDashboard_Prop_Orders_Products
SET productCode = b.productCode, 
productName = b.productName, 
productPrice = b.productPrice, 
productQuantity = b.productQuantity, 
tblOrders_Products_modified_on = b.modified_on, 
deleteX = b.deleteX,
readyForProp = 1
FROM tblDashboard_Prop_Orders_Products a
JOIN tblOrders_Products b
	ON a.ordersProductsID = b.[ID]
WHERE a.modDiff = 1

--//LOCAL 3
--//Insert new records into tblDashboard_Prop_Orders_Products
INSERT INTO tblDashboard_Prop_Orders_Products (orderID, productID, productCode, productName, productPrice, 
productQuantity, ordersProductsID, tblOrders_Products_modified_on, deleteX, readyForProp)
SELECT DISTINCT
a.orderID, a.productID, a.productCode, a.productName, a.productPrice, 
a.productQuantity, a.[ID], a.modified_on, a.deleteX, 1
FROM tblOrders_Products a
WHERE
a.orderID IN
	(SELECT DISTINCT orderID
	FROM tblOrders
	WHERE DATEDIFF(DD, orderDate, GETDATE()) <= 365
	AND orderID IS NOT NULL)
AND a.[ID] NOT IN
	(SELECT DISTINCT ordersProductsID
	FROM tblDashboard_Prop_Orders_Products
	WHERE ordersProductsID IS NOT NULL)

--//REMOTE 1
--//Now that all records have been updated or freshly imported, insert new records into remote version of tblDashboard_Prop_Orders_Products
DELETE FROM [dbo].[HOMLive_tblDashboard_Prop_Orders_Products]
INSERT INTO [dbo].[HOMLive_tblDashboard_Prop_Orders_Products] (orderID, productID, productCode, productName, productPrice, 
productQuantity, ordersProductsID, tblOrders_Products_modified_on, deleteX)
SELECT DISTINCT
a.orderID, a.productID, a.productCode, a.productName, a.productPrice, 
a.productQuantity, a.ordersProductsID, a.tblOrders_Products_modified_on, a.deleteX
FROM tblDashboard_Prop_Orders_Products a
WHERE a.readyForProp = 1
AND a.orderID IN
	(SELECT orderID
	FROM tblOrders
	WHERE orderStatus <> 'delivered'
	AND orderStatus NOT LIKE '%Transit%'
	AND orderStatus <> 'cancelled'
	AND orderStatus <> 'failed')

--//LOCAL 4
--//Cleanup
UPDATE tblDashboard_Prop_Orders_Products
SET modDiff = 0,
readyForProp = 0

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////// tblDashboard_Prop_JobTrack ////////////////////////////////////////////////////////////////////////

--// no updates are needed in JobTrack; it's always new inserts. tblJobTrack is read-only.

--// LOCAL 1
--// grab new records:
INSERT INTO tblDashboard_Prop_JobTrack (orderNo, 
trackingNumber, trackSource, mailClass, 
deliveredOn, location, signedForBy, 
delivery_StreetNumber, delivery_StreetPrefix, 
delivery_StreetName, delivery_StreetType, delivery_StreetSuffix, 
delivery_RoomSuiteFloor, delivery_City, 
delivery_State, delivery_Zip, 
tblJobTrack_PKID,
readyForProp, pickupDate, [weight])
SELECT DISTINCT
jt.jobNumber,
jt.trackingNumber, jt.trackSource, jt.mailClass,
jt.deliveredOn, jt.location, jt.signedForBy,
jt.[Delivery Street Number] AS 'delivery_StreetNumber', jt.[Delivery Street Prefix] AS 'delivery_StreetPrefix',
jt.[Delivery Street Name] AS 'delivery_StreetName', jt.[Delivery Street Type] AS 'delivery_StreetType', jt.[Delivery Street Suffix] AS 'delivery_StreetSuffix',
jt.[Delivery Room/Suite/Floor] AS 'delivery_RoomSuiteFloor', jt.[Delivery City] AS 'delivery_City', 
jt.[Delivery State/Province] AS 'delivery_State', jt.[Delivery Postal Code] AS 'delivery_Zip',
jt.PKID 'tblJobTrack_PKID',
1, [pickup date], [weight]
FROM tblJobTrack jt
WHERE jt.PKID NOT IN
	(SELECT DISTINCT tblJobTrack_PKID
	FROM tblDashboard_Prop_JobTrack
	WHERE tblJobTrack_PKID IS NOT NULL)
AND 
jt.jobNumber IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE DATEDIFF(DD, orderDate, GETDATE()) <= 60
	AND orderNo IS NOT NULL)

--//check for missing tracking data:
DELETE FROM tblDashboard_Prop_JobTrack_MissingTracking
INSERT INTO tblDashboard_Prop_JobTrack_MissingTracking (compKey)
SELECT DISTINCT orderNo + '.' + trackingNumber
FROM [dbo].[HOMLive_tblDashboard_JobTrack]

UPDATE tblDashboard_Prop_JobTrack 
SET readyForProp = 1
--SELECT * FROM tblDashboard_Prop_JobTrack
WHERE readyForProp = 0
AND orderNo + '.' + trackingNumber NOT IN
	(SELECT DISTINCT compKey
	FROM tblDashboard_Prop_JobTrack_MissingTracking
	WHERE compKey IS NOT NULL)
AND orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE DATEDIFF(DD, orderDate, GETDATE()) <= 60
	AND orderNo IS NOT NULL)

--//REMOTE 1
--//Now that all records have been updated or freshly imported, insert new records into remote version of tblDashboard_Prop_Orders_Products
DELETE FROM [dbo].[HOMLive_tblDashboard_Prop_JobTrack]
INSERT INTO [dbo].[HOMLive_tblDashboard_Prop_JobTrack] (orderNo, 
trackingNumber, trackSource, mailClass, 
deliveredOn, location, signedForBy, 
delivery_StreetNumber, delivery_StreetPrefix, 
delivery_StreetName, delivery_StreetType, delivery_StreetSuffix, 
delivery_RoomSuiteFloor, delivery_City, 
delivery_State, delivery_Zip, 
tblJobTrack_PKID, pickupDate, [weight])
SELECT DISTINCT
orderNo, 
trackingNumber, trackSource, mailClass, 
deliveredOn, location, signedForBy, 
delivery_StreetNumber, delivery_StreetPrefix, 
delivery_StreetName, delivery_StreetType, delivery_StreetSuffix, 
delivery_RoomSuiteFloor, delivery_City, 
delivery_State, delivery_Zip, 
tblJobTrack_PKID, pickupDate, [weight]
FROM tblDashboard_Prop_JobTrack
WHERE readyForProp = 1

--//REMOTE 2
--//Update the remote flag that controls when to push dash data in
UPDATE [dbo].[HOMLive_tblFlags]
SET ordersFlag = 1
WHERE ordersFlag = 0

--//LOCAL 2
--//Cleanup
UPDATE tblDashboard_Prop_JobTrack
SET readyForProp = 0
WHERE readyForProp = 1

--//Run remote SPROC
EXEC [dbo].[HOMLive_usp_getDash]