CREATE PROC dbo.Workflow_DeactivateByOrderNo @OrderNo varchar(15)
AS
BEGIN

	BEGIN TRY
	
		UPDATE opp SET isActive = 0
		FROM tblOPIDProductionProcess opp
		INNER JOIN tblOrders_Products op on opp.OPID = op.ID
		INNER JOIN tblOrders o on op.orderID = o.orderID
		WHERE o.orderNo = @OrderNo

	END TRY
	BEGIN CATCH

		EXEC [dbo].[usp_StoredProcedureErrorLog]
	
	END CATCH

END