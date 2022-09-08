CREATE PROCEDURE [dbo].[Report_PayLaterOrders]
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
		  AuthorizationTransactionResult
	  FROM dbo.NopCommerce_tblPayLater gp

	  ) 
	  SELECT cte.*, email, orderStatus, orderType
	  FROM tblOrderView ov
	  INNER JOIN cte ON cte.OrderId = ov.orderID

	  END