-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 04/27/2021		CKB, Markful
-- =============================================
CREATE PROCEDURE [dbo].[GetOrderStockCount]
@Tabs nvarchar(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE #statuscount          
     (          
        [STATUS] VARCHAR(20),          
        [COUNT] int        
     ) 
     if @Tabs='stock'
     begin
  
	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'all',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders] LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID where tblOrders.orderStatus<>'Delivered' AND tblOrders.orderStatus not like '%Transit%' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = 'Valid' AND tblOrders.orderType='Stock' AND tblCustomers.firstName <> ''AND tblOrders.orderAck=0) 
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inhouse',
	  (SELECT  Count([orderID])FROM [dbo].[tblOrders] LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID where tblOrders.orderStatus<>'Delivered' AND tblOrders.orderStatus not like '%Transit%' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = 'Valid' AND tblOrders.orderType='Stock' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'In House') 
	  )
	
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'onhomedock',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders] LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID where tblOrders.orderStatus<>'Delivered' AND tblOrders.orderStatus not like '%Transit%' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = 'Valid' AND tblOrders.orderType='Stock' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus IN ('On HOM Dock','On MRK Dock')) 
	  )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'intransit',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders] LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID where tblOrders.orderStatus<>'Delivered' AND tblOrders.orderStatus not like '%Transit%' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = 'Valid' AND tblOrders.orderType='Stock' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus LIKE '%Transit%') 
	  )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'delivered',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders] LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID where tblOrders.orderStatus<>'Delivered' AND tblOrders.orderStatus not like '%Transit%' AND tblOrders.archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 AND tblOrders.tabStatus = 'Valid' AND tblOrders.orderType='Stock'AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'Delivered') 
	  )
	 	
	SELECT * FROM #statuscount 
	   end	
	   else if @Tabs='custom'
	   begin
	   	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'all',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> ''AND tblOrders.orderAck=0) 
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inhouse',
	  (SELECT  Count([orderID])FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'In House') 
	  )	
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'onhomedock',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'On HOM Dock') 
	  )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'intransit',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus LIKE '%Transit%') 
	  )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'delivered',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'Delivered') 
	  )
	 	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'onproof',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'On Proof') 
	  )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'goodtogo',
	 (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND( tblOrders.orderStatus = 'Good To Go')) 
	  )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inproduction',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'In Production') 
	  )
		  INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inart',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrders]LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE
	   tblOrders.archived=0 AND (tblOrders.tabStatus <> 'Failed' AND tblOrders.tabStatus <> 'Exception') 
	   AND tblOrders.orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
	   AND tblCustomers.firstName <> '' AND tblOrders.orderAck=1 AND tblOrders.orderStatus = 'In Art') 
	  )
	SELECT * FROM #statuscount 
	   end	else if @Tabs = 'pending'
	   	   begin
	     	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'all',
	  (SELECT  Count(tblOrders.orderID)  FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID WHERE 
	  tblOrders.archived=0  AND tblOrders.paymentSuccessful= 0 AND (tblOrders.tabStatus = 'offline' OR tblOrders.tabStatus = 'faxed' OR
	   tblOrders.tabStatus = 'checkcash') AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND 
	   tblCustomers.firstName <> '')
	   )
	SELECT * FROM #statuscount 
	
	   end	
	   else if @Tabs = 'exception'
	   	   begin
	     	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'all',
	  (SELECT  Count([orderID]) FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
  WHERE tblOrders.archived=0 AND tblCustomers.firstName <> '' AND tblOrders.tabStatus = 'Exception'  ))
  INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'failed',
	  (SELECT  Count([orderID]) FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
  WHERE tblOrders.archived=0 AND tblCustomers.firstName <> '' AND tblOrders.tabStatus = 'Failed' AND tblOrders.orderStatus = 'Failed'  ))
  INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'cancelled',
	  (SELECT  Count([orderID]) FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
  WHERE tblOrders.archived=0 AND tblCustomers.firstName <> '' AND tblOrders.tabStatus = 'Failed' AND tblOrders.orderStatus = 'Cancelled'  ))
	SELECT * FROM #statuscount 
	 end else if @Tabs = 'web'
	   	   begin
	     	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'all',
	  (SELECT  Count([PKID]) FROM [tblAMZ_orderValid]))
 
  INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'ready',
	  (SELECT  Count([PKID]) FROM [tblAMZ_orderValid]
  WHERE tblAMZ_orderValid.orderStatus = 'Ready to Print'  ))
  INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'printed',
	  (SELECT  Count([PKID]) FROM [tblAMZ_orderValid]
  WHERE tblAMZ_orderValid.orderStatus = 'Printed'  ))
	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'shipped',
	  (SELECT  Count([PKID]) FROM [tblAMZ_orderValid]
  WHERE tblAMZ_orderValid.orderStatus = 'Shipped'  ))
	
	SELECT * FROM #statuscount 
	 end
	DROP TABLE #statuscount 
  
END