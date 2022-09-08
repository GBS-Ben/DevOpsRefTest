create proc usp_ReMigrateOrder
@orderNo varchar(50)
as
begin

update gbsStage.dbo.MigrationLog set GBSOrdersProcessed1 = 0, gbsordersprocessedstartdate = null, GBSOrdersProcessedEndDate = null
where [RowVersion] in
(
select [Rowversion]
from gbsStage.dbo.tblNOP_Order_RIP o
where o.gbsOrderID = @orderNo)

end