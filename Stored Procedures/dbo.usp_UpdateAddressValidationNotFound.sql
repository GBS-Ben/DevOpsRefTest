create proc [dbo].[usp_UpdateAddressValidationNotFound] 
@ShippingAddressID int
as
begin

update dbo.tblCustomers_ShippingAddress
set isValidated = 1
	,rdi = 'U'
	,returnCode = NULL --????
	,addrExists = 0 
	,UPSRural = 0
where ShippingAddressID = @ShippingAddressID

end