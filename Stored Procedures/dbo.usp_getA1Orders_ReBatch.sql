CREATE PROC [dbo].[usp_getA1Orders_ReBatch]
AS

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- SPROC that presents A1 data fir re-print on http://sbs/gbs/admin/ordersNewA1.asp
-- created on: 11/142016; CT.
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



-- SELECT statement retrieving rows
SELECT o.orderID, o.orderNo, o.orderDate, o.storeID, o.customerID, o.orderType,
o.paymentMethodRDesc, o.orderStatus, o.shippingDesc, 
o.orderTotal, o.paymentAmountRequired, o.paymentMethod, o.statusDate, o.lastStatusUpdate,
o.shippingMethod,  cust.firstName, cust.surName, o.NOP
FROM tblOrders o
JOIN tblCustomers cust
	ON o.customerID = cust.customerID
WHERE o.orderID IN 
		(SELECT a.orderID
		FROM tblOrders a
		JOIN tblCustomers c
			ON a.customerID = c.customerID
		JOIN tblCustomers_ShippingAddress s
			ON a.orderNo = s.orderNo
		WHERE

		--orders with valid orderStatus.
			a.orderStatus <> 'cancelled'
		AND a.orderStatus <> 'failed'
		AND a.orderStatus <> 'MIGZ'

		--orders which have already had an A1 label generated. this field is updated by label creation.
		AND a.orderJustPrinted = 1

		--orders which have been printed with the last 7 days.
		AND DATEDIFF(DD, a.orderBatchedDate, GETDATE()) <= 7

		--orders with valid payment.
		AND a.displayPaymentStatus = 'Good'

		--orders that are not custom (performance v. redundancy)
		AND a.orderType <> 'Custom'

		--and RDI is residential "R". Changed from tblOrders.rescom on 11/1/16; jf.
		AND s.rdi = 'R'

		--orders that have qualifying A1 products within, at a product quantity of "1" for numUnits * productQuantity; can only have a SUM of "1" per order in this criteria.
		AND a.orderID IN
			(SELECT orderID
			FROM tblOrders_Products op
			JOIN tblProducts pr
				ON op.productID = pr.productID
			WHERE op.deleteX <> 'yes'
			AND 
				--// Stock Cal Pad Mags
				(
					(pr.productType = 'Stock' AND pr.productName LIKE '%pad%' AND pr.productName LIKE '%calendar%')
					OR
					--// Stock QuickStix
					(pr.productType = 'Stock' AND pr.productName LIKE '%quickStix%' AND pr.productName NOT LIKE '%create%')
					OR
					--// Stock QuickStix
					(pr.productType = 'Stock' AND SUBSTRING(pr.productCode, 3, 2) = 'QS' AND pr.productName NOT LIKE '%create%')
					OR
					--// Stock QuickStix
					(pr.productType = 'Stock' AND SUBSTRING(pr.productCode, 1, 2) = 'QS' AND pr.productName NOT LIKE '%create%')
					OR
					--// Note Card Set (updated 2/17/16; jf; as per KH: "A1 tickets should include a single order of a 72 note card pak for the padded envelope rate")
					(pr.productType = 'Stock' AND pr.productName LIKE 'Note Card Set%')
				)
			GROUP BY orderID
			HAVING SUM(op.productQuantity * pr.numUnits) = 1
			)
	
		--order's shippingAddress has been validated.
		AND a.orderNo IN
			(SELECT orderNo
			FROM tblCustomers_ShippingAddress
			WHERE isValidated = 1)

		--orders that do not contain non-A1 products as shown above.
		AND a.orderID NOT IN
			(SELECT orderID
			FROM tblOrders_Products
			WHERE deleteX <> 'yes'
			AND productID NOT IN
					(SELECT productID 
					FROM tblProducts
					WHERE 
					--// Stock Cal Pad Mags
					(productType = 'Stock' AND productName LIKE '%pad%' AND productName LIKE '%calendar%' AND numUnits = 1)
					OR
					--// Stock QuickStix
					(productType = 'Stock' AND productName LIKE '%quickStix%' AND productName NOT LIKE '%create%' AND numUnits = 1)
					)
			)

		-- orders that do not have the "Production Timing: Complete Schedule (ship later)" product option selected.
		AND a.orderID NOT IN
			(SELECT orderID
			FROM tblOrders_Products
			WHERE deleteX <> 'yes'
			AND [ID] IN
				(SELECT ordersProductsID
				FROM tblOrdersProducts_productOptions
				WHERE deleteX <> 'yes'
				AND optionCaption = 'Complete Schedule (ship later)')
			)

		--orders that are not expedited.
		AND a.A1_expediteShipFlag <> 1
		)
	Order By o.orderDate DESC