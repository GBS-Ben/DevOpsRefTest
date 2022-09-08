--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>
--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>
CREATE PROC [dbo].[usp_artBackgrounds]
AS
SET NOCOUNT ON;

	BEGIN TRY
		-- INITIAL INSERT
		delete from tblArtBackgrounds
		insert into tblArtBackgrounds (orderNo, orderStatus, productQuantity, background, productCode, shipping_name, shipping_street, shipping_street2, shipping_suburb, shipping_state, shipping_postCode, ordersProductsID, orderID)
		select 
		a.orderNo, a.orderStatus, 
		p.productQuantity, 
		replace((x.textValue+'.pdf'),'.pdf.pdf','.pdf') as 'background',
		q.textValue as 'productCode',
		c.shipping_firstName+' '+c.shipping_surName as 'shipping_name',
		c.shipping_street, c.shipping_street2, c.shipping_suburb, c.shipping_state, c.shipping_postCode,
			--'ABC' as 'customEnv',
			--'ABCDEFGHIJKLMNOPQRSTUVWXYZ' as 'envFileName',
			--'ABC' as 'otherStock',
			--'ABC' as 'otherCustom'

		x.ordersProductsID,
		a.orderID
			--into tblArtBackgrounds
		from tblOrders a INNER JOIN tblOrders_Products p on a.orderID=p.orderID
		INNER JOIN tblCustomers_ShippingAddress c on a .orderNo=c.orderNo
		INNER JOIN tblOrdersProducts_ProductOptions x on p.[ID]=x.ordersProductsID
		INNER JOIN tblOrdersProducts_ProductOptions q on p.[ID]=q.ordersProductsID
		where
		p.productCode='NCCU-001'
		and p.deleteX<>'yes'
		and x.optionID=320
		and x.deleteX<>'yes'
		and q.optionID=293
		and q.deleteX<>'yes'
		--and a.orderNo like '%258020'
		order by a.orderNo ASC

		--Fix productCode
		update tblArtBackgrounds
		set productCode=b.productCode
		from tblArtBackgrounds a
		INNER JOIN tblProducts b ON  b.productName like '%'+a.productCode+'%'

		update tblArtBackgrounds
		set productCode='NCTKA2-003' where productCode like '%bountiful c%'

		--CUSTOM ENV YES/NO UPDATE
		update tblArtBackgrounds
		set customEnv='Yes' where orderNo in
		(select distinct orderNo from tblOrders where orderID in
		(select orderID from tblOrders_Products where productCode like 'NCEV%' and deleteX<>'yes'))

		update tblArtBackgrounds
		set customEnv='No'
		where customEnv is NULL

		--envFileName UPDATE
		update tblArtBackgrounds
		set envFileName=z.textValue
		from tblArtBackgrounds a INNER JOIN tblOrders_Products x
		on a.orderID=x.orderID
		INNER JOIN tblOrdersProducts_ProductOptions z
		on x.[ID]=z.ordersProductsID
		where a.ordersProductsID<>z.ordersProductsID
		and z.optionID=320
		and z.textValue like '%NCEV%'

		--otherStock / otherCustom UPDATES

		update tblArtBackgrounds
		set otherStock='Yes'
		where orderID in
		(select orderID from tblOrders_Products
		where deleteX<>'yes' and productCode<>'NCCU-001' and productCode not like 'NCEV%' 
		and productName not like 'Holiday Note Cards%' 
		and productName not like 'General Note Cards%' 
		and productID in
		(select distinct productID from tblProducts where productType='Stock'))

		update tblArtBackgrounds
		set otherCustom='Yes'
		where orderID in
		(select orderID from tblOrders_Products
		where deleteX<>'yes' and productCode<>'NCCU-001' and productCode not like 'NCEV%' and productID in
		(select distinct productID from tblProducts where productType='Custom'))

		update tblArtBackgrounds set otherStock='No' where otherStock is NULL
		update tblArtBackgrounds set otherCustom='No' where otherCustom is NULL

		delete from tblArtBackgrounds where productCode='Test Note Card'


		--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>
		--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>--- >>>>>>>>>
	END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH