create view vwEndicia_PrintHistory_Stage as 
SELECT [Id]
      ,[Print Date] as printDate
      ,[Amount Paid] as amountPaid
      ,[Adj  Amount] as adjustedAmount
      ,[Quoted Amount] as quotedAmount
      ,[Recipient] as recipient
      ,[Origin Zip] as originZip
      ,[Status] as [status]
      ,[Tracking #] as trackingNumber
      ,[Date Delivered] as dateDelivered
      ,[Carrier] as carrier
      ,[Class Service] as classService
      ,[Extra Services] as extraServices
      ,[Insured Value] as insuredValue
      ,[Insurance ID] as insuranceId
      ,[Cost Code] as costCode
      ,[Weight] as [weight]
      ,[Ship Date] as shipDate
      ,[Refund Type] as refundType
      ,[Printed Message] printedMessage
      ,[User] as [user]
      ,[Refund Request Date] as refundRequestDate
      ,[Refund Status] as refundStatus
      ,[Refund Requested] as refundRequested
      ,[Reference1] as reference1
      ,[Reference2] as reference2
      ,[Reference3] as reference3
      ,[Reference4] as reference4
      ,[Order ID] as orderId
      ,[inputFileName] 
      ,[dateCreated]
  FROM [dbo].[tblEndicia_PrintHistory_Stage]