CREATE proc [dbo].[usp_getCounts] @storeID int
AS
SET NOCOUNT ON;

BEGIN TRY
	select orderStatus, count(orderStatus) from tblOrders
	where storeID=@storeID
	group by orderStatus
	order by  count(orderStatus) desc

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH