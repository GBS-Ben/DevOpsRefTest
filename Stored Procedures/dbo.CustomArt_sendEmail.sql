

CREATE PROC [dbo].[CustomArt_sendEmail]
@Order_ProductID INT

AS
-------------------------------------------------------------------------------
-- Author      Jonathan Bentley
-- Created     08/22/22
-- Purpose     Send email to necessary party to inspect Custom art as it comes into system.
-------------------------------------------------------------------------------
-- Modification History
--
--08/22/22  Proc Created JSB
-------------------------------------------------------------------------------

DECLARE @emailSent INT = 0,
				 @subjecttext NVARCHAR(100),
				 @bodytext NVARCHAR(MAX),
				 @email NVARCHAR(255),
				 @OrderNo NVARCHAR(20),
				 @OrderID NVARCHAR(20),
				 @OPID NVARCHAR(20),
				 @ProductCode NVARCHAR(20),
				 @ProductName NVARCHAR(255),
				 @OppoCaption NVARCHAR(225),
				 @OppoValue NVARCHAR(225),
				 @OPPOCount INT

IF @OPID <> 0 
BEGIN
	SET @emailSent = (SELECT TOP 1 1
									 FROM CustomArtEmailLog
									 WHERE OPID =  @Order_ProductID
									 AND emailSent = 1)
END

IF @emailSent IS NULL
BEGIN
	SET @emailSent = 0
END

IF @emailSent = 0
BEGIN
	SET @OrderID = (SELECT orderID FROM tblOrders_Products WHERE ID = @Order_ProductID)
	SET @OrderNo = (SELECT orderNo FROM tblOrders WHERE orderID = @OrderID)
	SET @OPID = (SELECT ID FROM tblOrders_Products WHERE ID = @Order_ProductID)
	SET @ProductCode = (SELECT productCode FROM tblOrders_Products WHERE ID = @Order_ProductID)
	SET @ProductName = (SELECT productName FROM tblOrders_Products WHERE ID = @Order_ProductID)
	SET @email = 'staffordbentley@gmail.com'
	SET @subjecttext = 'INSPECT ART: ' + SUBSTRING(@ProductCode, 1 , 4) + ' ('+ @OPID + ')'
	
	DROP TABLE IF EXISTS #OppoTemp
	SELECT ROW_NUMBER() OVER(ORDER BY PKID ASC) AS ROW, po.orderviewDisplayText, oppo.textValue INTO #OppoTemp
	FROM tblOrdersProducts_ProductOptions oppo
	INNER JOIN tblProductOptions po ON po.optionID = oppo.optionID
	WHERE oppo.ordersProductsID = @OPID AND oppo.deletex <>'yes' AND po.displayOnOrderView = 1
	SET @OPPOCount = (SELECT COUNT(*) FROM #OppoTemp)
	

	SET @bodyText = 'Please Inspect the Custom art for order:  ' + RIGHT(@OrderNo,7) + '_' + @OPID + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodyText = @bodyText + 'Product Code: ' +@ProductCode+ ' -- Product Name:' +@ProductName + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	DECLARE @i INT
	SET @i = 1
		WHILE @i <= @OPPOCount
			BEGIN
				SET @OppoCaption = (SELECT orderviewDisplayText FROM #OppoTemp WHERE Row = @i)
				SET @OppoValue = (SELECT textValue FROM #OppoTemp WHERE Row = @i)
				SET @bodyText = @bodyText + CHAR(9) + @OppoCaption + ': ' + @OppoValue + CHAR(13) + CHAR(10)
				SET @i = @i + 1
			END
	SET @bodyText = @bodyText + CHAR(13) + CHAR(10)+ 'Here''s a link to the order: http://intranet/gbs/admin/orderView.asp?i=' + CONVERT(NVARCHAR(20), @orderID) + '&o=orders.asp&OrderNum=' + @orderNo + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	SET @bodyText = @bodyText + '~ SQL'

	--EXEC sp_send_cdosysmailtxt 'GBS.SQL@gogbs.com', @email, @subject, @body

	EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLAlerts',
				@recipients = @email,
				@body = @bodyText,
				@subject = @subjectText


	INSERT INTO CustomArtEmailLog (OrderID, OrderNo, OPID, emailSent, emailSentTo, emailSentOn)
	SELECT @OrderID, @OrderNo,@Order_ProductID, 1, @email, GETDATE()

END