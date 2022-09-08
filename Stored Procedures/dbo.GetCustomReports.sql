-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- JF 12/29/16 - not sure what this does.
-- =============================================

CREATE PROCEDURE [dbo].[GetCustomReports]

	@From nvarchar(25),
	@To nvarchar(25),
	@PageSize int = 100,
	@StartIndex int =0,
	@SqlWhere nvarchar(1024),
	@CountRow INT OUTPUT,	
	@OrderSq nvarchar(2000),
	@OrderDesc nvarchar(2000)
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @sq nvarchar(50)=''''' as productCode, '''' as productName,';
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);		
		IF( @SqlWhere LIKE '%productName%' or @SqlWhere LIKE '%productCode%')set @sq = ' o.productCode, o.productName,';
	IF (@SqlWhere<>'')
	begin
	set @SQLStatement = N' DECLARE @CountRow int;
	     SELECT @CountRow= COUNT (DISTINCT orderID)FROM CustomReportsWithProductView o  WHERE ( o.orderDate >= '''+@From+''' AND o.orderDate < '''+@To+''') '+@SqlWhere+';
	     SELECT  TOP ('+str(@PageSize)+') 
	      T1.OrderID,
	      T1.orderNo,
	      T1.orderStatus,
	      T1.orderType,
	      T1.orderDate,
	      T1.orderTotal,
	      T1.customerName,
	      T1.email,	            
	      T1.CountRow       
	      FROM    (  SELECT DISTINCT TOP ('+str(@PageSize + @StartIndex)+') 
	      o.orderNo,
	      o.orderStatus,
	      o.orderType,
	      o.orderDate,
	      o.orderTotal,
	      o.customerName,
	      o.orderID,          
	       case when  ''+@SqlWhere+'' LIKE ''%o.customerID%'' then  o.customerID else  '''' end as customerID,
	      case when  ''+@SqlWhere+'' LIKE ''%o.company%'' then  o.company else  '''' end as company,
	      -- case when  ''+@SqlWhere+'' LIKE ''%o.email%'' then   o.email else  '''' end as email,
	        case when  ''+@SqlWhere+'' LIKE ''%o.displayPaymentStatus%'' then  o.displayPaymentStatus else  '''' end as displayPaymentStatus,
	         case when  ''+@SqlWhere+'' LIKE ''%o.Shipping_State%'' then o.Shipping_State else  '''' end as Shipping_State,
	          case when  ''+@SqlWhere+'' LIKE ''%o.Shipping_PostCode%'' then  o.Shipping_PostCode else  '''' end as Shipping_PostCode,
	           case when  ''+@SqlWhere+'' LIKE ''%o.productCode%'' then  o.productCode else  '''' end as productCode,
	            case when  ''+@SqlWhere+'' LIKE ''%o.productName%'' then o.productName else  '''' end as productName,
	    --  o.company,
	     o.email,
	   --   o.displayPaymentStatus,
	    --  o.Shipping_State,
	    --  o.Shipping_PostCode,
	       
	     --	    '+@sq+'	      
	     @CountRow as ''CountRow''  
	     FROM CustomReportsWithProductView as o  WHERE ( o.orderDate >= '''+@From+''' AND o.orderDate < '''+@To+''') '+@SqlWhere+' '+@OrderSq+'
	      ) AS T1 
	     '+@OrderDesc+'
	       ';
	   end;
	   else
	   if  (@SqlWhere = '')   
	   begin 
	  set @SQLStatement = N' DECLARE @CountRow int;
	   SELECT @CountRow= COUNT(orderID)FROM CustomReportsView o WHERE ( o.orderDate >= '''+@From+''' AND o.orderDate < '''+@To+''');
	     
	     SELECT  TOP ('+str(@PageSize)+') 
	      T1.OrderID,
	      T1.orderNo,
	      T1.orderStatus,
	      T1.orderType,
	      T1.orderDate,
	      T1.orderTotal,
	      T1.customerName,	  
	      T1.email,         
	      T1.CountRow       
	      FROM    (  SELECT  TOP ('+str(@PageSize + @StartIndex)+') 
	      o.OrderID,
	      o.orderNo,
	      o.orderStatus,
	      o.orderType,
	      o.orderDate,
	      o.orderTotal,
	      o.customerName,
	      o.email,	               
	     @CountRow as ''CountRow''  
	     FROM CustomReportsView as o WHERE ( o.orderDate >= '''+@From+''' AND o.orderDate < '''+@To+''') '+@OrderSq+'
	      ) AS T1 
	     '+@OrderDesc+' 
	      ';
	   end;
	   
	 	   EXEC( @SQLStatement);	  
	   END