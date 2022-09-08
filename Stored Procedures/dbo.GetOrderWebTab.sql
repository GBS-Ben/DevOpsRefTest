-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetOrderWebTab]
	--@Tabs nvarchar(20),
	@SqlWhere nvarchar(1024),
	@Order nvarchar(50)--,
	--@CountRow INT OUTPUT	
	
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	declare @SQLSel nvarchar(500);
	
	
	  set @SQLStatement = N' 
SELECT 
 orderNo,
 [buyer-name] as firstName,
[item-price] as itemPrice,
 CONVERT(datetime, [purchase-date], 101) as purchaseDate,
 ''Stock'' as orderType,
 orderStatus,
 lastStatusUpdate,
 [order-id] as storeID,
  [order-item-id] as orderId
 FROM tblAMZ_orderValid
  '+@SqlWhere+' '+@Order+' ';
	  
	   EXEC( @SQLStatement);
	 --  EXEC( @SQLStatementCount);
	  
	   END