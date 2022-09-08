CREATE PROCEDURE [dbo].[usp_LoadOrdersProductsAgentName]
AS
SET NOCOUNT ON;

BEGIN TRY


UPDATE  p
SET AgentName = LEFT(oppo.TextValue,255)
FROM tblOrdersProducts_ProductOptions oppo
INNER JOIN tblOrders_Products p ON p.ID = oppo.ordersProductsID
WHERE oppo.optionid IN (279, 245)
AND p.created_on > dateadd(d,-7,convert(datetime, getdate()))


END TRY

BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH