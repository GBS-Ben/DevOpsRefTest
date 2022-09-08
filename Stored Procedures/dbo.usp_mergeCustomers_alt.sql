CREATE PROC [dbo].[usp_mergeCustomers_alt] 
	@SourceCustomerEmail nvarchar(500), 
	@DestinationCustomerEmail nvarchar(500),
	@login BIT  = 0,
	@email BIT  = 0
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
-------------------------------------------------------------------------------
Example:

	EXEC [usp_mergeCustomers]  'SOURCE', 'DESTINATION'
	EXEC [usp_mergeCustomers_alt] 'savannar@erawilderrealty.com', 'northeast@erawilderrealty.com', 1 , 0
	EXEC [usp_mergeCustomers] 'erindefrain@bhhs.com', 'erindefrain@bhhsmi.com'

*/

BEGIN TRY

IF @login =1
BEGIN
	--local updates
	UPDATE tblCustomers
	SET [login] = @DestinationCustomerEmail
	WHERE [login] = @SourceCustomerEmail

	--remote NOP updates
	UPDATE dbo.nopCommerce_Customer
	SET userName = @DestinationCustomerEmail
	WHERE userName = @SourceCustomerEmail

	 --remote classic updates
     UPDATE dbo.homlive_tblCustomers
     SET [Login] = @DestinationCustomerEmail
     WHERE [Login] = @SourceCustomerEmail
END

IF @email = 1
BEGIN
	UPDATE tblCustomers
	SET email = @DestinationCustomerEmail
	WHERE email = @SourceCustomerEmail

	UPDATE dbo.nopCommerce_Customer
	SET email = @DestinationCustomerEmail
	WHERE email = @SourceCustomerEmail
	
     UPDATE dbo.homlive_tblCustomers
     SET email = @DestinationCustomerEmail
     WHERE email = @SourceCustomerEmail
END


END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH

/*
SELECT email from tblCustomers WHERE email = ''
SELECT email from SQL01.homlive.dbo.tblCustomers WHERE email = ''

*/