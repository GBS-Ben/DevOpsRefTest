CREATE PROCEDURE [dbo].[sp_send_cdosysmailx] 
@From varchar(100) , 
@To varchar(100) , 
@Subject varchar(100)=" ", 
@Body varchar(4000) =" " ,
@attachments varchar(4000)=NULL
/********************************************************************* 
Supply attachments as either a single file or a comma delimited list

This stored procedure takes the above parameters and sends an e-mail. 
All of the mail configurations are hard-coded in the stored procedure. 
Comments are added to the stored procedure where necessary. 
Reference to the CDOSYS objects are at the following MSDN Web site: 
http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_messaging.asp 

***********************************************************************/ 
AS 
Declare @iMsg int 
Declare @hr int 
Declare @source varchar(255) 
Declare @description varchar(500) 
Declare @output varchar(1000) 
Declare @files table(fileid int identity(1,1),[file] varchar(255))
Declare @file varchar(255)
Declare @filecount int ; set @filecount=0
Declare @counter int ; set @counter = 1

--************* Create the CDO.Message Object ************************ 
EXEC @hr = sp_OACreate 'CDO.Message', @iMsg OUT 
--***************Configuring the Message Object ****************** 
-- This is to configure a remote SMTP server. 
-- http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_schema_configuration_sendusing.asp 
EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields ("http://schemas.microsoft.com/cdo/configuration/sendusing"). Value','2' 
-- This is to configure the Server Name or IP address. 
-- Replace MailServerName by the name or IP of your SMTP Server. 
--EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields ("http://schemas.microsoft.com/cdo/configuration/smtpserver"). Value', 'Servername' 
EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', '192.168.1.5'
-- Save the configurations to the message object. 
EXEC @hr = sp_OAMethod @iMsg, 'Configuration.Fields.Update', null 
-- Set the e-mail parameters. 
EXEC @hr = sp_OASetProperty @iMsg, 'To', @To 
EXEC @hr = sp_OASetProperty @iMsg, 'From', @From 
EXEC @hr = sp_OASetProperty @iMsg, 'Subject', @Subject 
-- If you are using HTML e-mail, use 'HTMLBody' instead of 'TextBody'. 
EXEC @hr = sp_OASetProperty @iMsg, 'TextBody', @Body 

IF @attachments IS NOT NULL
BEGIN
        INSERT @files SELECT value FROM dbo.fn_split(@attachments,',')
        SELECT @filecount=@@ROWCOUNT

        WHILE @counter<(@filecount+1)
        BEGIN
                SELECT @file = [file] 
                FROM @files
                WHERE fileid=@counter

                EXEC @hr = sp_OAMethod @iMsg, 'AddAttachment',NULL, @file

                SET @counter=@counter+1
        END
END

EXEC @hr = sp_OAMethod @iMsg, 'Send', NULL 

-- Do some error handling after each step if you need to. 
-- Clean up the objects created. 
EXEC @hr = sp_OADestroy @iMsg