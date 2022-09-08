CREATE proc [dbo].[usp_GetShippingAddressValidation] as
select top 100 a.ShippingAddressID
,a.Shipping_Street as addressLine1
,a.Shipping_Suburb as city
,a.Shipping_State as [state]
,a.Shipping_PostCode as postalCode
,case when a.Shipping_Country = 'United States' then 'US' else 'US' end as countryCode
from dbo.tblCustomers_ShippingAddress a
where a.isValidated = 0 
and a.returnCode is null
and len(rtrim(a.Shipping_Street)) > 0