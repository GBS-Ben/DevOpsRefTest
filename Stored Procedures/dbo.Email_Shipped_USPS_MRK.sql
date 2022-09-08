-- =============================================
-- Author:		CBrowne
-- Create date: 07/15/21
-- Description:	Get USPS orders to send shipped email
-- =============================================
CREATE PROCEDURE [dbo].[Email_Shipped_USPS_MRK] 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @tblOrderNos1 TABLE (orderNo nvarchar(50), trackingNumber varchar(255));
			DECLARE @tblOrderNos2 TABLE (orderNo nvarchar(50), trackingNumber varchar(255));

			UPDATE o
			SET emailStatus = 2
			OUTPUT deleted.orderNo,jt.trackingnumber into @tblOrderNos1
			--insert into @tblOrderNos1
			--select top 1 o.orderNo,jt.trackingnumber
			FROM tblOrders o 
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			INNER JOIN tblJobTrack jt ON o.orderNo = jt.jobNumber
			LEFT JOIN tblEmailStatus x ON x.orderNo = o.orderNo
				AND x.emailStatus = 2
				AND DATEDIFF(dd, x.emailDate, GETDATE()) < 30
			WHERE c.email LIKE '%@%'
			AND x.orderNo IS NULL
			AND o.orderStatus IN ('In Transit', 'In Transit USPS')
			AND SUBSTRING(jt.trackingNumber, 1, 1) = '9'
			AND o.membershipType IN ( 'HOM Customer', 'HOM','MRK Customer','MRK')
			AND DATEDIFF(dd, o.orderDate, GETDATE()) < 30
			AND NOT EXISTS
				(SELECT TOP 1 1
				FROM tblOrders_Products op
				WHERE op.deleteX <> 'yes'
				AND op.productCode LIKE 'FB%'
				AND op.orderID = o.orderID)


			INSERT INTO gbsWarehouse_tblCordialEmailQueue (email, orderNo, trackingNumber, emailTemplate, cordialAccount, emailJSON)
			SELECT DISTINCT
			c.email,o.orderNo,jt.trackingNumber, 'email_shipped_mrk','MRK',
				'{  
					"identifyBy": "email",
					 "to":{  
						  "contact":{  
							 "email":"' + c.email + '"
						  },
						  "extVars":{' + 
						  '"pickupDate":"' + jt.[pickup date] +  '",' +
						  '"trackingNumber":"' + ISNULL(jt.trackingNumber,'') + '",' +
						  '"trackingLink":"https://tools.usps.com/go/TrackConfirmAction_input?strOrigTrackNum=' + ISNULL(jt.trackingNumber,'') + '",' +
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
			INNER JOIN @tblOrderNos1 ton on ton.orderNo = jt.jobnumber and ton.trackingNumber = jt.trackingnumber
			INNER JOIN tblOrders o ON jt.JobNumber = o.orderNo
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			INNER JOIN tblCustomers_ShippingAddress cs ON o.orderNo = cs.orderNo


			UPDATE o
			SET emailStatus = 2
			OUTPUT deleted.orderNo,jt.trackingnumber into @tblOrderNos2
			--insert into @tblOrderNos2
			--select top 1 o.orderno,jt.trackingnumber
			FROM tblOrders o 
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			INNER JOIN tblJobTrack jt ON o.orderNo = jt.jobnumber
			LEFT JOIN tblEmailStatus x ON x.orderNo = o.orderNo
				AND x.emailStatus = 2
				AND DATEDIFF(dd, x.emailDate, GETDATE()) < 30
			WHERE c.email LIKE '%@%'
			AND x.orderNo IS NULL
			AND o.orderStatus LIKE '%transit%'
			AND jt.trackingNumber LIKE '1Z%'
			AND jt.trackingNumber LIKE '%stamp%'
			AND jt.trackingNumber IS NOT NULL
			AND o.membershipType IN ( 'HOM Customer', 'HOM','MRK Customer','MRK')
			AND DATEDIFF(dd, o.orderDate, GETDATE()) < 30
			AND NOT EXISTS
				(SELECT TOP 1 1
				FROM tblOrders_Products op
				WHERE op.deleteX <> 'yes'
				AND op.productCode LIKE 'FB%'
				AND op.orderID = o.orderID)


			INSERT INTO gbsWarehouse_tblCordialEmailQueue (email, orderNo, trackingNumber, emailTemplate, cordialAccount, emailJSON)
			SELECT DISTINCT
			c.email,o.orderNo,jt.trackingNumber, 'email_shipped_mrk','MRK',
				'{  
					"identifyBy": "email",
					 "to":{  
						  "contact":{  
							 "email":"' + c.email + '"
						  },
						  "extVars":{' + 
						  '"pickupDate":"' + jt.[pickup date] +  '",' +
						  '"trackingNumber":"' + ISNULL(jt.trackingNumber,'') + '",' +
						  '"trackingLink":"https://tools.usps.com/go/TrackConfirmAction_input?strOrigTrackNum=' + ISNULL(jt.trackingNumber,'') + '",' +
						  '"shipToName":"' + ISNULL(cs.Shipping_FullName,'') + '",' + 
						  '"shipToAddressLine1":"' + ISNULL(cs.Shipping_Street,'') + case when ISNULL(cs.Shipping_Street2,'') <> '' then '<br>' + cs.Shipping_Street2 ELSE '' END + '",' + 
						  '"shipToCity":"' + ISNULL(cs.Shipping_Suburb,'') + '",' + 
						  '"shipToState":"' + ISNULL(cs.Shipping_State,'') + '",' + 
						  '"shipToZip":"' + ISNULL(cs.Shipping_PostCode,'') + '",' +
						  '"shipToCountry":"' + ISNULL(cs.Shipping_Country,'') + '",' +
						  '"service":"UPS",' + 
						  '"serviceType":"' + ISNULL(jt.[mailClass], 'UPS') + '",' + 
						  '"orderDate":"' + FORMAT(orderdate, 'dddd, MMMM, dd') + '",' + 
						  '"orderNo":"' + o.orderNo  + '"}}}' as emailJSON
			FROM tblJobTrack jt
			INNER JOIN @tblOrderNos2 ton on ton.orderNo = jt.jobnumber and ton.trackingNumber = jt.trackingnumber
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