CREATE PROCEDURE  [dbo].[OmniSearch] -- 'KELLER', 2000,  50, 'orderStatus', 'OrderStatus', 2
	@SearchString NVARCHAR(500),
	@Rows int = 2500, 
	@PageNumber int = 1,
	@SearchColumn varchar(255) = NULL,
	@ReturnColumn varchar(255) = NULL

AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     11/30/18
Purpose     Updates OMNI search data

			EXEC OmniSearch 'fifer'
-------------------------------------------------------------------------------
Modification History

11/30/18		JF, created.
12/03/18		BS, Added wildcard 
12/5/18			JF, added count.
12/11/18		BS, added support for TOP N and searching specific columns
12/26/18		BS, added support for return column
12/
-------------------------------------------------------------------------------
*/

DECLARE @TopNRows int

DECLARE @ReverseSearchString NVARCHAR(500), @NewSearchString NVARCHAR(500)
SET @NewSearchString = '"' + @SearchString +  '*"' --* wild card, but can only be at the end
SET @ReverseSearchString = '"' + REVERSE(@SearchString) +  '*"'

SELECT COUNT(*) OVER (PARTITION BY 1) AS numRecords,
	a.orderID, a.orderNo, a.orderNumeric, a.orderStatus, a.lastStatusUpdate, a.orderType, a.[status], 
	a.orderDate, a.orderTotal, a.paymentProcessed, a.coordIDUsed, a.brokerOwnerIDUsed, a.specialOffer, 
	a.customerID, a.shippingDesc, a.shippingMethod, a.shipDate, a.storeID, a.archived, a.firstName, a.surname, 
	a.company, a.street, a.suburb, a.[state], a.postCode, a.phone, a.fax, a.email, a.shipping_Company, 
	a.shipping_FirstName, a.shipping_Surname, a.shipping_Street, a.shipping_Street2, a.shipping_Suburb, 
	a.shipping_State, a.shipping_PostCode, a.shipping_Country, a.shipping_Phone, a.billing_Company, 
	a.billing_FirstName, a.billing_Surname, a.billing_Street, a.billing_Street2, a.billing_Suburb, 
	a.billing_State, a.billing_PostCode, a.billing_Country, a.billing_Phone, a.tabStatus, a.orderAck, 
	a.paymentSuccessful, a.paymentAmountRequired, a.paymentMethod, a.statusDate, a.searchName, 
	a.searchCompany, a.searchAddress, a.searchCity, a.searchState, a.searchZip, a.searchPhone, a.modified_on, 
	a.tblOrders_shipping_Company, a.tblOrders_shipping_FirstName, a.tblOrders_shipping_Surname, 
	a.tblOrders_shipping_Street, a.tblOrders_shipping_Street2, a.tblOrders_shipping_Suburb, 
	a.tblOrders_shipping_State, a.tblOrders_shipping_PostCode, a.tblOrders_shipping_Country, 
	a.tblOrders_shipping_Phone, a.tblOrders_billing_Company, a.tblOrders_billing_FirstName, 
	a.tblOrders_billing_Surname, a.tblOrders_billing_Street, a.tblOrders_billing_Street2, 
	a.tblOrders_billing_Suburb, a.tblOrders_billing_State, a.tblOrders_billing_PostCode, 
	a.tblOrders_billing_Country, a.tblOrders_billing_Phone, a.cartVersion, a.billingReference, a.NOP
FROM tblOrderView a
INNER JOIN OMNI i ON a.orderID = i.orderID
WHERE  (CONTAINS (SearchString,@NewSearchString) OR CONTAINS(SearchString,@ReverseSearchString))
ORDER BY orderDate DESC
OFFSET @Rows * (@PageNumber - 1) ROWS
FETCH NEXT @Rows ROWS ONLY


--  OFFSET @Rows * (@PageNumber - 1) ROWS
--  FETCH NEXT @Rows ROWS ONLY




/*
IF @ReturnColumn IS NULL 
BEGIN

	SET @NewSearchString = '"' + @SearchString +  '*"' --* wild card, but can only be at the end
	SET @ReverseSearchString = '"' + REVERSE(@SearchString) +  '*"'


	IF @SearchColumn IS NOT NULL
	BEGIN

		SET @TopNRows =  ISNULL(@Rows,500) --lets max out at 500
		
		SELECT TOP (@TopNRows) COUNT(*) OVER (PARTITION BY 1) AS numRecords,
			a.orderID, a.orderNo, a.orderNumeric, a.orderStatus, a.lastStatusUpdate, a.orderType, a.[status], 
			a.orderDate, a.orderTotal, a.paymentProcessed, a.coordIDUsed, a.brokerOwnerIDUsed, a.specialOffer, 
			a.customerID, a.shippingDesc, a.shippingMethod, a.shipDate, a.storeID, a.archived, a.firstName, a.surname, 
			a.company, a.street, a.suburb, a.[state], a.postCode, a.phone, a.fax, a.email, a.shipping_Company, 
			a.shipping_FirstName, a.shipping_Surname, a.shipping_Street, a.shipping_Street2, a.shipping_Suburb, 
			a.shipping_State, a.shipping_PostCode, a.shipping_Country, a.shipping_Phone, a.billing_Company, 
			a.billing_FirstName, a.billing_Surname, a.billing_Street, a.billing_Street2, a.billing_Suburb, 
			a.billing_State, a.billing_PostCode, a.billing_Country, a.billing_Phone, a.tabStatus, a.orderAck, 
			a.paymentSuccessful, a.paymentAmountRequired, a.paymentMethod, a.statusDate, a.searchName, 
			a.searchCompany, a.searchAddress, a.searchCity, a.searchState, a.searchZip, a.searchPhone, a.modified_on, 
			a.tblOrders_shipping_Company, a.tblOrders_shipping_FirstName, a.tblOrders_shipping_Surname, 
			a.tblOrders_shipping_Street, a.tblOrders_shipping_Street2, a.tblOrders_shipping_Suburb, 
			a.tblOrders_shipping_State, a.tblOrders_shipping_PostCode, a.tblOrders_shipping_Country, 
			a.tblOrders_shipping_Phone, a.tblOrders_billing_Company, a.tblOrders_billing_FirstName, 
			a.tblOrders_billing_Surname, a.tblOrders_billing_Street, a.tblOrders_billing_Street2, 
			a.tblOrders_billing_Suburb, a.tblOrders_billing_State, a.tblOrders_billing_PostCode, 
			a.tblOrders_billing_Country, a.tblOrders_billing_Phone, a.cartVersion, a.billingReference, a.NOP
		FROM tblOrderView a
		WHERE OrderDate >= '1/1/2015'
			AND CASE @SearchColumn
			WHEN  'orderID' THEN   convert(nvarchar(500),a.orderID  )
			WHEN  'OrderNo' THEN   convert(nvarchar(500),orderNo  )
			WHEN  'orderNumeric' THEN   convert(nvarchar(500),orderNumeric  )
			WHEN  'orderStatus' THEN   convert(nvarchar(500),orderStatus  )
			WHEN  'lastStatusUpdate' THEN   convert(nvarchar(500),lastStatusUpdate)
			WHEN  'orderType' THEN  convert(nvarchar(500), orderType  )
			WHEN  'status' THEN   convert(nvarchar(500),[status] )
			WHEN  'orderDate' THEN   convert(nvarchar(500),a.orderDate  )
			WHEN  'orderTotal' THEN   convert(nvarchar(500),orderTotal)
			WHEN  'paymentProcessed' THEN   convert(nvarchar(500),paymentProcessed  )
			WHEN  'coordIDUsed' THEN  convert(nvarchar(500), coordIDUsed )
			WHEN  'brokerOwnerIDUsed' THEN  convert(nvarchar(500), brokerOwnerIDUsed  )
			WHEN  'specialOffer' THEN  convert(nvarchar(500), specialOffer)
			WHEN  'CustomerId' THEN convert(nvarchar(500),a.customerID  )
			WHEN  'shippingDesc' THEN  convert(nvarchar(500), shippingDesc )
			WHEN  'shippingMethod' THEN   convert(nvarchar(500),shippingMethod )
			WHEN  'shipDate' THEN  convert(nvarchar(500), shipDate )
			WHEN  'storeID' THEN   convert(nvarchar(500),storeID )
			WHEN  'archived' THEN   convert(nvarchar(500),archived ) 
			WHEN  'firstName' THEN   convert(nvarchar(500),firstName )
			WHEN  'surname' THEN   convert(nvarchar(500),surname)
			WHEN  'company' THEN   convert(nvarchar(500),a.company ) 
			WHEN  'street' THEN   convert(nvarchar(500),street  )
			WHEN  'suburb' THEN  convert(nvarchar(500), suburb  )
			WHEN  'state' THEN   convert(nvarchar(500),[state] )
			WHEN  'postCode' THEN  convert(nvarchar(500), postCode )
			WHEN  'phone' THEN   convert(nvarchar(500),phone  )
			WHEN  'fax' THEN   convert(nvarchar(500),fax  )
			WHEN  'email' THEN   convert(nvarchar(500),email  )
			WHEN  'shipping_Company' THEN   convert(nvarchar(500),shipping_Company )
			WHEN  'shipping_FirstName' THEN   convert(nvarchar(500),a.shipping_FirstName )
			WHEN  'shipping_Surname' THEN   convert(nvarchar(500),shipping_Surname) 
			WHEN  'shippingStreet' THEN   convert(nvarchar(500),shipping_Street  )
			WHEN  'shipping_Street2' THEN   convert(nvarchar(500),shipping_Street2 ) 
			WHEN  'shipping_Suburb' THEN   convert(nvarchar(500),shipping_Suburb )
			WHEN  'shipping_State' THEN   convert(nvarchar(500),a.shipping_State )
			WHEN  'shipping_PostCode' THEN  convert(nvarchar(500), shipping_PostCode ) 
			WHEN  'shipping_Country' THEN   convert(nvarchar(500),shipping_Country ) 
			WHEN  'shipping_Phone' THEN   convert(nvarchar(500),shipping_Phone  )
			WHEN  'billing_Company' THEN  convert(nvarchar(500), billing_Company )
			WHEN  'billing_FirstName' THEN convert(nvarchar(500),  a.billing_FirstName  )
			WHEN  'billing_Surname' THEN   convert(nvarchar(500),billing_Surname ) 
			WHEN  'billing_Street' THEN   convert(nvarchar(500),billing_Street  )
			WHEN  'billing_Street2' THEN  convert(nvarchar(500), billing_Street2 ) 
			WHEN  'billing_Suburb' THEN   convert(nvarchar(500),billing_Suburb )
			WHEN  'billing_State' THEN  convert(nvarchar(500), a.billing_State )
			WHEN  'billing_PostCode' THEN   convert(nvarchar(500),billing_PostCode)  
			WHEN  'billing_Country' THEN  convert(nvarchar(500), billing_Country  )
			WHEN  'billing_Phone' THEN  convert(nvarchar(500), billing_Phone  )
			WHEN  'tabStatus' THEN   convert(nvarchar(500),tabStatus  )
			WHEN  'orderAck' THEN  convert(nvarchar(500), orderAck )
			WHEN  'paymentSuccessful' THEN   convert(nvarchar(500),a.paymentSuccessful )
			WHEN  'paymentAmountRequired' THEN  convert(nvarchar(500), paymentAmountRequired  )
			WHEN  'paymentMethod' THEN convert(nvarchar(500),  paymentMethod )
			WHEN  'statusDate' THEN   convert(nvarchar(500),statusDate )
			WHEN  'searchName' THEN   convert(nvarchar(500),searchName )
			WHEN  'searchCompany' THEN  convert(nvarchar(500), a.searchCompany )
			WHEN  'searchAddress' THEN  convert(nvarchar(500), searchAddress)
			WHEN  'searchCity' THEN   convert(nvarchar(500),searchCity )
			WHEN  'searchState' THEN  convert(nvarchar(500), searchState  )
			WHEN  'searchZip' THEN   convert(nvarchar(500),searchZip )
			WHEN  'searchPhone' THEN   convert(nvarchar(500),searchPhone ) 
			WHEN  'modified_on' THEN   convert(nvarchar(500),modified_on )
			WHEN  'tblOrders_shipping_Company' THEN   convert(nvarchar(500),a.tblOrders_shipping_Company  )
			WHEN  'tblOrders_shipping_FirstName' THEN  convert(nvarchar(500), tblOrders_shipping_FirstName ) 
			WHEN  'tblOrders_shipping_Surname' THEN   convert(nvarchar(500),tblOrders_shipping_Surname) 
			WHEN  'tblOrders_shipping_Street' THEN   convert(nvarchar(500),a.tblOrders_shipping_Street ) 
			WHEN  'tblOrders_shipping_Street2' THEN  convert(nvarchar(500), tblOrders_shipping_Street2 ) 
			WHEN  'tblOrders_shipping_Suburb' THEN  convert(nvarchar(500), tblOrders_shipping_Suburb )
			WHEN  'tblOrders_shipping_State' THEN  convert(nvarchar(500), a.tblOrders_shipping_State  )
			WHEN  'tblOrders_shipping_PostCode' THEN  convert(nvarchar(500), tblOrders_shipping_PostCode) 
			WHEN  'tblOrders_shipping_Country' THEN   convert(nvarchar(500),tblOrders_shipping_Country )
			WHEN  'tblOrders_shipping_Phone' THEN   convert(nvarchar(500),a.tblOrders_shipping_Phone  )
			WHEN  'tblOrders_billing_Company' THEN   convert(nvarchar(500),tblOrders_billing_Company )
			WHEN  'tblOrders_billing_FirstName' THEN  convert(nvarchar(500), tblOrders_billing_FirstName )
			WHEN  'tblOrders_billing_Surname' THEN   convert(nvarchar(500),a.tblOrders_billing_Surname)
			WHEN  'tblOrders_billing_Street' THEN   convert(nvarchar(500),tblOrders_billing_Street )
			WHEN  'tblOrders_billing_Street2' THEN  convert(nvarchar(500), tblOrders_billing_Street2 )
			WHEN  'tblOrders_billing_Suburb' THEN  convert(nvarchar(500), a.tblOrders_billing_Suburb )
			WHEN  'tblOrders_billing_State' THEN   convert(nvarchar(500),tblOrders_billing_State )
			WHEN  'tblOrders_billing_PostCode' THEN  convert(nvarchar(500), tblOrders_billing_PostCode )
			WHEN  'tblOrders_billing_Country' THEN  convert(nvarchar(500), a.tblOrders_billing_Country  )
			WHEN  'tblOrders_billing_Phone' THEN  convert(nvarchar(500), tblOrders_billing_Phone ) 
			WHEN  'cartVersion' THEN  convert(nvarchar(500), cartVersion ) 
			WHEN  'billingReference' THEN convert(nvarchar(500),billingReference )
			END LIKE '%' + @SearchString +'%'

			RETURN;

	END 

	IF @Rows IS NULL
	BEGIN

		SELECT COUNT(*) OVER (PARTITION BY 1) AS numRecords,
		a.orderID, a.orderNo, a.orderNumeric, a.orderStatus, a.lastStatusUpdate, a.orderType, a.[status], 
		a.orderDate, a.orderTotal, a.paymentProcessed, a.coordIDUsed, a.brokerOwnerIDUsed, a.specialOffer, 
		a.customerID, a.shippingDesc, a.shippingMethod, a.shipDate, a.storeID, a.archived, a.firstName, a.surname, 
		a.company, a.street, a.suburb, a.[state], a.postCode, a.phone, a.fax, a.email, a.shipping_Company, 
		a.shipping_FirstName, a.shipping_Surname, a.shipping_Street, a.shipping_Street2, a.shipping_Suburb, 
		a.shipping_State, a.shipping_PostCode, a.shipping_Country, a.shipping_Phone, a.billing_Company, 
		a.billing_FirstName, a.billing_Surname, a.billing_Street, a.billing_Street2, a.billing_Suburb, 
		a.billing_State, a.billing_PostCode, a.billing_Country, a.billing_Phone, a.tabStatus, a.orderAck, 
		a.paymentSuccessful, a.paymentAmountRequired, a.paymentMethod, a.statusDate, a.searchName, 
		a.searchCompany, a.searchAddress, a.searchCity, a.searchState, a.searchZip, a.searchPhone, a.modified_on, 
		a.tblOrders_shipping_Company, a.tblOrders_shipping_FirstName, a.tblOrders_shipping_Surname, 
		a.tblOrders_shipping_Street, a.tblOrders_shipping_Street2, a.tblOrders_shipping_Suburb, 
		a.tblOrders_shipping_State, a.tblOrders_shipping_PostCode, a.tblOrders_shipping_Country, 
		a.tblOrders_shipping_Phone, a.tblOrders_billing_Company, a.tblOrders_billing_FirstName, 
		a.tblOrders_billing_Surname, a.tblOrders_billing_Street, a.tblOrders_billing_Street2, 
		a.tblOrders_billing_Suburb, a.tblOrders_billing_State, a.tblOrders_billing_PostCode, 
		a.tblOrders_billing_Country, a.tblOrders_billing_Phone, a.cartVersion, a.billingReference, a.NOP
		FROM tblOrderView a
		INNER JOIN OMNI i ON a.orderID = i.orderID
		WHERE OrderDate >=  '1/1/2015'
			AND  (CONTAINS (SearchString,@NewSearchString) OR CONTAINS(SearchString,@ReverseSearchString))
		-----i.SearchString LIKE '%' + @SearchString + '%'

	END
	ELSE 
	BEGIN

		SET @TopNRows =  @Rows
		SELECT TOP (@TopNRows) COUNT(*) OVER (PARTITION BY 1) AS numRecords,
		a.orderID, a.orderNo, a.orderNumeric, a.orderStatus, a.lastStatusUpdate, a.orderType, a.[status], 
		a.orderDate, a.orderTotal, a.paymentProcessed, a.coordIDUsed, a.brokerOwnerIDUsed, a.specialOffer, 
		a.customerID, a.shippingDesc, a.shippingMethod, a.shipDate, a.storeID, a.archived, a.firstName, a.surname, 
		a.company, a.street, a.suburb, a.[state], a.postCode, a.phone, a.fax, a.email, a.shipping_Company, 
		a.shipping_FirstName, a.shipping_Surname, a.shipping_Street, a.shipping_Street2, a.shipping_Suburb, 
		a.shipping_State, a.shipping_PostCode, a.shipping_Country, a.shipping_Phone, a.billing_Company, 
		a.billing_FirstName, a.billing_Surname, a.billing_Street, a.billing_Street2, a.billing_Suburb, 
		a.billing_State, a.billing_PostCode, a.billing_Country, a.billing_Phone, a.tabStatus, a.orderAck, 
		a.paymentSuccessful, a.paymentAmountRequired, a.paymentMethod, a.statusDate, a.searchName, 
		a.searchCompany, a.searchAddress, a.searchCity, a.searchState, a.searchZip, a.searchPhone, a.modified_on, 
		a.tblOrders_shipping_Company, a.tblOrders_shipping_FirstName, a.tblOrders_shipping_Surname, 
		a.tblOrders_shipping_Street, a.tblOrders_shipping_Street2, a.tblOrders_shipping_Suburb, 
		a.tblOrders_shipping_State, a.tblOrders_shipping_PostCode, a.tblOrders_shipping_Country, 
		a.tblOrders_shipping_Phone, a.tblOrders_billing_Company, a.tblOrders_billing_FirstName, 
		a.tblOrders_billing_Surname, a.tblOrders_billing_Street, a.tblOrders_billing_Street2, 
		a.tblOrders_billing_Suburb, a.tblOrders_billing_State, a.tblOrders_billing_PostCode, 
		a.tblOrders_billing_Country, a.tblOrders_billing_Phone, a.cartVersion, a.billingReference, a.NOP
		FROM tblOrderView a
		INNER JOIN OMNI i ON a.orderID = i.orderID
		WHERE  OrderDate >=  '1/1/2015'
			AND (CONTAINS (SearchString,@NewSearchString) OR CONTAINS(SearchString,@ReverseSearchString))
			
	END
END
ELSE
BEGIN

	/*
	I am not smart enought to know how to do this without dynamic SQL so here it is
	*/
	SET @NewSearchString = '''"' + @SearchString + '*"''' --'*"' --* wild card, but can only be at the end
	SET @ReverseSearchString = '''"' + REVERSE(@SearchString) +  '*"'''


	--SET @NewSearchString = '''' + @SearchString +  '*''' --* wild card, but can only be at the end
	--SET @ReverseSearchString = '''' + REVERSE(@SearchString) +  '*'''
	SET @Statement = 'SELECT ' 

	IF @SearchColumn IS NOT NULL
	BEGIN

		SET @TopNRows =  ISNULL(@Rows,500) --lets max out at 500
		
		SET @Statement = @Statement + 'TOP ( ' + CONVERT(varchar(500),@TopNRows) + ') COUNT(*) OVER (PARTITION BY 1) AS numRecords, '  
	
	SET @Statement = @Statement +
		CASE @ReturnColumn
			WHEN  'orderID' THEN   ' a.orderID '
			WHEN  'OrderNo' THEN  ' orderNo  '
			WHEN  'orderNumeric' THEN   ' orderNumeric  '
			WHEN  'orderStatus' THEN  ' orderStatus  '
			WHEN  'lastStatusUpdate' THEN   'lastStatusUpdate'
			WHEN  'orderType' THEN  ' orderType  '
			WHEN  'status' THEN   '[status]'
			WHEN  'orderDate' THEN   'a.orderDate  '
			WHEN  'orderTotal' THEN   'orderTotal'
			WHEN  'paymentProcessed' THEN   'paymentProcessed  '
			WHEN  'coordIDUsed' THEN  ' coordIDUsed '
			WHEN  'brokerOwnerIDUsed' THEN  ' brokerOwnerIDUsed  '
			WHEN  'specialOffer' THEN  ' specialOffer'
			WHEN  'CustomerId' THEN 'a.customerID  '
			WHEN  'shippingDesc' THEN  ' shippingDesc '
			WHEN  'shippingMethod' THEN   'shippingMethod '
			WHEN  'shipDate' THEN  ' shipDate '
			WHEN  'storeID' THEN   'storeID '
			WHEN  'archived' THEN   'archived ' 
			WHEN  'firstName' THEN   'firstName '
			WHEN  'surname' THEN   'surname'
			WHEN  'company' THEN   'a.company ' 
			WHEN  'street' THEN   'street  '
			WHEN  'suburb' THEN  ' suburb  '
			WHEN  'state' THEN   'state '
			WHEN  'postCode' THEN  ' postCode '
			WHEN  'phone' THEN   'phone  '
			WHEN  'fax' THEN   'fax  '
			WHEN  'email' THEN   'email  '
			WHEN  'shipping_Company' THEN   'shipping_Company '
			WHEN  'shipping_FirstName' THEN   'a.shipping_FirstName '
			WHEN  'shipping_Surname' THEN   'shipping_Surname' 
			WHEN  'shippingStreet' THEN   'shipping_Street  '
			WHEN  'shipping_Street2' THEN   'shipping_Street2 ' 
			WHEN  'shipping_Suburb' THEN   'shipping_Suburb '
			WHEN  'shipping_State' THEN   'a.shipping_State '
			WHEN  'shipping_PostCode' THEN  ' shipping_PostCode ' 
			WHEN  'shipping_Country' THEN   'shipping_Country ' 
			WHEN  'shipping_Phone' THEN   'shipping_Phone  '
			WHEN  'billing_Company' THEN  ' billing_Company '
			WHEN  'billing_FirstName' THEN '  a.billing_FirstName  '
			WHEN  'billing_Surname' THEN   'billing_Surname ' 
			WHEN  'billing_Street' THEN   'billing_Street  '
			WHEN  'billing_Street2' THEN  ' billing_Street2 ' 
			WHEN  'billing_Suburb' THEN   'billing_Suburb '
			WHEN  'billing_State' THEN  ' a.billing_State '
			WHEN  'billing_PostCode' THEN   'billing_PostCode'  
			WHEN  'billing_Country' THEN  ' billing_Country  '
			WHEN  'billing_Phone' THEN  ' billing_Phone  '
			WHEN  'tabStatus' THEN   'tabStatus  '
			WHEN  'orderAck' THEN  ' orderAck '
			WHEN  'paymentSuccessful' THEN   'a.paymentSuccessful '
			WHEN  'paymentAmountRequired' THEN  ' paymentAmountRequired  '
			WHEN  'paymentMethod' THEN '  paymentMethod '
			WHEN  'statusDate' THEN   'statusDate '
			WHEN  'searchName' THEN   'searchName '
			WHEN  'searchCompany' THEN  ' a.searchCompany '
			WHEN  'searchAddress' THEN  ' searchAddress'
			WHEN  'searchCity' THEN   'searchCity '
			WHEN  'searchState' THEN  ' searchState  '
			WHEN  'searchZip' THEN   'searchZip '
			WHEN  'searchPhone' THEN   'searchPhone ' 
			WHEN  'modified_on' THEN   'modified_on '
			WHEN  'tblOrders_shipping_Company' THEN   'a.tblOrders_shipping_Company  '
			WHEN  'tblOrders_shipping_FirstName' THEN  ' tblOrders_shipping_FirstName ' 
			WHEN  'tblOrders_shipping_Surname' THEN   'tblOrders_shipping_Surname' 
			WHEN  'tblOrders_shipping_Street' THEN   'a.tblOrders_shipping_Street ' 
			WHEN  'tblOrders_shipping_Street2' THEN  ' tblOrders_shipping_Street2 ' 
			WHEN  'tblOrders_shipping_Suburb' THEN  ' tblOrders_shipping_Suburb '
			WHEN  'tblOrders_shipping_State' THEN  ' a.tblOrders_shipping_State  '
			WHEN  'tblOrders_shipping_PostCode' THEN  ' tblOrders_shipping_PostCode' 
			WHEN  'tblOrders_shipping_Country' THEN   'tblOrders_shipping_Country '
			WHEN  'tblOrders_shipping_Phone' THEN   'a.tblOrders_shipping_Phone  '
			WHEN  'tblOrders_billing_Company' THEN   'tblOrders_billing_Company '
			WHEN  'tblOrders_billing_FirstName' THEN  ' tblOrders_billing_FirstName '
			WHEN  'tblOrders_billing_Surname' THEN   'a.tblOrders_billing_Surname'
			WHEN  'tblOrders_billing_Street' THEN   'tblOrders_billing_Street '
			WHEN  'tblOrders_billing_Street2' THEN  ' tblOrders_billing_Street2 '
			WHEN  'tblOrders_billing_Suburb' THEN  ' a.tblOrders_billing_Suburb '
			WHEN  'tblOrders_billing_State' THEN   'tblOrders_billing_State '
			WHEN  'tblOrders_billing_PostCode' THEN  ' tblOrders_billing_PostCode '
			WHEN  'tblOrders_billing_Country' THEN  ' a.tblOrders_billing_Country  '
			WHEN  'tblOrders_billing_Phone' THEN  ' tblOrders_billing_Phone ' 
			WHEN  'cartVersion' THEN  ' cartVersion ' 
			WHEN  'billingReference' THEN 'billingReference '
			END 
		 

		
		SET @Statement = @statement + ' FROM tblOrderView a '
		SET @Statement = @statement + ' WHERE  OrderDate >=  ''1/1/2015''
			 AND  ' + 
		CASE @SearchColumn 
			WHEN  'orderID' THEN   ' a.orderID '
			WHEN  'OrderNo' THEN  ' orderNo  '
			WHEN  'orderNumeric' THEN   ' orderNumeric  '
			WHEN  'orderStatus' THEN  ' orderStatus  '
			WHEN  'lastStatusUpdate' THEN   'lastStatusUpdate'
			WHEN  'orderType' THEN  ' orderType  '
			WHEN  'status' THEN   '[status] '
			WHEN  'orderDate' THEN   'a.orderDate  '
			WHEN  'orderTotal' THEN   'orderTotal'
			WHEN  'paymentProcessed' THEN   'paymentProcessed  '
			WHEN  'coordIDUsed' THEN  ' coordIDUsed '
			WHEN  'brokerOwnerIDUsed' THEN  ' brokerOwnerIDUsed  '
			WHEN  'specialOffer' THEN  ' specialOffer'
			WHEN  'CustomerId' THEN 'a.customerID  '
			WHEN  'shippingDesc' THEN  ' shippingDesc '
			WHEN  'shippingMethod' THEN   'shippingMethod '
			WHEN  'shipDate' THEN  ' shipDate '
			WHEN  'storeID' THEN   'storeID '
			WHEN  'archived' THEN   'archived ' 
			WHEN  'firstName' THEN   'firstName '
			WHEN  'surname' THEN   'surname'
			WHEN  'company' THEN   'a.company ' 
			WHEN  'street' THEN   'street  '
			WHEN  'suburb' THEN  ' suburb  '
			WHEN  'state' THEN   'state '
			WHEN  'postCode' THEN  ' postCode '
			WHEN  'phone' THEN   'phone  '
			WHEN  'fax' THEN   'fax  '
			WHEN  'email' THEN   'email  '
			WHEN  'shipping_Company' THEN   'shipping_Company '
			WHEN  'shipping_FirstName' THEN   'a.shipping_FirstName '
			WHEN  'shipping_Surname' THEN   'shipping_Surname' 
			WHEN  'shippingStreet' THEN   'shipping_Street  '
			WHEN  'shipping_Street2' THEN   'shipping_Street2 ' 
			WHEN  'shipping_Suburb' THEN   'shipping_Suburb '
			WHEN  'shipping_State' THEN   'a.shipping_State '
			WHEN  'shipping_PostCode' THEN  ' shipping_PostCode ' 
			WHEN  'shipping_Country' THEN   'shipping_Country ' 
			WHEN  'shipping_Phone' THEN   'shipping_Phone  '
			WHEN  'billing_Company' THEN  ' billing_Company '
			WHEN  'billing_FirstName' THEN '  a.billing_FirstName  '
			WHEN  'billing_Surname' THEN   'billing_Surname ' 
			WHEN  'billing_Street' THEN   'billing_Street  '
			WHEN  'billing_Street2' THEN  ' billing_Street2 ' 
			WHEN  'billing_Suburb' THEN   'billing_Suburb '
			WHEN  'billing_State' THEN  ' a.billing_State '
			WHEN  'billing_PostCode' THEN   'billing_PostCode'  
			WHEN  'billing_Country' THEN  ' billing_Country  '
			WHEN  'billing_Phone' THEN  ' billing_Phone  '
			WHEN  'tabStatus' THEN   'tabStatus  '
			WHEN  'orderAck' THEN  ' orderAck '
			WHEN  'paymentSuccessful' THEN   'a.paymentSuccessful '
			WHEN  'paymentAmountRequired' THEN  ' paymentAmountRequired  '
			WHEN  'paymentMethod' THEN '  paymentMethod '
			WHEN  'statusDate' THEN   'statusDate '
			WHEN  'searchName' THEN   'searchName '
			WHEN  'searchCompany' THEN  ' a.searchCompany '
			WHEN  'searchAddress' THEN  ' searchAddress'
			WHEN  'searchCity' THEN   'searchCity '
			WHEN  'searchState' THEN  ' searchState  '
			WHEN  'searchZip' THEN   'searchZip '
			WHEN  'searchPhone' THEN   'searchPhone ' 
			WHEN  'modified_on' THEN   'modified_on '
			WHEN  'tblOrders_shipping_Company' THEN   'a.tblOrders_shipping_Company  '
			WHEN  'tblOrders_shipping_FirstName' THEN  ' tblOrders_shipping_FirstName ' 
			WHEN  'tblOrders_shipping_Surname' THEN   'tblOrders_shipping_Surname' 
			WHEN  'tblOrders_shipping_Street' THEN   'a.tblOrders_shipping_Street ' 
			WHEN  'tblOrders_shipping_Street2' THEN  ' tblOrders_shipping_Street2 ' 
			WHEN  'tblOrders_shipping_Suburb' THEN  ' tblOrders_shipping_Suburb '
			WHEN  'tblOrders_shipping_State' THEN  ' a.tblOrders_shipping_State  '
			WHEN  'tblOrders_shipping_PostCode' THEN  ' tblOrders_shipping_PostCode' 
			WHEN  'tblOrders_shipping_Country' THEN   'tblOrders_shipping_Country '
			WHEN  'tblOrders_shipping_Phone' THEN   'a.tblOrders_shipping_Phone  '
			WHEN  'tblOrders_billing_Company' THEN   'tblOrders_billing_Company '
			WHEN  'tblOrders_billing_FirstName' THEN  ' tblOrders_billing_FirstName '
			WHEN  'tblOrders_billing_Surname' THEN   'a.tblOrders_billing_Surname'
			WHEN  'tblOrders_billing_Street' THEN   'tblOrders_billing_Street '
			WHEN  'tblOrders_billing_Street2' THEN  ' tblOrders_billing_Street2 '
			WHEN  'tblOrders_billing_Suburb' THEN  ' a.tblOrders_billing_Suburb '
			WHEN  'tblOrders_billing_State' THEN   'tblOrders_billing_State '
			WHEN  'tblOrders_billing_PostCode' THEN  ' tblOrders_billing_PostCode '
			WHEN  'tblOrders_billing_Country' THEN  ' a.tblOrders_billing_Country  '
			WHEN  'tblOrders_billing_Phone' THEN  ' tblOrders_billing_Phone ' 
			WHEN  'cartVersion' THEN  ' cartVersion ' 
			WHEN  'billingReference' THEN 'billingReference '
			END 
		  + '	LIKE ''%' + @SearchString + '%'''


		   --Finally execute the procedure
		EXECUTE sp_executesql @statement
			RETURN;

	END 

	IF @Rows IS NULL
	BEGIN
		
		SET @Statement = @Statement + '  COUNT(*) OVER (PARTITION BY 1) AS numRecords, '  +
		CASE @ReturnColumn
			WHEN  'orderID' THEN   ' a.orderID '
			WHEN  'OrderNo' THEN  ' orderNo  '
			WHEN  'orderNumeric' THEN   ' orderNumeric  '
			WHEN  'orderStatus' THEN  ' orderStatus  '
			WHEN  'lastStatusUpdate' THEN   'lastStatusUpdate'
			WHEN  'orderType' THEN  ' orderType  '
			WHEN  'status' THEN   '[status]'
			WHEN  'orderDate' THEN   'a.orderDate  '
			WHEN  'orderTotal' THEN   'orderTotal'
			WHEN  'paymentProcessed' THEN   'paymentProcessed  '
			WHEN  'coordIDUsed' THEN  ' coordIDUsed '
			WHEN  'brokerOwnerIDUsed' THEN  ' brokerOwnerIDUsed  '
			WHEN  'specialOffer' THEN  ' specialOffer'
			WHEN  'CustomerId' THEN 'a.customerID  '
			WHEN  'shippingDesc' THEN  ' shippingDesc '
			WHEN  'shippingMethod' THEN   'shippingMethod '
			WHEN  'shipDate' THEN  ' shipDate '
			WHEN  'storeID' THEN   'storeID '
			WHEN  'archived' THEN   'archived ' 
			WHEN  'firstName' THEN   'firstName '
			WHEN  'surname' THEN   'surname'
			WHEN  'company' THEN   'a.company ' 
			WHEN  'street' THEN   'street  '
			WHEN  'suburb' THEN  ' suburb  '
			WHEN  'state' THEN   'state '
			WHEN  'postCode' THEN  ' postCode '
			WHEN  'phone' THEN   'phone  '
			WHEN  'fax' THEN   'fax  '
			WHEN  'email' THEN   'email  '
			WHEN  'shipping_Company' THEN   'shipping_Company '
			WHEN  'shipping_FirstName' THEN   'a.shipping_FirstName '
			WHEN  'shipping_Surname' THEN   'shipping_Surname' 
			WHEN  'shippingStreet' THEN   'shipping_Street  '
			WHEN  'shipping_Street2' THEN   'shipping_Street2 ' 
			WHEN  'shipping_Suburb' THEN   'shipping_Suburb '
			WHEN  'shipping_State' THEN   'a.shipping_State '
			WHEN  'shipping_PostCode' THEN  ' shipping_PostCode ' 
			WHEN  'shipping_Country' THEN   'shipping_Country ' 
			WHEN  'shipping_Phone' THEN   'shipping_Phone  '
			WHEN  'billing_Company' THEN  ' billing_Company '
			WHEN  'billing_FirstName' THEN '  a.billing_FirstName  '
			WHEN  'billing_Surname' THEN   'billing_Surname ' 
			WHEN  'billing_Street' THEN   'billing_Street  '
			WHEN  'billing_Street2' THEN  ' billing_Street2 ' 
			WHEN  'billing_Suburb' THEN   'billing_Suburb '
			WHEN  'billing_State' THEN  ' a.billing_State '
			WHEN  'billing_PostCode' THEN   'billing_PostCode'  
			WHEN  'billing_Country' THEN  ' billing_Country  '
			WHEN  'billing_Phone' THEN  ' billing_Phone  '
			WHEN  'tabStatus' THEN   'tabStatus  '
			WHEN  'orderAck' THEN  ' orderAck '
			WHEN  'paymentSuccessful' THEN   'a.paymentSuccessful '
			WHEN  'paymentAmountRequired' THEN  ' paymentAmountRequired  '
			WHEN  'paymentMethod' THEN '  paymentMethod '
			WHEN  'statusDate' THEN   'statusDate '
			WHEN  'searchName' THEN   'searchName '
			WHEN  'searchCompany' THEN  ' a.searchCompany '
			WHEN  'searchAddress' THEN  ' searchAddress'
			WHEN  'searchCity' THEN   'searchCity '
			WHEN  'searchState' THEN  ' searchState  '
			WHEN  'searchZip' THEN   'searchZip '
			WHEN  'searchPhone' THEN   'searchPhone ' 
			WHEN  'modified_on' THEN   'modified_on '
			WHEN  'tblOrders_shipping_Company' THEN   'a.tblOrders_shipping_Company  '
			WHEN  'tblOrders_shipping_FirstName' THEN  ' tblOrders_shipping_FirstName ' 
			WHEN  'tblOrders_shipping_Surname' THEN   'tblOrders_shipping_Surname' 
			WHEN  'tblOrders_shipping_Street' THEN   'a.tblOrders_shipping_Street ' 
			WHEN  'tblOrders_shipping_Street2' THEN  ' tblOrders_shipping_Street2 ' 
			WHEN  'tblOrders_shipping_Suburb' THEN  ' tblOrders_shipping_Suburb '
			WHEN  'tblOrders_shipping_State' THEN  ' a.tblOrders_shipping_State  '
			WHEN  'tblOrders_shipping_PostCode' THEN  ' tblOrders_shipping_PostCode' 
			WHEN  'tblOrders_shipping_Country' THEN   'tblOrders_shipping_Country '
			WHEN  'tblOrders_shipping_Phone' THEN   'a.tblOrders_shipping_Phone  '
			WHEN  'tblOrders_billing_Company' THEN   'tblOrders_billing_Company '
			WHEN  'tblOrders_billing_FirstName' THEN  ' tblOrders_billing_FirstName '
			WHEN  'tblOrders_billing_Surname' THEN   'a.tblOrders_billing_Surname'
			WHEN  'tblOrders_billing_Street' THEN   'tblOrders_billing_Street '
			WHEN  'tblOrders_billing_Street2' THEN  ' tblOrders_billing_Street2 '
			WHEN  'tblOrders_billing_Suburb' THEN  ' a.tblOrders_billing_Suburb '
			WHEN  'tblOrders_billing_State' THEN   'tblOrders_billing_State '
			WHEN  'tblOrders_billing_PostCode' THEN  ' tblOrders_billing_PostCode '
			WHEN  'tblOrders_billing_Country' THEN  ' a.tblOrders_billing_Country  '
			WHEN  'tblOrders_billing_Phone' THEN  ' tblOrders_billing_Phone ' 
			WHEN  'cartVersion' THEN  ' cartVersion ' 
			WHEN  'billingReference' THEN 'billingReference '
			END 
		 
		SET @Statement = @statement + ' FROM tblOrderView a 
		INNER JOIN OMNI i ON a.orderID = i.orderID
		WHERE   OrderDate >=  ''1/1/2015''
			AND  (CONTAINS (SearchString,' + '' + @NewSearchString + '' + ') OR CONTAINS(SearchString,' + '' + @ReverseSearchString + '))'


	END
	ELSE 
	BEGIN

		--SET @TopNRows =  @Rows
		--SELECT TOP (@TopNRows) COUNT(*) OVER (PARTITION BY 1) AS numRecords,
		SET @TopNRows =  ISNULL(@Rows,500) --lets max out at 500
		
		SET @Statement = @Statement + 'TOP (  ' + CONVERT(varchar(500),@TopNRows) + ') COUNT(*) OVER (PARTITION BY 1) AS numRecords, '  
		SET @Statement = @Statement +
		CASE @ReturnColumn
			WHEN  'orderID' THEN   ' a.orderID '
			WHEN  'OrderNo' THEN  ' orderNo  '
			WHEN  'orderNumeric' THEN   ' orderNumeric  '
			WHEN  'orderStatus' THEN  ' orderStatus  '
			WHEN  'lastStatusUpdate' THEN   'lastStatusUpdate'
			WHEN  'orderType' THEN  ' orderType  '
			WHEN  'status' THEN   '[status] '
			WHEN  'orderDate' THEN   'a.orderDate  '
			WHEN  'orderTotal' THEN   'orderTotal'
			WHEN  'paymentProcessed' THEN   'paymentProcessed  '
			WHEN  'coordIDUsed' THEN  ' coordIDUsed '
			WHEN  'brokerOwnerIDUsed' THEN  ' brokerOwnerIDUsed  '
			WHEN  'specialOffer' THEN  ' specialOffer'
			WHEN  'CustomerId' THEN 'a.customerID  '
			WHEN  'shippingDesc' THEN  ' shippingDesc '
			WHEN  'shippingMethod' THEN   'shippingMethod '
			WHEN  'shipDate' THEN  ' shipDate '
			WHEN  'storeID' THEN   'storeID '
			WHEN  'archived' THEN   'archived ' 
			WHEN  'firstName' THEN   'firstName '
			WHEN  'surname' THEN   'surname'
			WHEN  'company' THEN   'a.company ' 
			WHEN  'street' THEN   'street  '
			WHEN  'suburb' THEN  ' suburb  '
			WHEN  'state' THEN   'state '
			WHEN  'postCode' THEN  ' postCode '
			WHEN  'phone' THEN   'phone  '
			WHEN  'fax' THEN   'fax  '
			WHEN  'email' THEN   'email  '
			WHEN  'shipping_Company' THEN   'shipping_Company '
			WHEN  'shipping_FirstName' THEN   'a.shipping_FirstName '
			WHEN  'shipping_Surname' THEN   'shipping_Surname' 
			WHEN  'shippingStreet' THEN   'shipping_Street  '
			WHEN  'shipping_Street2' THEN   'shipping_Street2 ' 
			WHEN  'shipping_Suburb' THEN   'shipping_Suburb '
			WHEN  'shipping_State' THEN   'a.shipping_State '
			WHEN  'shipping_PostCode' THEN  ' shipping_PostCode ' 
			WHEN  'shipping_Country' THEN   'shipping_Country ' 
			WHEN  'shipping_Phone' THEN   'shipping_Phone  '
			WHEN  'billing_Company' THEN  ' billing_Company '
			WHEN  'billing_FirstName' THEN '  a.billing_FirstName  '
			WHEN  'billing_Surname' THEN   'billing_Surname ' 
			WHEN  'billing_Street' THEN   'billing_Street  '
			WHEN  'billing_Street2' THEN  ' billing_Street2 ' 
			WHEN  'billing_Suburb' THEN   'billing_Suburb '
			WHEN  'billing_State' THEN  ' a.billing_State '
			WHEN  'billing_PostCode' THEN   'billing_PostCode'  
			WHEN  'billing_Country' THEN  ' billing_Country  '
			WHEN  'billing_Phone' THEN  ' billing_Phone  '
			WHEN  'tabStatus' THEN   'tabStatus  '
			WHEN  'orderAck' THEN  ' orderAck '
			WHEN  'paymentSuccessful' THEN   'a.paymentSuccessful '
			WHEN  'paymentAmountRequired' THEN  ' paymentAmountRequired  '
			WHEN  'paymentMethod' THEN '  paymentMethod '
			WHEN  'statusDate' THEN   'statusDate '
			WHEN  'searchName' THEN   'searchName '
			WHEN  'searchCompany' THEN  ' a.searchCompany '
			WHEN  'searchAddress' THEN  ' searchAddress'
			WHEN  'searchCity' THEN   'searchCity '
			WHEN  'searchState' THEN  ' searchState  '
			WHEN  'searchZip' THEN   'searchZip '
			WHEN  'searchPhone' THEN   'searchPhone ' 
			WHEN  'modified_on' THEN   'modified_on '
			WHEN  'tblOrders_shipping_Company' THEN   'a.tblOrders_shipping_Company  '
			WHEN  'tblOrders_shipping_FirstName' THEN  ' tblOrders_shipping_FirstName ' 
			WHEN  'tblOrders_shipping_Surname' THEN   'tblOrders_shipping_Surname' 
			WHEN  'tblOrders_shipping_Street' THEN   'a.tblOrders_shipping_Street ' 
			WHEN  'tblOrders_shipping_Street2' THEN  ' tblOrders_shipping_Street2 ' 
			WHEN  'tblOrders_shipping_Suburb' THEN  ' tblOrders_shipping_Suburb '
			WHEN  'tblOrders_shipping_State' THEN  ' a.tblOrders_shipping_State  '
			WHEN  'tblOrders_shipping_PostCode' THEN  ' tblOrders_shipping_PostCode' 
			WHEN  'tblOrders_shipping_Country' THEN   'tblOrders_shipping_Country '
			WHEN  'tblOrders_shipping_Phone' THEN   'a.tblOrders_shipping_Phone  '
			WHEN  'tblOrders_billing_Company' THEN   'tblOrders_billing_Company '
			WHEN  'tblOrders_billing_FirstName' THEN  ' tblOrders_billing_FirstName '
			WHEN  'tblOrders_billing_Surname' THEN   'a.tblOrders_billing_Surname'
			WHEN  'tblOrders_billing_Street' THEN   'tblOrders_billing_Street '
			WHEN  'tblOrders_billing_Street2' THEN  ' tblOrders_billing_Street2 '
			WHEN  'tblOrders_billing_Suburb' THEN  ' a.tblOrders_billing_Suburb '
			WHEN  'tblOrders_billing_State' THEN   'tblOrders_billing_State '
			WHEN  'tblOrders_billing_PostCode' THEN  ' tblOrders_billing_PostCode '
			WHEN  'tblOrders_billing_Country' THEN  ' a.tblOrders_billing_Country  '
			WHEN  'tblOrders_billing_Phone' THEN  ' tblOrders_billing_Phone ' 
			WHEN  'cartVersion' THEN  ' cartVersion ' 
			WHEN  'billingReference' THEN 'billingReference '
			END 
		 

		
		SET @Statement = @statement + ' FROM tblOrderView a 
		INNER JOIN OMNI i ON a.orderID = i.orderID
		WHERE   OrderDate >=  ''1/1/2015''  AND (CONTAINS (SearchString,' + @NewSearchString  + ') OR CONTAINS(SearchString,' + @ReverseSearchString + '))'

	END

   --Finally execute the procedure
  EXECUTE sp_executesql @statement

END






*/