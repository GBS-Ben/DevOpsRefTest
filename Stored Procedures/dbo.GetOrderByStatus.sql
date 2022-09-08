-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 04/27/2021		CKB, Markful
-- =============================================

CREATE PROCEDURE [dbo].[GetOrderByStatus]
	@Status nvarchar(50)='',
	@Field nvarchar(50)='',
	@Param nvarchar(50)='',
	@From datetime,
	@To datetime,
	@PageSize int = 100,
	@StartIndex int =0,
	@CountRow INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT @CountRow = Count([orderID])
				  FROM [dbo].[tblOrderView] 
				  where 
				 
				(	 
				    (@Field ='all')
				    or   (@Field ='orderNo' AND [orderNo] like @Param )
				    or   (@Field ='customerID' AND [customerID] like @Param ) 
				    or   (@Field ='searchName' AND [firstName] like '%'+@Param+'%')
				 	or   (@Field ='searchCompany' AND [searchCompany] like '%'+@Param+'%')
					or   (@Field ='searchState' AND [searchState] like '%'+@Param+'%')
					or   (@Field ='orderStatus' AND [orderStatus] like @Param )
				)
					and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)					
				 and
				 (	 
				    (@Status ='all')
				    or   (@Status ='inhouse' AND [orderStatus]='In House' )
				    or   (@Status ='onproof' AND [orderStatus]='On Proof' ) 
				    or   (@Status ='goodtogo' AND ([orderStatus]='Good To Go' or [orderStatus]='GTG-Waiting for Payment' ))
				 	or   (@Status ='inproduction' AND [orderStatus]='In Production' ) 
					or   (@Status ='onhomedock' AND [orderStatus]='On HOM Dock' ) 
					or   (@Status ='onhomedock' AND [orderStatus]='On MRK Dock' ) 
					or   (@Status ='intransit' AND [orderStatus] NOT LIKE '%Transit%' )
					or   (@Status ='delivered' AND [orderStatus]='Delivered' )
				    or   (@Status ='inart' AND ([orderStatus]='In Art' or [orderStatus]='Waiting for New Art' or [orderStatus]='Waiting On Customer' or [orderStatus]='In Art for Changes')) 
				  )
				  and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'ADHMIG' and [orderStatus] != 'MIGZ'

	
  SELECT 
  --TOP (@PageSize) T1.*
   -- FROM
   	--	(SELECT  TOP (@PageSize + @StartIndex)
					[orderID] AS 'Id'
					  ,[orderNo] AS 'Order'
	 				  ,[orderStatus] AS 'Status'
					  ,[lastStatusUpdate] AS 'LastUpdated'
					  ,[orderType] AS 'Type'
					  ,[orderDate] AS 'OrderDate'
					  ,[orderTotal] AS 'Total'
					  ,[company] AS 'Company'
					  ,[firstName]+' '+[surname] AS 'Customer'
					  ,[storeID] AS 'Store'
					  ,[shippingDesc] AS 'ShipMethod'
					  ,[state] AS 'State'
					  ,[customerID] AS 'CustomerId'
					  ,[brokerOwnerIDUsed] AS 'BrokerUser'
					  ,[coordIDUsed] AS 'CoordUser'
					  ,[specialOffer] AS 'SpecialOffer'
				  FROM [dbo].[tblOrderView] 
				  where 
				  
				  (	 
				    (@Field ='all')
				    or   (@Field ='orderNo' AND [orderNo] like @Param )
				    or   (@Field ='customerID' AND [customerID] like @Param ) 
				    or   (@Field ='searchName' AND [firstName] like '%'+@Param+'%')
				 	or   (@Field ='searchCompany' AND [searchCompany] like '%'+@Param+'%')
					or   (@Field ='searchState' AND [searchState] like '%'+@Param+'%')
					or   (@Field ='orderStatus' AND [orderStatus] like @Param )
				)
					and					
					(
					[orderDate]>=@From and [orderDate]<=@To
					)					
				 and
				 (
				   (@Status ='all')or (@Status ='inhouse' AND [orderStatus]='In House' )
				    or  (@Status ='onproof' AND [orderStatus]='On Proof' ) 
				    or   (@Status ='goodtogo' AND ([orderStatus]='Good To Go' or [orderStatus]='GTG-Waiting for Payment' ))
				 	or   (@Status ='inproduction' AND [orderStatus]='In Production' ) 
					or   (@Status ='onhomedock' AND [orderStatus]='On HOM Dock' ) 
					or   (@Status ='onhomedock' AND [orderStatus]='On MRK Dock' ) 
					or   (@Status ='intransit' AND [orderStatus] NOT LIKE '%Transit%' )
					or   (@Status ='delivered' AND [orderStatus]='Delivered' )
				    or   (@Status ='inart' AND ([orderStatus]='In Art' or [orderStatus]='Waiting for New Art' or [orderStatus]='Waiting On Customer' or [orderStatus]='In Art for Changes')) )
				    and [archived] = 0 and [orderStatus] != 'ACTMIG' and [orderStatus] != 'ADHMIG' and [orderStatus] != 'MIGZ'
			--	Order by [orderID] DESC
			--	) AS T1
--Order by T1.[Id] 
END