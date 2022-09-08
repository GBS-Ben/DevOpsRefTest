CREATE PROCEDURE [dbo].[usp_LoadOrdersProductsCustomerEmail]
AS
SET NOCOUNT ON;

BEGIN TRY

		--codes to include
		UPDATE op
		SET CustomerEmail =  dbo.fnParseEmailAddress(textValue) --DISTINCT ProductName, ProductCode 
		FROM tblOrders o
		INNER JOIN  tblOrders_Products  op ON o.OrderID = op.orderID
		INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
		WHERE  op.CustomerEmail IS NULL
			AND textValue LIKE '%@%.%'
			AND  convert(datetime, orderdate)  > dateadd(d,-7,convert(datetime, getdate()))  --only orders in the last 7 days
			AND dbo.fnParseEmailAddress(textValue) IS NOT NULL

END TRY

BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH