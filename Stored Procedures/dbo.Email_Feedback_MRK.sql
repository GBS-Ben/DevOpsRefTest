-- =============================================
-- Author:		CBrowne
-- Create date: 07/15/21
-- Description:	Get calendar orders to send UPS shipped email
-- =============================================
CREATE PROCEDURE [dbo].[Email_Feedback_MRK] 
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @tblOrderNos TABLE (orderNo nvarchar(50));

			UPDATE o
			SET emailStatus = 4
			OUTPUT deleted.orderNo into @tblOrderNos
			--insert into @tblOrderNos
			--select top 1 o.orderno
			FROM tblOrders o
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			INNER JOIN tblEmailStatus es on es.orderNo = o.orderNo and datediff(day,es.emaildate,getdate()) = 5		--send five days after delivery
			WHERE o.orderStatus = 'Delivered'
			AND ISNULL(o.emailStatus, 0) <> 4
			AND o.membershipType IN ('HOM Customer', 'HOM','MRK Customer', 'MRK')
			AND o.orderStatus NOT IN ('Failed', 'Cancelled')
			AND not EXISTS
				 ( SELECT ISNULL(orderNo, '')
				 FROM tblEmailStatus e
				 WHERE emailStatus = 4
				 AND e.orderNo = o.orderno)
			AND NOT EXISTS
				(SELECT TOP 1 1
				FROM tblOrders_Products opx
				WHERE opx.deleteX <> 'yes'
				AND opx.productCode LIKE 'FB%'
				AND opx.orderID = o.orderID)


	
	        INSERT INTO gbsWarehouse_tblCordialEmailQueue (email, orderNo, emailTemplate, cordialAccount, emailJSON)
			SELECT DISTINCT
			c.email,o.orderNo, 'email_feedback_mrk','MRK',
				'{  
					"identifyBy": "email",
					 "to":{  
						  "contact":{  
							 "email":"' + c.email + '"
						  },
						  "extVars":{' + 
						  '"orderDate":"' + FORMAT(orderdate, 'dddd, MMMM, dd') + '",' + 
						  '"orderNo":"' + o.orderNo  + '"}}}' as emailJSON
			FROM tblOrders o 
			INNER JOIN @tblOrderNos ton ON ton.orderNo = o.orderNo
			INNER JOIN tblCustomers c ON o.customerID = c.customerID

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
END