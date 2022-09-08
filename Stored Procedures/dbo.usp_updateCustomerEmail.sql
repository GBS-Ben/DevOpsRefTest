CREATE PROC [dbo].[usp_updateCustomerEmail]
@login VARCHAR(255) = '',
@passwordHash VARCHAR(255) = ''

AS

UPDATE dbo.HOMLIVE_tblCustomers
SET hashPassword = @passwordHash
WHERE [login] = @login