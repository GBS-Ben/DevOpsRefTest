CREATE PROCEDURE [dbo].[usp_PaymentStatus_ProcessQueue] 
AS

/*
-------------------------------------------------------------------------------
Author      Cherilyn Browne
Created     03/25/21
Purpose     Calls usp_PaymentStatus for each order in the queue
					
------------------------------------------------------------------------------
Modification History

-------------------------------------------------------------------------------
*/
  SET NOCOUNT ON

BEGIN TRY


	DECLARE @orderNo NVARCHAR(50)
	DECLARE @SQL NVARCHAR(2000)
	
	DECLARE rOrders CURSOR FOR
		SELECT DISTINCT orderNo FROM tblPaymentStatus_Queue WHERE processDateTime IS NULL
	
	OPEN rOrders
	FETCH NEXT FROM rOrders INTO @orderNo  

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		--print @orderNo

		EXEC dbo.usp_PaymentStatus @orderNo = @orderNo  

		EXEC usp_PaymentStatus_UpdateQueue @orderNo = @orderNo

		FETCH NEXT FROM rOrders INTO @orderNo  
	END

	CLOSE rOrders
	DEALLOCATE rOrders

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH