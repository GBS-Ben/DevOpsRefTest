CREATE procedure [dbo].[GetAddressTaxRate] 
@Address varchar(500),
@city varchar(500),
@zip varchar(10),
@taxrate varchar(20) OUTPUT,
@taxcity varchar(50) OUTPUT
as 
begin
--declare @Latitude varchar(50) = '39.177026',
--@Longitude varchar(50) = '-120.8451'

	Declare @Object as Int;
	DECLARE @hr  int
	Declare @json as table(Json_Table nvarchar(max))
	declare @null varchar(1) = null
	declare @url varchar(255) = 'https://services.maps.cdtfa.ca.gov/api/taxrate/GetRateByAddress?address={Address}&city={city}&zip={zip}'

	set @url = replace(replace(replace(@url,'{Address}',@Address),'{city}',@city),'{zip}',@zip)


	Exec @hr=sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
	IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
	Exec @hr=sp_OAMethod @Object, 'open', null, 'get',
					 @url, --Your Web Service Url (invoked)
					 0
	IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object

	Exec @hr=sp_OAMethod @Object, 'send'
	IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object

	INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'
	---- select the JSON string
	--select * from @json
	---- Parse the JSON string
	SELECT @taxrate = taxrate, @taxcity = taxcity FROM OPENJSON((select * from @json), N'$.taxRateInfo')
	WITH (   
		  [TaxRate] nvarchar(max) N'$.rate'   ,
		  [TaxCity]   nvarchar(max) N'$.city'
	)
	EXEC sp_OADestroy @Object
--{"taxRateInfo":[{"rate":0.0875,"jurisdiction":"SACRAMENTO","city":"SACRAMENTO","county":"SACRAMENTO","tac":"340607050000"}],"geocodeInfo":{"bufferDistance":50},"termsOfUse":"https://www.cdtfa.ca.gov/dataportal/policy.htm","disclaimer":"https://www.cdtfa.ca.gov/dataportal/disclaimer.htm"}
END