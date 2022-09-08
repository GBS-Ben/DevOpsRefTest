CREATE proc [dbo].[usp_GetMonthlyBillingInvoice] 
  @InvoiceNumber nvarchar(255)--= '10779-052'
as
select o.orderID
,o.feeAmount
,o.storeID
,o.orderNo
,o.orderDate
,o.orderTotal
,o.calcTransTotal
,o.calcOrderTotal
,o.calcProducts
,o.calcOPPO
,taxAmount = cast(case when o.taxAmountInTotal > 0 then o.taxAmountInTotal else o.taxAmountAdded end as decimal(8,2))
,taxDescription =  case when o.taxAmountInTotal > 0 then isnull(s.[description],'') + ' (in total)' else o.taxDescription end
,o.shippingAmount
,o.shippingDesc
,o.specialInstructions
,o.paymentMethod
,o.cardNumber
,o.cardExpiryMonth
,o.cardExpiryYear
,o.cardType
,vsu.sVoucherCode
,ISNULL(vsu.sVoucherAmountApplied,0.00) as sVoucherAmountApplied
,o.shipping_Company AS shipping_Company
,o.shipping_FirstName AS shipping_FirstName
,o.shipping_Surname AS shipping_Surname
,o.shipping_Street AS shipping_Street
,o.shipping_Street2 AS shipping_Street2
,o.shipping_Suburb AS shipping_Suburb
,o.shipping_State AS shipping_State
,o.shipping_PostCode AS shipping_PostCode
,o.shipping_Country AS shipping_Country
,o.shipping_Phone AS shipping_Phone
,case when o.billing_Company = 'Graphic Business Solutions' then 0 else o.billingAddressID end AS billingAddressID
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Company else o.billing_Company end AS billing_Company
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_FirstName else o.billing_FirstName end AS billing_FirstName
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Surname else o.billing_Surname end AS billing_Surname
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Street else o.billing_Street end AS billing_Street
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Street2 else o.billing_Street2 end AS billing_Street2
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Suburb else o.billing_Suburb end AS billing_Suburb
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_State else o.billing_State end AS billing_State
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_PostCode else o.billing_PostCode end AS billing_PostCode
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Country else o.billing_Country end AS billing_Country
,case when o.billing_Company = 'Graphic Business Solutions' then o.shipping_Phone else o.billing_Phone end AS billing_Phone
--,o.cartVersion 
,sp.storeName
,sp.storeStreet
,sp.storeBusinessDetails
,sp.storeSuburb
,sp.storeState
,sp.storePostCode
,sp.storeCountry
,sp.storePhone
,sp.storeFax
,sp.storeEmail
,sp.storeWebsite
--,sp.storeLogo
,storeLogo = 'img/logos/MRKLogoBW.jpg'
,c.email
,r.creditDesc
,isnull(r.creditAmount,0.00) as creditAmount
from dbo.tblOrders o 
inner join dbo.InvoiceStage inv
	on o.orderNo = inv.orderNo
left join dbo.tblCustomers c
	on o.customerID = c.customerID
left join tblVouchersSalesUse vsu
	on o.orderID = vsu.orderID
left join tblStore_Prefs sp
	on o.storeID = sp.ID
LEFT JOIN tblCountries ON o.shipping_country = tblCountries.countryName
LEFT JOIN tblCountry_States ON o.shipping_state = tblCountry_States.stateName and tblCountry_States.countryID = tblCountry_States.countryID
left join tblStore_Tax s on s.countryID = tblCountries.countryId and s.stateID = tblCountry_States.stateID
AND (
		tblCountries.countryName = 'United States'
		AND (tblCountry_States.stateName) = o.shipping_state
		AND (
			s.zip = o.shipping_postcode
			OR (
				s.zip IS NULL
				AND NOT EXISTS (
					SELECT TOP 1 1
					FROM tblStore_Tax
					WHERE stateid = tblcountry_states.stateID
						AND zip = o.shipping_postcode
					)
				)
			)
		)
LEFT JOIN tblCredits r on r.creditOrderID = o.orderId
where inv.InvoiceNumber = @InvoiceNumber