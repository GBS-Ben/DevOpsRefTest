-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/26/12
-- Purpose     Main Website data migration.
-------------------------------------------------------------------------------
-- Modification History
--
-- 09/01/07		Created, jf.
-- 09/19/18		Added the subquery for tblCredits as there should only ever be one credit per order, jf.
-- 09/25/18		Reverted change above, jf.


--exec [usp_getOrderView_TestJF_SafetoDelete] 555776429
--exec [usp_getOrderView_TestJF_SafetoDelete] 555776454
-------------------------------------------------------------------------------

CREATE PROC [dbo].[usp_getOrderView_TestJF_SafetoDelete]
@orderID INT

AS

SELECT DISTINCT 
a.calcOrderTotal
,a.calcTransTotal
,a.calcProducts
,a.calcOPPO
,a.displayPaymentStatus
,a.orderStatus
,a.tabStatus
,a.orderType
,a.orderAck
,a.orderJustPrinted
,a.orderCancelled
,CONVERT(VARCHAR(255),a.messageToCustomer) AS 'messageToCustomer'
,a.feeAmount
,a.paymentMethodIsCC
,a.paymentMethodIsSC
,a.paymentMethodID
,a.cardStoreInfo
,a.orderID
,a.orderNo
,a.orderDate
,a.orderTotal
,a.paymentAmountRequired
,a.shippingAmount
,a.shippingMethod
,CONVERT(VARCHAR(255),a.shippingDesc ) AS 'shippingDesc'
,CONVERT(VARCHAR(255),a.specialInstructions) AS 'specialInstructions'
,a.taxAmountInTotal
,a.taxAmountAdded
,a.taxDescription
,a.ipAddress
,a.referrer
,a.reasonforpurchase
,a.lastStatusUpdate
,a.coordIDUsed
,a.brokerOwnerIDUsed
,a.specialOffer
,a.repName
,a.grpOrder
,a.resCom
,a.shipZone
,a.sampler
,a.paymentMethod
,a.cardNumber
,a.cardCCV
,a.cardExpiryMonth
,a.cardExpiryYear
,a.cardName
,a.cardType
,a.paymentProcessed
,a.paymentProcessedDate
,a.paymentSuccessful
,a.membershipType
,a.cartVersion, a.NOP
,a.billing_Company AS 'tblOrders_billing_Company'
,a.billing_FirstName AS 'tblOrders_billing_FirstName'
,a.billing_Surname AS 'tblOrders_billing_Surname'
,a.billing_Street AS 'tblOrders_billing_Street'
,a.billing_Street2 AS 'tblOrders_billing_Street2'
,a.billing_Suburb AS 'tblOrders_billing_Suburb'
,a.billing_State AS 'tblOrders_billing_State'
,a.billing_PostCode AS 'tblOrders_billing_PostCode'
,a.billing_Country AS 'tblOrders_billing_Country'
,a.billing_Phone AS 'tblOrders_billing_Phone'
,a.billingReference
,b.processType
,b.ID
,b.productID
,b.productName
,b.productCode
,b.optionID
,b.productPrice
,b.productQuantity
,b.delivered
,b.deliveredDate
,b.deliveryTrackingNumber
,b.deletex
,b.ID
,b.dateInput
,b.groupID
,b.fastTrak_status
,b.fastTrak_status_lastModified
,b.fastTrak
,c.customerID
,c.firstName
,c.surname
,CASE 
	WHEN c.company = '' THEN s.shipping_Company
	ELSE CONVERT(VARCHAR(255), c.company)
END AS 'company'
--,c.company
,c.street
,c.street2
,c.suburb
,c.postCode
,c.[state]
,c.country
,c.phone
,c.fax
,c.email
,c.sUserDefined
,c.po
,c.monthlyBill
,p.shortDescription
,p.productType
,p.productCompany
,p.itemStyle
,p.dimensionW
,p.productHeader
,p.displayOrderGroup
,p.shortName
,bl.billing_Company
,bl.billing_FirstName
,bl.billing_Surname
,bl.billing_Street
,bl.billing_Street2
,bl.billing_Suburb
,bl.billing_State
,bl.billing_PostCode
,bl.billing_Country
,bl.billing_Phone
,s.shipping_Company AS 'tblOrders_shipping_Company'
,s.shipping_FirstName AS 'tblOrders_shipping_FirstName'
,s.shipping_Surname AS 'tblOrders_shipping_Surname'
,s.shipping_Street AS 'tblOrders_shipping_Street'
,s.shipping_Street2 AS 'tblOrders_shipping_Street2'
,s.shipping_Suburb AS 'tblOrders_shipping_Suburb'
,s.shipping_State AS 'tblOrders_shipping_State'
,s.shipping_PostCode AS 'tblOrders_shipping_PostCode'
,s.shipping_Country AS 'tblOrders_shipping_Country'
,s.shipping_Phone AS 'tblOrders_shipping_Phone'
,s.shipping_Company
,s.shipping_FirstName
,s.shipping_Surname
,s.shipping_Street
,s.shipping_Street2
,s.shipping_Suburb
,s.shipping_State
,s.shipping_PostCode
,s.shipping_Country
,s.shipping_Phone
,s.address_type
,CASE 
	WHEN s.isValidated IS NULL THEN ''
	ELSE CONVERT(VARCHAR(255), s.isValidated)
END AS 'isValidated'
,CASE 
	WHEN s.rdi IS NULL THEN ''
	ELSE CONVERT(VARCHAR(255), s.rdi)
END AS 'rdi'
,CASE 
	WHEN s.returnCode IS NULL THEN ''
	ELSE CONVERT(VARCHAR(255), s.returnCode)
END AS 'returnCode'
,CASE 
	WHEN s.UPSRural IS NULL THEN ''
	ELSE CONVERT(VARCHAR(255), s.UPSRural)
END AS 'UPSRural'
,v.voucherCode
,v.initialAmount
,v.valueApplied
,v.valueRemaining
,dv.dVoucherCode
,dv.dVoucherAmount
,vsu.sVoucherID
,vsu.sVoucherCode
,vsu.sVoucherAmountApplied
,vsu.isDeleted
,r.creditID
,r.creditOrderID
,r.creditDesc
,r.creditAmount
FROM dbo.tblOrders a
LEFT JOIN tblOrders_Products b 
	ON a.orderID = b.orderID 
LEFT JOIN tblCustomers c 
	ON a.customerID = c.customerID 
left join (SELECT   vu.orderid,   
            STUFF((    SELECT ',' + v2.voucherCode 
                        FROM tblVoucherUse vu2
						inner join tblVouchers v2 on vu2.voucherID = v2.voucherID
                        WHERE vu2.orderID = @orderID and
                        vu.orderID = vu2.orderID
                        FOR XML PATH('') 
                        ), 1, 1, '' )
                        
            AS [VoucherCode],
			sum(vu.valueApplied) as valueApplied
			,sum(vu.valueRemaining) as valueRemaining
			,sum(v.initialAmount) as initialAmount
			FROM  tblVoucherUse vu
			inner join tblVouchers v on vu.voucherID = v.voucherID
			where vu.orderID = @orderID
			group by vu.orderid) v	
	ON v.orderID = a.orderID
LEFT JOIN tblProducts p 
	ON b.productID = p.productID 
LEFT JOIN tblDiscountVouchers dv 
	ON a.orderID = dv.orderID 
LEFT JOIN --tblVouchersSalesUse vsu
	(
		select
			orderID
			,min(sVoucherID) sVoucherID
			,min(sVoucherCode) sVoucherCode
			,max(sVoucherAmountApplied) sVoucherAmountApplied
			,isDeleted = 0
		from tblVouchersSalesUse 
		where isDeleted = 0
		group by orderID
	) vsu 
	ON a.orderID = vsu.orderID 
LEFT JOIN tblCustomers_ShippingAddress s 
	ON a.orderNo = s.orderNo
LEFT JOIN tblCredits r 
	ON a.orderID = r.creditOrderID 
--LEFT JOIN (SELECT TOP 1 * FROM tblCredits) r ON a.orderID = r.creditOrderID --this was removed on 9/25/18 as it was causing missing credits in total section.
LEFT JOIN tblCustomers_BillingAddress bl 
	ON a.orderNo = bl.orderNo
WHERE a.orderID = @orderID
ORDER BY groupID DESC, displayOrderGroup