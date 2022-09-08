CREATE PROC [dbo].[ordersInvoice_Insert]
AS
BEGIN

SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO dbo.tblOrdersInvoice (orderNo, invoiceNumber,invoiceTotal)
		SELECT inv.orderNo,inv.InvoiceNumber,o.calcOrderTotal
		FROM InvoiceStage inv
		INNER JOIN tblorders o on inv.orderNo = o.orderno

	END TRY
	BEGIN CATCH

	  EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
END