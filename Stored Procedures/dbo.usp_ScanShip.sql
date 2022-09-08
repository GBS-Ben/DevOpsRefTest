CREATE PROCEDURE [dbo].[usp_ScanShip]
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		08/22/2018
-- Purpose		This proc populates ScanShip table with data used for shipping station scans.
--						This replaces v_ups.

-------------------------------------------------------------------------------
-- Modification History
--
--08/22/18		Created, JF
--09/13/18		Added cte, JF
--03/28/19		Added Attention to the update, BS
--09/11/19		JF, updated some dates stuff and MIGZ additions.
--01/14/20		BS, removed the < 2 days because it caused missing orders
--				and no shipping records.
--04/27/21		CKB, Markful
-------------------------------------------------------------------------------
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;WITH cte
AS
(SELECT x.orderNo
FROM tblOrders x
LEFT JOIN ScanShip w ON x.orderNo = w.orderNo
WHERE DATEDIFF(DD,x.orderDate, GETDATE()) < 60)

-- Insert regular orders

INSERT INTO ScanShip (Unique_Identifier, Customer_ID, Company, Address_1, Address_2, City, [State], Zip, Country, Phone, [Service], Billing_Option, Attention, Email, noti_flag, From_Company, From_Address, From_City, From_State, From_Zip, From_Phone, From_Fax, From_Country, SpecialInstructions, fStoreID, fCompany, fAddress1, fCity, fState, fZip, fTollFree, fFax, fCSZ, totalBadgeWeight, orderNo)

SELECT DISTINCT 'ON' + a.orderNo AS 'Unique_Identifier', 
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
	a.calcBadges AS 'totalBadgeWeight',
	a.orderNo
FROM tblOrders a
INNER JOIN cte c ON a.orderNo = c.orderNo
INNER JOIN tblCustomers z ON a.customerID = z.customerID
INNER JOIN tblShipping_FROM f ON a.storeID = f.storeID
INNER JOIN tblCustomers_ShippingAddress x ON a.orderNo = x.orderNo
LEFT JOIN ScanShip w ON a.orderNo = w.orderNo
WHERE w.orderNo IS NULL
AND LEN(a.orderNo) IN (9, 10, 11)
AND ISNULL(a.shippingDesc,'') NOT LIKE 'Local Pickup%'
AND a.orderStatus <> 'MIGZ'

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;WITH cte
AS
(SELECT x.orderNo
FROM tblAMZ_orderShip x
LEFT JOIN ScanShip w ON x.orderNo = w.orderNo
WHERE DATEDIFF(DD,x.orderDate, GETDATE()) < 60)

-- Insert Marketplace orders

INSERT INTO ScanShip (Unique_Identifier, Customer_ID, Company, Address_1, Address_2, City, [State], Zip, Country, Phone, [Service], Billing_Option, Attention, Email, noti_flag, From_Company, From_Address, From_City, From_State, From_Zip, From_Phone, From_Fax, From_Country, SpecialInstructions, fStoreID, fCompany, fAddress1, fCity, fState, fZip, fTollFree, fFax, fCSZ, totalBadgeWeight, orderNo)

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
0 AS 'totalBadgeWeight',
 a.orderNo
FROM tblAMZ_orderShip a 
INNER JOIN cte c ON a.orderNo = c.orderNo
INNER JOIN tblShipping_FROM f ON a.storeID = f.storeID 
LEFT JOIN ScanShip w ON a.orderNo = w.orderNo
WHERE w.orderNo IS NULL
 AND a.orderStatus < > 'Shipped'

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Updated Shipped orders

UPDATE a
SET City = 'JOB HAS ALREADY SHIPPED',
	   Shipped = 1,
	   Customer_ID = Customer_ID + 'R'
FROM ScanShip a
INNER JOIN tblJobTrack jt ON a.orderNo = jt.jobNumber  
AND a.Shipped = 0

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Updated Changed orders in tblCustomers_ShippingAddress

;WITH cte
AS
(SELECT orderNo
FROM tblCustomers_ShippingAddress x
WHERE DATEDIFF(DD,x.modified_on, GETDATE()) < 60)

UPDATE a
SET Company = x.Shipping_company,
Address_1 = x.Shipping_street,
Address_2 = x.Shipping_street2,
City = x.Shipping_suburb,
[State] = x.Shipping_state,
Zip = x.Shipping_postCode,
Phone = x.Shipping_phone,
Attention = x.Shipping_FirstName + ISNULL(NULLIF(x.Shipping_Surname,''),'')
FROM ScanShip a
INNER JOIN cte c ON a.orderNo = c.orderNo
INNER JOIN tblCustomers_ShippingAddress x ON a.orderNo = x.orderNo
WHERE x.modified_on> a.modified_on