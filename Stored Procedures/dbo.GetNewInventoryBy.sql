-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[GetNewInventoryBy]

	@From nvarchar(25),
	@To nvarchar(25),
	@PageSize int = 100,
	@StartIndex int =0,
	@SqlWhere nvarchar(1024),
	@CountRow INT OUTPUT	
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	
	set @SQLStatement = N' DECLARE @CountRow int;
	     SELECT @CountRow=
	     Count (t.ProductID)from (Select distinct(a.ProductID)FROM [dbo].[tblProducts] a 
	  	 '+@SqlWhere+') as t ;
	    
	     SELECT DISTINCT TOP ('+str(@PageSize)+') T1.*  FROM    (  SELECT DISTINCT TOP ('+str(@PageSize + @StartIndex)+')     a.ProductId,a.productCode,a.productName,
	  
	      a.stock_Level - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO as AvailStock,
	      a.productType,
	      a.onOrder,
	      a.INV_ONHOLD_SOLO as OnHold,
	      a.INV_WIP_SOLO as WIP,
	      a.stock_Level as PhysStock, 
	      a.productOnline as Hide,
	      a.stock_LowLevel as MinStock,
	      a.stock_Level as StockLevel,
	      a.parentProductId,
   	    
   	   (SELECT DISTINCT sum(p.productPrice*p.productQuantity)
	    FROM tblProducts q JOIN tblOrders_Products p ON p.productID=q.productID JOIN tblOrders o on p.orderID=o.orderID
	    WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID )  and o.orderstatus <> ''Cancelled'' AND o.orderStatus <> ''Failed''  AND o.orderDate > '''+ @From+ ''' AND o.orderDate < '''+ @To + ''' 	    AND p.deletex <> ''yes''   )  as ''totalValueSold'', 
	   
	   (SELECT SUM(p.productQuantity*q.numUnits)
	    FROM tblProducts q JOIN tblOrders_Products p ON p.productID=q.productID JOIN tblOrders o on p.orderID=o.orderID
	    WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) and o.orderstatus <> ''Cancelled'' AND o.orderStatus <> ''Failed''	  AND o.orderDate > '''+ @From+ '''  AND o.orderDate < '''+ @To + '''  	   AND p.deletex <> ''yes''	    )as ''totalNumberSold'',
	    (
	     SELECT COUNT(distinct(productID+orderID)) FROM tblOrders_products WHERE deleteX <> ''yes''	     and orderID in (select orderID from tblOrders where orderstatus <> ''failed'' AND	      orderStatus <> ''cancelled'' AND orderDate > '''+ @From+ '''  AND orderDate < '''+ @To + ''' ) AND productID IN (SELECT distinct productID FROM tblProducts where parentProductID = a.productID)	    
	     )	      as ''NumTrans'', 
	     @CountRow as ''CountRow''  
	     FROM tblProducts a 	     '+@SqlWhere+'
	     Order by a.ProductId DESC ) AS T1 Order by T1.ProductId';
	   
	  --  set @SQLStatementCount = N' SELECT @CountRow= Count(ProductID)FROM [dbo].[tblProducts] a where  a.productname NOT LIKE ''%SPECIAL%'' AND a.productname NOT LIKE ''%PACK%'' AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') '+@SqlWhere+'' ;
	   
	   EXEC( @SQLStatement);
	 --  EXEC( @SQLStatementCount);
	  
	   END