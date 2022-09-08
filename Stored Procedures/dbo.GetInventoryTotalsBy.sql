-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[GetInventoryTotalsBy]

	@From nvarchar(25),
	@To nvarchar(25),
	@SqlWhere nvarchar(1024)
		
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);DECLARE @SQLStatementN nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	
	set @SQLStatement = N' 	 
	
	SELECT 
convert(int,sum(Isnull(t1.AvailStock,0))) as TotalStock,
sum(Isnull(t1.onOrder,0)) as TotalOrder,
sum(Isnull(t1.OnHold,0)) as TotalOnHold,
sum(Isnull(t1.WIP,0)) as TotalWIP,
sum(Isnull(t1.PhysStock,0)) as TotalPhysStock,
sum(Isnull(t1.totalValueSold,0)) as TotalValue,
sum(Isnull(t1.totalNumberSold,0)) as TotalNumber,
sum(Isnull(t1.NumTrans,0)) as TotalNumTrans
FROM
(SELECT		
	      case 
	      when a.stock_Level<0 
	       then  0 - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO
	       else  a.stock_Level - a.INV_ONHOLD_SOLO - a.INV_WIP_SOLO
	     end  as AvailStock ,
	     
	      a.onOrder,
	      
	      a.INV_ONHOLD_SOLO as OnHold,
	      
	      a.INV_WIP_SOLO as WIP,
	      
	       case 
	       when a.stock_Level<0 
	       then  0
	       else  a.stock_Level
	       end   as PhysStock ,
	        
   	  ( SELECT DISTINCT sum(TotalValueSold) from [dbo].[TotalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate >= '''+ @From+ ''' AND q.orderDate < '''+ @To + '''   )  as ''totalValueSold'',
	  
	  (SELECT SUM(TotalNumberSold)FROM [dbo].[TotalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate >= '''+ @From+ '''  AND q.orderDate < '''+ @To + '''     )as ''totalNumberSold'',
	   	    
	   (SELECT COUNT(distinct(NumTrans)) FROM [dbo].[TotalInventory]as q  WHERE  orderDate >= '''+ @From+ '''  AND orderDate < '''+ @To + '''  AND (q.parentProductID = a.ProductID ))	 as ''NumTrans''
	    	     	    
	     FROM tblProducts a  where  a.productname NOT LIKE ''% SPECIAL %'' AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') '+@SqlWhere+') as t1' ;
	   
	   
		set @SQLStatementN = N' 	 
	
	SELECT 
convert(int,sum(Isnull(t1.AvailStock,0))) as TotalStock,
sum(Isnull(t1.onOrder,0)) as TotalOrder,
sum(Isnull(t1.OnHold,0)) as TotalOnHold,
sum(Isnull(t1.WIP,0)) as TotalWIP,
sum(Isnull(t1.PhysStock,0)) as TotalPhysStock,
sum(Isnull(t1.totalValueSold,0)) as TotalValue,
sum(Isnull(t1.totalNumberSold,0)) as TotalNumber,
sum(Isnull(t1.NumTrans,0)) as TotalNumTrans
FROM
(SELECT	distinct	
	      a.AvailStock ,	      
	      a.onOrder,
	      a.OnHold,
	      a.WIP,
	      a.PhysStock ,   
	   
	  (SELECT DISTINCT sum(TotalValueSold) from [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate >= '''+ @From+ ''' AND q.orderDate < '''+ @To + '''   )  as ''totalValueSold'',
	
	  (SELECT SUM(TotalNumberSold)FROM [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate >= '''+ @From+ '''  AND q.orderDate < '''+ @To + '''     )as ''totalNumberSold'',
	
	  (SELECT COUNT(NumTrans) FROM [dbo].[totalInventory]as q  WHERE  orderDate >= '''+ @From+ '''  AND orderDate < '''+ @To + '''  AND (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID))	 as ''NumTrans''
	
	      FROM totalInventory a  where  a.productname NOT LIKE ''% SPECIAL %''  AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') 
	    AND ( a.orderDate >= '''+ @From+ '''  AND a.orderDate < '''+ @To + ''' )	 '+@SqlWhere+') as t1' ;
	   
	   
	   EXEC( @SQLStatementN);  
	   
		  
	   END