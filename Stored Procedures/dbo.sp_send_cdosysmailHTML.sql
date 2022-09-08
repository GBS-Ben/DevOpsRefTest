/*

Test Script

declare @Body varchar(4000)
   select @Body = 'This is a Test Message'
   exec sp_send_cdosysmail 'clint@gogbs.com','clint@gogbs.com','TEST',@Body

*/

CREATE PROCEDURE [dbo].[sp_send_cdosysmailHTML]
	   @From varchar(100) ,
	   @To varchar(900) ,
	   @Subject varchar(100)=" ",
	   @Body varchar(4000) =" "
	/*********************************************************************

	This stored procedure takes the parameters and sends an e-mail.
	All the mail configurations are hard-coded in the stored procedure.
	Comments are added to the stored procedure where necessary.
	References to the CDOSYS objects are at the following MSDN Web site:
	http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_messaging.asp

	***********************************************************************/
	   AS
	   Declare @iMsg int
	   Declare @hr int
	   Declare @source varchar(255)
	   Declare @description varchar(500)
	   Declare @output varchar(1000)

	--************* Create the CDO.Message Object ************************
	   EXEC @hr = sp_OACreate 'CDO.Message', @iMsg OUT
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OACreate')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
                   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OACreate')
                   RETURN
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           RETURN
	         END
	     END

	--***************Configuring the Message Object ******************
	-- This is to configure a remote SMTP server.
	-- http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_schema_configuration_sendusing.asp
	   EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','2'
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty sendusing')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
                   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty sendusing')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	-- This is to configure the Server Name or IP address.
	-- Replace MailServerName by the name or IP of your SMTP Server.
	   EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', '192.168.1.7'
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty smtpserver')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty smtpserver')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	-- Save the configurations to the message object.
	   EXEC @hr = sp_OAMethod @iMsg, 'Configuration.Fields.Update', null
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty Update')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty Update')
		   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	-- Set the e-mail parameters.
	   EXEC @hr = sp_OASetProperty @iMsg, 'To', @To
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty To')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty To')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	   EXEC @hr = sp_OASetProperty @iMsg, 'From', @From
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty From')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty From')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	   EXEC @hr = sp_OASetProperty @iMsg, 'Subject', @Subject
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty Subject')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty Subject')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	-- If you are using HTML e-mail, use 'HTMLBody' instead of 'TextBody'.
	   --EXEC @hr = sp_OASetProperty @iMsg, 'TextBody', @Body
	   EXEC @hr = sp_OASetProperty @iMsg, 'HTMLBody', @Body
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OASetProperty HTMLBody')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty HTMLBody')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	   EXEC @hr = sp_OAMethod @iMsg, 'Send', NULL
	   IF @hr <>0
	     BEGIN
	       SELECT @hr
	       INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OAMethod Send')
	       EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @hr = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           PRINT  @output
  	  	   INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OAMethod Send')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END


	-- Do some error handling after each step if you have to.
	-- Clean up the objects created.
        send_cdosysmail_cleanup:
	If (@iMsg IS NOT NULL) -- if @iMsg is NOT NULL then destroy it
	BEGIN
		EXEC @hr=sp_OADestroy @iMsg

		-- handle the failure of the destroy if needed
		IF @hr <>0
	     	BEGIN
			select @hr
        	        INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'Failed at sp_OADestroy')
	       		EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT

			-- if sp_OAGetErrorInfo was successful, print errors
			IF @hr = 0
			BEGIN
				SELECT @output = '  Source: ' + @source
			        PRINT  @output
			        SELECT @output = '  Description: ' + @description
			        PRINT  @output
				INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OADestroy')
			END

			-- else sp_OAGetErrorInfo failed
			ELSE
			BEGIN
				PRINT '  sp_OAGetErrorInfo failed.'
			        RETURN
			END
		END
	END
	ELSE
	BEGIN
		PRINT ' sp_OADestroy skipped because @iMsg is NULL.'
		INSERT INTO master.dbo.cdosysmail_failures VALUES (getdate(), @@spid, @From, @To, @Subject, @Body, @iMsg, @hr, @source, @description, @output, '@iMsg is NULL, sp_OADestroy skipped')
	        RETURN
	END