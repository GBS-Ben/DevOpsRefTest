CREATE PROCEDURE  [dbo].[OmniInsert] 
AS
/*
-------------------------------------------------------------------------------
Author		 Jeremy Fifer
Created		 11/30/18
Purpose		 Updates OMNI search data
-------------------------------------------------------------------------------
Modification History

11/30/18		Created, jf.

-------------------------------------------------------------------------------
*/
--Only refresh Omni nightly
DECLARE @NOW DATETIME2 = GETDATE()
IF DATEPART(HH, @NOW) = 23 AND DATEPART(MI, @NOW) BETWEEN 20 AND 30
BEGIN
	DELETE FROM OMNI
	WHERE orderID IN
		(SELECT ISNULL(o.orderID, 0)
		FROM tblOrders_Products op
		INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.id
		INNER JOIN tblOrderView ov ON ov.orderID = op.OrderID
		INNER JOIN tblOrders o ON ov.orderID = o.orderID
		INNER JOIN OMNI i ON ov.orderID = i.orderID
		WHERE (o.modified_on > i.UpdatedOn
			OR op.modified_on > i.UpdatedOn
			OR oppo.modified_on > i.UpdatedOn)
		AND o.orderStatus NOT IN ('Cancelled', 'Failed', 'Delivered', 'In Transit', 'In Transit USPS', 'MIGZ'))
END

--Always run insert of new records
INSERT INTO OMNI (OrderId, SearchString, UpdatedOn)
SELECT ov.OrderID,
			 CONVERT(VARCHAR(MAX), ISNULL(ov.orderID, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderNo, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderStatus, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderType, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderTotal, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.coordIDUsed, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.brokerOwnerIDUsed, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.specialOffer, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.customerID, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shippingDesc, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.firstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.[state], '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.postCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.fax, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.email, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billingReference, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.NOP, ''))
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(oppo.textValue,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(oppo.optionCaption,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(oppo.optionGroupCaption,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.productCode,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.productName,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.fastTrak_status,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.processType,'')), ' ') 
	+ ' ' +  CASE STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.fastTrak_resubmit,'')), ' ') WHEN  '1' THEN 'resubmit'
			 ELSE ''
			 END
	+ ' ' +  CASE STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(ov.NOP, '')) , ' ') 
				WHEN  '0' THEN 'Classic'
				WHEN  '1' THEN 'NOP'
			 ELSE ''
			 END
	/*Need to reverse so we can use CONTAINS @searchterm *.  We can only add wildcard to the end of a search */
	+ REVERSE(
		 CONVERT(VARCHAR(MAX), ISNULL(ov.orderID, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderNo, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderStatus, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderType, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.orderTotal, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.coordIDUsed, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.brokerOwnerIDUsed, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.specialOffer, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.customerID, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shippingDesc, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.firstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.[state], '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.postCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.fax, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.email, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.shipping_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billing_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_shipping_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Company, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_FirstName, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Surname, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Street, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Street2, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Suburb, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_State, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_PostCode, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Country, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.tblOrders_billing_Phone, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.billingReference, '')) 
	+ ' ' +  CONVERT(VARCHAR(MAX), ISNULL(ov.NOP, ''))
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(oppo.textValue,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(oppo.optionCaption,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(oppo.optionGroupCaption,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.productCode,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.productName,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.fastTrak_status,'')), ' ') 
	+ ' ' +  STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.processType,'')), ' ') 
	+ ' ' +  CASE STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(op.fastTrak_resubmit,'')), ' ') WHEN  '1' THEN 'resubmit'
			 ELSE ''
			 END
	+ ' ' +  CASE STRING_AGG (CONVERT(NVARCHAR(MAX),ISNULL(ov.NOP, '')) , ' ') 
				WHEN  '0' THEN 'Classic'
				WHEN  '1' THEN 'NOP'
			 ELSE ''
			 END)

	AS SearchString,
	GETDATE() 
FROM tblOrders_Products op
INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.id
INNER JOIN tblOrderView ov ON ov.orderID = op.OrderID
LEFT JOIN OMNI i ON ov.orderID = i.orderID
WHERE i.orderID IS NULL
GROUP BY ov.OrderID, ov.OrderNo, ov.orderID, ov.orderNo, ov.orderStatus, ov.orderType, ov.orderTotal, 
ov.coordIDUsed, ov.brokerOwnerIDUsed, ov.specialOffer, ov.customerID, ov.shippingDesc, ov.firstName, 
ov.surname, ov.company, ov.street, ov.suburb, ov.[state], ov.postCode, ov.phone, ov.fax, ov.email, 
ov.shipping_Company, ov.shipping_FirstName, ov.shipping_Surname, ov.shipping_Street, ov.shipping_Street2, 
ov.shipping_Suburb, ov.shipping_State, ov.shipping_PostCode, ov.shipping_Country, ov.shipping_Phone, 
ov.billing_Company, ov.billing_FirstName, ov.billing_Surname, ov.billing_Street, ov.billing_Street2, 
ov.billing_Suburb, ov.billing_State, ov.billing_PostCode, ov.billing_Country, ov.billing_Phone, 
ov.tblOrders_shipping_Company, ov.tblOrders_shipping_FirstName, ov.tblOrders_shipping_Surname, 
ov.tblOrders_shipping_Street, ov.tblOrders_shipping_Street2, ov.tblOrders_shipping_Suburb, 
ov.tblOrders_shipping_State, ov.tblOrders_shipping_PostCode, ov.tblOrders_shipping_Country, 
ov.tblOrders_shipping_Phone, ov.tblOrders_billing_Company, ov.tblOrders_billing_FirstName, 
ov.tblOrders_billing_Surname, ov.tblOrders_billing_Street, ov.tblOrders_billing_Street2, 
ov.tblOrders_billing_Suburb, ov.tblOrders_billing_State, ov.tblOrders_billing_PostCode, 
ov.tblOrders_billing_Country, ov.tblOrders_billing_Phone, ov.billingReference, ov.NOP