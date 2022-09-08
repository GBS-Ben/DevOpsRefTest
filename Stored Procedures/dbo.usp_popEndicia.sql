CREATE PROCEDURE  [dbo].[usp_popEndicia]
AS
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++
--First, update tblEndiciaPostBack data to correctly present records that come in with the "attention" field shifted to the right.
UPDATE tblEndiciaPostBack
SET attention=address1,
address1=address2,
address2=''
--select * from tblEndiciaPostBack
WHERE attention='' and address1<>'' and address2<>''

--Make sure everything is clean (redundant):
update tblEndiciaPostBack
set address2='' where address1=address2

--Start tblJobTrack pop.
--step 1
INSERT INTO tblJobTrack (trackingnumber,jobnumber,[pickup date],
[Delivery Street Name],[Delivery City],
[Delivery State/Province],[Delivery Postal Code],
[subscription file name], 
trackSource,
mailClass, postageAmount, transactionDate, transactionID, weight)
SELECT trackingNo, replace(orderNo,'ON',''), postMarkDate,
address1, city,
[state], zip,
'051225_123456789', --Place Holder Data
'USPS Endicia',
mailClass, convert(money,postageAmount), transactionDate, transactionID, floor([weight])--round((weight/16),0)
FROM tblEndiciaPostBack
WHERE jobTrack_migStamp is NULL

--step 2
UPDATE tblEndiciaPostBack
SET jobTrack_migStamp=getDate()
--select * from tblEndiciaPostBack
WHERE transactionID in
(select distinct transactionID from tblJobTrack where transactionID is NOT NULL and transactionID<>'')
and jobTrack_migStamp is NULL 
OR 
transactionID in
(select distinct transactionID from tblJobTrack where transactionID is NOT NULL and transactionID<>'')
and jobTrack_migStamp=''

UPDATE tblJobTrack
set weight=1 where weight=0

--update USPS ON HOM Dock status where applicable
UPDATE tblOrders
set orderStatus='ON MRK Dock'
--select orderNo from tblOrders
where orderStatus not like '%Transit%'
and orderStatus<>'Delivered'
and orderStatus NOT IN ('ON HOM Dock','ON MRK Dock')
and orderNo in
(select replace(orderNo,'ON','') from tblEndiciaPostBack
where 
--datediff(hh,jobTrack_migStamp, getDate())<1 and
orderNo is NOT NULL)

--update USPS In Transit status where applicable
update tblOrders
set orderStatus='In Transit USPS'
--select * from tblOrders
where orderStatus IN ('ON HOM Dock','ON MRK Dock')
and orderNo in
    (select distinct orderNo 
    from tblEndiciaPostBack
    where orderNo is NOT NULL
    and datediff(hh,jobTrack_migStamp,getDate())>=4
    and datepart(hh,getDate())>=20
    and datepart(hh,getDate())<=24)

--update "In Transit - USPS Stamped"
update tblOrders
set orderStatus='In Transit USPS (Stamped)'
where orderStatus IN ('ON HOM Dock','ON MRK Dock')
and orderNo in
    (select distinct jobNo 
    from tbl_barCode 
    where trackingNo like '%USPS%' 
    and trackingNo is NOT NULL
    and jobNo is NOT NULL)

--write notes.
-- 5day delivered offset
--how does this code coincide with usp_updateUSPS which runs nightly at 1AM?
--think it over.  In the meantime, they've both been updated as of 12/13/11 JF.
--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++