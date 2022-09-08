-- =============================================
-- Author:		Russian
-- Create date: 2011
-- Description:	This is the SPROC used by
-- JF works on this now as of 06/15/16
-- =============================================

CREATE PROCEDURE [dbo].[GetInventory]

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
	DECLARE @SQLUpdProduct nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	
	set @SQLStatement = N' DECLARE @CountRow int;
	     SELECT @CountRow= Count(ProductID)FROM [dbo].[tblProducts] a 
		 WHERE  (a.productname NOT LIKE ''%SPECIAL%'' AND a.productName NOT LIKE ''%pack%'')
		 AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') '+@SqlWhere+';
	
	     SELECT TOP ('+str(@PageSize)+') T1.*  FROM    (  SELECT  TOP ('+str(@PageSize + @StartIndex)+')     a.ProductId,a.productCode,a.productName,
	     -- a.stock_Level - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO as AvailStock,
	      case 
	      when a.stock_Level<0 
	       then  0 - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO
	       else  a.stock_Level - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO
	     end  as AvailStock ,
	      a.productType,
	      a.onOrder,
	      a.INV_ONHOLD_SOLO as OnHold,
	      a.INV_WIP_SOLO as WIP,
	       case 
	       when a.stock_Level<0 
	       then  0
	       else  a.stock_Level
	       end   as PhysStock ,
	      -- a.stock_Level as PhysStock,
	        a.productOnline as Hide,
	         a.stock_LowLevel as MinStock,
	          a.stock_Level as StockLevel,
	           a.parentProductId, 	    

	   
	   
	  (SELECT DISTINCT sum(TotalValueSold) from [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate > '''+ @From+ ''' AND q.orderDate < '''+ @To + '''   )  as ''totalValueSold'',
	
	  (SELECT SUM(TotalNumberSold)FROM [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate > '''+ @From+ '''  AND q.orderDate < '''+ @To + '''     )as ''totalNumberSold'',
	
	  (SELECT COUNT(distinct(NumTrans)) FROM [dbo].[totalInventory]as q  WHERE  orderDate > '''+ @From+ '''  AND orderDate < '''+ @To + '''  AND (q.parentProductID = a.ProductID ))	 as ''NumTrans'', 
	
	     @CountRow as ''CountRow''  
	     FROM tblProducts a  
		 WHERE  (a.productname NOT LIKE ''% SPECIAL %'')
		 AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') 
	 
	     '+@SqlWhere+'
	     '+@OrderSq+') AS T1  '+@OrderDesc+' ';
	   	    
	   	    set @SQLUpdProduct = N' 
	    
	      SELECT ''EXEC usp_popInv '' + CAST(a.ProductId AS varchar)  FROM tblProducts a 
		  WHERE  (a.productname NOT LIKE ''% SPECIAL %'')  
		  AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') 
	 	     '+@SqlWhere;
	    -- EXEC( @SQLUpdProduct);	
	    
	  EXEC( @SQLStatement);	
	  
	   END