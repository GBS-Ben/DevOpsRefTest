CREATE PROCEDURE [dbo].[usp_updateWeights]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     circa 2006
-- Purpose     Update weights
-------------------------------------------------------------------------------
-- Modification History

--	12/13/18	bs, removed cursor and added tblorder update at the end


-------------------------------------------------------------------------------
SET NOCOUNT ON;

BEGIN TRY

	DECLARE 
	@orderWeight FLOAT,
	@orderNo VARCHAR(255),
	@orderId int, 
	@com FLOAT,
	@res FLOAT,
	@aReg FLOAT,
	@bReg FLOAT, 
	@rowCount int,
	@intFlag int

	DECLARE @Orders TABLE (
	rownum int identity(1, 1), 
	OrderId int, 
	OrderNo VARCHAR(100), 
	orderWeight FLOAT,
	res FLOAT,
	com FLOAT,
	aReg FLOAT,
	bReg FLOAT
		) 

	SET @intFlag = 1

	INSERT @Orders (orderId, OrderNo, orderWeight, res, com, aReg, bReg)
	SELECT OrderId, orderNo, orderWeight, res, com, aReg, bReg
	FROM tblOrders
	WHERE DATEDIFF(dd,orderDate,GETDATE()) < 2
		AND orderWeight IS NULL
		AND res IS NULL
		AND com IS NULL
		AND aReg IS NULL
		AND bReg IS NULL

	SELECT @rowCount = COUNT(*) FROM @Orders

	WHILE (@intFlag <= @rowCount)
	BEGIN

	--NULL VARS OUT
	SET @orderWeight = NULL
	SET @com = NULL
	SET @res = NULL
	SET @aReg = NULL
	SET @bReg = NULL
	SET @orderNo = NULL
	SET @orderId = NULL

	SELECT @orderNo = OrderNo, 
		@OrderID = OrderId
	FROM @Orders 
	WHERE rownum = @intFlag

	--SET VARS
	SET @orderWeight = (SELECT CEILING(SUM(a.productQuantity * b.[weight]))
						FROM tblOrders_Products a 
						INNER JOIN tblOrders x ON a.orderID = x.orderID
						INNER JOIN tblProducts b ON a.productID = b.productID
						WHERE a.deleteX<>'yes'
						AND a.orderID = @OrderID
						) 

	IF @orderWeight > 75
	BEGIN
		SET @orderWeight = 75
	END

	SET @com = (SELECT ROUND(a.com,2) 
						FROM tblRates a 
						INNER JOIN tblOrders b ON a.Zones = b.shipZone
						WHERE a.lbs = @orderWeight
						AND orderNo = @orderNo)

	SET @res = (SELECT ROUND(a.res,2) 
						FROM tblRates a 
						INNER JOIN tblOrders b
						ON a.Zones = b.shipZone
						WHERE a.lbs = @orderWeight
						AND orderNo = @orderNo)

	SET @aReg = (SELECT a.aReg 
							FROM tblRates a 
							INNER JOIN tblOrders b
							ON a.Zones = b.shipZone
							WHERE a.lbs = @orderWeight
							AND orderNo = @orderNo)

	SET @bReg = (SELECT a.bReg 
							FROM tblRates a 
							INNER JOIN tblOrders b
							ON a.Zones = b.shipZone
							WHERE a.lbs = @orderWeight
							AND orderNo = @orderNo)

		UPDATE @Orders
		SET 	orderWeight = @orderWeight,
			res = @res,
			com = @com,
			aReg = @aReg,
			bReg = @bReg
		WHERE orderNo = @orderNo

	 SET @intFlag = @intFlag + 1
	END	

	UPDATE o
	SET orderWeight = d.orderWeight,
			res = d.res,
			com = d.com,
			aReg = d.aReg,
			bReg = d.bReg
	FROM tblOrders o
	INNER JOIN @Orders d ON d.OrderID = o.OrderID


END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH