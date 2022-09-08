-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 04/27/2021		CKB, Markful
-- =============================================
CREATE PROCEDURE [dbo].[GetOrderStatusCount]
@From datetime,
	@To datetime
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #statuscount          
     (          
        [STATUS] VARCHAR(20),          
        [COUNT] int        
     ) 
	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'all',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where [archived] = 0 and	
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	) 
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inhouse',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where [orderStatus]='In House' and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	  and [archived] = 0) 
	 )
	INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'onproof',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  [orderStatus]='On Proof'and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	  and [archived] = 0  and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'goodtogo',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  ([orderStatus]='Good To Go' or [orderStatus]='GTG-Waiting for Payment' )and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	  and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inproduction',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  [orderStatus]='In Production' and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	 and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'onhomedock',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  [orderStatus] IN ('On HOM Dock','On MRK Dock') and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	  and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 )
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'intransit',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  [orderStatus] LIKE '%Transit%'and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	  and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ'and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 ) 
	 INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'delivered',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  [orderStatus]='Delivered' and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	 and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 )
	  INSERT into #statuscount ([STATUS],[COUNT]) values 
	 (
	 'inart',
	  (SELECT  Count([orderID]) FROM [dbo].[tblOrderView]where  ([orderStatus]='In Art' or [orderStatus]='Waiting for New Art' or [orderStatus]='Waiting On Customer' or [orderStatus]='In Art for Changes') and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)	 and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'MIGZ')
	 )
	SELECT * FROM #statuscount 
				 
	DROP TABLE #statuscount 
  
END