CREATE PROCEDURE [dbo].[Dashboard_PayLaterOrders]
	  AS
	  SET NOCOUNT ON;
	 
	  DECLARE @OrderOffset INT; 
	  EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;

	  BEGIN 
	  WITH cte
	  AS 
	  (
	  SELECT CASE WHEN PaidDateUTC IS NOT NULL THEN 'YES' ELSE 'no' END AS PAID,
		  OrderNo,
		  OrderId + @OrderOffset AS OrderId,	
		  PaidDateUtc, 	
		  OrderDate,	
		  PaymentAmountRequired	,
		  AuthorizationTransactionCode	,
		  AuthorizationTransactionResult,
		  activeflag
	  FROM NopCommerce_tblPayLater gp

	  ) 
	  SELECT cte.*, email, orderStatus, orderType
	  FROM tblOrderView ov
	  INNER JOIN cte ON cte.OrderId = ov.orderID
	  where activeflag = 1

	  END