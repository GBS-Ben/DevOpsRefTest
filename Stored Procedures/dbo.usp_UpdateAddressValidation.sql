create proc usp_UpdateAddressValidation 
@ShippingAddressID int
,@Shipping_Street varchar(255)
,@Shipping_Suburb varchar(255)
,@Shipping_State varchar(10)
,@Shipping_PostCode varchar(20)
,@Shipping_Country varchar(50)
,@isResidential varchar(10)
,@status varchar(50)
as
begin
--declare 
--@ShippingAddressID int
--,@Shipping_Street varchar(255)
--,@Shipping_Suburb varchar(255)
--,@Shipping_State varchar(10)
--,@Shipping_PostCode varchar(20)
--,@Shipping_Country varchar(50)
--,@isResidential varchar(10)
--,@status varchar(50)

update dbo.tblCustomers_ShippingAddress
set Shipping_Street = @Shipping_Street
	,Shipping_Suburb = @Shipping_Suburb
	,Shipping_State = @Shipping_State
	,Shipping_PostCode = @Shipping_PostCode
	,Shipping_Country = @Shipping_Country
	,isValidated = 1
	,rdi = case when @isResidential = 'no' then 'B' else 'R' end
	,returnCode = 31 --????
	,addrExists = case when @status = 'verified' then 1 else 0 end
	,UPSRural = 0
where ShippingAddressID = @ShippingAddressID

end