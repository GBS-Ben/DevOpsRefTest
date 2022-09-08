-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetOrderTabs]
	@Tabs nvarchar(20),
	@SqlWhere nvarchar(1024),
	@Order nvarchar(50)--,
	--@CountRow INT OUTPUT	
	
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	declare @SQLSel nvarchar(500);
	
	if @Tabs='stock'
	begin	
	set @SQLStatement = N' 
	--DECLARE @CountRow int;
	   --  SELECT @CountRow= Count(tblOrders.orderID) FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.orderStatus<>''Delivered'' AND tblOrders.orderStatus not like ''%Transit%'' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = ''Valid'' AND tblOrders.orderType=''Stock'' AND tblCustomers.firstName <> ''''
	   --    '+@SqlWhere+';
	     SELECT   
	      tblOrders.orderID,
	      tblOrders.customerID,
	      tblOrders.orderDate,--
	      tblOrders.orderNo,--
	      tblOrders.orderTotal,--
	      tblOrders.paymentAmountRequired,--
	      tblOrders.paymentMethod,--
	      tblOrders.orderStatus,--
	      tblOrders.displayPaymentStatus,--
	      tblOrders.statusDate,--
	      tblOrders.lastStatusUpdate,
	       tblOrders.orderBatchedDate, 
	      tblOrders.orderType,--
	      tblOrders.shippingMethod, --
	      tblOrders.shippingDesc, --
	      tblOrders.storeID, --
	      tblCustomers.firstName, 
	      tblCustomers.surname,
	       tblCustomers.phone,
	      tblCustomers.email
	      --,
	     -- @CountRow as CountRow 
	       FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.orderStatus<>''Delivered'' AND tblOrders.orderStatus not like ''%Transit%'' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = ''Valid'' AND tblOrders.orderType=''Stock'' AND tblCustomers.firstName <> ''''
	       '+@SqlWhere+'
	        '+@Order+' '
	        ;
	    --  set @SQLStatementCount = N' SELECT @CountRow= Count(ProductID)FROM [dbo].[tblProducts] a where  a.productname NOT LIKE ''%SPECIAL%'' AND a.productname NOT LIKE ''%PACK%'' AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') '+@SqlWhere+'' ;
	  end 
	  ELSE if @Tabs='custom'
	  begin 
	  set @SQLStatement = N' 
	  --DECLARE @CountRow int;
	     --SELECT @CountRow= Count(tblOrders.orderID) FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> ''Failed'' AND tblOrders.tabStatus <> ''Exception'') AND tblOrders.orderType=''Custom'' AND tblOrders.orderStatus <> ''Failed'' AND tblOrders.orderStatus <> ''Cancelled'' AND tblCustomers.firstName <> ''''
	    --   '+@SqlWhere+';
	     SELECT   
	      tblOrders.orderID,
	      tblOrders.customerID,
	      tblOrders.orderDate,--
	      tblOrders.orderNo,--
	      tblOrders.orderTotal,--
	      tblOrders.paymentAmountRequired,--
	      tblOrders.paymentMethod,--
	      tblOrders.orderStatus,--
	      tblOrders.displayPaymentStatus,--
	      tblOrders.statusDate,--
	      tblOrders.lastStatusUpdate,
	      tblOrders.orderType,--
	      tblOrders.shippingMethod, --
	      tblOrders.shippingDesc, --
	      tblOrders.storeID, --
	      tblCustomers.firstName, 
	       tblOrders.orderBatchedDate, 
	      tblCustomers.surname,
	      tblCustomers.email,
	       tblCustomers.phone
	    --  @CountRow as CountRow 
	       FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> ''Failed'' AND tblOrders.tabStatus <> ''Exception'') AND tblOrders.orderType=''Custom'' AND tblOrders.orderStatus <> ''Failed'' AND tblOrders.orderStatus <> ''Cancelled'' AND tblCustomers.firstName <> ''''
	       '+@SqlWhere+' '+@Order+' ';
	  end
	  ELSE IF @Tabs='pending'
	  begin 
	  set @SQLStatement = N' 
	  --DECLARE @CountRow int;
	   --  SELECT @CountRow= Count(tblOrders.orderID)  FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0  AND tblOrders.paymentSuccessful= 0 AND (tblOrders.tabStatus = ''offline'' OR tblOrders.tabStatus = ''faxed'' OR tblOrders.tabStatus = ''checkcash'') AND tblOrders.orderStatus <> ''Failed'' AND tblOrders.orderStatus <> ''Cancelled'' AND tblCustomers.firstName <> ''''
	   -- '+@SqlWhere+';
	     SELECT   
	      tblOrders.orderID,
	      tblOrders.customerID,
	      tblOrders.orderDate,--
	      tblOrders.orderNo,--
	      tblOrders.orderTotal,--
	      tblOrders.paymentAmountRequired,--
	      tblOrders.paymentMethod,--
	      tblOrders.orderStatus,--
	      tblOrders.displayPaymentStatus,--
	      tblOrders.statusDate,--
	      tblOrders.lastStatusUpdate,
	      tblOrders.orderType,--
	      tblOrders.shippingMethod, --
	      tblOrders.shippingDesc, --
	      tblOrders.storeID, --
	      tblCustomers.firstName, 
	       tblOrders.orderBatchedDate, 
	      tblCustomers.surname,
	       tblCustomers.phone,
	      tblCustomers.email
	    --  ,
	  --    @CountRow as CountRow 
	      FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE
	       tblOrders.archived=0  AND tblOrders.paymentSuccessful= 0 AND (tblOrders.tabStatus = ''offline'' OR 
	       tblOrders.tabStatus = ''faxed'' OR tblOrders.tabStatus = ''checkcash'') AND tblOrders.orderStatus <> ''Failed'' AND 
	       tblOrders.orderStatus <> ''Cancelled'' AND tblCustomers.firstName <> ''''
	       '+@Order+' ';
	       end
	       ELSE IF @Tabs='exceptions'
	  begin 
	  set @SQLStatement = N'
	  -- DECLARE @CountRow int;
	   --  SELECT @CountRow= Count(tblOrders.orderID) FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
	   --  WHERE tblOrders.archived=0 AND tblCustomers.firstName <> ''''
  -- '+@SqlWhere+';
  SELECT 
  tblOrders.orderID,
  tblOrders.customerID,	
  tblOrders.orderDate, 
  tblOrders.orderNo, 
  tblOrders.orderTotal, 
  tblOrders.paymentAmountRequired, 
  tblOrders.paymentMethod, 
  tblOrders.orderStatus, 
  tblOrders.statusDate, 
  tblOrders.orderType, 
  tblOrders.shippingMethod, 
  tblOrders.shippingDesc, 
  tblOrders.storeID, 
  tblCustomers.firstName, 
   tblOrders.lastStatusUpdate,
    tblOrders.orderBatchedDate, 
  --  @CountRow as CountRow,
    tblCustomers.email,
     tblCustomers.phone,
       tblOrders.displayPaymentStatus,--
  tblCustomers.surname 
  FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
  WHERE tblOrders.archived=0 AND tblCustomers.firstName <> ''''  
'+@SqlWhere+' '+@Order+' ';
	  end ELSE IF @Tabs='failed'
	  begin 
	  set @SQLStatement = N' 
select * from tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID where
 orderNo in (SELECT orderNo FROM tblReviewedFailedOrders) 
 '+@Order+' ';
	  end ELSE IF @Tabs='printed'
	  begin 
	  set @SQLStatement = N' 
SELECT 
 tblOrders.orderID,
 tblOrders.orderDate, 
 tblOrders.orderNo, 
 tblOrders.orderTotal, 
 tblOrders.paymentAmountRequired, 
 tblOrders.paymentMethod, 
 tblOrders.orderStatus, 
 tblOrders.statusDate, 
 tblOrders.shippingMethod, 
 tblOrders.orderType, 
 tblOrders.shippingDesc, 
 tblOrders.orderBatchedDate, 
 tblOrders.storeID, 
 tblOrders.lastStatusUpdate,
 tblCustomers.email,
 tblOrders.displayPaymentStatus,
 tblCustomers.firstName, 
 tblOrders.customerID,
  tblCustomers.phone,
 tblCustomers.surname FROM 
 tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE 
 NOT tblOrders.orderBatchedDate IS NULL AND tblOrders.orderBatchedDate <> ''''
 '+@SqlWhere+' '+@Order+' ';
	  end
	   EXEC( @SQLStatement);
	 --  EXEC( @SQLStatementCount);
	  
	   END