CREATE proc [dbo].[usp_UPSAPI_GetOrdersForUPSShipment]
as

select top 20
ul.ID
--Shipper Info
,ul.shipperName
,ul.shipperAttentionName
,ul.shipperStreet
,ul.shipperCity
,ul.shipperState
,ul.shipperPostalCode
,ul.shipperCountry
,shipperPhone = case 
	when ul.shipperPhone = '0000000000' then '6192584087' 
	else ul.shipperPhone end
--ShipTo Info
,shiptoFullName = left(ul.shiptoFullName,30)
,ul.shiptoAttention
,ul.shiptoCompany
,shiptoStreet = left(ul.shiptoStreet,35)
,ul.shiptostreet2
,ul.shiptoCity
,shiptoState = upper(ul.shiptoState)
,ul.shiptoPostalCode
,ul.shiptoCountry
,shiptoPhone = case 
	when len(rtrim(ul.shiptoPhone)) = 0 or isnumeric(ul.shiptoPhone) = 0 then '0000000000'
	else ul.shiptoPhone end
--Order product info
,ul.orderNo
,ul.upsServiceCode
,ul.packageWeight
,ul.unitOfMeasure
,ul.packageTypeCode

from dbo.tblUPSLabel ul

where ul.trackingNumber is null
and ul.insertDate > '1/1/2020'
and ul.orderNo > 'WEB337923'
--Validation
and ul.packageWeight > 0
and len(ul.shiptoPostalCode) in (5,10)
and len(rtrim(ul.shiptoStreet)) > 0
and len(rtrim(ul.shiptoFullName)) > 0

order by ul.ID desc