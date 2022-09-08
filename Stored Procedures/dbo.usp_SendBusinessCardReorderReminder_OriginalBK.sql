CREATE PROCEDURE [dbo].[usp_SendBusinessCardReorderReminder_OriginalBK] @NumberToSend int = 100
AS
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @tableHTML  NVARCHAR(MAX),  @OPID int, @ImageUrl varchar(255),	@Recipient varchar(255), @OrderNo varchar(100), @intFlag int, @counter int

	DECLARE @Orders TABLE (
		rownum int IDENTITY(1,1), 
		OrderNo varchar(50), 
		OrderId int,
		OPID int,
		OrderEmail varchar(500), 
		BusinessCardEmail varchar(500),
		ReorderLink varchar(500),
		LastOrderDate datetime, 
		DaysSinceLastOrder int, 
		ImageUrl varchar(500)
	)

	--Load the orders we will send emails for
	INSERT @Orders (OrderNo,
			OrderId ,
			OPID,
			OrderEmail,
			BusinessCardEmail,
			ReorderLink,
			LastOrderDate,
			DaysSinceLastOrder,
			ImageUrl
			)
	SELECT TOP (@NumberToSend) OrderNo, --we limit it to 1000 each day
			OrderId ,
			OPID,
			OrderEmail,
			BusinessCardEmail,
			ReorderLink,
			LastOrderDate,
			DaysSinceLastOrder,
			ImageUrl
	FROM tblBusinessCardReorderQueue WITH (NOLOCK)
		
	SET @intFlag = 1
	SET @counter = (SELECT MAX(rownum) FROM @Orders)

	WHILE (@intFlag <= @counter)
	BEGIN

			SELECT @OPID = OPID, 
				@ImageUrl = ImageUrl ,
				@Recipient = BusinessCardEmail, 
				@OrderNo = OrderNo
			FROM @Orders 
			WHERE rownum = @intFlag 

			   IF @OPID IS NOT NULL
			   BEGIN

	SET @tableHTML = 
	'<!doctype html>
	<html>
	<head>
	<meta charset="utf-8">
	<title>House of Magnets</title>
	<style>
	#outlook a {
		padding: 0;
	} /* Force Outlook to provide a "view in browser" menu link. */
	body {
		width: 100% !important;
		-webkit-text-size-adjust: 100%;
		-ms-text-size-adjust: 100%;
		margin: 0;
		padding: 0;
	}

	@media only screen and (max-width: 480px) {
	*.width160 {
		width: 160px !important;
	}
	*.width270 {
		width: 270px !important;
	} /* 25px margins */
	*.width280 {
		width: 280px !important;
	} /* 20px margins */
	*.width300 {
		width: 300px !important;
	} /* 10px margins */
	*.width320 {
		width: 320px !important;
	}
	*.heightauto {
		height: auto !important;
	}
	*.fluid {
		width: 100% !important;
		height: auto !important;
	}
	*.hide {
		display: none !important;
	}
	/* CAMPAIGN CSS */
	*.block {
		display: block !important;
	}
	*.padbtm {
		padding-bottom: 30px !important;
	}
	}
	</style>
	</head>

	<body>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:0 auto;" >
	  <tr>
		<td align="center"><!-- WRAPPER -->
      
		  <div>
			<table width="100%" bgcolor="#01265b" cellpadding="0" cellspacing="0" border="0">
			  <tr>
				<td bgcolor="#01265b" style="background-color: #01265b;"><table bgcolor="#01265b" width="580" align="center" cellspacing="0" cellpadding="0" border="0" class="width320" style="margin: 0 auto;" >
					<tr>
					  <td><table width="540" align="center" cellspacing="0" cellpadding="0" border="0" class="width280">
						  <tr>
							<td style="font-family: Helvetica, arial, sans-serif; font-size:12px; color: #FFFFFF; text-align:center; padding-top:5px; padding-bottom: 7px;">Reorder your business cards</td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
		  </div>
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0">
			  <tr>
				<td bgcolor="#ffffff" style="background-color:#ffffff;"><table bgcolor="#ffffff" width="580" align="center" cellspacing="0" cellpadding="0" border="0" class="width320" style="margin: 0 auto;" >
					<tr>
					  <td><table width="540" align="center" cellspacing="0" cellpadding="0" border="0" class="width280">
						  <tr>
							<td style="font-family: Helvetica, arial, sans-serif; font-size:12px; color: #FFFFFF; text-align:center;" ><div><a href="http://www.houseofmagnets.com/default.asp?utm_source=cordial&utm_medium=email&utm_content=2017&utm_campaign=logo"> <img src="https://d1ok0qgebci2d3.cloudfront.net/130/320x65/logo_HOM.png" alt="House of Magnets"  width="320" height="65" style="border:none; outline:none; text-decoration:none;"></a></div></td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
		  </div>
		  <div> 
        
			<!-- image + text -->
        
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0">
			  <tr>
				<td><table bgcolor="#ffffff" width="580" align="center" cellspacing="0" cellpadding="0" border="0" class="width320" style="margin: 0 auto;">
					<tr>
					  <td style="padding-top:15px; padding-bottom:15px;" align="center"><table width="540" align="center" cellspacing="0" cellpadding="0" border="0" class="width280">
						  <tr>
							<td class="width280" align="center"><a href="http://www.houseofmagnets.com/webservices/marketing.aspx?reorderlink=true&opid=' + CONVERT(varchar(20), @OPID) + '&utm_source=hom&utm_medium=email&utm_content=bct&utm_campaign=reorderLnk"><img width="320" border="0" alt="Don''t run out. Re-order today!" style="border:none; outline:none; text-decoration:none;" src="https://d1ok0qgebci2d3.cloudfront.net/130/320x169/headline.png" class="fluid"></a></td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
		  </div>
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0">
			  <tr>
				<td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width320" style="   margin: 0 auto;">
					<tr>
					  <td align="center" style="text-align: center;" ><table width="540" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0" align="center" class="width280 ">
						  <tr>
							<td class="herofont" align="center" valign="middle" style="font-family: Helvetica, arial, sans-serif; text-align:center; color:#003b78; font-size:20px; line-height:24px; padding-bottom:30px; " >It''s been a while since you ordered your business cards. <br>
							  If you are running low, <a href="http://www.houseofmagnets.com/webservices/marketing.aspx?reorderlink=true&opid=' + CONVERT(varchar(20), @OPID) + '&utm_source=hom&utm_medium=email&utm_content=bct&utm_campaign=reorderLnk" style="color:#ff6f06; text-decoration: none; ">reorder&nbsp;here.</a></td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
		  </div>
		  <div> 
        
			<!-- image + text -->
        
			<table width="100%" bgcolor="#e9e9ea" cellpadding="0" cellspacing="0" border="0">
			  <tr>
				<td bgcolor="#e9e9ea" style="padding-top:25px; padding-bottom: 25px; background-color: #e9e9ea; "><table width="580" align="center" cellspacing="0" cellpadding="0" border="0" class="width320" style="margin: 0 auto;">
					<tr>
					  <td style="" align="center"><table width="540" align="center" cellspacing="0" cellpadding="0" border="0" class="width280">
						  <tr>
							<td class="width280" align="center"><a href="http://www.houseofmagnets.com/webservices/marketing.aspx?reorderlink=true&opid=' + CONVERT(varchar(20), @OPID) + '&utm_source=hom&utm_medium=email&utm_content=bct&utm_campaign=reorderLnk"><img width="540" border="0" alt="Football Schedule Sale Ends Thursday" style="display:block; border:none; outline:none; text-decoration:none;" src="' + @ImageUrl + '" class="fluid"></a></td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
		  </div>
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0">
			  <tr>
				<td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width320" style="   margin: 0 auto;">
					<tr>
					  <td align="center" style="text-align: center; padding-top:25px; padding-bottom: 15px;" ><table width="180" border="0" align="center" cellpadding="0" cellspacing="0" style="margin:0 auto;">
						  <tbody>
							<tr>
							  <td width="180" height="42" align="center" valign="middle" bgcolor="#ff6f06" style="text-align:center; font-family:Arial, Helvetica, sans-serif; font-size:13px; color:#ffffff; "><a style="font-size:20px; color:#ffffff; text-decoration:none;" href="http://www.houseofmagnets.com/webservices/marketing.aspx?reorderlink=true&opid=' + CONVERT(varchar(20), @OPID) + '&utm_source=hom&utm_medium=email&utm_content=bct&utm_campaign=reorderLnk">Reorder Now</a></td>
							</tr>
						  </tbody>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
		  </div>

      
		  <!-- ///// GN RECOVERY NAV -->
      
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0" class="fluid">
			  <tbody>
				<tr>
				  <td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
					  <tbody>
						<tr>
						  <td align="center" ><table width="320" cellpadding="0" cellspacing="0" border="0" align="center" class="width280">
							  <tbody>
								<tr> 
								  <!-- start of image -->
								  <td class="fluid" align="center"><img border="0" alt="" style="display:block; border:none; outline:none; text-decoration:none;" src="https://d1ok0qgebci2d3.cloudfront.net/130/320x10/shadow_transparent.png" class="fluid"></td>
								</tr>
							  </tbody>
							</table></td>
						</tr>
					  </tbody>
					</table></td>
				</tr>
			  </tbody>
			</table>
		  </div>
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0" class="fluid">
			  <tbody>
				<tr>
				  <td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
					  <tbody>
						<tr>
						  <td align="center" style="text-align: center" ><table width="450" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
							  <tbody>
								<tr>
								  <td style="font-family: Helvetica, arial, sans-serif; text-align:center; color:#003b78; font-size:16px; line-height:20px; padding-top:30px; padding-bottom:5px; letter-spacing:.1em "><a href="https://www.houseofmagnets.com/default.asp?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=hom" style="color:#333333; text-decoration:none; font-weight:normal; font-size:14px;">MAGNETIC MARKETING</a></td>
								</tr>
								<tr>
								  <td class="block" style="font-family: Helvetica, arial, sans-serif; text-align:center; color:#003b78; font-size:16px; line-height:20px; padding-top:0px; padding-bottom:30px; "><a href="https://www.houseofmagnets.com/calendars/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=cals" style="color:#003b78; text-decoration: none;">Calendars</a>&nbsp;<span style="color:#afafaf;">&bull;</span> <a href="https://www.houseofmagnets.com/sports/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=sports" style="color:#003b78; text-decoration: none;">Sports Magnets</a>&nbsp;<span style="color:#afafaf;">&bull;</span> <a href="https://www.houseofmagnets.com/notepads/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=notepads" style="color:#003b78; text-decoration: none;">Notepads</a><br>
									<a href="https://www.houseofmagnets.com/gateway/gateway.aspx?code=specialty-magnets&utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=specialty" style="color:#003b78; text-decoration: none; ">Specialty</a>&nbsp;<span style="color:#afafaf;">&bull;</span> <a href="http://www.houseofmagnets.com/gallery/gallery.aspx?code=whiteboards&utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=whiteboards" style="color:#003b78; text-decoration: none;">Whiteboards</a></td>
								</tr>
							  </tbody>
							</table></td>
						</tr>
					  </tbody>
					</table></td>
				</tr>
			  </tbody>
			</table>
		  </div>
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0" class="fluid">
			  <tbody>
				<tr>
				  <td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
					  <tbody>
						<tr>
						  <td align="center" style="text-align: center;" ><table width="450" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
							  <tbody>
								<tr>
								  <td style="font-family: Helvetica, arial, sans-serif; text-align:center; color:#003b78; font-size:16px; line-height:20px; padding-top:0px; padding-bottom:5px; letter-spacing:.1em "><a href="http://www.houseofmagnets.com/market-centers/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=marketcenters" style="color:#333333; text-decoration:none; font-weight:normal; font-size:14px;">BUSINESS PRODUCTS</a></td>
								</tr>
								<tr>
								  <td class="block" style="font-family: Helvetica, arial, sans-serif; text-align:center; color:#003b78; font-size:16px; line-height:20px; padding-top:0px; padding-bottom:30px; "><a href="https://www.houseofmagnets.com/main_badge.asp?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=namebadge" style="color:#003b78; text-decoration: none;">Name&nbsp;Badges</a>&nbsp;<span style="color:#afafaf;">&bull; </span><a href="https://www.houseofmagnets.com/business-cards/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=bizcards " style="color:#003b78; text-decoration: none;">Business&nbsp;Cards</a>&nbsp;<span style="color:#afafaf;">&bull;</span> <a href="https://www.houseofmagnets.com/pens/pens-gallery.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=pens" style="color:#003b78; text-decoration: none;">Logo&nbsp;Pens</a><br>
									<a href="https://www.houseofmagnets.com/car-magnets/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=carmagnets" style="color:#003b78; text-decoration: none;">Car&nbsp;Magnets</a>&nbsp;<span style="color:#afafaf;">&bull;</span> <a href="http://www.houseofmagnets.com/gallery/gallery.aspx?code=awards&utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=awards" style="color:#003b78; text-decoration: none;">Awards</a>&nbsp;<span style="color:#afafaf;">&bull;</span> <a href="https://www.houseofmagnets.com/notecardcafe/default.aspx?utm_source=cordial&utm_medium=email&utm_content=recNav&utm_campaign=ncc" style="color:#003b78; text-decoration: none;">Note&nbsp;Cards</a></td>
								</tr>
							  </tbody>
							</table></td>
						</tr>
					  </tbody>
					</table></td>
				</tr>
			  </tbody>
			</table>
		  </div>
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0" class="fluid">
			  <tbody>
				<tr>
				  <td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
					  <tbody>
						<tr>
						  <td align="center" ><table width="320" cellpadding="0" cellspacing="0" border="0" align="center" class="width280">
							  <tbody>
								<tr> 
								  <!-- start of image -->
								  <td class="fluid" align="center"><img border="0" alt="" style="display:block; border:none; outline:none; text-decoration:none;" src="https://d1ok0qgebci2d3.cloudfront.net/130/320x10/shadow_transparent.png" class="fluid"></td>
								</tr>
							  </tbody>
							</table></td>
						</tr>
					  </tbody>
					</table></td>
				</tr>
			  </tbody>
			</table>
		  </div>
      
		  <!-- ///// GN RECOVERY NAV END --> 
		  <!-- ///// SUPPORT -->
      
		  <div>
			<table width="100%" bgcolor="#ffffff" cellpadding="0" cellspacing="0" border="0" class="fluid">
			  <tbody>
				<tr>
				  <td><table bgcolor="#ffffff" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
					  <tbody>
						<tr>
						  <td align="center" style="text-align: center;" ><table width="450" cellpadding="0" cellspacing="0" border="0" align="center" class="width280" style="margin: 0 auto;">
							  <tbody>
								<tr>
								  <td class="fluid" align="center" style="padding-bottom:30px; padding-top:30px;"><img border="0" alt="Shop with confidence. Live phone support. Satisfaction Guarantee." style="" src="https://d1ok0qgebci2d3.cloudfront.net/130/395x120/livephonesupport.jpg" class="fluid"></td>
								</tr>
							  </tbody>
							</table></td>
						</tr>
					  </tbody>
					</table></td>
				</tr>
			  </tbody>
			</table>
		  </div>
      
		  <!-- ///// SUPPORT END -->
      
		  <div> 
        
			<!-- fulltext -->
        
			<table width="100%" bgcolor="#01265b" cellpadding="0" cellspacing="0" border="0"  style="min-width: 100%">
			  <tr>
				<td><table bgcolor="#01265b" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width320" style="margin: 0 auto;">
					<tr>
					  <td><table width="540" align="center" cellpadding="0" cellspacing="0" border="0" class="width280">
                      
						  <!-- Title -->
                      
						  <tr>
							<td style="padding-top:5px; padding-bottom:5px; font: normal 11px/25px Arial, Helvetica, sans-serif; color:#FFFFFF !important;" align="center" bgcolor="#01265b">800.789.6247 &nbsp; |&nbsp;<a style="color:#ffffff;" href="mailto:info@houseofmagnets.com">INFO@HOUSEOFMAGNETS.COM</a></td>
						  </tr>
                      
						  <!-- End of spacing -->
                      
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
			<table width="100%" bgcolor="#023f7e" cellpadding="0" cellspacing="0" border="0"  style="min-width: 100%">
			  <tr>
				<td><table bgcolor="#023f7e" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width320" style="margin: 0 auto;">
					<tr>
					  <td align="center"><table width="60" align="center" vaalign="middle"  border="0" cellpadding="10" cellspacing="0">
						  <tr>
							<td width="25"  align="center"><div class="imgpop"> <a href="https://www.facebook.com/houseofmagnets"> <img src="https://d1ok0qgebci2d3.cloudfront.net/130/40x40/facebook_circle.png" alt="Facebook" border="0" width="40" height="40" style="display:block; border:none; outline:none; text-decoration:none;"> </a> </div></td>
							<td width="25" align="center"><div class="imgpop"> <a href="https://twitter.com/houseofmagnets"> <img src="https://d1ok0qgebci2d3.cloudfront.net/130/40x40/twitter_circle.png" alt="Twitter" border="0" width="40" height="40" style="display:block; border:none; outline:none; text-decoration:none;"> </a> </div></td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
			<!-- end of fulltext --> 
        
		  </div>
		  <div class="fluid"> 
        
			<!-- fulltext -->
        
			<table width="100%" bgcolor="#f6f4f5" cellpadding="0" cellspacing="0" border="0" st-sortable="fulltext">
			  <tr>
				<td><table bgcolor="#f6f4f5" width="580" cellpadding="0" cellspacing="0" border="0" align="center" class="width320" style="margin: 0 auto;">
					<tr>
					  <td style="padding-top:25px; padding-bottom:25px; "><table width="540" align="center" cellpadding="0" cellspacing="0" border="0" class="width280">
                      
						  <!-- Title -->
                      
						  <tr>
							<td style="text-align:left; font-family: Arial,Verdana,sans-serif;font-size: 10px; color: #9a9a9a; line-height: 12px; font-weight:normal;"> This publication is intended for industry professionals only and complies with Federal law. If, for some reason, this was sent in error or you would not like to have any more contact from House of Magnets, simply click the remove me link below. <br>
							  <br>
							  We take great pride in our reputation for quality and value and unconditionally guarantee every item sold against any defect in manufacturing. <br>
							  <br>
							  * * *<br>
							  <strong>Shipping</strong><br>
							  For peel &amp; stick items, we try to ship out within 2 business days. The exceptions to that would be temporary outages or seasonal products, like baseball, football, and calendars. They may take a bit longer. <br>
							  <br>
							  We ship mostly via UPS from San Diego, California – depending on how far you are from us, your order will be in transit between one to five business days. You can determine the actual transit-time on the UPS website. (Our zip code is 92020.) Tracking numbers for UPS are sent via email. <br>
							  <br>
							  For personalized product orders, depending on the products, there is typically a 5-10 business day production period + shipping time - although it may be a bit longer during our busiest seasons. Contact Customer Care - (800) 789-6247 - for information on our current production times. <br>
							  <br>
							  * * *<br>
							  This email comes to you from House Of Magnets, which is affiliated with Note Card Cafe, Giving Cards, Atomic Envelopes, Bella Gift Wrap, Team Magnet Promotions, and Magnetic Attractions. Parent company is Graphic Business Solutions: www.gogbs.com <br>
							  <br>
							  To read our privacy policy, please <a href="http://www.houseofmagnets.com/privacypolicy.asp" style="color:#9a9a9a; text-decoration: underline;" >click here</a>. <br>
							  <br>
							  This is a product offering from House of Magnets, 1912 John Towers Ave, El Cajon, CA 92020. <br>
							  <br>
							  If you have any questions, reply to this email, or email <a href="mailto:info@houseofmagnets.com" style="color:#9a9a9a; text-decoration: underline;" >info@houseofmagnets.com</a> or call (800) 789-6247 (outside the U.S./Canada, dial (619) 258-4087). © 2017 House of Magnets. All rights reserved.<br>
							  <br>
							  <a href="http://www.houseofmagnets.com/email-remove/email-remove.asp?e='+ @Recipient +'" style="color:#9a9a9a; text-decoration: underline;" >Remove me from reminder emails</a></td>
						  </tr>
						</table></td>
					</tr>
				  </table></td>
			  </tr>
			</table>
        
			<!-- end of fulltext --> 
        
		  </div>
      
		  <!-- WRAPPER END --></td>
	  </tr>
	</table>
	</body>
	</html>

	'

						EXEC msdb.dbo.sp_send_dbmail  
						@profile_name = 'House of Magnets',  
						@recipients = @Recipient,
						@reply_to= 'info@houseofmagnets.com',
						@subject = 'Don’t run out! Reorder your business cards today.' ,
						@body = @tableHTML,
						@body_format = 'HTML';

					--Log sending the email
					INSERT tblBusinessCardReorderEmailLog (DateEmailSent,ImageUrl, ReorderLink,HTMLBody, RecipientEmail,OPID, OrderNo	)
					SELECT GETDATE(), 
						@ImageUrl, 
						'http://www.houseofmagnets.com/webservices/marketing.aspx?reorderlink=true&opid=' + convert(varchar(100),@OPID) ,
						 @tableHTML, 
						 @Recipient,
						 @OPID,
						 @OrderNo

						 DELETE tblBusinessCardReorderQueue WHERE businessCardEmail = @Recipient AND OrderNo = @OrderNo AND opid = @Opid
			END

			SET @intFlag = @intFlag + 1
			SET @ImageUrl = ''
			SET @Recipient = ''
			SET @OPID = NULL
			SET @OrderNo = ''
	END

END TRY

BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH