CREATE PROCEDURE [dbo].[GetInventoryTotalsBy_dev]

	@From nvarchar(25),
	@To nvarchar(25),
	@SqlWhere nvarchar(1024)
		
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);
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
(SELECT	distinct	
	      a.AvailStock ,	      
	      a.onOrder,
	      a.OnHold,
	      a.WIP,
	      a.PhysStock ,   
	   
	  (SELECT DISTINCT sum(TotalValueSold) from [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate > '''+ @From+ ''' AND q.orderDate < '''+ @To + '''   )  as ''totalValueSold'',
	
	  (SELECT SUM(TotalNumberSold)FROM [dbo].[totalInventory] as q WHERE  (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID ) AND q.orderDate > '''+ @From+ '''  AND q.orderDate < '''+ @To + '''     )as ''totalNumberSold'',
	
	  (SELECT COUNT(NumTrans) FROM [dbo].[totalInventory]as q  WHERE  orderDate > '''+ @From+ '''  AND orderDate < '''+ @To + '''  AND (q.ProductID = a.ProductID OR q.parentProductID = a.ProductID))	 as ''NumTrans''
	
	      FROM totalInventory a  where  a.productname NOT LIKE ''%SPECIAL%''  AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') 
	    AND ( a.orderDate >= '''+ @From+ '''  AND a.orderDate < '''+ @To + ''' )	 '+@SqlWhere+') as t1' ;
	   
	   
	   EXEC( @SQLStatement);
		  
	   END

--// exec [dbo].[GetInventoryTotalsBy] @From=N'2014-07-16 00:00:00.000',@To=N'2014-07-16 23:59:59.000',@SqlWhere=N''