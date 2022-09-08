CREATE PROC [dbo].[usp_mergeCustomers] 
	@SourceCustomerEmail nvarchar(500), 
	@DestinationCustomerEmail nvarchar(500),
	@StartDate datetime2 = NULL, 
	@EndDate datetime2 = NULL
AS
SET NOCOUNT ON;
/*
-------------------------------------------------------------------------------
Author      Bobby Shreckengost
Created     12/12/18
Purpose     NOP data rip migration.
-------------------------------------------------------------------------------
Modification History

 12/12/18		Created, jf.
 04/27/21		Shreck, added logging and address
-------------------------------------------------------------------------------
Example:

	EXEC [usp_mergeCustomers]  'SOURCE', 'DESTINATION'
	EXEC [usp_mergeCustomers] 'savannar@erawilderrealty.com', 'northeast@erawilderrealty.com'
	EXEC [usp_mergeCustomers] 'erindefrain@bhhs.com', 'erindefrain@bhhsmi.com'
	EXEC [usp_mergeCustomers] 'erinh@homeservices-ins.com', 'erinw@homeservices-ins.com'

*/


BEGIN TRY
		
		DECLARE
		@NOPSourceCustomerId int = 0,
		@NOPDestinationCustomerId int = 0,
		@LocalSourceCustomerId int = 0,
		@LocalDestinationCustomerId int= 0

	SELECT TOP 1 @NOPSourceCustomerId = id FROM sql01.nopcommerce.dbo.customer WHERE email = @SourceCustomerEmail AND Deleted = 0 AND Active = 1
	SELECT TOP 1 @NOPDestinationCustomerId = id FROM sql01.nopcommerce.dbo.customer WHERE email = @DestinationCustomerEmail AND Deleted = 0 AND Active = 1
	SELECT TOP 1 @LocalSourceCustomerId = customerID FROM dbo.tblcustomers WHERE email = @SourceCustomerEmail 
	SELECT TOP 1 @LocalDestinationCustomerId = customerID FROM dbo.tblcustomers WHERE email = @DestinationCustomerEmail 

	--Log the change
		INSERT INTO tblEmailAddressChangeLog (SourceCustomerEmail,DestinationCustomerEmail, CreateDate, NOPSourceCustomerId, NOPDestinationCustomerId, LocalSourceCustomerId, LocalDestinationCustomerId)
		VALUES(@SourceCustomerEmail, @DestinationCustomerEmail, GETDATE(),@NOPSourceCustomerId,@NOPDestinationCustomerId,@LocalSourceCustomerId,@LocalDestinationCustomerId)
	--local updates


	UPDATE dbo.tblcustomers
	SET [login] = @DestinationCustomerEmail
	WHERE [login] = @SourceCustomerEmail

	UPDATE dbo.tblcustomers
	SET email = @DestinationCustomerEmail
	WHERE email = @SourceCustomerEmail

	--remote NOP ADDRESS updates
	UPDATE c
	SET Email = @DestinationCustomerEmail
	FROM  sql01.nopcommerce.dbo.[address] c
	WHERE Email = @SourceCustomerEmail

	--remote NOP updates
	UPDATE sql01.nopcommerce.dbo.customer
	SET userName = @DestinationCustomerEmail
	WHERE userName = @SourceCustomerEmail

	UPDATE sql01.nopcommerce.dbo.customer
	SET email = @DestinationCustomerEmail
	WHERE email = @SourceCustomerEmail
	
	update sql01.nopcommerce.dbo.[order] 	set customerid = @LocalDestinationCustomerId where customerid = @LocalSourceCustomerId
	
	update sql01.nopcommerce.dbo.customer  set deleted = 1 where id = @NOPSourceCustomerId
END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH