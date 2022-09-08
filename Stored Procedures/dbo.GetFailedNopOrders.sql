CREATE PROCEDURE [dbo].[GetFailedNopOrders]
AS
SET NOCOUNT ON;


BEGIN TRY

--DECLARE @sql varchar(max)

--SELECT @sql = '

SELECT o.GBSOrderID, o.CreatedOn AS OrderDate, OrderTotal, Username, phonenumber as PhoneNumber, ISNULL(c.Email, a.email) AS Email,   Company, p.Sku , p.Name AS ProductName, s.Name AS StoreName  , CardType, CardName, MaskedCreditCardNumber, CardExpirationMonth, CardExpirationYear--,  *

FROM sql01.nopCommerce.dbo.tblFailedOrderItems oi
	INNER JOIN  sql01.nopCommerce.dbo.tblFailedOrders o ON oi.FailedOrderID = o.Id
	INNER JOIN  sql01.nopCommerce.dbo.Customer c ON c.id = oi.Customerid
	INNER JOIN  sql01.nopCommerce.dbo.Address a ON a.id = c.BillingAddress_Id
	INNER JOIN   sql01.nopCommerce.dbo.product p ON p.id = oi.ProductId
	INNER JOIN  sql01.nopCommerce.dbo.Store s ON s.id = oi.StoreId
	WHERE o.CreatedOn > GETDATE() -2
	ORDER BY o.UpdatedOn desc, o.GbsOrderid, p.Sku
	
	-- '


--		EXEC msdb.dbo.sp_send_dbmail @profile_name = 'email',
--		@query=@sql,
--		@recipients = 'bobby@gogbs.com',
--		@subject = 'Failed Orders',
--		@body = 'Attached you will find the failed orders from NOP for the last 4 days
		
--		Enjoy, 
--		Bobby',
--@attach_query_result_as_file = 1,
--@query_attachment_filename = 'result.txt',
--@query_result_separator=',',@query_result_width =32767,
--@query_result_no_padding=1




END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH