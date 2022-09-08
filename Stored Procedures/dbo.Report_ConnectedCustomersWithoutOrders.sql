-- =============================================
-- Author:		Bobby
-- Create date: 02162022
-- Description: Marketing Report to see connected customers without orders
-- =============================================
CREATE PROCEDURE Report_ConnectedCustomersWithoutOrders
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT *	FROM sql01.nopcommerce.dbo.ConnectedCustomersWithoutOrders
END