CREATE PROCEDURE [dbo].[usp_PaymentStatus_UpdateQueue] 
	 @orderNo VARCHAR(255)
AS

/*
-------------------------------------------------------------------------------
Author      Cherilyn Browne
Created     03/25/21
Purpose     Marks paymentstatus queue record as processed
					
------------------------------------------------------------------------------
Modification History


-------------------------------------------------------------------------------
*/

BEGIN TRY

	UPDATE tblPaymentStatus_Queue SET processDateTime = getdate() WHERE orderNo = @orderNo and processDateTime IS NULL

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH