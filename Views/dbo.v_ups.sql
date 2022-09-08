CREATE VIEW [dbo].[v_ups]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     8/6/05
-- Purpose     This view is used by UPS Worldship for the Import Key. The data in this view is pulled into Worldship
 --			   when a 4 digit jobnumber is entered (v_ups.Unique_Identifier).
-------------------------------------------------------------------------------------
-- Modification History
-- 06/11/15		updated, jf.
-- 04/11/17		rewrite, jf.
-- 07/25/17		shreck.  dont exclude orders in jobtrack
-- 08/13/18		updated for new db, jf.
-- 08/22/18		updated to use ScanShip table. We should eventually ditch the view and do a call on the table directly, jf.
-------------------------------------------------------------------------------------

SELECT 
Unique_Identifier, Customer_ID, Company, Address_1, Address_2, City, [State], Zip, Country, Phone, [Service], Billing_Option, Attention, Email, noti_flag, 
From_Company, From_Address, From_City, From_State, From_Zip, From_Phone, From_Fax, From_Country, SpecialInstructions, fStoreID, fCompany, fAddress1, 
fCity, fState, fZip, fTollFree, fFax, fCSZ, totalBadgeWeight
FROM ScanShip 

/*
--// HAVE NOT SHIPPED YET
--Part 1. Retrieve all orders that have never been scanned to ship. Adds the ON prefix to them.
SELECT  'ON' + a.orderNo AS 'Unique_Identifier', 
	CONVERT(VARCHAR(50), a.orderNo) AS 'Customer_ID', 
	CONVERT(VARCHAR(255), x.Shipping_company) AS 'Company', 
	CONVERT(VARCHAR(255), x.Shipping_street) AS 'Address_1', 
	CONVERT(VARCHAR(255), x.Shipping_street2) AS 'Address_2', 
	CONVERT(VARCHAR(100), x.Shipping_suburb) AS 'City', 
	CONVERT(VARCHAR(50), x.Shipping_state) AS 'State', 
	CONVERT(VARCHAR(50), x.Shipping_postCode) AS 'Zip', 
	'USA' AS 'Country', 
	CONVERT(VARCHAR(50), x.Shipping_phone) AS 'Phone', 
	'UPS Ground' AS 'Service', 
	'Prepaid' AS 'Billing_Option', 
	REPLACE(CONVERT(VARCHAR(255), (x.Shipping_firstName + ' ' + x.Shipping_surname)), ' ', ' ') AS 'Attention', 
	CONVERT(VARCHAR(255), z.email) AS 'Email', 
	'Y' AS 'noti_flag', 
	'Markful' AS 'From_Company', 
	'1912 John Towers Avenue' AS 'From_Address', 
	'El Cajon' AS 'From_City', 
	'CA' AS 'From_State', 
	'92020' AS 'From_Zip', 
	'800-789-6247' AS 'From_Phone', 
	'619-449-6248' AS 'From_Fax', 
	'USA' AS 'From_Country', 
	CONVERT(VARCHAR(255), a.specialInstructions) AS 'SpecialInstructions', 
	f.storeID AS 'fStoreID', f.Company AS 'fCompany', f.Address1 AS 'fAddress1', f.City AS 'fCity', 
	f.[state] AS 'fState', f.Zip AS 'fZip', f.tollFree AS 'fTollFree', f.fax AS 'fFax', f.CSZ AS 'fCSZ',
	a.calcBadges AS 'totalBadgeWeight'
FROM tblOrders a
INNER JOIN tblCustomers z 
	ON a.customerID = z.customerID
INNER  JOIN tblShipping_FROM f 
	ON a.storeID = f.storeID
INNER JOIN tblCustomers_ShippingAddress x 
	ON a.orderNo = x.orderNo
LEFT JOIN tblJobTrack jt
	ON a.orderNo = jt.jobNumber
WHERE jt.jobNumber IS NULL
AND ISNULL(a.shippingDesc,'') NOT LIKE 'Local Pickup%'
AND DATEDIFF(dd, a.orderDate, GETDATE()) < 160

UNION

--// ALREADY SHIPPED
--Part 2. Retrieve all orders that have been scanned to ship. Adds the ON prefix to them. Subsitutes the CITY field with a warning.
SELECT  'ON' + a.orderNo AS 'Unique_Identifier', 
CONVERT(VARCHAR(50), a.orderNo) + 'R' AS 'Customer_ID', 
CONVERT(VARCHAR(255), x.Shipping_company) AS 'Company', 
CONVERT(VARCHAR(255), x.Shipping_street) AS 'Address_1', 
CONVERT(VARCHAR(255), x.Shipping_street2) AS 'Address_2', 
'JOB HAS ALREADY SHIPPED' AS 'City', 
CONVERT(VARCHAR(50), x.Shipping_state) AS 'State', 
CONVERT(VARCHAR(50), x.Shipping_postCode) AS 'Zip', 
'USA' AS 'Country', 
CONVERT(VARCHAR(50), x.Shipping_phone) AS 'Phone', 
'UPS Ground' AS 'Service', 
'Prepaid' AS 'Billing_Option', 
REPLACE(CONVERT(VARCHAR(255), (x.Shipping_firstName + ' ' + x.Shipping_surname)), ' ', ' ') AS 'Attention', 
CONVERT(VARCHAR(255), z.email) AS 'Email', 
'Y' AS 'noti_flag', 
'Markful' AS 'From_Company', 
'1912 John Towers Avenue' AS 'From_Address', 
'El Cajon' AS 'From_City', 
'CA' AS 'From_State', 
'92020' AS 'From_Zip', 
'800-789-6247' AS 'From_Phone', 
'619-449-6248' AS 'From_Fax', 
'USA' AS 'From_Country', 
CONVERT(VARCHAR(255), a.specialInstructions) AS 'SpecialInstructions', 
f.storeID AS 'fStoreID', f.Company AS 'fCompany', f.Address1 AS 'fAddress1', f.City AS 'fCity', 
f.[state] AS 'fState', f.Zip AS 'fZip', f.tollFree AS 'fTollFree', f.fax AS 'fFax', f.CSZ AS 'fCSZ',
a.calcBadges AS 'totalBadgeWeight'
FROM tblOrders a
INNER JOIN tblCustomers z 
	ON a.customerID = z.customerID
INNER JOIN tblShipping_FROM f 
	ON a.storeID = f.storeID
INNER JOIN tblCustomers_ShippingAddress x 
	ON a.orderNo = x.orderNo
INNER JOIN tblJobTrack jt
	ON a.orderNo = jt.jobNumber
WHERE 
ISNULL(a.shippingDesc,'') NOT LIKE 'Local Pickup%'
AND DATEDIFF(dd, a.orderDate, GETDATE()) < 160

UNION

--Part 3. Retrieve Marketplace orders
SELECT 'ON' + a.orderNo AS 'Unique_Identifier', 
a.orderNo AS 'Customer_ID', 
' ' AS 'Company', 
a.[ship-address-1] AS 'Address_1', 
a.[ship-address-2] AS 'Address_2', 
a.[ship-city] AS 'City', 
a.[ship-state] AS 'State', 
a.[ship-postal-code] AS 'Zip', 
'USA' AS 'Country', 
a.[ship-phone-number] AS 'Phone', 
'UPS Ground' AS 'Service', 
'Prepaid' AS 'Billing_Option', 
a.[recipient-name] AS 'Attention', 
a.[buyer-email] AS 'Email', 
'Y' AS 'noti_flag', 
'Note Card Cafe' AS 'From_Company', 
'1912 John Towers Avenue' AS 'From_Address', 
'El Cajon' AS 'From_City', 
'CA' AS 'From_State', 
'92020' AS 'From_Zip', 
'800-789-6247' AS 'From_Phone', 
'619-449-6248' AS 'From_Fax', 
'USA' AS 'From_Country', 
' ' AS 'SpecialInstructions', 
f.storeID AS 'fStoreID', f.Company AS 'fCompany', f.Address1 AS 'fAddress1', 
f.City AS 'fCity', f.[state] AS 'fState', f.Zip AS 'fZip', f.tollFree AS 'fTollFree', 
f.fax AS 'fFax', f.CSZ AS 'fCSZ',
0 AS 'totalBadgeWeight'
FROM tblAMZ_orderShip a 
INNER JOIN tblShipping_FROM f 
	ON a.storeID = f.storeID
WHERE 
-DATEDIFF(dd, CONVERT(DATETIME, a.orderDate), GETDATE()) < 160
AND a.orderStatus < > 'Shipped'
GO
*/