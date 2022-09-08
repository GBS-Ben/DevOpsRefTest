CREATE PROC [dbo].[usp_checkMigrateOrder] @orderNo VARCHAR(MAX)
as

--select *

--from gbsStage.dbo.tblNOP_Order_RIP tor left join gbsCore.dbo.tblOrders o on
--tor.gbsOrderID = o.orderNo where o.orderNo is null


--select gbsOrderID from gbsstage.dbo.tblNOP_Order_RIP where [RowVersion] in
--(
--select [RowVersion] from gbsStage.dbo.MigrationLog where GBSOrdersProcessed1
--<> 1
--)

select 'gbsStageMigrationLogQueue' as Title,o.gbsOrderID,ml.*
from gbsStage.dbo.MigrationLog ml with(nolock)
inner join gbsStage.dbo.tblNOP_Order_RIP o with(nolock)
	on ml.[RowVersion] = o.[RowVersion]
--update gbsStage.dbo.MigrationLog set GBSOrdersProcessed1 = 0,
--GBSOrdersProcessedStartDate = null, GBSOrdersProcessedEndDate = null
where ml.GBSOrdersProcessed1 <> 1
--or ml.[RowVersion] = '2019-10-10 16:16:40.000'


--Get Bad Order
select 'gbsStageMigrationLogOrderCheck' as Title,*
from gbsStage.dbo.MigrationLog with(nolock)
--update gbsStage.dbo.MigrationLog set GBSOrdersProcessed1 = 0,
--gbsordersprocessedstartdate = null, GBSOrdersProcessedEndDate = null
where [RowVersion] in
(
select [Rowversion]
from gbsStage.dbo.tblNOP_Order_RIP o
--where o.migID = 5555414836
where o.gbsOrderID =  @orderNo)
--where o.gbsOrderID in7
--(
--HOM970399 HOM970404 HOM977524 HOM977675
--)
--usp_orderView) where [RowVersion] in
--(
--'2020-02-11 11:57:42.000'
--)