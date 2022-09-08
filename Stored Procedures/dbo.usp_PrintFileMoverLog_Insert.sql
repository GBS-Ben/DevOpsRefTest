CREATE PROC [dbo].[usp_PrintFileMoverLog_Insert]
 @OrderID VARCHAR(50)
,@OPID INT
,@optionCaption VARCHAR(255)
,@SourceFile VARCHAR(255)
,@DestinationFile VARCHAR(255)
,@Status VARCHAR(10)
as 
INSERT INTO [dbo].[tblPrintFileMoverLog]
           ([OrderID]
           ,[OPID]
		   ,[optionCaption]
           ,[SourceFile]
           ,[DestinationFile]
		   ,[Status]
           ,[ProcessDate])
     VALUES
           (@OrderID
           ,@OPID
		   ,@optionCaption
           ,@SourceFile
           ,@DestinationFile
		   ,@Status
           ,GETDATE())