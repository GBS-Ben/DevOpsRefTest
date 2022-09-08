CREATE PROCEDURE [dbo].[usp_orderView_SearchFields_update]
AS
--THIS PROC RUNS PERIODICALLY TO REFRESH THE SEARCH FIELDS THAT THE INTRANET USES, IN CASE DATA HAS BEEN UPDATED ON THE INTRANET
--SINCE THE INCEPTION OF THE ORDER.

--// Next, run usp_searchNameConstruct, a SPROC that generates data for searchName, then populate tblOrderView.searchName
EXEC usp_searchNameConstruct

UPDATE tblOrderView
SET searchName = b.searchName
FROM tblOrderView a JOIN tblSearchName_Constructed b
ON a.orderNo = b.orderNo

--// Other Fields
UPDATE tblOrderView
SET searchCompany = b.company + ' ' + c.shipping_Company
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
JOIN tblCustomers_ShippingAddress c
ON a.orderNo = c.orderNo
AND b.company IS NOT NULL
AND c.shipping_Company IS NOT NULL

UPDATE tblOrderView
SET searchAddress = b.street + ' ' + c.shipping_Street + ' ' + c.shipping_Street2
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
JOIN tblCustomers_ShippingAddress c
ON a.orderNo = c.orderNo
AND b.street IS NOT NULL
AND c.shipping_Street IS NOT NULL
AND c.shipping_Street2 IS NOT NULL

UPDATE tblOrderView
SET searchCity = b.suburb + ' ' + c.shipping_Suburb
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
JOIN tblCustomers_ShippingAddress c
ON a.orderNo = c.orderNo
AND b.suburb IS NOT NULL
AND c.shipping_Suburb IS NOT NULL

UPDATE tblOrderView
SET searchState = b.[state] + ' ' + c.shipping_State
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
JOIN tblCustomers_ShippingAddress c
ON a.orderNo = c.orderNo
AND b.[state] IS NOT NULL
AND c.shipping_State IS NOT NULL

UPDATE tblOrderView
SET searchZip = b.postCode + ' ' + c.shipping_PostCode
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
JOIN tblCustomers_ShippingAddress c
ON a.orderNo = c.orderNo
AND b.postCode IS NOT NULL
AND c.shipping_PostCode IS NOT NULL

UPDATE tblOrderView
SET searchPhone = b.phone + ' ' + c.shipping_Phone
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
JOIN tblCustomers_ShippingAddress c
ON a.orderNo = c.orderNo
AND b.phone IS NOT NULL
AND c.shipping_Phone IS NOT NULL

UPDATE tblOrderView
SET email = b.email
FROM tblOrderView a JOIN tblCustomers b ON a.customerID = b.customerID
WHERE a.email IS NOT NULL
AND b.email IS NOT NULL
AND a.email <> b.email