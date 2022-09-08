CREATE PROCEDURE [dbo].[ProcessUPSTracking]
 AS
 SET NOCOUNT ON;

 DECLARE @newID nvarchar(100)
 SET @newID = newID()
 UPDATE gbsAcquire.dbo.UPSTracking 
 SET  ProcessExecutionId = @newID
 WHERE ProcessExecutionId IS NULL

 
--Process Scheduled Delivery
 UPDATE j
 SET [scheduled delivery date] = TRY_CONVERT(date, DeliveryDateDate)
--SELECT   u.TrackingNumber, * 
FROM gbsAcquire.dbo.UPSTracking u
INNER JOIN tbljobtrack j ON j.trackingnumber = u.TrackingNumber
CROSS APPLY OPENJSON(TrackingRequest, N'lax $.trackResponse.shipment')
WITH (
	DeliveryDateType  varchar(max) 'lax $.package[0].deliveryDate[0].type',
	DeliveryDateDate  varchar(max) 'lax $.package[0].deliveryDate[0].date',
	DeliveryTime  varchar(max) 'lax $.package[0].deliveryTime.endTime',
	DeliveryTimeType  varchar(max) 'lax $.package[0].deliveryTime.type',
	StatusType  varchar(max) 'lax $.package[0].activity[0].status.type',
	StatusDescription  varchar(max) 'lax $.package[0].activity[0].status.description',
	StatusCode  varchar(max) 'lax $.package[0].activity[0].status.code',
	ActivityDate  varchar(max) 'lax $.package[0].activity[0].date',
	ActivityTime  varchar(max) 'lax $.package[0].activity[0].time',
	--StatusCode  varchar(max) 'lax $.package[0].activity[0].status.code',
	arrayelement nvarchar(max) N'$' AS JSON
	) as ResponseJson
WHERE ResponseJson.DeliveryDateType IN ( 'SDD', 'RDD')
	AND ProcessExecutionId = @newID 


--Process Delivery
 UPDATE j
 SET DeliveredOn = TRY_CONVERT(date, DeliveryDateDate)
--SELECT   u.TrackingNumber, * 
FROM gbsAcquire.dbo.UPSTracking u  
INNER JOIN tbljobtrack j ON j.trackingnumber = u.TrackingNumber
CROSS APPLY OPENJSON(TrackingRequest, N'lax $.trackResponse.shipment')
WITH (
		DeliveryDateType  varchar(max) 'lax $.package[0].deliveryDate[0].type',
		DeliveryDateDate  varchar(max) 'lax $.package[0].deliveryDate[0].date',
		DeliveryTime  varchar(max) 'lax $.package[0].deliveryTime.endTime',
		DeliveryTimeType  varchar(max) 'lax $.package[0].deliveryTime.type',
		StatusType  varchar(max) 'lax $.package[0].activity[0].status.type',
		StatusDescription  varchar(max) 'lax $.package[0].activity[0].status.description',
		StatusCode  varchar(max) 'lax $.package[0].activity[0].status.code',
		ActivityDate  varchar(max) 'lax $.package[0].activity[0].date',
		ActivityTime  varchar(max) 'lax $.package[0].activity[0].time',
		--StatusCode  varchar(max) 'lax $.package[0].activity[0].status.code',
		arrayelement nvarchar(max) N'$' AS JSON
	) as ResponseJson
WHERE ResponseJson.DeliveryDateType = 'DEL'
	AND ProcessExecutionId = @newID

--  UPS Notes
INSERT INTO tbl_notes (jobnumber,notes,notedate,author,notesType)
SELECT DISTINCT CONVERT(VARCHAR(255), orderNo), 'Delivered', max(convert(datetime, deliveredOn)), 'SQL', 'order'
FROM [tbljobtrack] j 
INNER JOIN gbsAcquire.dbo.UPSTracking u ON j.trackingnumber = u.TrackingNumber
INNER JOIN [tblOrders] o ON o.[orderNo] = j.[JobNumber]
WHERE o.[orderStatus] NOT IN ('Delivered', 'Cancelled')
	AND NULLIF([deliveredOn],'') IS NOT NULL
	AND ProcessExecutionId = @newID
GROUP BY orderNo

--Mark orders delivered that are delivered
UPDATE o
SET orderStatus = 'Delivered'   
FROM [tbljobtrack] j 
INNER JOIN gbsAcquire.dbo.UPSTracking u ON j.trackingnumber = u.TrackingNumber
INNER JOIN [tblOrders] o ON o.[orderNo] = j.[JobNumber]
WHERE o.[orderStatus] NOT IN ('Delivered', 'Cancelled')
	AND NULLIF([deliveredOn],'') IS NOT NULL
	AND ProcessExecutionId = @newID