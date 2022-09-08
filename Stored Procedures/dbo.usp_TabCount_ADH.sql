CREATE PROCEDURE [dbo].[usp_TabCount_ADH]
AS

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// ADH
--//PART ONE

UPDATE tblTabCount SET ordersADHInHouse=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In House')

UPDATE tblTabCount SET ordersADHInArt=(select count(orderID) from tblOrders 
where archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting for New Art' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting On Customer' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art for Changes')

UPDATE tblTabCount SET ordersADHInPro=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Production')

UPDATE tblTabCount SET ordersADHGTG=(select count(orderID) from tblOrders 
where archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Good To Go' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='GTG-Waiting for Payment')

UPDATE tblTabCount SET ordersADHWFP=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting For Payment')

UPDATE tblTabCount SET ordersADHOnDock=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On ADH Dock')


UPDATE tblTabCount SET ordersADHOnProof=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL 
and tabStatus<>'Failed' 
and orderStatus='On Proof')

UPDATE tblTabCount SET ordersADHInTrans=(select count(orderID) from tblOrders 
where archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit'
	  or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS'
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS (Stamped)')
	  
--// PART TWO (HIGHER TABS)	 
	 
UPDATE tblTabCount SET ADHnewordersStock=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 
AND tabStatus = 'Valid' AND orderType='Stock' AND tblCustomers.firstName <> ''
AND orderStatus <> 'Cancelled'
AND orderStatus <> 'Failed'
AND orderStatus <> 'Delivered'
AND orderStatus NOT LIKE '%transit%'
and storeID=3)


UPDATE tblTabCount SET ADHnewordersCustom=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 
AND tabStatus <> 'Exception' 
AND orderType='Custom' 
AND tblOrders.orderStatus <> 'Failed' 
AND tblOrders.orderStatus <> 'Cancelled' 
AND orderStatus <> 'Delivered'
AND orderStatus NOT LIKE '%transit%'
AND tblCustomers.firstName <> ''
AND storeID=3)

UPDATE tblTabCount SET ADHnewordersWaiting=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=3 AND tblOrders.paymentSuccessful=0 AND (tabStatus = 'Offline' OR tabStatus = 'Faxed' OR tabStatus = 'CheckCash') 
AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
AND tblCustomers.firstName <> '')

UPDATE tblTabCount SET ADHnewordersExcept=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=3 AND tblOrders.tabStatus = 'Exception' AND tblCustomers.firstName <> '')

UPDATE tblTabCount SET ADHnewordersFailed=(SELECT Count(tblOrders.customerID) 
FROM tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID 
where orderNo in (SELECT orderNo FROM tblReviewedFailedOrders where orderNo is NOT NULL) 
and orderStatus = 'Failed' and storeID=3)

UPDATE tblTabCount set ordersADHValid=(
SELECT COUNT(orderID) AS numRecords
FROM tblOrders a JOIN tblCustomers c
ON a.customerID=c.customerID
JOIN tblCustomers_ShippingAddress s
ON a.orderNo=s.orderNo
WHERE orderStatus <> 'ACTMIG' 
AND orderStatus <> 'MIGZ' 
AND orderStatus <> 'ADHMIG'
AND archived=0 and storeID=3
)