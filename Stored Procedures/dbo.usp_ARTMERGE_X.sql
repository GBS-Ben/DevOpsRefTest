--select * from tblArtMerge
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~       B E G I N     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE PROCEDURE [dbo].[usp_ARTMERGE_X]
AS
SET NOCOUNT ON;

BEGIN TRY
	-- 1.  [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Refresh Table

	delete from tblArtMerge
	--select * from tblArtMerge where orderNo='HOM269900'

	--2. [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Populate table with initial values

	INSERT INTO tblArtMerge (PKID, orderNo, ordersProductsID, productID, productCode, productName, productQuantity)
	select distinct substring(a.orderNo,4,6), a.orderNo, b.[ID], b.productID, b.productCode, b.productName, b.productQuantity
	from tblOrders a INNER JOIN  tblOrders_Products b
	on a.orderID=b.orderID 
	where b.deleteX<>'yes'
	and b.productID in
			(select distinct productID from tblProducts where productType='Custom' and productCode not like 'NB%')
	and a.orderType='Custom'
	and substring(a.orderNo,4,6) not in
			(select distinct PKID from tblArtMerge where PKID is NOT NULL)
	and datediff(dd,a.orderDate,getdate())<160
	and a.orderStatus<>'delivered'
	and a.orderStatus<>'cancelled'
	and a.orderStatus not like '%transit%'
	and a.orderStatus not like '%DOCK%'
	order by substring(a.orderNo,4,6)



	-- 3.  [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Do field updates

	--INPUT 1 (yourname)
	update tblArtMerge
	set yourName=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 1:%'
	and a.yourname is NULL
	and p.deleteX<>'yes'

	--INPUT 2 (yourcompany)
	update tblArtMerge
	set yourcompany=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 2:%'
	and p.deleteX<>'yes'

	--INPUT 3 (input1)
	update tblArtMerge
	set input1=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 3:%'
	and p.deleteX<>'yes'

	--INPUT 4 /a
	update tblArtMerge
	set input2=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 4:%'
	and p.deleteX<>'yes'

	--INPUT 5 /a
	update tblArtMerge
	set input3=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 5:%'
	and p.deleteX<>'yes'

	--INPUT 6 /a
	update tblArtMerge
	set input4=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 6:%'
	and p.deleteX<>'yes'

	--INPUT 7
	update tblArtMerge
	set input5=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 7:%'
	and p.deleteX<>'yes'

	--INPUT 8
	update tblArtMerge
	set input6=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 8:%'
	and p.deleteX<>'yes'

	--INPUT 9
	update tblArtMerge
	set input7=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 9:%'
	and p.deleteX<>'yes'

	--INPUT 10
	update tblArtMerge
	set input8=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 10:%'
	and p.deleteX<>'yes'

	update tblArtMerge
	set marketCenterName=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Market Center Name:%'
	and p.deleteX<>'yes'

	--projectDesc
	update tblArtMerge
	set projectDesc=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Project Description:%'
	and p.deleteX<>'yes'

	--csz
	update tblArtMerge
	set csz=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'City/state/zip:%'
	and p.deleteX<>'yes'

	--yourName2
	update tblArtMerge
	set yourName2=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Your name:%'
	and p.deleteX<>'yes'

	--streetAddress
	update tblArtMerge
	set streetAddress=convert(varchar(255), p.textValue)
	from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Street address:%'
	and p.deleteX<>'yes'


	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK STARTS HERE.


											--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1--SYMBOL #1
											-- 3	A. Realtor Symbol
											-- 4	B. Equal Housing Opportunity Symbol
											-- 5	C. Realtor - MLS Combo Symbol
											-- 6	D. ABR Symbol
											-- 7	E. CRS Symbol
											-- 8	F. GRI Symbol
											-- 9	G. CRB Symbol
											-- 10	H.  WCR Symbol
											-- 11	I. CRP Symbol
											-- 12	J.  MLS Symbol
											-- 13	K.  e-Pro Symbol
											-- 14	L.  SRES Symbol
											-- 15	M. FDIC Symbol
											-- 141	N. Equal Housing Lender Symbol
											-- 155	O. NAHREP Symbol


											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=3
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=4
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=5
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=6
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=7
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=8
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=9
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=10
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=11
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=12
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=13
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=14
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=15
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=141
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=155
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%facebook%'
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%linkedin%'
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%SFR%'
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol1=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%Twitter%'
											and p.deleteX<>'yes'


											--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=3
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=4
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=5
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=6
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=7
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=8
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=9
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=10
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=11
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=12
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=13
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=14
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=15
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=141
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=155
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%facebook%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%linkedin%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%SFR%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol2=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%Twitter%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=3
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=4
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=5
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=6
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=7
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=8
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=9
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=10
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=11
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=12
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=13
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=14
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=15
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=141
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=155
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%Facebook%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%linkedin%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%SFR%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblArtMerge
											set profsymbol3=p.optionCaption
											from tblArtMerge a INNER JOIN  tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%Twitter%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'


											/*
											A. Realtor Symbol
											B. Equal Housing Opportunity Symbol
											C. Realtor - MLS Combo Symbol
											D. ABR Symbol
											E. CRS Symbol
											F. GRI Symbol
											G. CRB Symbol
											H.  WCR Symbol
											I. CRP Symbol
											J.  MLS Symbol
											K.  e-Pro Symbol
											L.  SRES Symbol
											M. FDIC Symbol
											No Thanks...
											N. Equal Housing Lender Symbol
											O. NAHREP Symbol
											SFR
											Facebook
											LinkedIn
											Twitter
											*/


											update tblArtMerge set profsymbol1='A.Realtor.R.Stroke.eps' where profsymbol1 like '%Realtor Symbol%'
											update tblArtMerge set profsymbol2='A.Realtor.R.Stroke.eps' where profsymbol2 like '%Realtor Symbol%'
											update tblArtMerge set profsymbol3='A.Realtor.R.Stroke.eps' where profsymbol3 like '%Realtor Symbol%'

											update tblArtMerge set profsymbol1='B.EqualHousing.Stroke.eps' where profsymbol1 like '%Equal Housing Opportunity Symbol%'
											update tblArtMerge set profsymbol2='B.EqualHousing.Stroke.eps' where profsymbol2 like '%Equal Housing Opportunity Symbol%'
											update tblArtMerge set profsymbol3='B.EqualHousing.Stroke.eps' where profsymbol3 like '%Equal Housing Opportunity Symbol%'

											update tblArtMerge set profsymbol1='C.Realtor.MLS.Stroke.eps' where profsymbol1 like '%Realtor - MLS Combo Symbol%'
											update tblArtMerge set profsymbol2='C.Realtor.MLS.Stroke.eps' where profsymbol2 like '%Realtor - MLS Combo Symbol%'
											update tblArtMerge set profsymbol3='C.Realtor.MLS.Stroke.eps' where profsymbol3 like '%Realtor - MLS Combo Symbol%'

											update tblArtMerge set profsymbol1='D.abr.Stroke.eps' where profsymbol1 like '%ABR Symbol%'
											update tblArtMerge set profsymbol2='D.abr.Stroke.eps' where profsymbol2 like '%ABR Symbol%'
											update tblArtMerge set profsymbol3='D.abr.Stroke.eps' where profsymbol3 like '%ABR Symbol%'

											update tblArtMerge set profsymbol1='E.crs.Stroke.eps' where profsymbol1 like '%CRS Symbol%'
											update tblArtMerge set profsymbol2='E.crs.Stroke.eps' where profsymbol2 like '%CRS Symbol%'
											update tblArtMerge set profsymbol3='E.crs.Stroke.eps' where profsymbol3 like '%CRS Symbol%'

											update tblArtMerge set profsymbol1='F.gri.Stroke.eps' where profsymbol1 like '%GRI Symbol%'
											update tblArtMerge set profsymbol2='F.gri.Stroke.eps' where profsymbol2 like '%GRI Symbol%'
											update tblArtMerge set profsymbol3='F.gri.Stroke.eps' where profsymbol3 like '%GRI Symbol%'

											update tblArtMerge set profsymbol1='G.crb.Stroke.eps' where profsymbol1 like '%CRB Symbol%'
											update tblArtMerge set profsymbol2='G.crb.Stroke.eps' where profsymbol2 like '%CRB Symbol%'
											update tblArtMerge set profsymbol3='G.crb.Stroke.eps' where profsymbol3 like '%CRB Symbol%'

											update tblArtMerge set profsymbol1='H.WCI.Stroke.eps' where profsymbol1 like '%WCR Symbol%'
											update tblArtMerge set profsymbol2='H.WCI.Stroke.eps' where profsymbol2 like '%WCR Symbol%'
											update tblArtMerge set profsymbol3='H.WCI.Stroke.eps' where profsymbol3 like '%WCR Symbol%'

											update tblArtMerge set profsymbol1='I.crp.stroke.eps' where profsymbol1 like '%CRP Symbol%'
											update tblArtMerge set profsymbol2='I.crp.stroke.eps' where profsymbol2 like '%CRP Symbol%'
											update tblArtMerge set profsymbol3='I.crp.stroke.eps' where profsymbol3 like '%CRP Symbol%'

											update tblArtMerge set profsymbol1='J.MLS.Stroked.eps' where profsymbol1 like '%MLS Symbol%'
											update tblArtMerge set profsymbol2='J.MLS.Stroked.eps' where profsymbol2 like '%MLS Symbol%'
											update tblArtMerge set profsymbol3='J.MLS.Stroked.eps' where profsymbol3 like '%MLS Symbol%'

											update tblArtMerge set profsymbol1='K.epro.Stroke.eps' where profsymbol1 like '%e-Pro Symbol%'
											update tblArtMerge set profsymbol2='K.epro.Stroke.eps' where profsymbol2 like '%e-Pro Symbol%'
											update tblArtMerge set profsymbol3='K.epro.Stroke.eps' where profsymbol3 like '%e-Pro Symbol%'

											update tblArtMerge set profsymbol1='L.sres.Stroke.eps' where profsymbol1 like '%SRES Symbol%'
											update tblArtMerge set profsymbol2='L.sres.Stroke.eps' where profsymbol2 like '%SRES Symbol%'
											update tblArtMerge set profsymbol3='L.sres.Stroke.eps' where profsymbol3 like '%SRES Symbol%'

											update tblArtMerge set profsymbol1='M.FDIC.Stroke.eps' where profsymbol1 like '%FDIC Symbol%'
											update tblArtMerge set profsymbol2='M.FDIC.Stroke.eps' where profsymbol2 like '%FDIC Symbol%'
											update tblArtMerge set profsymbol3='M.FDIC.Stroke.eps' where profsymbol3 like '%FDIC Symbol%'

											update tblArtMerge set profsymbol1='N.EHLender.Stroke.eps' where profsymbol1 like '%Equal Housing Lender Symbol%'
											update tblArtMerge set profsymbol2='N.EHLender.Stroke.eps' where profsymbol2 like '%Equal Housing Lender Symbol%'
											update tblArtMerge set profsymbol3='N.EHLender.Stroke.eps' where profsymbol3 like '%Equal Housing Lender Symbol%'

											update tblArtMerge set profsymbol1='O.NAHREP.Stroke.eps' where profsymbol1 like '%NAHREP Symbol%'
											update tblArtMerge set profsymbol2='O.NAHREP.Stroke.eps' where profsymbol2 like '%NAHREP Symbol%'
											update tblArtMerge set profsymbol3='O.NAHREP.Stroke.eps' where profsymbol3 like '%NAHREP Symbol%'

											update tblArtMerge set profsymbol1='Facebook.Stroke.eps' where profsymbol1 like '%facebook%'
											update tblArtMerge set profsymbol2='Facebook.Stroke.eps' where profsymbol2 like '%facebook%'
											update tblArtMerge set profsymbol3='Facebook.Stroke.eps' where profsymbol3 like '%facebook%'

											update tblArtMerge set profsymbol1='LinkedIn.Stroke.eps' where profsymbol1 like '%LinkedIn%'
											update tblArtMerge set profsymbol2='LinkedIn.Stroke.eps' where profsymbol2 like '%LinkedIn%'
											update tblArtMerge set profsymbol3='LinkedIn.Stroke.eps' where profsymbol3 like '%LinkedIn%'

											update tblArtMerge set profsymbol1='SFR.Stroke.eps' where profsymbol1 like '%SFR%'
											update tblArtMerge set profsymbol2='SFR.Stroke.eps' where profsymbol2 like '%SFR%'
											update tblArtMerge set profsymbol3='SFR.Stroke.eps' where profsymbol3 like '%SFR%'

											update tblArtMerge set profsymbol1='Twitter.Stroke.eps' where profsymbol1 like '%Twitter%'
											update tblArtMerge set profsymbol2='Twitter.Stroke.eps' where profsymbol2 like '%Twitter%'
											update tblArtMerge set profsymbol3='Twitter.Stroke.eps' where profsymbol3 like '%Twitter%'

	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.


	--BKGND_OLD
	update tblArtMerge
	set bkgnd_old=x.artBackgroundImageName
	from tblArtMerge a INNER JOIN  tblProducts x
	on a.productID=x.productID
	where a.bkgnd_old is NULL
	and x.artBackgroundImageName is NOT NULL

	-- FIX NCC ROWS
	update tblArtMerge
	set yourName=NULL
	where orderNo in
	(select orderNo from tblORders where orderID in
	(select orderID from tblOrders_Products where productID in
	(select productID from tblProducts where productCompany='NCC')))

	--ENTERDATE
	update tblArtMerge
	set enterDate=convert(varchar(255),datepart(month,getdate()))+'/'+convert(varchar(255),datepart(day,getdate()))+'/'+convert(varchar(255),datepart(year,getdate()))
	where enterDate is NULL AND orderNo is NOT NULL

	--DELETE STOCK-ONLY ORDERS
					-- just a double check.
	delete from tblArtMerge
	where orderNo in
	(select distinct OrderNo from tblOrders 
	where orderType='Stock')

	--DELETE NULL ORDERNO'S
	delete from tblArtMerge
	where orderNo is NULL

	--  UPDATE 02/02/12  -- we needed to take out the code below to only show "IN ART" orders.
	----DELETE UNWANTED ORDERSTATUS JOBS
	--delete from tblArtMerge
	--where orderNo not in
	--(select distinct orderNo from tblOrders 
	--where orderStatus='in house' and orderNo is NOT NULL
	--or
	--orderStatus='Waiting For Payment' and orderNo is NOT NULL)

	--select distinct orderStatus from tblOrders where orderStatus like '%wait%'
	--DELETE NAMEBADGE-ONLY ORDERS
					--  ***(this effectively searches for custom orders that have nothing other than Name Badges in them)
	delete from tblArtMerge
	where orderNo not in
			(select distinct orderNo from tblOrders a where 
			datediff(dd, a.orderDate,getdate())<170
			and a.orderStatus<>'delivered'
			and a.orderStatus<>'cancelled'
			and a.orderStatus not like '%transit%'
			and a.orderStatus not like '%DOCK%'
			and a.orderType='Custom'
			and a.orderID in
						(select distinct orderID from tblOrders_Products 
						where deleteX<>'yes' and productCode not like '%NB%' 
						and orderID is not null))

	/*
	--53sec:
	--DELETE NCC-CUSTOM-ONLY ORDERS
	delete from tblArtMerge
	where orderNo in
				(select distinct orderNo from tblOrders where orderType='Custom'
				and orderID in
							(select distinct orderID from tblOrders_Products
							where deleteX<>'yes' and productID in
											(select distinct productID from tblProducts where
											productCompany='NCC')))
	and orderNo not in
				(select distinct orderNo from tblOrders where orderType='Custom'
				and orderID in
							(select distinct orderID from tblOrders_Products
							where deleteX<>'yes' and productID not in
											(select distinct productID from tblProducts where
											productCompany='NCC')))  
	*/

	-- 4. [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Clean data so that it is in the format that Art Dept. requires.

	-- FIX productQuantity

	update tblArtMerge
	set productQuantity=productQuantity*500
	where productCode like 'BC%'
	and productQuantity is NOT NULL

	update tblArtMerge
	set productQuantity=productQuantity*250
	where productCode like 'GNNC%'
	and productQuantity is NOT NULL

	update tblArtMerge
	set productQuantity=productQuantity*100
	where productCode not like 'BC%'
	and productCode not like 'GNNC%'
	and productCode not like 'HLBG%'
	and productQuantity is NOT NULL

	-- FIX bkgnd_new

	update tblArtMerge
	set bkgnd_new=productCode+'.gp'
	where productCode like 'BC%'
	or productName like '%calendar%'
	or productName like '%Halloween Bag%'

	update tblArtMerge
	set bkgnd_new=productCode+'.eps'
	where productCode not like 'BC%'
	and productName not like '%calendar%'
	and productName not like '%Halloween Bag%'

	-- KILL projectName

	update tblArtMerge
	set projectName=NULL

	-- FIX bkgnd_old

	update tblArtMerge
	set bkgnd_old=replace(replace(bkgnd_old,'QC','QS'),'QM','QS')
	where productCode like 'FB%'
	or productCode like 'BB%'
	or productCode like 'HK%'
	or productCode like 'BK%'

	update tblArtMerge
	set bkgnd_old=replace(bkgnd_old,'SP','')
	where bkgnd_old like '%SP'

	-- FIX sequencing for orders that have more than 1 custom product in the order  (XXXXX_1, XXXXX_2, etc.)

	delete from tblArtMerge_Sequencer

	insert into tblArtMerge_Sequencer (PKID, countPKID)
	select pkid as 'PKID', count(pkid) as 'countPKID'
	from tblArtMerge
	group by pkid
	having count(PKID)>1
	order by count(pkid) desc

	update tblArtMerge
	set sequencer=b.countPKID
	from tblArtMerge a
	inner join tblArtMerge_Sequencer b
		ON a.PKID=b.PKID

	update tblArtMerge_Sequencer
	set lowestArb=b.arb
	from tblArtMerge_Sequencer a 
	INNER JOIN  tblArtMerge b ON a.pkid=b.pkid
	where b.arb in (select top 1 arb from tblArtMerge
		where pkid=a.pkid order by arb asc)


	update tblArtMerge
	set pkid=convert(varchar(50),a.pkid)+'_'+convert(varchar(50),(a.arb-b.lowestArb+1))
	from tblArtMerge a
	INNER JOIN tblArtMerge_Sequencer b ON a.pkid=b.pkid

	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.

	--SET NULLS: for comparitive clauses to follow.
	update tblArtMerge set logo1='' where logo1 is NULL
	update tblArtMerge set logo2='' where logo2 is NULL
	update tblArtMerge set photo1='' where photo1 is NULL
	update tblArtMerge set photo2='' where photo2 is NULL
	update tblArtMerge set overflow1='' where overflow1 is NULL
	update tblArtMerge set overflow2='' where overflow2 is NULL
	update tblArtMerge set overflow3='' where overflow3 is NULL
	update tblArtMerge set overflow4='' where overflow4 is NULL
	update tblArtMerge set overflow5='' where overflow5 is NULL
	update tblArtMerge set previousJobArt='' where previousJobArt is NULL
	update tblArtMerge set previousJobInfo='' where previousJobInfo is NULL
	update tblArtMerge set artInstructions='' where artInstructions is NULL


	--FILES >>>>>>>>>>>>> next 3 queries take 10m


	--- PART 1/3 (LOGO): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ******** LOGO1 ************
	update tblArtMerge
	set logo1=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	----and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblArtMerge
	set logo1=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblArtMerge
	set logo1=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblArtMerge
	set logo1=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblArtMerge
	set logo1=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	-- ******** LOGO2 ************
	update tblArtMerge
	set logo2=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblArtMerge
	set logo2=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblArtMerge
	set logo2=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblArtMerge
	set logo2=b.textValue
	from tblArtMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblArtMerge
	set logo2=b.textValue
	from tblArtMerge a 
	INNER JOIN tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	--- PART 2/3 (PHOTO): ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ******** PHOTO1 ************
	update tblArtMerge
	set photo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblArtMerge
	set photo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b 
		ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblArtMerge
	set photo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b 
		ON a.ordersProductsID=b.ordersProductsID
	where	b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblArtMerge
	set photo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblArtMerge
	set photo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	-- ******** PHOTO2 ************
	update tblArtMerge
	set photo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblArtMerge
	set photo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblArtMerge
	set photo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblArtMerge
	set photo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblArtMerge
	set photo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	--- PART 3/3 (OVERFLOW): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- ******** OVERFLOW1 ************
	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	-- ******** OVERFLOW2 ************
	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblArtMerge
	set overflow2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	-- ******** OVERFLOW3 ************
	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a 
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	update tblArtMerge
	set overflow3=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue

	-- ******** OVERFLOW4 ************
	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue


	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue


	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue


	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	update tblArtMerge
	set overflow4=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue

	-- ******** OVERFLOW5 ************
	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow5=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>''
	and a.overflow4<>''
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	-- ******** THE CRAZIES ************

	--CRAZY LOGOS
	update tblArtMerge
	set logo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like '%logo%'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set logo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like '%logo%'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	--CRAZY PHOTOS
	update tblArtMerge
	set photo1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like '%phot%'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set photo2=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue like '%phot%'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	--CRAZY UNKNOWN FILES
	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue is NOT NULL
	and b.textValue <>''
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue is NOT NULL
	and b.textValue <>''
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue is NOT NULL
	and b.textValue <>''
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption like '%File Name%'
	and b.textValue is NOT NULL
	and b.textValue <>''
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>'' 
	and a.overflow4='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblArtMerge
	set overflow1=b.textValue
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption like '%File Name%'
	and b.textValue is NOT NULL
	and b.textValue <>''
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3<>'' 
	and a.overflow4<>'' 
	and a.overflow5='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	-- ******** THE INSTRUCTIONS ************

	update tblArtMerge
	set previousJobArt=left(b.textValue,250)
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where  b.optionCaption='Previous Job Art'
	and b.textValue is NOT NULL
	and b.textValue<>''
	and a.previousJobArt<>b.textValue

	update tblArtMerge
	set previousJobInfo=left(b.textValue,250)
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON  a.ordersProductsID=b.ordersProductsID
	where b.optionCaption='Previous Job Info'
	and b.textValue is NOT NULL
	and b.textValue<>''
	and a.previousJobInfo<>b.textValue

	update tblArtMerge
	set artInstructions=left(b.textValue,250)
	--select a.*, b.*
	from tblArtMerge a
	INNER JOIN  tblOrdersProducts_ProductOptions b ON a.ordersProductsID=b.ordersProductsID
	where b.optionCaption='Art Instructions'
	and b.textValue is NOT NULL
	and b.textValue<>''
	and a.artInstructions<>b.textValue

	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK ENDS HERE.

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH