create proc usp_UPSAPI_UpdateShippingLabel
@ID int
,@labelGenerated bit = 1
,@errorReceived bit = 0
,@errorValue nvarchar(50) = null
,@billingWeight numeric(7,2)
,@transactionCharge numeric(7,2)
,@negotiatedCharge numeric(7,2)
,@totalCharge numeric(7,2)
,@trackingNumber varchar(50)
,@labelName varchar(50)
,@labelPath varchar(100)
as
begin 
	--update tblUPSLabel
	update dbo.tblUpsLabel
	set labelGenerated = @labelGenerated
		,errorReceived = @errorReceived
		,errorValue = @errorValue
		,billingWeight = @billingWeight
		,transactionCharge = @transactionCharge
		,negotiatedCharge = @negotiatedCharge
		,totalCharge = @totalCharge
		,trackingNumber = @trackingNumber
		,labelName = @labelName
		,labelPath = @labelPath
	where ID = @ID
	--update tblShippingLabels ???
	--update tblJobTrack ???

end