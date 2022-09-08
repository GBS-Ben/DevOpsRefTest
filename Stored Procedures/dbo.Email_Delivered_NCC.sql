-- =============================================
-- Author:		CBrowne
-- Create date: 08/17/21
-- Description:	Get NCC UPS delivered email
-- =============================================
CREATE PROCEDURE [dbo].[Email_Delivered_NCC] 
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @tblOrderNos TABLE (orderNo nvarchar(50), trackingNumber varchar(255));

			UPDATE o
			SET emailStatus = 3
			OUTPUT deleted.orderNo,jt.trackingnumber into @tblOrderNos
			--insert into @tblOrderNos
			--select top 1 o.orderNo, jt.trackingnumber
			FROM tblJobTrack jt
			INNER JOIN tblOrders o ON jt.JobNumber = o.orderNo
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			WHERE SUBSTRING(jt.trackingnumber, 1, 2) = '1Z' 
			AND o.emailStatus = 2
			AND o.membershipType IN ('NCC Customer', 'NCC')
			AND jt.deliveredOn IS NOT NULL
			AND o.orderStatus NOT IN ('Failed', 'Cancelled')
			AND DATEDIFF(DD, ISNULL(jt.[deliveredOn],''), GETDATE()) < 2

	
	        INSERT INTO gbsWarehouse_tblCordialEmailQueue (email, orderNo, trackingNumber, emailTemplate, cordialAccount, emailJSON)
			SELECT DISTINCT
			c.email,o.orderNo,jt.trackingNumber, 'email_delivered_ncc','NCC',
				'{  
					"identifyBy": "email",
					 "to":{  
						  "contact":{  
							 "email":"' + c.email + '"
						  },
						  "extVars":{' + 
						  '"pickupDate":"' + jt.[pickup date] +  '",' +
						  '"trackingNumber":"' + ISNULL(jt.trackingNumber,'') + '",' +
						  '"trackingLink":"https://www.ups.com/track?trackingNumber=' + ISNULL(jt.trackingNumber,'') + '",' +
						  '"shipToName":"' + ISNULL(cs.Shipping_FullName,'') + '",' + 
						  '"shipToAddressLine1":"' + ISNULL(cs.Shipping_Street,'') + case when ISNULL(cs.Shipping_Street2,'') <> '' then '<br>' + cs.Shipping_Street2 ELSE '' END + '",' + 
						  '"shipToCity":"' + ISNULL(cs.Shipping_Suburb,'') + '",' + 
						  '"shipToState":"' + ISNULL(cs.Shipping_State,'') + '",' + 
						  '"shipToZip":"' + ISNULL(cs.Shipping_PostCode,'') + '",' +
						  '"shipToCountry":"' + ISNULL(cs.Shipping_Country,'') + '",' +
						  '"scheduledDeliveryDate":"' + ISNULL(jt.[scheduled delivery date],'') + '",' + 
						  '"packageCount":"' + ISNULL(jt.[package count], 'TBD') + '",' + 
						  '"packageWeight":"' + ISNULL(jt.[weight], 'TBD') + '",' +
						  '"service":"UPS",' + 
						  '"serviceType":"' + ISNULL(jt.[mailClass], 'UPS') + '",' + 
						  '"orderDate":"' + FORMAT(orderdate, 'dddd, MMMM, dd') + '",' + 
						  '"orderNo":"' + o.orderNo  + '"}}}' as emailJSON
			FROM tblJobTrack jt
			INNER JOIN @tblOrderNos ton on ton.orderNo = jt.jobnumber and ton.trackingNumber = jt.trackingnumber
			INNER JOIN tblOrders o ON jt.JobNumber = o.orderNo
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			INNER JOIN tblCustomers_ShippingAddress cs ON o.orderNo = cs.orderNo

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  

		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
END