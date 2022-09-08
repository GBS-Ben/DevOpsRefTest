-- =============================================
-- exec dbo.ReportGiftCardUsage
-- select * FROM sql01.nopcommerce.dbo.GiftCard gc where GiftCardCouponCode like 'BHHSSRG%'
/*
	Go run this on GBSAZ-sql01....
	begin tran update gc set IsGiftCardActivated=0 FROM nopcommerce.dbo.GiftCard gc where GiftCardCouponCode like 'BHHSSRG%' rollback
*/
-- =============================================
CREATE PROCEDURE [dbo].[ReportGiftCardUsage]
	
AS
BEGIN
	
	SET NOCOUNT ON;


		SELECT 
			DiscountType='GiftCard'
			,GiftCardCode=gc.GiftCardCouponCode
			,Amount=CAST(TRY_CONVERT(DECIMAL(12,2), gc.Amount) AS MONEY)
			,Active=gc.IsGiftCardActivated
			,CreatedOn=CONVERT(VARCHAR(12), gc.CreatedOnUTC, 101)
			,AmountUsed=CAST(TRY_CONVERT(DECIMAL(12,2), SUM(ISNULL(h.UsedValue,0.00))) AS MONEY)
			,OrderCount=COUNT(h.usedvalue)
			--,OrderNum=ISNULL(MIN(o.ID),'')
			,OrderNum=STRING_AGG(o.id, ', ')
			,AmountRemaining=CAST(TRY_CONVERT(DECIMAL(12,2), gc.Amount-SUM(ISNULL(h.UsedValue,0.00))) AS MONEY)
			,UsedBy=ISNULL(MIN(ISNULL(a.FirstName + ' ' + a.LastName, c.UserName)),'')
			--,UsedBy=ISNULL(
			--			STUFF((   --get distinct values 
			--				SELECT ',' + ISNULL(a.FirstName + ' ' + a.LastName, c.UserName) as NewN	
			--				FROM sql01.nopcommerce.dbo.Customer c 
			--				LEFT JOIN sql01.nopcommerce.dbo.Address a ON a.id=c.BillingAddress_id
			--				where c.id=o.CustomerID
			--				FOR XML PATH('') -- Select it as XML
			--				, type
   --                     ).value('.', 'nvarchar(255)')
			--			, 1, 1, '' )
			--		,'')		
			--,OrderDate=ISNULL(CONVERT(VARCHAR(12), min(o.CreatedOnPST), 101),'')
			,OrderDate=STRING_AGG(ISNULL(CONVERT(VARCHAR(12), o.CreatedOnPST, 101),''),', ')
			--select o.*
		FROM dbo.nopcommerce_GiftCard gc
		LEFT JOIN dbo.nopcommerce_GiftCardusageHistory h ON h.GiftCardID=gc.ID
		LEFT JOIN dbo.nopcommerce_Order o ON o.ID=h.UsedWithOrderID
		LEFT JOIN dbo.nopcommerce_Customer c ON c.id=o.CustomerID
		LEFT JOIN dbo.nopcommerce_Address a ON a.id=c.BillingAddress_id
		--where giftcardcouponcode='0B4Z20FNVZ106V3Y13'
		GROUP BY gc.GiftCardCouponCode, gc.Amount, gc.IsGiftCardActivated, gc.CreatedOnUTC, o.CustomerID
		UNION
		SELECT 
			 DiscountType='Voucher'
			,v.sVoucherCode
			,Amount=v.sVoucherAmount
			,Active=CASE WHEN v.isDeleted=1 then 0 ELSE 1 END
			,CreatedOn=CONVERT(VARCHAR(12), v.dateCreated, 101)
			,AmountUsed=CAST(TRY_CONVERT(DECIMAL(12,2),sum(o.orderTotal)) AS MONEY)
			,OrderCount=count(o.customerID)
			,OrderNum=MIN(O.orderNo)
			,AmountRemaining=CAST(TRY_CONVERT(DECIMAL(12,2), 0) AS MONEY)
			,UsedBy=MIN(o.shipping_FirstName + ' ' + o.shipping_Surname)
			,OrderDate=CONVERT(VARCHAR(12), MIN(o.orderDate), 101)
		--select *
		FROM dbo.tblVouchersSales v
		INNER JOIN dbo.tblVouchersSalesUse su on su.sVoucherID=v.sVoucherID
		INNER JOIN dbo.tblOrders o on o.orderID=su.orderID
		--WHERE v.sVoucherCode='CS3795WR7U7PCJR5'
		GROUP BY v.sVoucherCode, v.sVoucherAmount, CASE WHEN v.isDeleted=1 then 0 ELSE 1 END, v.dateCreated
		ORDER BY 1, 2, 3		

END