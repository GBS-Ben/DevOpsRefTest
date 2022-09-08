CREATE PROCEDURE [dbo].[Voucher_Redeemer_Update]
AS  



--Get All Vouchers from the files
IF OBJECT_ID('tempdb..#SheetVouchers') IS NOT NULL
	DROP TABLE #SheetVouchers;
		CREATE TABLE #SheetVouchers ( 
		rownumber int IDENTITY(1,1), 
		VoucherCode varchar(100), 
		Used BIT, 
		OrderNo VARCHAR(100), 
		OrderTotal VARCHAR(100), 
		OrderDate VARCHAR(100), 
		OrderStatus VARCHAR(100),
		ShipTo VARCHAR(255),
		ShipToCity VARCHAR(255),
		ShipToState VARCHAR(255),
		Agent VARCHAR(255)
	)

INSERT #SheetVouchers  ([VoucherCode] , Used , [OrderNo] , [OrderTotal] , [OrderDate], [OrderStatus], [ShipTo], [ShipToCity], [ShipToState], [Agent])
SELECT [Voucher Code] , Used , [Order No] , [Order Total] , [Order Date] , [Order Status],[Ship To], [Ship To City], [Ship To State], [Agent]
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\Redeemer_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [Vouchers$]') o
WHERE [Voucher Code] IS NOT NULL

	;WITH VoucherCTE
	AS
	(
 	SELECT 
		[sVoucherUseID],
		[sVoucherID],
		[sVoucherCode],
		[sVoucherAmountApplied],
		[vDateTime],
		o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVouchersSalesUse] v ON o.OrderId = v.OrderID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = v.sVoucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')
	UNION
	SELECT 
		v.voucherUseID AS  [sVoucherUseID],
		vs.voucherId  AS [sVoucherID],
		vs.voucherCode AS [sVoucherCode],
		v.valueApplied AS [sVoucherAmountApplied],
		[vDateTime],
		o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVoucherUse] v ON o.OrderId = v.OrderID
	INNER JOIN dbo.tblVouchers vs ON vs.voucherID = v.voucherID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = vs.voucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')
		)
, AgentCte
AS
(
SELECT DISTINCT op.orderID AS OrderId,  AgentName FROM dbo.tblOrders_Products op WHERE AgentName IS NOT NULL
)

	UPDATE o 
	SET  [Used] = CASE WHEN [Used] = 1 THEN 1
				WHEN OrderNo IS NOT NULL THEN 1
				ELSE 0
				END
		,[Order No] = ISNULL(o.[Order No], vo.Orderno)
	    ,[Order Total] =  ISNULL( o.[Order Total],vo.orderTotal )
		,[Order Date] = ISNULL( o.[Order Date],  vo.OrderDate)
		,[Order Status] =  ISNULL(o.[Order Status], 
				CASE  vo.OrderStatus WHEN  'Delivered' THEN 'Delivered'
					WHEN  	'Cancelled' THEN 'Cancelled' 
					WHEN  'In Production' THEN 'In Production' 
					WHEN  'In Transit' THEN 'In Transit' 
					WHEN  'In Transit USPS' THEN 'In Transit' 
					WHEN  'On HOM Dock' THEN 'On MRK Dock' 
					WHEN  'On MRK Dock' THEN 'On MRK Dock' 
				END)
		,[Ship To] = ISNULL([Ship To], Shipping_FirstName + ISNULL(' ' + NULLIF(Shipping_Surname,''),''))
		,[Ship To City] = ISNULL( o.[Ship To City],  vo.shipping_Suburb )
		,[Ship To State] = ISNULL( o.[Ship To State],vo.shipping_State )
		,[Agent]  = ISNULL([Agent], (SELECT TOP 1 AgentName FROM AgentCte op WHERE op.orderID = vo.OrderId )) --businesss card first and the
	--  , --Add Job Status column 
	-- ,vo.*
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\Redeemer_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [Vouchers$]') o
INNER JOIN VoucherCTE vo 
ON vo.[sVoucherCode] = o.[Voucher Code]

		
;WITH VoucherCTE
AS
(
SELECT 
	[sVoucherUseID],
	[sVoucherID],
	[sVoucherCode],
	[sVoucherAmountApplied],
	[vDateTime],
	o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVouchersSalesUse] v ON o.OrderId = v.OrderID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = v.sVoucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')
	UNION
	SELECT 
		v.voucherUseID AS  [sVoucherUseID],
		vs.voucherId  AS [sVoucherID],
		vs.voucherCode AS [sVoucherCode],
		v.valueApplied AS [sVoucherAmountApplied],
		[vDateTime],
		o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVoucherUse] v ON o.OrderId = v.OrderID
	INNER JOIN dbo.tblVouchers vs ON vs.voucherID = v.voucherID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = vs.voucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')		

	)
UPDATE o 
SET  [Order Status] =  ISNULL(o.[Order Status], 
			CASE  vo.OrderStatus WHEN  'Delivered' THEN 'Delivered'
				WHEN  	'Cancelled' THEN 'Cancelled' 
				WHEN  'In Production' THEN 'In Production' 
				WHEN  'In Transit' THEN 'In Transit' 
				WHEN  'In Transit USPS' THEN 'In Transit' 
				WHEN  'On HOM Dock' THEN 'On MRK Dock' 
				WHEN  'On MRK Dock' THEN 'On MRK Dock' 
			END)
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\Redeemer_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [Vouchers$]') o
INNER JOIN VoucherCTE vo 
	ON vo.[sVoucherCode] = o.[Voucher Code]


;WITH   RemoteVoucherCTE
	AS
	(
	---Discounts
	SELECT vs.CouponCode AS sVoucherCode,  o.CreateDate AS OrderDate,  GbsOrderID  AS Orderno
			FROM  dbo.nopcommerce_Discount vs
				LEFT JOIN  dbo.nopcommerce_DiscountUsageHistory vsu ON vsu.DiscountId = vs.Id
				LEFT  JOIN   dbo.nopcommerce_tblNopOrder  o ON vsu.OrderId = o.nopId 
				WHERE vs.CouponCode  IN (SELECT VoucherCode FROM  #SheetVouchers v )
	UNION
		--Gift Cards
		SELECT vs.GiftCardCouponCode AS sVoucherCode,  o.CreateDate AS OrderDate,  GbsOrderID  AS Orderno 
			FROM  dbo.nopcommerce_GiftCard vs
				LEFT JOIN  dbo.nopCommerce_GiftCardUsageHistory vsu ON vsu.GiftCardId = vs.Id
				LEFT  JOIN   dbo.nopcommerce_tblNopOrder  o ON vsu.UsedWithOrderId = o.nopId 
				WHERE [GiftCardCouponCode]  IN (SELECT VoucherCode FROM  #SheetVouchers v )
				
	)

UPDATE o 
SET [Used] = CASE WHEN o.[Used] = 1 THEN 1
				WHEN OrderNo = 'OrderNo Not Known' THEN 0
				WHEN OrderNo IS NOT NULL AND OrderNo <> 'OrderNo Not Known' THEN 1
				END
			,[Order No] = CASE WHEN vo.OrderNo <> 'OrderNo Not Known'  THEN ISNULL(o.[Order No], vo.Orderno)
				WHEN vo.OrderNo = 'OrderNo Not Known' THEN ''
				ELSE ''
				END
		,[Order Date] =  ISNULL( o.[Order Date] , TRY_CONVERT(date,vo.OrderDate))
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\Redeemer_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [Vouchers$]') o 
INNER JOIN RemoteVoucherCTE vo ON vo.[sVoucherCode] = o.[Voucher Code]