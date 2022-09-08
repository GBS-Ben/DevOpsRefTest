CREATE PROCEDURE [dbo].[usp_LoadBusinessCardReOrderEmails]
AS 
SET NOCOUNT ON;

--CREATE TABLE tblBusinessCardReorderQueue ( 
--	BusinessCardReorderQueueKey int IDENTITY(1,1), 
--	OrderNo varchar(50), 
--	OrderId int,
--	OPID int,
--	OrderEmail varchar(500), 
--	BusinessCardEmail varchar(500),
--	ReorderLink varchar(500),
--	LastOrderDate datetime, 
--	DaysSinceLastOrder int, 
--	ImageUrl varchar(500)
--	)
BEGIN TRY

	 DECLARE @Orders TABLE (
		rownum int IDENTITY(1,1), 
		OrderNo varchar(50), 
		OrderId int,
		OPID int,
		OrderEmail varchar(500), 
		BusinessCardEmail varchar(500),
		ReorderLink varchar(500),
		LastOrderDate datetime, 
		DaysSinceLastOrder int, 
		ImageUrl varchar(500)
		)

	 --Business Card Orders in last 90 days
	 ;WITH RecentOrders
	 AS (
		SELECT DISTINCT OrderNo, OrderDate
		FROM tblOrderView o
		INNER JOIN  tblOrders_Products  op ON o.OrderID = op.orderID
		INNER JOIN tblProducts p ON p.productID = op.productID
		WHERE p.productcode like 'BP%%'
			AND o.OrderStatus = 'Delivered'
			AND  convert(datetime, orderdate)  >= dateadd(dd,-90,convert(datetime, getdate()) )
		),
	  OrdersThisYear
	 AS (
		SELECT OrderNo
		FROM tblOrderView o
		INNER JOIN  tblOrders_Products  op ON o.OrderID = op.orderID
		INNER JOIN tblProducts p ON p.productID = op.productID
		WHERE p.productcode like 'BP%'
			AND o.OrderStatus = 'Delivered'
			AND  convert(datetime, orderdate)  >= dateadd(dd,-120,convert(datetime, getdate()) )
		)

	INSERT @Orders (OrderNo, OrderId, OPID, OrderEmail,BusinessCardEmail, ReOrderLink, LastOrderDate, DaysSinceLastOrder)
	SELECT DISTINCT o.OrderNo, 
		o.OrderId,
		op.Id - 444333222 AS Opid,   --gotta do the offset so we can use the OPID when we call HOM
		email AS OrderPlacerEmail, 
		CustomerEmail AS CardEmail,
		'http://www.houseofmagnets.com/webservices/marketing.aspx?reorderlink=true&opid=' + CONVERT(varchar(20), op.Id - 444333222) AS ReorderLink, 
		orderDate, 
		DATEDIFF(dd, orderDate, GETDATE()) AS DaysSinceLastOrder
	FROM OrdersThisYear oty 
	INNER JOIN  tblOrderView o ON oty.OrderNo = o.orderNo
	INNER JOIN  tblOrders_Products  op ON o.OrderID = op.orderID
	INNER JOIN 	 tblProducts p ON p.productID = op.productID
	--INNER JOIN  tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
	WHERE o.orderNo NOT IN (SELECT orderNo FROM RecentOrders)
		AND p.productcode like 'BP%'
		AND op.CustomerEmail IS NOT NULL

	UPDATE o 
	SET ImageUrl = 'https://gluon.houseofmagnets.com' + textValue
	FROM @Orders o
	INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = (o.OPID + 444333222)
	WHERE oppo.optionID = 320 --files

	--Remove all duplicate orders
	DELETE @Orders
	WHERE rownum NOT IN (
		SELECT rownum
		FROM (
			SELECT ROW_NUMBER() OVER(PARTITION BY BusinessCardEmail ORDER BY LastOrderDate DESC) AS LastOrder , o.*
			FROM @Orders o
		) a 
		WHERE a.LastOrder = 1
	)

	--Remove unsubscribed from Reminders members
	;WITH RemoveMembers
	AS
	(
	SELECT Email 
	FROM [dbo].[HOMLive_tblUnsubscribeMember]
	)
	DELETE @Orders WHERE BusinessCardEmail IN (SELECT Email FROM RemoveMembers)



	--Insert Only new
	INSERT tblBusinessCardReorderQueue (
		OrderNo,
		OrderId ,
		OPID,
		OrderEmail,
		BusinessCardEmail,
		ReorderLink,
		LastOrderDate,
		DaysSinceLastOrder,
		ImageUrl
		)
	SELECT 	o.OrderNo,
		o.OrderId ,
		o.OPID,
		o.OrderEmail,
		o.BusinessCardEmail,
		o.ReorderLink,
		o.LastOrderDate,
		o.DaysSinceLastOrder,
		o.ImageUrl
	FROM @Orders o 
	LEFT JOIN tblBusinessCardReorderQueue q ON q.OrderID = o.OrderId 
		AND q.Opid = o.OPID
		AND q.BusinessCardEmail = o.BusinessCardEmail
	LEFT JOIN tblBusinessCardReorderEmailLog l ON l.RecipientEmail = o.BusinessCardEmail
		AND l.OPID = o.OPID
		AND l.OrderNo = o.OrderNo
	WHERE q.Opid IS NULL --make sure we dont have this opid email queued
		and l.OPID IS NULL  --make sure we havent sent this email
END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH