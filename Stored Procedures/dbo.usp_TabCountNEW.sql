CREATE PROCEDURE [dbo].[usp_TabCountNEW]
AS
--04/27/21		CKB, Markful

--SELECT * FROM tblTabCountNew

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// ALL
--// PART ONE

UPDATE tblTabCountNew SET ordersAllInHouse=(select count(orderID) from tblOrders where archived=0 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In House')

UPDATE tblTabCountNew SET ordersAllInArt=(select count(orderID) from tblOrders 
where archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art' 
      or archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting for New Art' 
      or archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting On Customer' 
      or archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art for Changes')

UPDATE tblTabCountNew SET ordersAllInPro=(select count(orderID) from tblOrders where archived=0 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Production')

UPDATE tblTabCountNew SET ordersAllGTG=(select count(orderID) from tblOrders 
where archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Good To Go' 
      or archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='GTG-Waiting for Payment')

UPDATE tblTabCountNew SET ordersAllWFP=(select count(orderID) from tblOrders where archived=0 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting For Payment')

UPDATE tblTabCountNew SET ordersAllOnDock=(select count(orderID) from tblOrders where archived=0 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus IN ('On HOM Dock','On MRK Dock'))


UPDATE tblTabCountNew SET ordersAllOnProof=(select count(orderID) from tblOrders where archived=0 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On Proof')

UPDATE tblTabCountNew SET ordersAllInTrans=(select count(orderID) from tblOrders 
where archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit'
	  or archived=0 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS')
	  
--// PART TWO	 
	 
UPDATE tblTabCountNew SET newordersStock=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 
AND tabStatus = 'Valid' AND orderType='Stock' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET newordersCustom=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 AND tabStatus <> 'Failed' AND tabStatus <> 'Exception' 
AND orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET newordersWaiting=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 AND tblOrders.paymentSuccessful=0 AND (tabStatus = 'Offline' OR tabStatus = 'Faxed' OR tabStatus = 'CheckCash') 
AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET newordersExcept=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 AND tblOrders.tabStatus = 'Exception' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET newordersFailed=(SELECT Count(tblOrders.customerID) 
FROM tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID 
where orderNo in (SELECT orderNo FROM tblReviewedFailedOrders where orderNo is NOT NULL) 
and orderStatus = 'Failed')

UPDATE tblTabCountNew set ordersAllValid=(
SELECT COUNT(orderID) AS numRecords
FROM tblOrders a JOIN tblCustomers c
ON a.customerID=c.customerID
JOIN tblCustomers_ShippingAddress s
ON a.orderNo=s.orderNo
WHERE orderStatus <> 'ACTMIG' 
AND orderStatus <> 'MIGZ' 
AND orderStatus <> 'ADHMIG' 
AND archived=0
)


--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// HOM
--// PART ONE

UPDATE tblTabCountNew SET ordersHOMInHouse=(select count(orderID) from tblOrders where archived=0 and storeID=2 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In House')

UPDATE tblTabCountNew SET ordersHOMInArt=(select count(orderID) from tblOrders 
where archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art' 
      or archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting for New Art' 
      or archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting On Customer' 
      or archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art for Changes')

UPDATE tblTabCountNew SET ordersHOMInPro=(select count(orderID) from tblOrders where archived=0 and storeID=2 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Production')

UPDATE tblTabCountNew SET ordersHOMGTG=(select count(orderID) from tblOrders 
where archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Good To Go' 
      or archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='GTG-Waiting for Payment')

UPDATE tblTabCountNew SET ordersHOMWFP=(select count(orderID) from tblOrders where archived=0 and storeID=2 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting For Payment')

UPDATE tblTabCountNew SET ordersHOMOnDock=(select count(orderID) from tblOrders where archived=0 and storeID=2 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus IN ('On HOM Dock','On MRK Dock'))


UPDATE tblTabCountNew SET ordersHOMOnProof=(select count(orderID) from tblOrders where archived=0 and storeID=2 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On Proof')

UPDATE tblTabCountNew SET ordersHOMInTrans=(select count(orderID) from tblOrders 
where archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit'
	  or archived=0 and storeID=2 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS')
	  
--// PART TWO	 
	 
UPDATE tblTabCountNew SET HOMnewordersStock=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=2 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 
AND tabStatus = 'Valid' AND orderType='Stock' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET HOMnewordersCustom=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=2 AND tabStatus <> 'Failed' AND tabStatus <> 'Exception' 
AND orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET HOMnewordersWaiting=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=2 AND tblOrders.paymentSuccessful=0 AND (tabStatus = 'Offline' OR tabStatus = 'Faxed' OR tabStatus = 'CheckCash') 
AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET HOMnewordersExcept=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=2 AND tblOrders.tabStatus = 'Exception' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET HOMnewordersFailed=(SELECT Count(tblOrders.customerID) 
FROM tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID 
where orderNo in (SELECT orderNo FROM tblReviewedFailedOrders where orderNo is NOT NULL) 
and orderStatus = 'Failed' and storeID=2)

UPDATE tblTabCountNew set ordersHOMValid=(
SELECT COUNT(orderID) AS numRecords
FROM tblOrders a JOIN tblCustomers c
ON a.customerID=c.customerID
JOIN tblCustomers_ShippingAddress s
ON a.orderNo=s.orderNo
WHERE orderStatus <> 'ACTMIG' 
AND orderStatus <> 'MIGZ' 
AND orderStatus <> 'ADHMIG'
AND archived=0 and storeID=2
)




--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// ADH
--//PART ONE

UPDATE tblTabCountNew SET ordersADHInHouse=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In House')

UPDATE tblTabCountNew SET ordersADHInArt=(select count(orderID) from tblOrders 
where archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting for New Art' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting On Customer' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art for Changes')

UPDATE tblTabCountNew SET ordersADHInPro=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Production')

UPDATE tblTabCountNew SET ordersADHGTG=(select count(orderID) from tblOrders 
where archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Good To Go' 
      or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='GTG-Waiting for Payment')

UPDATE tblTabCountNew SET ordersADHWFP=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting For Payment')

UPDATE tblTabCountNew SET ordersADHOnDock=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On ADH Dock')


UPDATE tblTabCountNew SET ordersADHOnProof=(select count(orderID) from tblOrders where archived=0 and storeID=3 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On Proof')

UPDATE tblTabCountNew SET ordersADHInTrans=(select count(orderID) from tblOrders 
where archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit'
	  or archived=0 and storeID=3 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS')
	  
--// PART TWO	 
	 
UPDATE tblTabCountNew SET ADHnewordersStock=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=3 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 
AND tabStatus = 'Valid' AND orderType='Stock' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET ADHnewordersCustom=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=3 AND tabStatus <> 'Failed' AND tabStatus <> 'Exception' 
AND orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET ADHnewordersWaiting=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=3 AND tblOrders.paymentSuccessful=0 AND (tabStatus = 'Offline' OR tabStatus = 'Faxed' OR tabStatus = 'CheckCash') 
AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET ADHnewordersExcept=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=3 AND tblOrders.tabStatus = 'Exception' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET ADHnewordersFailed=(SELECT Count(tblOrders.customerID) 
FROM tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID 
where orderNo in (SELECT orderNo FROM tblReviewedFailedOrders where orderNo is NOT NULL) 
and orderStatus = 'Failed' and storeID=3)

UPDATE tblTabCountNew set ordersADHValid=(
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



--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// NCC
--//PART ONE

UPDATE tblTabCountNew SET ordersNCCInHouse=(select count(orderID) from tblOrders where archived=0 and storeID=4 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In House')

UPDATE tblTabCountNew SET ordersNCCInArt=(select count(orderID) from tblOrders 
where archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art' 
      or archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting for New Art' 
      or archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting On Customer' 
      or archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art for Changes')

UPDATE tblTabCountNew SET ordersNCCInPro=(select count(orderID) from tblOrders where archived=0 and storeID=4 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Production')

UPDATE tblTabCountNew SET ordersNCCGTG=(select count(orderID) from tblOrders 
where archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Good To Go' 
      or archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='GTG-Waiting for Payment')

UPDATE tblTabCountNew SET ordersNCCWFP=(select count(orderID) from tblOrders where archived=0 and storeID=4 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting For Payment')

UPDATE tblTabCountNew SET ordersNCCOnDock=(select count(orderID) from tblOrders where archived=0 and storeID=4 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On NCC Dock')


UPDATE tblTabCountNew SET ordersNCCOnProof=(select count(orderID) from tblOrders where archived=0 and storeID=4 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On Proof')

UPDATE tblTabCountNew SET ordersNCCInTrans=(select count(orderID) from tblOrders 
where archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit'
	  or archived=0 and storeID=4 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS')
	  
--// PART TWO	 
	 
UPDATE tblTabCountNew SET NCCnewordersStock=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=4 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 
AND tabStatus = 'Valid' AND orderType='Stock' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET NCCnewordersCustom=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=4 AND tabStatus <> 'Failed' AND tabStatus <> 'Exception' 
AND orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET NCCnewordersWaiting=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=4 AND tblOrders.paymentSuccessful=0 AND (tabStatus = 'Offline' OR tabStatus = 'Faxed' OR tabStatus = 'CheckCash') 
AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET NCCnewordersExcept=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=4 AND tblOrders.tabStatus = 'Exception' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET NCCnewordersFailed=(SELECT Count(tblOrders.customerID) 
FROM tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID 
where orderNo in (SELECT orderNo FROM tblReviewedFailedOrders where orderNo is NOT NULL) 
and orderStatus = 'Failed' and storeID=4)

UPDATE tblTabCountNew set ordersNCCValid=(
SELECT COUNT(orderID) AS numRecords
FROM tblOrders a JOIN tblCustomers c
ON a.customerID=c.customerID
JOIN tblCustomers_ShippingAddress s
ON a.orderNo=s.orderNo
WHERE orderStatus <> 'ACTMIG' 
AND orderStatus <> 'MIGZ' 
AND orderStatus <> 'ADHMIG'
AND archived=0 and storeID=4
)


--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// CMC
--//PART ONE

UPDATE tblTabCountNew SET ordersCMCInHouse=(select count(orderID) from tblOrders where archived=0 and storeID=5 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In House')

UPDATE tblTabCountNew SET ordersCMCInArt=(select count(orderID) from tblOrders 
where archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art' 
      or archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting for New Art' 
      or archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting On Customer' 
      or archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Art for Changes')

UPDATE tblTabCountNew SET ordersCMCInPro=(select count(orderID) from tblOrders where archived=0 and storeID=5 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Production')

UPDATE tblTabCountNew SET ordersCMCGTG=(select count(orderID) from tblOrders 
where archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Good To Go' 
      or archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='GTG-Waiting for Payment')

UPDATE tblTabCountNew SET ordersCMCWFP=(select count(orderID) from tblOrders where archived=0 and storeID=5 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='Waiting For Payment')

UPDATE tblTabCountNew SET ordersCMCOnDock=(select count(orderID) from tblOrders where archived=0 and storeID=5 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On CMC Dock')


UPDATE tblTabCountNew SET ordersCMCOnProof=(select count(orderID) from tblOrders where archived=0 and storeID=5 
and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='On Proof')

UPDATE tblTabCountNew SET ordersCMCInTrans=(select count(orderID) from tblOrders 
where archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit'
	  or archived=0 and storeID=5 and orderID is NOT NULL and tabStatus<>'Failed' and orderStatus='In Transit USPS')
	  
--// PART TWO	 
	 
UPDATE tblTabCountNew SET CMCnewordersStock=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=5 AND tblOrders.paymentProcessed=1 AND tblOrders.paymentSuccessful=1 
AND tabStatus = 'Valid' AND orderType='Stock' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET CMCnewordersCustom=(SELECT Count(paymentProcessed)
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE orderAck=0 AND archived=0 and storeID=5 AND tabStatus <> 'Failed' AND tabStatus <> 'Exception' 
AND orderType='Custom' AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' 
AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET CMCnewordersWaiting=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=5 AND tblOrders.paymentSuccessful=0 AND (tabStatus = 'Offline' OR tabStatus = 'Faxed' OR tabStatus = 'CheckCash') 
AND tblOrders.orderStatus <> 'Failed' AND tblOrders.orderStatus <> 'Cancelled' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET CMCnewordersExcept=(SELECT Count(paymentProcessed) 
FROM tblOrders LEFT JOIN tblCustomers ON tblOrders.customerID = tblCustomers.customerID 
WHERE archived=0 and storeID=5 AND tblOrders.tabStatus = 'Exception' AND tblCustomers.firstName <> '')

UPDATE tblTabCountNew SET CMCnewordersFailed=(SELECT Count(tblOrders.customerID) 
FROM tblOrders left join tblCustomers on tblCustomers.customerID = tblOrders.customerID 
where orderNo in (SELECT orderNo FROM tblReviewedFailedOrders where orderNo is NOT NULL) 
and orderStatus = 'Failed' and storeID=5)

UPDATE tblTabCountNew set ordersCMCValid=(
SELECT COUNT(orderID) AS numRecords
FROM tblOrders a JOIN tblCustomers c
ON a.customerID=c.customerID
JOIN tblCustomers_ShippingAddress s
ON a.orderNo=s.orderNo
WHERE orderStatus <> 'ACTMIG' 
AND orderStatus <> 'MIGZ'
AND orderStatus <> 'ADHMIG' 
AND archived=0 and storeID=5
)