CREATE   PROC [dbo].[usp_updateCRM_Z_DailyCAT]
as
--04/27/21		CKB, Markful

--RUN UPDATES
update tblCRM
set CAT_Football='Yes' where CAT_Football is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%Football%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_Baseball='Yes' where CAT_Baseball is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%baseball%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_Calendars='Yes' where CAT_Calendars is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%calendar%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_Pad='Yes' where CAT_Pad is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%pad%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_Stock='Yes' where CAT_Stock is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productID in (select distinct ProductID from tblProducts where productType='Stock' and productType is not null))
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_Envelopes='Yes' where CAT_Envelopes is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_DoorknobBags='Yes' where CAT_DoorknobBags is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%doork%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CAT_AdhesiveMags='Yes' where CAT_AdhesiveMags is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%adhesive%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set STYLE_Custom='Yes' where STYLE_Custom is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productID in (select distinct ProductID from tblProducts where productType='Custom' and productType is not null))
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set STYLE_QuickCard='Yes' where STYLE_QuickCard is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%quickcard%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set STYLE_QuickStix='Yes' where STYLE_QuickStix is null and orderID in (select distinct orderID from tblOrders_Products where deleteX<>'Yes' and productName like '%stix%' and productName not like '%envelope%')
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)

update tblCRM
set CRM_InfoBlockAvailable='Yes' where orderNo in (select distinct orderNo from tblInfoBlockMaster where orderNo is not null)
and CRM_InfoBlockAvailable is null
and orderID in (select orderID from tblOrders where (orderNo like 'HOM%' OR orderNo like 'MRK%') and orderID is not NULL and datediff(dd,orderDate,getdate())<=1)