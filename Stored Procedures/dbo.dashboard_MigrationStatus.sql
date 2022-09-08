create proc [dbo].[dashboard_MigrationStatus] as

with cteMig as (
SELECT  tno.nopid,tno.gbsorderid,datediff(s,o.createdonpst,t.ProcessEndDateTime) as 'seconds since order created',datediff(s,max(tnoi.updatedon),t.ProcessEndDateTime) as 'seconds since order updated',o.createdonpst,t.ProcessEndDateTime,max(tnoi.updatedon) as 'updatedate'
,ROW_NUMBER() over (partition by t.noporderid order by processenddatetime) as syncnumber
  --into #temp
  FROM  nopcommerce_tblnoporder tno
   inner join nopCommerce_order o on tno.nopid = o.id
   inner join nopCommerce_orderitem oi on o.id = oi.orderid
   inner join nopCommerce_tblnoporderitem tnoi on oi.id = tnoi.noporderitemid
   left join gbsStage_tblNOPOrderMigrationLog t with (readuncommitted) on t.noporderid = o.id 
where  o.createdonpst >= dateadd(day,-2,getdate()) 
group by tno.nopid,tno.gbsorderid,o.createdonpst,t.processenddatetime,t.noporderid

)
select syncnumber,nopid,gbsorderid,case when syncnumber = 1 then [seconds since order created] else [seconds since order updated] end as 'elasped time(s)',createdonpst as NOPOrderCreation,updatedate as ResubDateTime,ProcessEndDateTime as MigrationFinish
 from cteMig a
where syncnumber = 1 or syncnumber = (select max(syncnumber) from cteMig b where b.gbsOrderId = a.gbsorderid)
order by nopid desc