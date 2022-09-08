CREATE PROC [dbo].[usp_searchNameConstruct]
AS

--//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- The purpose of this SPROC is to create the combined values that can be searched on the Intranet in certain circumstances, such as the ability
-- to search names on Badges, even when those names are not actual customers on the order ticket.
--//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--// Set Variables
DECLARE @NumberRecords INT,
        @RowCount      INT
DECLARE @orderNo	VARCHAR(50),
		@searchName VARCHAR(255),
		@lastRunTime DATETIME
		
--// Grab all badge names and put them in a table with their corresponding orderNo
--IF OBJECT_ID(N'tblSearchName_Primer', N'U') IS NOT NULL
--DROP TABLE tblSearchName_Primer

--CREATE TABLE tblSearchName_Primer
--  (
--     RowID   INT IDENTITY(1, 1),
--     orderNo VARCHAR(50),
--	 searchName VARCHAR(500)
--  )

SET @lastRunTime = (SELECT TOP 1 lastRunTime 
				   FROM tblSearchName_LastRunTime)

INSERT INTO tblSearchName_Primer (orderNo, searchName)
SELECT DISTINCT a.orderNo, x.textValue AS 'searchName'
FROM tblOrders a
JOIN tblOrders_Products op
	ON a.orderID = op.orderID
JOIN tblOrdersProducts_productOptions x
	ON op.[ID] = x.ordersProductsID 
WHERE
x.modified_on >= @lastRunTime
AND x.deleteX <> 'yes'
AND op.deleteX <> 'yes'
AND x.optionCaption LIKE '%Name:%'
AND x.textValue NOT LIKE 'SEE %'
AND x.textValue NOT LIKE '%email%'
AND x.textValue NOT LIKE '%spreadsheet%'
AND x.textValue NOT LIKE '%@%'
AND x.textValue <> ''
AND x.textValue NOT LIKE '%multiple%'
AND x.textValue NOT LIKE '% - Deanna%'
AND x.textValue NOT LIKE '%DO NOT PRINT%'
AND x.textValue NOT LIKE '%send proof%'
AND x.textValue NOT LIKE 'test %'
AND x.textValue <> 'test'
AND x.textValue NOT LIKE 'NOT KW%'

UNION

SELECT  a.orderNo, x.textValue AS 'searchName'
FROM tblOrders a
JOIN tblOrders_Products op
	ON a.orderID = op.orderID
JOIN tblOrdersProducts_productOptions x
	ON op.[ID] = x.ordersProductsID 
WHERE 
x.modified_on >= @lastRunTime
AND x.deleteX <> 'yes'
AND op.deleteX <> 'yes'
AND x.optionCaption = 'Info Line 1:'
AND x.textValue NOT LIKE 'SEE %'
AND x.textValue NOT LIKE '%email%'
AND x.textValue NOT LIKE '%spreadsheet%'
AND x.textValue NOT LIKE '%@%'
AND x.textValue <> ''
AND x.textValue NOT LIKE '%multiple%'
AND x.textValue NOT LIKE '% - Deanna%'
AND x.textValue NOT LIKE '%DO NOT PRINT%'
AND x.textValue NOT LIKE '%send proof%'
AND x.textValue NOT LIKE 'test %'
AND x.textValue <> 'test'
AND x.textValue NOT LIKE 'NOT KW%'
AND x.textValue NOT LIKE '%GROUP%'
AND x.textValue NOT LIKE '%INFO%'
AND x.textValue NOT LIKE '%[0-9]%'
AND x.textValue NOT LIKE '%(%'
AND x.textValue NOT LIKE '%"%'
AND x.textValue NOT LIKE '%Please%'
AND x.textValue NOT IN
	(SELECT DISTINCT searchName_exception
	FROM tblSearchName_Exception
	WHERE searchName_exception IS NOT NULL)

--// Get the number of records in tblSearchName_Primer
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1


----// Create indexes on Primer
--CREATE NONCLUSTERED INDEX [iX_orderNo] ON [dbo].[tblSearchName_Primer]
--(
--	[orderNo] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

--CREATE UNIQUE CLUSTERED INDEX [iX_PKID] ON [dbo].[tblSearchName_Primer]
--(
--	[RowID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


--// Now, create table that will consolidate all badge names into a single field per orderNo
--IF OBJECT_ID(N'tblSearchName_Constructed', N'U') IS NOT NULL
--DROP TABLE tblSearchName_Constructed

--CREATE TABLE tblSearchName_Constructed
--  (
--     RowID   INT IDENTITY(1, 1),
--     orderNo VARCHAR(50),
--	 searchName VARCHAR(4000),
--	 tblOrders_shipping_FirstName VARCHAR(255),
--	 tblOrders_shipping_SurName VARCHAR(255),
--	 tblOrders_billing_FirstName VARCHAR(255),
--	 tblOrders_billing_SurName VARCHAR(255),
--	 tblCustomers_firstName VARCHAR(255),
--	 tblCustomers_surName VARCHAR(255),
--	 tblCustomers_ShippingAddress_Shipping_FirstName VARCHAR(255),
--	 tblCustomers_ShippingAddress_Shipping_SurName VARCHAR(255)
--  )

DELETE FROM tblSearchName_Constructed
WHERE orderNo IN
(SELECT DISTINCT orderNo
FROM tblSearchName_Primer
WHERE orderNo IS NOT NULL)

INSERT INTO tblSearchName_Constructed (orderNo, searchName, tblOrders_shipping_FirstName, tblOrders_shipping_SurName,
tblOrders_billing_FirstName, tblOrders_billing_SurName, tblCustomers_firstName, tblCustomers_surName, 
tblCustomers_ShippingAddress_Shipping_FirstName, tblCustomers_ShippingAddress_Shipping_SurName)
SELECT DISTINCT orderNo, '', '', '', '', '', '', '', '', ''
FROM tblSearchName_Primer
WHERE orderNo IS NOT NULL

----// Create Clustered Index on Constructed
--CREATE UNIQUE CLUSTERED INDEX [iX_uC_orderNo] ON [dbo].[tblSearchName_Constructed]
--(
--	[orderNo] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

--// Loop through all records in the temp table using the WHILE loop construct
WHILE @RowCount <= @NumberRecords
  BEGIN
      SELECT @orderNo = orderNo,
			 @searchName = searchName
      FROM   tblSearchName_Primer
      WHERE  RowID = @RowCount

      UPDATE tblSearchName_Constructed
	  SET searchName = searchName + ' ' + @searchName
	  WHERE orderNo = @orderNo

      SET @RowCount = @RowCount + 1
  END

--// Insert all other orderNo's
INSERT INTO tblSearchName_Constructed (orderNo, searchName)
SELECT DISTINCT orderNo, ''
FROM tblOrders
WHERE LEN(orderNo) = 9
AND orderNo NOT IN
	(SELECT DISTINCT orderNo
	FROM tblSearchName_Constructed
	WHERE orderNo IS NOT NULL)

--// Update other customer name fields where applicable

UPDATE tblSearchName_Constructed
SET tblOrders_shipping_FirstName = b.shipping_FirstName,
tblOrders_shipping_SurName = b.shipping_SurName,
tblOrders_billing_FirstName = b.billing_FirstName,
tblOrders_billing_SurName = b.billing_SurName
FROM tblSearchName_Constructed a 
JOIN tblOrders b
	ON a.orderNo = b.orderNo
WHERE b.modified_on >= @lastRunTime


UPDATE tblSearchName_Constructed
SET tblCustomers_firstName = c.firstName,
tblCustomers_surName = c.surName
FROM tblSearchName_Constructed a 
JOIN tblOrders b
	ON a.orderNo = b.orderNo
JOIN tblCustomers c
	ON b.customerID = c.customerID
WHERE c.modified_on >= @lastRunTime


UPDATE tblSearchName_Constructed
SET tblCustomers_ShippingAddress_Shipping_FirstName = c.Shipping_FirstName,
tblCustomers_ShippingAddress_Shipping_SurName = c.Shipping_SurName
FROM tblSearchName_Constructed a 
JOIN tblCustomers_ShippingAddress c
	ON a.orderNo = c.orderNo
WHERE c.modified_on >= @lastRunTime

--// Fix NULLS

UPDATE tblSearchName_Constructed
SET tblOrders_shipping_FirstName = ''
WHERE tblOrders_shipping_FirstName IS NULL

UPDATE tblSearchName_Constructed
SET tblOrders_shipping_SurName = ''
WHERE tblOrders_shipping_SurName IS NULL

UPDATE tblSearchName_Constructed
SET tblOrders_billing_FirstName = ''
WHERE tblOrders_billing_FirstName IS NULL

UPDATE tblSearchName_Constructed
SET tblOrders_billing_SurName = ''
WHERE tblOrders_billing_SurName IS NULL

UPDATE tblSearchName_Constructed
SET tblCustomers_firstName = ''
WHERE tblCustomers_firstName IS NULL

UPDATE tblSearchName_Constructed
SET tblCustomers_surName = ''
WHERE tblCustomers_surName IS NULL

UPDATE tblSearchName_Constructed
SET tblCustomers_ShippingAddress_Shipping_FirstName = ''
WHERE tblCustomers_ShippingAddress_Shipping_FirstName IS NULL

UPDATE tblSearchName_Constructed
SET tblCustomers_ShippingAddress_Shipping_SurName = ''
WHERE tblCustomers_ShippingAddress_Shipping_SurName IS NULL

--// Merge values into searchName field (JFp)
--// First, trim searchName
UPDATE tblSearchName_Constructed
SET searchName = SUBSTRING(searchName, 1, 50)

UPDATE tblSearchName_Constructed
SET searchName = searchName + ' ' + tblOrders_shipping_FirstName + ' ' + tblOrders_shipping_SurName + ' ' + tblOrders_billing_FirstName + ' ' + tblOrders_billing_SurName + ' ' + tblCustomers_firstName + ' ' + tblCustomers_surName + ' ' + tblCustomers_ShippingAddress_Shipping_FirstName + ' ' + tblCustomers_ShippingAddress_Shipping_SurName

--// Timestamp
UPDATE tblSearchName_LastRunTime
SET lastRunTime = GETDATE()

--//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@