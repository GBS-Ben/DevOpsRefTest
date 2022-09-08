-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[GetInventory_dev]

	@From nvarchar(25),
	@To nvarchar(25),
	@PageSize int = 100,
	@StartIndex int =0,
	@SqlWhere nvarchar(1024),
	@CountRow INT OUTPUT,
	@OrderSq nvarchar(3000)	,
	@OrderDesc nvarchar(3000)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	
	set @SQLStatement = N' DECLARE @CountRow int;
	     set @CountRow= (Select  Count  ( distinct a.ProductID)FROM [dbo].[totalInventory] a where  a.productname NOT LIKE ''%SPECIAL%'' AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') AND ( a.orderDate > '''+ @From+ '''  AND a.orderDate < '''+ @To + ''' )	 '+@SqlWhere+');
	
	     SELECT TOP ('+str(@PageSize)+') T1.*  FROM    (  SELECT   TOP ('+str(@PageSize + @StartIndex)+')     a.ProductId,a.productCode,a.productName,
	    	     a.AvailStock ,
	      a.productType,
	      a.onOrder,
	      a.OnHold,
	      a.WIP,
	       a.PhysStock ,
	        a.Hide,
	         a.MinStock,
	          a.StockLevel,
	           a.parentProductId,       
	   
	  (SELECT sum(TotalValueSold) from [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate > '''+ @From+ ''' AND q.orderDate < '''+ @To + '''   )  as ''totalValueSold'',
	
	  (SELECT SUM(TotalNumberSold)FROM [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate > '''+ @From+ '''  AND q.orderDate < '''+ @To + '''     )as ''totalNumberSold'',
	
	  (SELECT COUNT(NumTrans) FROM [dbo].[totalInventory]as q  WHERE  orderDate > '''+ @From+ '''  AND orderDate < '''+ @To + '''  AND (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID))	 as ''NumTrans'', 
	
	     @CountRow as ''CountRow''  
	     FROM totalInventory a  where  a.productname NOT LIKE ''%SPECIAL%''  AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') 
	    AND ( a.orderDate > '''+ @From+ '''  AND a.orderDate < '''+ @To + ''' )	 
	     '+@SqlWhere+' group by   a.ProductId,a.productCode,a.productName,
	    	     a.AvailStock ,
	      a.productType,
	      a.onOrder,
	      a.OnHold,
	      a.WIP,
	       a.PhysStock ,
	        a.Hide,
	         a.MinStock,
	          a.StockLevel,
	           a.parentProductId '+@OrderSq+') AS T1  '+@OrderDesc+' ';
	   	    
	   EXEC( @SQLStatement);	
	  
	   END