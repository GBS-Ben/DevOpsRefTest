﻿CREATE VIEW [dbo].[vwTbl_upsx]
as
SELECT [pkid]
      ,[trackingnumber]
      ,[voidindicator]
      ,[referencenumber]
	  ,case when right(referencenumber,1) = 'R' then substring(REPLACE(ISNULL(referenceNumber, ''), 'ON', ''),1,datalength(REPLACE(ISNULL(referenceNumber, ''), 'ON', ''))-1) else REPLACE(ISNULL(referenceNumber, ''), 'ON', '') end as jobnumber      ,[cod]
      ,[numberpackages]
      ,[freight]
      ,[createdate]
      ,[serviceType]
      ,[actualWeight]
      ,[reference1]
      ,[reference2]
      ,[reference3]
      ,[reference4]
      ,[reference5]
      ,[packageType]
      ,[customerID]
      ,[companyName]
      ,[attention]
      ,[uspsPOBOX]
      ,[address1]
      ,[address2]
      ,[address3]
      ,[postalCode]
      ,[city]
      ,[state]
      ,[residentialIndicator]
      ,[intranetUpdate]
      ,[dateCreated]
  FROM [dbo].[tbl_upsx]