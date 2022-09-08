--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~       B E G I N     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE PROCEDURE [dbo].[usp_superMerge]
AS
SET NOCOUNT ON;

BEGIN TRY
	-- 1.  [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Refresh Table

	TRUNCATE TABLE tblSuperMerge
	--select * from tblSuperMerge where orderNo='HOM269900'
	--select * into tblSuperMerge from tblArtMerge
	--slow spots:  c to d, l to m, m to n.  about 4min each on 3/6/12, jf.


	--2. [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Populate table with initial values

	INSERT INTO tblSuperMerge (PKID, orderNo, ordersProductsID, productID, productCode, productName, productQuantity)
	SELECT DISTINCT SUBSTRING(a.orderNo,4,7), a.orderNo, b.[ID], b.productID, b.productCode, b.productName, b.productQuantity
	from tblOrders a INNER JOIN tblOrders_Products b
	on a.orderID=b.orderID 
	where b.deleteX<>'yes'
	and b.processType = 'Custom'
	AND SUBSTRING(b.productCode, 1, 2) <> 'NB'
	--//The following clause was removed upon the introduction of processType on 11/4/15 JF
	--and b.productID in
	--        (select distinct productID from tblProducts where productType='Custom' and productCode not like 'NB%')
	and a.orderType='Custom'
	and substring(a.orderNo,4,7) not in
			(select distinct PKID from tblSuperMerge where PKID is NOT NULL)
	and datediff(dd,a.orderDate,getdate())<160
	and a.orderStatus<>'delivered'
	and a.orderStatus<>'cancelled'
	and a.orderStatus<>'failed'
	and a.orderStatus not like '%transit%'
	and a.orderStatus not like '%DOCK%'
	AND (a.displayPaymentStatus = 'Good' OR a.displayPaymentStatus = 'Waiting For Payment')


	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////


	--AND b.productCode NOT IN
	--	(SELECT DISTINCT productCode
	--	FROM tblProducts
	--	WHERE (SUBSTRING(productCode, 3, 2) = 'QC' OR SUBSTRING(productCode, 3, 2) = 'QM' OR SUBSTRING(productCode, 3, 2) = 'FC')
	--	AND 
	--	(SUBSTRING(productCode, 1, 2) = 'FB' 
	--	OR SUBSTRING(productCode, 1, 2) = 'BB' OR SUBSTRING(productCode, 1, 2) = 'BK' 
	--	OR SUBSTRING(productCode, 1, 2) = 'HY' OR SUBSTRING(productCode, 1, 2) = 'PG' 
	--	OR SUBSTRING(productCode, 1, 2) = 'NS' OR SUBSTRING(productCode, 1, 2) = 'VB'))


	AND b.ID NOT IN
		(SELECT DISTINCT ID
		FROM tblOrders_Products
		WHERE   (SUBSTRING(productCode, 3, 2) = 'QC' OR SUBSTRING(productCode, 3, 2) = 'QM' OR SUBSTRING(productCode, 3, 2) = 'FC')
				AND 
				(
				SUBSTRING(productCode, 1, 2) = 'FB' 
				OR SUBSTRING(productCode, 1, 2) = 'BB' OR SUBSTRING(productCode, 1, 2) = 'BK' 
				OR SUBSTRING(productCode, 1, 2) = 'HY' OR SUBSTRING(productCode, 1, 2) = 'PG' 
				OR SUBSTRING(productCode, 1, 2) = 'NS' OR SUBSTRING(productCode, 1, 2) = 'VB'
				)
		AND ID NOT IN
			(SELECT DISTINCT ordersProductsID
			FROM tblOrdersProducts_productOptions
			WHERE deleteX <> 'yes'
			AND optionCaption = 'OPC')
		)


	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////////////////////////////////


	--// the following OR clause added 11/10/15 to accomodate NB00SU-001, and all future NB exceptions
	OR
		b.deleteX<>'yes'
		and b.processType = 'Custom'
		AND productCode = 'NB00SU-001'
		--//The following clause was removed upon the introduction of processType on 11/4/15 JF
		--and b.productID in
		--        (select distinct productID from tblProducts where productType='Custom' and productCode not like 'NB%')
		and a.orderType='Custom'
		and substring(a.orderNo,4,7) not in
				(select distinct PKID from tblSuperMerge where PKID is NOT NULL)
		and datediff(dd,a.orderDate,getdate())<160
		and a.orderStatus<>'delivered'
		and a.orderStatus<>'cancelled'
		and a.orderStatus not like '%transit%'
		and a.orderStatus not like '%DOCK%'
	order by SUBSTRING(a.orderNo,4,7)

	-- 3.  [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[   Do field updates

	--INPUT 1 (yourname)
	update tblSuperMerge
	set yourName=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 1%'
	and a.yourname is NULL
	and p.deleteX<>'yes'

	--INPUT 2 (yourcompany)
	update tblSuperMerge
	set yourcompany=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where 
	(convert(varchar(255), p.optionCaption) like 'Info Line 2%' OR convert(varchar(255), p.optionCaption) like '%Background Color%')
	and p.deleteX<>'yes'

	--INPUT 3 (input1)
	update tblSuperMerge
	set input1=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where
	(convert(varchar(255), p.optionCaption) like 'Info Line 3%' OR convert(varchar(255), p.optionCaption) like '%Text Color%')
	and p.deleteX<>'yes'

	--INPUT 4 /a
	update tblSuperMerge
	set input2=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where 
	(convert(varchar(255), p.optionCaption) like 'Info Line 4%'  OR convert(varchar(255), p.optionGroupCaption) like '%Frame%')
	and p.deleteX<>'yes'

	--INPUT 5 /a
	update tblSuperMerge
	set input3=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where 
	(convert(varchar(255), p.optionCaption) like 'Info Line 5%'  OR convert(varchar(255), p.optionGroupCaption) like '%Shape%')
	and p.deleteX<>'yes'

	--INPUT 6 /a
	update tblSuperMerge
	set input4=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 6%'
	and p.deleteX<>'yes'

	--INPUT 7
	update tblSuperMerge
	set input5=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 7%'
	and p.deleteX<>'yes'

	--INPUT 8
	update tblSuperMerge
	set input6=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 8%'
	and p.deleteX<>'yes'

	--INPUT 9
	update tblSuperMerge
	set input7=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 9%'
	and p.deleteX<>'yes'

	--INPUT 10
	update tblSuperMerge
	set input8=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Info Line 10%'
	and p.deleteX<>'yes'

	update tblSuperMerge
	set marketCenterName=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Market Center Name%'
	and p.deleteX<>'yes'

	--projectDesc
	update tblSuperMerge
	set projectDesc=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Project Description%'
	and p.deleteX<>'yes'

	--csz
	update tblSuperMerge
	set csz=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'City/state/zip%'
	and p.deleteX<>'yes'

	--yourName2
	update tblSuperMerge
	set yourName2=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Your name%'
	and p.deleteX<>'yes'

	--streetAddress
	update tblSuperMerge
	set streetAddress=convert(varchar(255), p.textValue)
	from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
	on a.ordersProductsID=p.ordersProductsID
	where convert(varchar(255), p.optionCaption) like 'Street address%'
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


											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=3
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=4
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=5
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=6
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=7
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=8
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=9
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=10
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=11
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=12
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=13
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=14
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=15
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=141
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionID=155
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%facebook%'
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%linkedin%'
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%SFR%'
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol1=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p 
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol1 is NULL
											and p.optionCaption like '%Twitter%'
											and p.deleteX<>'yes'


											--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=3
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=4
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=5
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=6
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=7
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=8
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=9
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=10
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=11
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=12
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=13
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=14
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=15
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=141
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=155
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%facebook%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%linkedin%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'


											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%SFR%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol2=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol2 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%Twitter%'
											and p.optionCaption<>a.profsymbol1
											and p.deleteX<>'yes'

											--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=3
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=4
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=5
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=6
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=7
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=8
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=9
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=10
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=11
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=12
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=13
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=14
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=15
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=141
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionID=155
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%Facebook%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%linkedin%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
											on a.ordersProductsID=p.ordersProductsID
											where a.profsymbol3 is NULL
											and a.profsymbol1 is NOT NULL
											and p.optionCaption like '%SFR%'
											and p.optionCaption<>a.profsymbol1
											and a.profsymbol2 is NOT NULL
											and p.optionCaption<>a.profsymbol2
											and p.deleteX<>'yes'

											update tblSuperMerge
											set profsymbol3=p.optionCaption
											from tblSuperMerge a INNER JOIN tblOrdersProducts_ProductOptions p
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


											update tblSuperMerge set profsymbol1='A.Realtor.R.Stroke.eps' where profsymbol1 like '%Realtor Symbol%'
											update tblSuperMerge set profsymbol2='A.Realtor.R.Stroke.eps' where profsymbol2 like '%Realtor Symbol%'
											update tblSuperMerge set profsymbol3='A.Realtor.R.Stroke.eps' where profsymbol3 like '%Realtor Symbol%'

											update tblSuperMerge set profsymbol1='B.EqualHousing.Stroke.eps' where profsymbol1 like '%Equal Housing Opportunity Symbol%'
											update tblSuperMerge set profsymbol2='B.EqualHousing.Stroke.eps' where profsymbol2 like '%Equal Housing Opportunity Symbol%'
											update tblSuperMerge set profsymbol3='B.EqualHousing.Stroke.eps' where profsymbol3 like '%Equal Housing Opportunity Symbol%'

											update tblSuperMerge set profsymbol1='C.Realtor.MLS.Stroke.eps' where profsymbol1 like '%Realtor - MLS Combo Symbol%'
											update tblSuperMerge set profsymbol2='C.Realtor.MLS.Stroke.eps' where profsymbol2 like '%Realtor - MLS Combo Symbol%'
											update tblSuperMerge set profsymbol3='C.Realtor.MLS.Stroke.eps' where profsymbol3 like '%Realtor - MLS Combo Symbol%'

											update tblSuperMerge set profsymbol1='D.abr.Stroke.eps' where profsymbol1 like '%ABR Symbol%'
											update tblSuperMerge set profsymbol2='D.abr.Stroke.eps' where profsymbol2 like '%ABR Symbol%'
											update tblSuperMerge set profsymbol3='D.abr.Stroke.eps' where profsymbol3 like '%ABR Symbol%'

											update tblSuperMerge set profsymbol1='E.crs.Stroke.eps' where profsymbol1 like '%CRS Symbol%'
											update tblSuperMerge set profsymbol2='E.crs.Stroke.eps' where profsymbol2 like '%CRS Symbol%'
											update tblSuperMerge set profsymbol3='E.crs.Stroke.eps' where profsymbol3 like '%CRS Symbol%'

											update tblSuperMerge set profsymbol1='F.gri.Stroke.eps' where profsymbol1 like '%GRI Symbol%'
											update tblSuperMerge set profsymbol2='F.gri.Stroke.eps' where profsymbol2 like '%GRI Symbol%'
											update tblSuperMerge set profsymbol3='F.gri.Stroke.eps' where profsymbol3 like '%GRI Symbol%'

											update tblSuperMerge set profsymbol1='G.crb.Stroke.eps' where profsymbol1 like '%CRB Symbol%'
											update tblSuperMerge set profsymbol2='G.crb.Stroke.eps' where profsymbol2 like '%CRB Symbol%'
											update tblSuperMerge set profsymbol3='G.crb.Stroke.eps' where profsymbol3 like '%CRB Symbol%'

											update tblSuperMerge set profsymbol1='H.WCI.Stroke.eps' where profsymbol1 like '%WCR Symbol%'
											update tblSuperMerge set profsymbol2='H.WCI.Stroke.eps' where profsymbol2 like '%WCR Symbol%'
											update tblSuperMerge set profsymbol3='H.WCI.Stroke.eps' where profsymbol3 like '%WCR Symbol%'

											update tblSuperMerge set profsymbol1='I.crp.stroke.eps' where profsymbol1 like '%CRP Symbol%'
											update tblSuperMerge set profsymbol2='I.crp.stroke.eps' where profsymbol2 like '%CRP Symbol%'
											update tblSuperMerge set profsymbol3='I.crp.stroke.eps' where profsymbol3 like '%CRP Symbol%'

											update tblSuperMerge set profsymbol1='J.MLS.Stroked.eps' where profsymbol1 like '%MLS Symbol%'
											update tblSuperMerge set profsymbol2='J.MLS.Stroked.eps' where profsymbol2 like '%MLS Symbol%'
											update tblSuperMerge set profsymbol3='J.MLS.Stroked.eps' where profsymbol3 like '%MLS Symbol%'

											update tblSuperMerge set profsymbol1='K.epro.Stroke.eps' where profsymbol1 like '%e-Pro Symbol%'
											update tblSuperMerge set profsymbol2='K.epro.Stroke.eps' where profsymbol2 like '%e-Pro Symbol%'
											update tblSuperMerge set profsymbol3='K.epro.Stroke.eps' where profsymbol3 like '%e-Pro Symbol%'

											update tblSuperMerge set profsymbol1='L.sres.Stroke.eps' where profsymbol1 like '%SRES Symbol%'
											update tblSuperMerge set profsymbol2='L.sres.Stroke.eps' where profsymbol2 like '%SRES Symbol%'
											update tblSuperMerge set profsymbol3='L.sres.Stroke.eps' where profsymbol3 like '%SRES Symbol%'

											update tblSuperMerge set profsymbol1='M.FDIC.Stroke.eps' where profsymbol1 like '%FDIC Symbol%'
											update tblSuperMerge set profsymbol2='M.FDIC.Stroke.eps' where profsymbol2 like '%FDIC Symbol%'
											update tblSuperMerge set profsymbol3='M.FDIC.Stroke.eps' where profsymbol3 like '%FDIC Symbol%'

											update tblSuperMerge set profsymbol1='N.EHLender.Stroke.eps' where profsymbol1 like '%Equal Housing Lender Symbol%'
											update tblSuperMerge set profsymbol2='N.EHLender.Stroke.eps' where profsymbol2 like '%Equal Housing Lender Symbol%'
											update tblSuperMerge set profsymbol3='N.EHLender.Stroke.eps' where profsymbol3 like '%Equal Housing Lender Symbol%'

											update tblSuperMerge set profsymbol1='O.NAHREP.Stroke.eps' where profsymbol1 like '%NAHREP Symbol%'
											update tblSuperMerge set profsymbol2='O.NAHREP.Stroke.eps' where profsymbol2 like '%NAHREP Symbol%'
											update tblSuperMerge set profsymbol3='O.NAHREP.Stroke.eps' where profsymbol3 like '%NAHREP Symbol%'

											update tblSuperMerge set profsymbol1='Facebook.Stroke.eps' where profsymbol1 like '%facebook%'
											update tblSuperMerge set profsymbol2='Facebook.Stroke.eps' where profsymbol2 like '%facebook%'
											update tblSuperMerge set profsymbol3='Facebook.Stroke.eps' where profsymbol3 like '%facebook%'

											update tblSuperMerge set profsymbol1='LinkedIn.Stroke.eps' where profsymbol1 like '%linkedin%'
											update tblSuperMerge set profsymbol2='LinkedIn.Stroke.eps' where profsymbol2 like '%linkedin%'
											update tblSuperMerge set profsymbol3='LinkedIn.Stroke.eps' where profsymbol3 like '%linkedin%'

											update tblSuperMerge set profsymbol1='SFR.Stroke.eps' where profsymbol1 like '%SFR%'
											update tblSuperMerge set profsymbol2='SFR.Stroke.eps' where profsymbol2 like '%SFR%'
											update tblSuperMerge set profsymbol3='SFR.Stroke.eps' where profsymbol3 like '%SFR%'

											update tblSuperMerge set profsymbol1='Twitter.Stroke.eps' where profsymbol1 like '%Twitter%'
											update tblSuperMerge set profsymbol2='Twitter.Stroke.eps' where profsymbol2 like '%Twitter%'
											update tblSuperMerge set profsymbol3='Twitter.Stroke.eps' where profsymbol3 like '%Twitter%'

	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## SYMBOL WORK ENDS HERE.

	--BKGND_OLD
	update tblSuperMerge
	set bkgnd_old=x.artBackgroundImageName
	from tblSuperMerge a INNER JOIN tblProducts x
	on a.productID=x.productID
	where a.bkgnd_old is NULL
	and x.artBackgroundImageName is NOT NULL

	-- FIX NCC ROWS
	update tblSuperMerge
	set yourName=NULL
	where orderNo in
	(select orderNo from tblORders where orderID in
	(select orderID from tblOrders_Products where productID in
	(select productID from tblProducts where productCompany='NCC')))

	--ENTERDATE
	update tblSuperMerge
	set enterDate=convert(varchar(255),datepart(month,getdate()))+'/'+convert(varchar(255),datepart(day,getdate()))+'/'+convert(varchar(255),datepart(year,getdate()))
	where enterDate is NULL AND orderNo is NOT NULL

	--DELETE STOCK-ONLY ORDERS
					-- just a double check.
	delete from tblSuperMerge
	where orderNo in
	(select distinct OrderNo from tblOrders 
	where orderType='Stock')

	--DELETE NULL ORDERNO'S
	delete from tblSuperMerge
	where orderNo is NULL


	--  UPDATE 02/02/12  -- we needed to take out the code below to only show "IN ART" orders.
	----DELETE UNWANTED ORDERSTATUS JOBS
	--delete from tblSuperMerge
	--where orderNo not in
	--(select distinct orderNo from tblOrders 
	--where orderStatus='in house' and orderNo is NOT NULL
	--or
	--orderStatus='Waiting For Payment' and orderNo is NOT NULL)

	--select distinct orderStatus from tblOrders where orderStatus like '%wait%'
	--DELETE NAMEBADGE-ONLY ORDERS
					--  ***(this effectively searches for custom orders that have nothing other than Name Badges in them)
	delete from tblSuperMerge
	where orderNo NOT IN
			(SELECT DISTINCT orderNo 
			FROM tblOrders a 
			WHERE 
			DATEDIFF(dd, a.orderDate, GETDATE()) < 170
			and a.orderStatus <> 'delivered'
			and a.orderStatus <> 'cancelled'
			and a.orderStatus not like '%transit%'
			and a.orderStatus not like '%DOCK%'
			and a.orderType = 'Custom'
			and a.orderID IN
						(SELECT DISTINCT orderID 
						FROM tblOrders_Products 
						WHERE deleteX <> 'yes' 
						and productCode NOT LIKE 'NB%' 
						and orderID is not null)
			)
	AND productCode <> 'NB00SU-001'

	/*
	--53sec:
	--DELETE NCC-CUSTOM-ONLY ORDERS
	delete from tblSuperMerge
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

	update tblSuperMerge
	set productQuantity=productQuantity*500
	where productCode like 'BC%'
	and productQuantity is NOT NULL

	update tblSuperMerge
	set productQuantity=productQuantity*500
	where productCode like 'KWBC%'
	and productQuantity is NOT NULL

	update tblSuperMerge
	set productQuantity=productQuantity*250
	where productCode like 'GNNC%'
	and productQuantity is NOT NULL

	update tblSuperMerge
	set productQuantity=productQuantity*100
	where productCode not like 'BC%'
	and productCode not like 'GNNC%'
	and productCode not like 'HLBG%'
	and productQuantity is NOT NULL



	-- FIX bkgnd_new
	--Follow all the rules that did apply to column c, and add/change, extensions should be ".gp" for all products, 
	--except products starting with BB, FB, BK and HY, they should have the extension ".eps". 
	--All products starting with BB, FB, BK, and HY should have QC changed to QS and QM changed to QS.

	--select * from tblSuperMerge WHERE bkgnd_new LIKE 'PG%'

	update tblSuperMerge
	set bkgnd_new=''
	where bkgnd_new is NULL

	update tblSuperMerge
	set bkgnd_new=productCode+'.gp'
	where productCode not like 'BB%'
	and productCode not like 'FB%'
	and productCode not like 'BK%'
	and productCode not like 'HY%'
	and bkgnd_new not like '%.gp'
	and bkgnd_new not like '%.eps'

	update tblSuperMerge
	set bkgnd_new=productCode+'.eps'
	where productCode like 'BB%'  and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'
	or productCode  like 'FB%'  and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'
	or productCode like 'BK%'  and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'
	or productCode like 'HY%'  and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'

	update tblSuperMerge
	set bkgnd_new=productCode+'.gp'
	where productCode like 'BC%' and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'
	or productName like '%calendar%' and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'
	or productName like '%Halloween Bag%' and bkgnd_new not like '%.gp' and bkgnd_new not like '%.eps'

	update tblSuperMerge
	set bkgnd_new=productCode+'.eps'
	where productCode not like 'BC%'
	and productName not like '%calendar%'
	and productName not like '%Halloween Bag%'
	and bkgnd_new not like '%.gp'
	and bkgnd_new not like '%.eps'

	-- added this fix for PG, 2/3/16, JF.
	UPDATE tblSuperMerge
	SET bkgnd_new = REPLACE(bkgnd_new,'.gp','.eps')
	WHERE bkgnd_new like 'PG%'


	--All products starting with BB, FB, BK, and HY should have QC changed to QS and QM changed to QS.
	--added PG to the mix on 2/2/16, JF.

	update tblSuperMerge
	set bkgnd_new=replace(bkgnd_new,'QC','QS')
	where bkgnd_new like 'BB%'
	or bkgnd_new  like 'FB%'
	or bkgnd_new  like 'BK%'
	or bkgnd_new  like 'HY%'
	or bkgnd_new  like 'PG%'

	update tblSuperMerge
	set bkgnd_new=replace(bkgnd_new,'QM','QS')
	where bkgnd_new like 'BB%'
	or bkgnd_new  like 'FB%'
	or bkgnd_new  like 'BK%'
	or bkgnd_new  like 'HY%'
	or bkgnd_new  like 'PG%'




	-- KILL projectName

	update tblSuperMerge
	set projectName=NULL

	-- FIX bkgnd_old

	update tblSuperMerge
	set bkgnd_old=replace(replace(bkgnd_old,'QC','QS'),'QM','QS')
	where productCode like 'FB%'
	or productCode like 'BB%'
	or productCode like 'HK%'
	or productCode like 'BK%'

	update tblSuperMerge
	set bkgnd_old=replace(bkgnd_old,'SP','')
	where bkgnd_old like '%SP'



	-- FIX sequencing for orders that have more than 1 custom product in the order  (XXXXX_1, XXXXX_2, etc.)

	delete from tblSuperMerge_Sequencer
	--select * from tblSuperMerge_Sequencer

	insert into tblSuperMerge_Sequencer (PKID, countPKID)
	select pkid as 'PKID', count(pkid) as 'countPKID'
	--into tblSuperMerge_Sequencer
	from tblSuperMerge
	group by pkid
	having count(PKID)>1
	order by count(pkid)  desc

	update tblSuperMerge
	set sequencer=b.countPKID
	from tblSuperMerge a
	INNER JOIN tblSuperMerge_Sequencer b
		ON a.PKID=b.PKID

	update tblSuperMerge_Sequencer
	set lowestArb=b.arb
	from tblSuperMerge_Sequencer a
		INNER JOIN tblSuperMerge b
		ON a.pkid=b.pkid
	WHERE b.arb in (select top 1 arb from tblSuperMerge
	where pkid=a.pkid order by arb asc)


	update tblSuperMerge
	set pkid=convert(varchar(50),a.pkid)+'_'+convert(varchar(50),(a.arb-b.lowestArb+1))
	from tblSuperMerge a
	inner join tblSuperMerge_Sequencer b
		on a.pkid=b.pkid


	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.
	--##############--##############--##############--##############--##############--##############--##############--############## LOGO & PHOTO WORK STARTS HERE.

	--SET NULLS: for comparitive clauses to follow.
	update tblSuperMerge set logo1='' where logo1 is NULL
	update tblSuperMerge set logo2='' where logo2 is NULL
	update tblSuperMerge set photo1='' where photo1 is NULL
	update tblSuperMerge set photo2='' where photo2 is NULL
	update tblSuperMerge set overflow1='' where overflow1 is NULL
	update tblSuperMerge set overflow2='' where overflow2 is NULL
	update tblSuperMerge set overflow3='' where overflow3 is NULL
	update tblSuperMerge set overflow4='' where overflow4 is NULL
	update tblSuperMerge set overflow5='' where overflow5 is NULL
	update tblSuperMerge set previousJobArt='' where previousJobArt is NULL
	update tblSuperMerge set previousJobInfo='' where previousJobInfo is NULL
	update tblSuperMerge set artInstructions='' where artInstructions is NULL




	--- PART 1/1 (Create-Your-Own Merge Columns): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE tblSuperMerge SET backgroundFileName = '' WHERE backgroundFileName IS NULL
	UPDATE tblSuperMerge SET layoutFileName = '' WHERE layoutFileName IS NULL
	UPDATE tblSuperMerge SET productBack = '' WHERE productBack IS NULL
	UPDATE tblSuperMerge SET team1FileName = '' WHERE team1FileName IS NULL
	UPDATE tblSuperMerge SET team2FileName = '' WHERE team2FileName IS NULL
	UPDATE tblSuperMerge SET team3FileName = '' WHERE team3FileName IS NULL
	UPDATE tblSuperMerge SET team4FileName = '' WHERE team4FileName IS NULL
	UPDATE tblSuperMerge SET team5FileName = '' WHERE team5FileName IS NULL
	UPDATE tblSuperMerge SET team6FileName = '' WHERE team6FileName IS NULL

	update tblSuperMerge
	set backgroundFileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Background File Name'
	and b.deleteX<>'yes'
	and a.backgroundFileName<>b.textValue

	update tblSuperMerge
	set layoutFileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Layout File Name'
	and b.deleteX<>'yes'
	and a.layoutFileName<>b.textValue

	update tblSuperMerge
	set productBack=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Product Back'
	and b.deleteX<>'yes'
	and a.productBack<>b.textValue

	update tblSuperMerge
	set team1FileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 1 File Name'
	and b.deleteX<>'yes'
	and a.team1FileName<>b.textValue

	update tblSuperMerge
	set team2FileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 2 File Name'
	and b.deleteX<>'yes'
	and a.team2FileName<>b.textValue

	update tblSuperMerge
	set team3FileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 3 File Name'
	and b.deleteX<>'yes'
	and a.team3FileName<>b.textValue

	update tblSuperMerge
	set team4FileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 4 File Name'
	and b.deleteX<>'yes'
	and a.team4FileName<>b.textValue

	update tblSuperMerge
	set team5FileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 5 File Name'
	and b.deleteX<>'yes'
	and a.team5FileName<>b.textValue

	update tblSuperMerge
	set team6FileName=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption = 'Team 6 File Name'
	and b.deleteX<>'yes'
	and a.team6FileName<>b.textValue

	--- PART 1/3 (LOGO): --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ******** LOGO1 ************
	update tblSuperMerge
	set logo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	----and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblSuperMerge
	set logo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblSuperMerge
	set logo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblSuperMerge
	set logo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	update tblSuperMerge
	set logo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue

	-- ******** LOGO2 ************
	update tblSuperMerge
	set logo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblSuperMerge
	set logo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblSuperMerge
	set logo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblSuperMerge
	set logo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.logo1<>''
	and a.logo2=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue

	update tblSuperMerge
	set logo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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
	update tblSuperMerge
	set photo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblSuperMerge
	set photo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblSuperMerge
	set photo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblSuperMerge
	set photo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	update tblSuperMerge
	set photo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue

	-- ******** PHOTO2 ************
	update tblSuperMerge
	set photo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblSuperMerge
	set photo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblSuperMerge
	set photo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblSuperMerge
	set photo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.photo1<>''
	and a.photo2=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue

	update tblSuperMerge
	set photo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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
	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 1%'
	and b.textValue like '%-v%'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 2%'
	and b.textValue like '%-v%'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue


	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 3%'
	and b.textValue like '%-v%'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue


	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 4%'
	and b.textValue like '%-v%'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue


	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue


	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'logo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'photo%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.photo2<>b.textValue
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue

	update tblSuperMerge
	set overflow1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue


	-- ******** OVERFLOW2 ************
	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 1%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name 2%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 3%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 4%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%1.jpg%'
	and substring(right(b.textValue,5),1,2) like '1.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%2.jpg%'
	and substring(right(b.textValue,5),1,2) like '2.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%3.jpg%'
	and substring(right(b.textValue,5),1,2) like '3.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%4.jpg%'
	and substring(right(b.textValue,5),1,2) like '4.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	update tblSuperMerge
	set overflow2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like 'misc%'
	--and b.textValue like '%5.jpg%'
	and substring(right(b.textValue,5),1,2) like '5.'
	and a.overflow1<>''
	and a.overflow2='' 
	and b.deleteX<>'yes'
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue

	-- ******** OVERFLOW3 ************

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 1%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue


	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 2%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue


	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 3%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue


	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 4%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue


	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
	and a.overflow1<>''
	and a.overflow2<>''
	and a.overflow3='' 
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.logo2<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue


	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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
	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 1%'
	and b.textValue like '%-v%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 2%'
	and b.textValue like '%-v%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 3%'
	and b.textValue like '%-v%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name 4%'
	and b.textValue like '%-v%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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


	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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


	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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


	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like '%-v%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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
	update tblSuperMerge
	set logo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE b.optionCaption like '%File Name%'
	and b.textValue like '%logo%'
	and a.logo1=''
	and b.deleteX<>'yes'
	and a.logo1<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblSuperMerge
	set logo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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
	update tblSuperMerge
	set photo1=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
	and b.textValue like '%phot%'
	and a.photo1=''
	and b.deleteX<>'yes'
	and a.photo1<>b.textValue
	and a.overflow1<>b.textValue
	and a.overflow2<>b.textValue
	and a.overflow3<>b.textValue
	and a.overflow4<>b.textValue
	and a.overflow5<>b.textValue

	update tblSuperMerge
	set photo2=b.textValue
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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
	update tblSuperMerge
	set overflow1=LEFT(b.textValue, 255)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow2=LEFT(b.textValue, 255)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow3=LEFT(b.textValue, 255)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow4=LEFT(b.textValue, 255)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set overflow5=LEFT(b.textValue, 255)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption like '%File Name%'
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

	update tblSuperMerge
	set previousJobArt=left(b.textValue,250)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption='Previous Job Art'
	and b.textValue is NOT NULL
	and b.textValue<>''
	and a.previousJobArt<>b.textValue

	update tblSuperMerge
	set previousJobInfo=left(b.textValue,250)
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption='Previous Job Info'
	and b.textValue is NOT NULL
	and b.textValue<>''
	and a.previousJobInfo<>b.textValue

	update tblSuperMerge
	set artInstructions=left(b.textValue,250)
	--select a.*, b.*
	from tblSuperMerge a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.optionCaption='Art Instructions'
	and b.textValue is NOT NULL
	and b.textValue<>''
	and a.artInstructions<>b.textValue



	--// NEW ADDITIONAL CODE 3/2/12

	--REPLACE ALL IMAGE EXTENSIONS FROM ALL IMAGES

	--//LOGO
	update tblSuperMerge set logo1=replace(logo1,'.bmp','.eps') where logo1 like '%logo%' and logo1 like '%.bmp'
	update tblSuperMerge set logo1=replace(logo1,'.jpg','.eps') where logo1 like '%logo%' and logo1 like '%.jpg'
	update tblSuperMerge set logo1=replace(logo1,'.jpeg','.eps') where logo1 like '%logo%' and logo1 like '%.jpeg'
	update tblSuperMerge set logo1=replace(logo1,'.gif','.eps') where logo1 like '%logo%' and logo1 like '%.gif'
	update tblSuperMerge set logo1=replace(logo1,'.png','.eps') where logo1 like '%logo%' and logo1 like '%.png'
	update tblSuperMerge set logo1=replace(logo1,'.tif','.eps') where logo1 like '%logo%' and logo1 like '%.tif'
	update tblSuperMerge set logo1=replace(logo1,'.pdf','.eps') where logo1 like '%logo%' and logo1 like '%.pdf'
	update tblSuperMerge set logo1=replace(logo1,'.psd','.eps') where logo1 like '%logo%' and logo1 like '%.psd'

	update tblSuperMerge set logo2=replace(logo2,'.bmp','.eps') where logo2 like '%logo%' and logo2 like '%.bmp'
	update tblSuperMerge set logo2=replace(logo2,'.jpg','.eps') where logo2 like '%logo%' and logo2 like '%.jpg'
	update tblSuperMerge set logo2=replace(logo2,'.jpeg','.eps') where logo2 like '%logo%' and logo2 like '%.jpeg'
	update tblSuperMerge set logo2=replace(logo2,'.gif','.eps') where logo2 like '%logo%' and logo2 like '%.gif'
	update tblSuperMerge set logo2=replace(logo2,'.png','.eps') where logo2 like '%logo%' and logo2 like '%.png'
	update tblSuperMerge set logo2=replace(logo2,'.tif','.eps') where logo2 like '%logo%' and logo2 like '%.tif'
	update tblSuperMerge set logo2=replace(logo2,'.pdf','.eps') where logo2 like '%logo%' and logo2 like '%.pdf'
	update tblSuperMerge set logo2=replace(logo2,'.psd','.eps') where logo2 like '%logo%' and logo2 like '%.psd'

	update tblSuperMerge set overflow1=replace(overflow1,'.bmp','.eps') where overflow1 like '%logo%' and overflow1 like '%.bmp'
	update tblSuperMerge set overflow1=replace(overflow1,'.jpg','.eps') where overflow1 like '%logo%' and overflow1 like '%.jpg'
	update tblSuperMerge set overflow1=replace(overflow1,'.jpeg','.eps') where overflow1 like '%logo%' and overflow1 like '%.jpeg'
	update tblSuperMerge set overflow1=replace(overflow1,'.gif','.eps') where overflow1 like '%logo%' and overflow1 like '%.gif'
	update tblSuperMerge set overflow1=replace(overflow1,'.png','.eps') where overflow1 like '%logo%' and overflow1 like '%.png'
	update tblSuperMerge set overflow1=replace(overflow1,'.tif','.eps') where overflow1 like '%logo%' and overflow1 like '%.tif'
	update tblSuperMerge set overflow1=replace(overflow1,'.pdf','.eps') where overflow1 like '%logo%' and overflow1 like '%.pdf'
	update tblSuperMerge set overflow1=replace(overflow1,'.psd','.eps') where overflow1 like '%logo%' and overflow1 like '%.psd'

	update tblSuperMerge set overflow2=replace(overflow2,'.bmp','.eps') where overflow2 like '%logo%' and overflow2 like '%.bmp'
	update tblSuperMerge set overflow2=replace(overflow2,'.jpg','.eps') where overflow2 like '%logo%' and overflow2 like '%.jpg'
	update tblSuperMerge set overflow2=replace(overflow2,'.jpeg','.eps') where overflow2 like '%logo%' and overflow2 like '%.jpeg'
	update tblSuperMerge set overflow2=replace(overflow2,'.gif','.eps') where overflow2 like '%logo%' and overflow2 like '%.gif'
	update tblSuperMerge set overflow2=replace(overflow2,'.png','.eps') where overflow2 like '%logo%' and overflow2 like '%.png'
	update tblSuperMerge set overflow2=replace(overflow2,'.tif','.eps') where overflow2 like '%logo%' and overflow2 like '%.tif'
	update tblSuperMerge set overflow2=replace(overflow2,'.pdf','.eps') where overflow2 like '%logo%' and overflow2 like '%.pdf'
	update tblSuperMerge set overflow2=replace(overflow2,'.psd','.eps') where overflow2 like '%logo%' and overflow2 like '%.psd'

	update tblSuperMerge set overflow3=replace(overflow3,'.bmp','.eps') where overflow3 like '%logo%' and overflow3 like '%.bmp'
	update tblSuperMerge set overflow3=replace(overflow3,'.jpg','.eps') where overflow3 like '%logo%' and overflow3 like '%.jpg'
	update tblSuperMerge set overflow3=replace(overflow3,'.jpeg','.eps') where overflow3 like '%logo%' and overflow3 like '%.jpeg'
	update tblSuperMerge set overflow3=replace(overflow3,'.gif','.eps') where overflow3 like '%logo%' and overflow3 like '%.gif'
	update tblSuperMerge set overflow3=replace(overflow3,'.png','.eps') where overflow3 like '%logo%' and overflow3 like '%.png'
	update tblSuperMerge set overflow3=replace(overflow3,'.tif','.eps') where overflow3 like '%logo%' and overflow3 like '%.tif'
	update tblSuperMerge set overflow3=replace(overflow3,'.pdf','.eps') where overflow3 like '%logo%' and overflow3 like '%.pdf'
	update tblSuperMerge set overflow3=replace(overflow3,'.psd','.eps') where overflow3 like '%logo%' and overflow3 like '%.psd'

	update tblSuperMerge set overflow4=replace(overflow4,'.bmp','.eps') where overflow4 like '%logo%' and overflow4 like '%.bmp'
	update tblSuperMerge set overflow4=replace(overflow4,'.jpg','.eps') where overflow4 like '%logo%' and overflow4 like '%.jpg'
	update tblSuperMerge set overflow4=replace(overflow4,'.jpeg','.eps') where overflow4 like '%logo%' and overflow4 like '%.jpeg'
	update tblSuperMerge set overflow4=replace(overflow4,'.gif','.eps') where overflow4 like '%logo%' and overflow4 like '%.gif'
	update tblSuperMerge set overflow4=replace(overflow4,'.png','.eps') where overflow4 like '%logo%' and overflow4 like '%.png'
	update tblSuperMerge set overflow4=replace(overflow4,'.tif','.eps') where overflow4 like '%logo%' and overflow4 like '%.tif'
	update tblSuperMerge set overflow4=replace(overflow4,'.pdf','.eps') where overflow4 like '%logo%' and overflow4 like '%.pdf'
	update tblSuperMerge set overflow4=replace(overflow4,'.psd','.eps') where overflow4 like '%logo%' and overflow4 like '%.psd'

	update tblSuperMerge set overflow5=replace(overflow5,'.bmp','.eps') where overflow5 like '%logo%' and overflow5 like '%.bmp'
	update tblSuperMerge set overflow5=replace(overflow5,'.jpg','.eps') where overflow5 like '%logo%' and overflow5 like '%.jpg'
	update tblSuperMerge set overflow5=replace(overflow5,'.jpeg','.eps') where overflow5 like '%logo%' and overflow5 like '%.jpeg'
	update tblSuperMerge set overflow5=replace(overflow5,'.gif','.eps') where overflow5 like '%logo%' and overflow5 like '%.gif'
	update tblSuperMerge set overflow5=replace(overflow5,'.png','.eps') where overflow5 like '%logo%' and overflow5 like '%.png'
	update tblSuperMerge set overflow5=replace(overflow5,'.tif','.eps') where overflow5 like '%logo%' and overflow5 like '%.tif'
	update tblSuperMerge set overflow5=replace(overflow5,'.pdf','.eps') where overflow5 like '%logo%' and overflow5 like '%.pdf'
	update tblSuperMerge set overflow5=replace(overflow5,'.psd','.eps') where overflow5 like '%logo%' and overflow5 like '%.psd'


	--//PHOTO
	update tblSuperMerge set photo1=replace(photo1,'.bmp','.eps') where photo1 like '%photo%' and photo1 like '%.bmp'
	update tblSuperMerge set photo1=replace(photo1,'.jpg','.eps') where photo1 like '%photo%' and photo1 like '%.jpg'
	update tblSuperMerge set photo1=replace(photo1,'.jpeg','.eps') where photo1 like '%photo%' and photo1 like '%.jpeg'
	update tblSuperMerge set photo1=replace(photo1,'.gif','.eps') where photo1 like '%photo%' and photo1 like '%.gif'
	update tblSuperMerge set photo1=replace(photo1,'.png','.eps') where photo1 like '%photo%' and photo1 like '%.png'
	update tblSuperMerge set photo1=replace(photo1,'.tif','.eps') where photo1 like '%photo%' and photo1 like '%.tif'
	update tblSuperMerge set photo1=replace(photo1,'.pdf','.eps') where photo1 like '%photo%' and photo1 like '%.pdf'
	update tblSuperMerge set photo1=replace(photo1,'.psd','.eps') where photo1 like '%photo%' and photo1 like '%.psd'

	update tblSuperMerge set photo2=replace(photo2,'.bmp','.eps') where photo2 like '%photo%' and photo2 like '%.bmp'
	update tblSuperMerge set photo2=replace(photo2,'.jpg','.eps') where photo2 like '%photo%' and photo2 like '%.jpg'
	update tblSuperMerge set photo2=replace(photo2,'.jpeg','.eps') where photo2 like '%photo%' and photo2 like '%.jpeg'
	update tblSuperMerge set photo2=replace(photo2,'.gif','.eps') where photo2 like '%photo%' and photo2 like '%.gif'
	update tblSuperMerge set photo2=replace(photo2,'.png','.eps') where photo2 like '%photo%' and photo2 like '%.png'
	update tblSuperMerge set photo2=replace(photo2,'.tif','.eps') where photo2 like '%photo%' and photo2 like '%.tif'
	update tblSuperMerge set photo2=replace(photo2,'.pdf','.eps') where photo2 like '%photo%' and photo2 like '%.pdf'
	update tblSuperMerge set photo2=replace(photo2,'.psd','.eps') where photo2 like '%photo%' and photo2 like '%.psd'

	update tblSuperMerge set overflow1=replace(overflow1,'.bmp','.eps') where overflow1 like '%photo%' and overflow1 like '%.bmp'
	update tblSuperMerge set overflow1=replace(overflow1,'.jpg','.eps') where overflow1 like '%photo%' and overflow1 like '%.jpg'
	update tblSuperMerge set overflow1=replace(overflow1,'.jpeg','.eps') where overflow1 like '%photo%' and overflow1 like '%.jpeg'
	update tblSuperMerge set overflow1=replace(overflow1,'.gif','.eps') where overflow1 like '%photo%' and overflow1 like '%.gif'
	update tblSuperMerge set overflow1=replace(overflow1,'.png','.eps') where overflow1 like '%photo%' and overflow1 like '%.png'
	update tblSuperMerge set overflow1=replace(overflow1,'.tif','.eps') where overflow1 like '%photo%' and overflow1 like '%.tif'
	update tblSuperMerge set overflow1=replace(overflow1,'.pdf','.eps') where overflow1 like '%photo%' and overflow1 like '%.pdf'
	update tblSuperMerge set overflow1=replace(overflow1,'.psd','.eps') where overflow1 like '%photo%' and overflow1 like '%.psd'

	update tblSuperMerge set overflow2=replace(overflow2,'.bmp','.eps') where overflow2 like '%photo%' and overflow2 like '%.bmp'
	update tblSuperMerge set overflow2=replace(overflow2,'.jpg','.eps') where overflow2 like '%photo%' and overflow2 like '%.jpg'
	update tblSuperMerge set overflow2=replace(overflow2,'.jpeg','.eps') where overflow2 like '%photo%' and overflow2 like '%.jpeg'
	update tblSuperMerge set overflow2=replace(overflow2,'.gif','.eps') where overflow2 like '%photo%' and overflow2 like '%.gif'
	update tblSuperMerge set overflow2=replace(overflow2,'.png','.eps') where overflow2 like '%photo%' and overflow2 like '%.png'
	update tblSuperMerge set overflow2=replace(overflow2,'.tif','.eps') where overflow2 like '%photo%' and overflow2 like '%.tif'
	update tblSuperMerge set overflow2=replace(overflow2,'.pdf','.eps') where overflow2 like '%photo%' and overflow2 like '%.pdf'
	update tblSuperMerge set overflow2=replace(overflow2,'.psd','.eps') where overflow2 like '%photo%' and overflow2 like '%.psd'

	update tblSuperMerge set overflow3=replace(overflow3,'.bmp','.eps') where overflow3 like '%photo%' and overflow3 like '%.bmp'
	update tblSuperMerge set overflow3=replace(overflow3,'.jpg','.eps') where overflow3 like '%photo%' and overflow3 like '%.jpg'
	update tblSuperMerge set overflow3=replace(overflow3,'.jpeg','.eps') where overflow3 like '%photo%' and overflow3 like '%.jpeg'
	update tblSuperMerge set overflow3=replace(overflow3,'.gif','.eps') where overflow3 like '%photo%' and overflow3 like '%.gif'
	update tblSuperMerge set overflow3=replace(overflow3,'.png','.eps') where overflow3 like '%photo%' and overflow3 like '%.png'
	update tblSuperMerge set overflow3=replace(overflow3,'.tif','.eps') where overflow3 like '%photo%' and overflow3 like '%.tif'
	update tblSuperMerge set overflow3=replace(overflow3,'.pdf','.eps') where overflow3 like '%photo%' and overflow3 like '%.pdf'
	update tblSuperMerge set overflow3=replace(overflow3,'.psd','.eps') where overflow3 like '%photo%' and overflow3 like '%.psd'

	update tblSuperMerge set overflow4=replace(overflow4,'.bmp','.eps') where overflow4 like '%photo%' and overflow4 like '%.bmp'
	update tblSuperMerge set overflow4=replace(overflow4,'.jpg','.eps') where overflow4 like '%photo%' and overflow4 like '%.jpg'
	update tblSuperMerge set overflow4=replace(overflow4,'.jpeg','.eps') where overflow4 like '%photo%' and overflow4 like '%.jpeg'
	update tblSuperMerge set overflow4=replace(overflow4,'.gif','.eps') where overflow4 like '%photo%' and overflow4 like '%.gif'
	update tblSuperMerge set overflow4=replace(overflow4,'.png','.eps') where overflow4 like '%photo%' and overflow4 like '%.png'
	update tblSuperMerge set overflow4=replace(overflow4,'.tif','.eps') where overflow4 like '%photo%' and overflow4 like '%.tif'
	update tblSuperMerge set overflow4=replace(overflow4,'.pdf','.eps') where overflow4 like '%photo%' and overflow4 like '%.pdf'
	update tblSuperMerge set overflow4=replace(overflow4,'.psd','.eps') where overflow4 like '%photo%' and overflow4 like '%.psd'

	update tblSuperMerge set overflow5=replace(overflow5,'.bmp','.eps') where overflow5 like '%photo%' and overflow5 like '%.bmp'
	update tblSuperMerge set overflow5=replace(overflow5,'.jpg','.eps') where overflow5 like '%photo%' and overflow5 like '%.jpg'
	update tblSuperMerge set overflow5=replace(overflow5,'.jpeg','.eps') where overflow5 like '%photo%' and overflow5 like '%.jpeg'
	update tblSuperMerge set overflow5=replace(overflow5,'.gif','.eps') where overflow5 like '%photo%' and overflow5 like '%.gif'
	update tblSuperMerge set overflow5=replace(overflow5,'.png','.eps') where overflow5 like '%photo%' and overflow5 like '%.png'
	update tblSuperMerge set overflow5=replace(overflow5,'.tif','.eps') where overflow5 like '%photo%' and overflow5 like '%.tif'
	update tblSuperMerge set overflow5=replace(overflow5,'.pdf','.eps') where overflow5 like '%photo%' and overflow5 like '%.pdf'
	update tblSuperMerge set overflow5=replace(overflow5,'.psd','.eps') where overflow5 like '%photo%' and overflow5 like '%.psd'



	--//MISC
	update tblSuperMerge set photo1=replace(photo1,'.bmp','.eps') where photo1 like '%misc%' and photo1 like '%.bmp'
	update tblSuperMerge set photo1=replace(photo1,'.jpg','.eps') where photo1 like '%misc%' and photo1 like '%.jpg'
	update tblSuperMerge set photo1=replace(photo1,'.jpeg','.eps') where photo1 like '%misc%' and photo1 like '%.jpeg'
	update tblSuperMerge set photo1=replace(photo1,'.gif','.eps') where photo1 like '%misc%' and photo1 like '%.gif'
	update tblSuperMerge set photo1=replace(photo1,'.png','.eps') where photo1 like '%misc%' and photo1 like '%.png'
	update tblSuperMerge set photo1=replace(photo1,'.tif','.eps') where photo1 like '%misc%' and photo1 like '%.tif'
	update tblSuperMerge set photo1=replace(photo1,'.pdf','.eps') where photo1 like '%misc%' and photo1 like '%.pdf'
	update tblSuperMerge set photo1=replace(photo1,'.psd','.eps') where photo1 like '%misc%' and photo1 like '%.psd'

	update tblSuperMerge set photo2=replace(photo2,'.bmp','.eps') where photo2 like '%misc%' and photo2 like '%.bmp'
	update tblSuperMerge set photo2=replace(photo2,'.jpg','.eps') where photo2 like '%misc%' and photo2 like '%.jpg'
	update tblSuperMerge set photo2=replace(photo2,'.jpeg','.eps') where photo2 like '%misc%' and photo2 like '%.jpeg'
	update tblSuperMerge set photo2=replace(photo2,'.gif','.eps') where photo2 like '%misc%' and photo2 like '%.gif'
	update tblSuperMerge set photo2=replace(photo2,'.png','.eps') where photo2 like '%misc%' and photo2 like '%.png'
	update tblSuperMerge set photo2=replace(photo2,'.tif','.eps') where photo2 like '%misc%' and photo2 like '%.tif'
	update tblSuperMerge set photo2=replace(photo2,'.pdf','.eps') where photo2 like '%misc%' and photo2 like '%.pdf'
	update tblSuperMerge set photo2=replace(photo2,'.psd','.eps') where photo2 like '%misc%' and photo2 like '%.psd'

	update tblSuperMerge set overflow1=replace(overflow1,'.bmp','.eps') where overflow1 like '%misc%' and overflow1 like '%.bmp'
	update tblSuperMerge set overflow1=replace(overflow1,'.jpg','.eps') where overflow1 like '%misc%' and overflow1 like '%.jpg'
	update tblSuperMerge set overflow1=replace(overflow1,'.jpeg','.eps') where overflow1 like '%misc%' and overflow1 like '%.jpeg'
	update tblSuperMerge set overflow1=replace(overflow1,'.gif','.eps') where overflow1 like '%misc%' and overflow1 like '%.gif'
	update tblSuperMerge set overflow1=replace(overflow1,'.png','.eps') where overflow1 like '%misc%' and overflow1 like '%.png'
	update tblSuperMerge set overflow1=replace(overflow1,'.tif','.eps') where overflow1 like '%misc%' and overflow1 like '%.tif'
	update tblSuperMerge set overflow1=replace(overflow1,'.pdf','.eps') where overflow1 like '%misc%' and overflow1 like '%.pdf'
	update tblSuperMerge set overflow1=replace(overflow1,'.psd','.eps') where overflow1 like '%misc%' and overflow1 like '%.psd'

	update tblSuperMerge set overflow2=replace(overflow2,'.bmp','.eps') where overflow2 like '%misc%' and overflow2 like '%.bmp'
	update tblSuperMerge set overflow2=replace(overflow2,'.jpg','.eps') where overflow2 like '%misc%' and overflow2 like '%.jpg'
	update tblSuperMerge set overflow2=replace(overflow2,'.jpeg','.eps') where overflow2 like '%misc%' and overflow2 like '%.jpeg'
	update tblSuperMerge set overflow2=replace(overflow2,'.gif','.eps') where overflow2 like '%misc%' and overflow2 like '%.gif'
	update tblSuperMerge set overflow2=replace(overflow2,'.png','.eps') where overflow2 like '%misc%' and overflow2 like '%.png'
	update tblSuperMerge set overflow2=replace(overflow2,'.tif','.eps') where overflow2 like '%misc%' and overflow2 like '%.tif'
	update tblSuperMerge set overflow2=replace(overflow2,'.pdf','.eps') where overflow2 like '%misc%' and overflow2 like '%.pdf'
	update tblSuperMerge set overflow2=replace(overflow2,'.psd','.eps') where overflow2 like '%misc%' and overflow2 like '%.psd'

	update tblSuperMerge set overflow3=replace(overflow3,'.bmp','.eps') where overflow3 like '%misc%' and overflow3 like '%.bmp'
	update tblSuperMerge set overflow3=replace(overflow3,'.jpg','.eps') where overflow3 like '%misc%' and overflow3 like '%.jpg'
	update tblSuperMerge set overflow3=replace(overflow3,'.jpeg','.eps') where overflow3 like '%misc%' and overflow3 like '%.jpeg'
	update tblSuperMerge set overflow3=replace(overflow3,'.gif','.eps') where overflow3 like '%misc%' and overflow3 like '%.gif'
	update tblSuperMerge set overflow3=replace(overflow3,'.png','.eps') where overflow3 like '%misc%' and overflow3 like '%.png'
	update tblSuperMerge set overflow3=replace(overflow3,'.tif','.eps') where overflow3 like '%misc%' and overflow3 like '%.tif'
	update tblSuperMerge set overflow3=replace(overflow3,'.pdf','.eps') where overflow3 like '%misc%' and overflow3 like '%.pdf'
	update tblSuperMerge set overflow3=replace(overflow3,'.psd','.eps') where overflow3 like '%misc%' and overflow3 like '%.psd'

	update tblSuperMerge set overflow4=replace(overflow4,'.bmp','.eps') where overflow4 like '%misc%' and overflow4 like '%.bmp'
	update tblSuperMerge set overflow4=replace(overflow4,'.jpg','.eps') where overflow4 like '%misc%' and overflow4 like '%.jpg'
	update tblSuperMerge set overflow4=replace(overflow4,'.jpeg','.eps') where overflow4 like '%misc%' and overflow4 like '%.jpeg'
	update tblSuperMerge set overflow4=replace(overflow4,'.gif','.eps') where overflow4 like '%misc%' and overflow4 like '%.gif'
	update tblSuperMerge set overflow4=replace(overflow4,'.png','.eps') where overflow4 like '%misc%' and overflow4 like '%.png'
	update tblSuperMerge set overflow4=replace(overflow4,'.tif','.eps') where overflow4 like '%misc%' and overflow4 like '%.tif'
	update tblSuperMerge set overflow4=replace(overflow4,'.pdf','.eps') where overflow4 like '%misc%' and overflow4 like '%.pdf'
	update tblSuperMerge set overflow4=replace(overflow4,'.psd','.eps') where overflow4 like '%misc%' and overflow4 like '%.psd'

	update tblSuperMerge set overflow5=replace(overflow5,'.bmp','.eps') where overflow5 like '%misc%' and overflow5 like '%.bmp'
	update tblSuperMerge set overflow5=replace(overflow5,'.jpg','.eps') where overflow5 like '%misc%' and overflow5 like '%.jpg'
	update tblSuperMerge set overflow5=replace(overflow5,'.jpeg','.eps') where overflow5 like '%misc%' and overflow5 like '%.jpeg'
	update tblSuperMerge set overflow5=replace(overflow5,'.gif','.eps') where overflow5 like '%misc%' and overflow5 like '%.gif'
	update tblSuperMerge set overflow5=replace(overflow5,'.png','.eps') where overflow5 like '%misc%' and overflow5 like '%.png'
	update tblSuperMerge set overflow5=replace(overflow5,'.tif','.eps') where overflow5 like '%misc%' and overflow5 like '%.tif'
	update tblSuperMerge set overflow5=replace(overflow5,'.pdf','.eps') where overflow5 like '%misc%' and overflow5 like '%.pdf'
	update tblSuperMerge set overflow5=replace(overflow5,'.psd','.eps') where overflow5 like '%misc%' and overflow5 like '%.psd'





	--ADD .EPS EXTENSION ON ALL IMAGES WHERE .EPS DOES NOT EXIST YET
	update tblSuperMerge set photo1=photo1+'.eps' where photo1 like '%photo%' and photo1 not like '%.eps'
	update tblSuperMerge set photo2=photo2+'.eps' where photo2 like '%photo%' and photo2 not like '%.eps'
	update tblSuperMerge set logo1=logo1+'.eps' where logo1 like '%logo%' and logo1 not like '%.eps'
	update tblSuperMerge set logo2=logo2+'.eps' where logo2 like '%logo%' and logo2 not like '%.eps'
	update tblSuperMerge set overflow1=overflow1+'.eps' where overflow1 like '%photo%' and overflow1 not like '%.eps'
	update tblSuperMerge set overflow2=overflow2+'.eps' where overflow2 like '%photo%' and overflow2 not like '%.eps'
	update tblSuperMerge set overflow3=overflow3+'.eps' where overflow3 like '%photo%' and overflow3 not like '%.eps'
	update tblSuperMerge set overflow4=overflow4+'.eps' where overflow4 like '%photo%' and overflow4 not like '%.eps'
	update tblSuperMerge set overflow5=overflow5+'.eps' where overflow5 like '%photo%' and overflow5 not like '%.eps'
	update tblSuperMerge set overflow1=overflow1+'.eps' where overflow1 like '%logo%' and overflow1 not like '%.eps'
	update tblSuperMerge set overflow2=overflow2+'.eps' where overflow2 like '%logo%' and overflow2 not like '%.eps'
	update tblSuperMerge set overflow3=overflow3+'.eps' where overflow3 like '%logo%' and overflow3 not like '%.eps'
	update tblSuperMerge set overflow4=overflow4+'.eps' where overflow4 like '%logo%' and overflow4 not like '%.eps'
	update tblSuperMerge set overflow5=overflow5+'.eps' where overflow5 like '%logo%' and overflow5 not like '%.eps'
	update tblSuperMerge set overflow1=overflow1+'.eps' where overflow1 like '%misc%' and overflow1 not like '%.eps'
	update tblSuperMerge set overflow2=overflow2+'.eps' where overflow2 like '%misc%' and overflow2 not like '%.eps'
	update tblSuperMerge set overflow3=overflow3+'.eps' where overflow3 like '%misc%' and overflow3 not like '%.eps'
	update tblSuperMerge set overflow4=overflow4+'.eps' where overflow4 like '%misc%' and overflow4 not like '%.eps'
	update tblSuperMerge set overflow5=overflow5+'.eps' where overflow5 like '%misc%' and overflow5 not like '%.eps'




	--// CLEAN BEGIN--// CLEAN BEGIN--// CLEAN BEGIN--// CLEAN BEGIN--// CLEAN BEGIN--// CLEAN BEGIN--// CLEAN BEGIN--// CLEAN BEGIN

	--yourName FIELD
	update tblSuperMerge set yourName=replace(yourName,'&#174;','®')
	update tblSuperMerge set yourName=replace(yourName,'&#174','®')
	update tblSuperMerge set yourName=replace(yourName,'(R)','®')
	update tblSuperMerge set yourName=replace(yourName,'&amp;','&')
	update tblSuperMerge set yourName=replace(yourName,'&amp','&')
	update tblSuperMerge set yourName=replace(yourName,'&quot;','"')
	update tblSuperMerge set yourName=replace(yourName,'&quot','"')
	update tblSuperMerge set yourName=replace(yourName,'&#233;','é')
	update tblSuperMerge set yourName=replace(yourName,'&#233','é')
	update tblSuperMerge set yourName=replace(yourName,'&#241;','ñ')
	update tblSuperMerge set yourName=replace(yourName,'&#241','ñ')
	update tblSuperMerge set yourName=replace(yourName,'&#211;','Ó')
	update tblSuperMerge set yourName=replace(yourName,'&#243;','Ó')
	update tblSuperMerge set yourName=replace(yourName,'&#211','Ó')
	update tblSuperMerge set yourName=replace(yourName,'&#243','Ó')
	update tblSuperMerge set yourName=replace(yourName,'realtor','REALTOR')
	update tblSuperMerge set yourName=replace(yourName,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName=replace(yourName,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName=replace(yourName,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName=replace(yourName,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName=replace(yourName,'REALTOR','REALTOR®') where yourName not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set yourName=replace(yourName,'REALTORS','REALTORS®') where yourName not like '%REALTORS®%' and yourName like '%REALTORS%'
	update tblSuperMerge set yourName=replace(yourName,'®®','®')
	update tblSuperMerge set yourName=replace(yourName,'®-',' ® -')
	update tblSuperMerge set yourName=replace(yourName,'-®',' - ®')
	update tblSuperMerge set yourName=replace(yourName,',',', ')
	update tblSuperMerge set yourName=replace(yourName,'  ',' ')
	update tblSuperMerge set yourName=replace(yourName,'  ',' ')
	update tblSuperMerge set yourName=replace(yourName,'®','<V>®<P>')

	--yourCompany FIELD
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#174;','®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#174','®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'(R)','®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&amp;','&'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&amp','&'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&quot;','"'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&quot','"'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#233;','é'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#233','é'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#241;','ñ'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#241','ñ'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#211;','Ó'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#243;','Ó'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#211','Ó'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'&#243','Ó'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'realtor','REALTOR'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'REALTOR Associate','REALTOR-ASSOCIATE®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'REALTOR Associate','REALTOR-ASSOCIATE®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'REALTOR','REALTOR®'), 1, 255) where yourCompany not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'REALTORS','REALTORS®'), 1, 255) where yourCompany not like '%REALTORS®%' and yourCompany like '%REALTORS%'
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'®®','®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'®-',' ® -'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'-®',' - ®'), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,',',', '), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'  ',' '), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'  ',' '), 1, 255)
	update tblSuperMerge set yourCompany=SUBSTRING(replace(yourCompany,'®','<V>®<P>'), 1, 255)


	--input1 FIELD
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#174;','®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#174','®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'(R)','®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&amp;','&'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&amp','&'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&quot;','"'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&quot','"'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#233;','é'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#233','é'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#241;','ñ'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#241','ñ'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#211;','Ó'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#243;','Ó'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#211','Ó'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'&#243','Ó'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'realtor','REALTOR'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'REALTOR','REALTOR®'), 255) where input1 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'REALTORS','REALTORS®'), 255) where input1 not like '%REALTORS®%' and input1 like '%REALTORS%'
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'®®','®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'®-',' ® -'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'-®',' - ®'), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,',',', '), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'  ',' '), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'  ',' '), 255)
	update tblSuperMerge set input1 = LEFT(REPLACE(input1,'®','<V>®<P>'), 255)

	--input2 FIELD
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#174;','®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#174','®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'(R)','®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&amp;','&'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&amp','&'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&quot;','"'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&quot','"'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#233;','é'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#233','é'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#241;','ñ'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#241','ñ'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#211;','Ó'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#243;','Ó'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#211','Ó'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'&#243','Ó'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'realtor','REALTOR'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'REALTOR','REALTOR®'), 255) where input2 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'REALTORS','REALTORS®'), 255) where input2 not like '%REALTORS®%' and input2 like '%REALTORS%'
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'®®','®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'®-',' ® -'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'-®',' - ®'), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,',',', '), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'  ',' '), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'  ',' '), 255)
	update tblSuperMerge set input2 = LEFT(REPLACE(input2,'®','<V>®<P>'), 255)

	--input3 FIELD
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#174;','®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#174','®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'(R)','®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&amp;','&'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&amp','&'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&quot;','"'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&quot','"'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#233;','é'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#233','é'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#241;','ñ'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#241','ñ'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#211;','Ó'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#243;','Ó'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#211','Ó'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'&#243','Ó'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'realtor','REALTOR'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'REALTOR','REALTOR®'), 255) where input3 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'REALTORS','REALTORS®'), 255) where input3 not like '%REALTORS®%' and input3 like '%REALTORS%'
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'®®','®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'®-',' ® -'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'-®',' - ®'), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,',',', '), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'  ',' '), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'  ',' '), 255)
	update tblSuperMerge set input3 = LEFT(REPLACE(input3,'®','<V>®<P>'), 255)

	--input4 FIELD
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#174;','®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#174','®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'(R)','®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&amp;','&'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&amp','&'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&quot;','"'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&quot','"'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#233;','é'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#233','é'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#241;','ñ'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#241','ñ'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#211;','Ó'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#243;','Ó'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#211','Ó'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'&#243','Ó'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'realtor','REALTOR'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'REALTOR','REALTOR®'), 255) where input4 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'REALTORS','REALTORS®'), 255) where input4 not like '%REALTORS®%' and input4 like '%REALTORS%'
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'®®','®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'®-',' ® -'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'-®',' - ®'), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,',',', '), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'  ',' '), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'  ',' '), 255)
	update tblSuperMerge set input4 = LEFT(REPLACE(input4,'®','<V>®<P>'), 255)

	--input5 FIELD
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#174;','®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#174','®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'(R)','®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&amp;','&'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&amp','&'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&quot;','"'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&quot','"'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#233;','é'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#233','é'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#241;','ñ'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#241','ñ'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#211;','Ó'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#243;','Ó'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#211','Ó'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'&#243','Ó'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'realtor','REALTOR'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'REALTOR','REALTOR®'), 255) where input5 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'REALTORS','REALTORS®'), 255) where input5 not like '%REALTORS®%' and input5 like '%REALTORS%'
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'®®','®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'®-',' ® -'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'-®',' - ®'), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,',',', '), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'  ',' '), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'  ',' '), 255)
	update tblSuperMerge set input5 = LEFT(REPLACE(input5,'®','<V>®<P>'), 255)

	--input6 FIELD
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#174;','®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#174','®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'(R)','®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&amp;','&'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&amp','&'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&quot;','"'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&quot','"'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#233;','é'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#233','é'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#241;','ñ'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#241','ñ'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#211;','Ó'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#243;','Ó'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#211','Ó'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'&#243','Ó'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'realtor','REALTOR'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'REALTOR','REALTOR®'), 255) where input6 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'REALTORS','REALTORS®'), 255) where input6 not like '%REALTORS®%' and input6 like '%REALTORS%'
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'®®','®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'®-',' ® -'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'-®',' - ®'), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,',',', '), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'  ',' '), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'  ',' '), 255)
	update tblSuperMerge set input6 = LEFT(REPLACE(input6,'®','<V>®<P>'), 255)

	--input7 FIELD
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#174;','®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#174','®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'(R)','®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&amp;','&'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&amp','&'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&quot;','"'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&quot','"'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#233;','é'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#233','é'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#241;','ñ'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#241','ñ'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#211;','Ó'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#243;','Ó'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#211','Ó'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'&#243','Ó'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'realtor','REALTOR'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'REALTOR','REALTOR®'), 255) where input7 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'REALTORS','REALTORS®'), 255) where input7 not like '%REALTORS®%' and input7 like '%REALTORS%'
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'®®','®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'®-',' ® -'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'-®',' - ®'), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,',',', '), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'  ',' '), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'  ',' '), 255)
	update tblSuperMerge set input7 = LEFT(REPLACE(input7,'®','<V>®<P>'), 255)

	--input8 FIELD
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#174;','®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#174','®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'(R)','®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&amp;','&'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&amp','&'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&quot;','"'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&quot','"'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#233;','é'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#233','é'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#241;','ñ'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#241','ñ'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#211;','Ó'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#243;','Ó'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#211','Ó'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'&#243','Ó'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'realtor','REALTOR'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'REALTOR-Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'REALTOR - Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'REALTOR Associate','REALTOR-ASSOCIATE®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'REALTOR','REALTOR®'), 255) where input8 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'REALTORS','REALTORS®'), 255) where input8 not like '%REALTORS®%' and input8 like '%REALTORS%'
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'®®','®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'®-',' ® -'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'-®',' - ®'), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,',',', '), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'  ',' '), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'  ',' '), 255)
	update tblSuperMerge set input8 = LEFT(REPLACE(input8,'®','<V>®<P>'), 255)

	--marketCenterName FIELD
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#174;','®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#174','®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'(R)','®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&amp;','&')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&amp','&')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&quot;','"')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&quot','"')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#233;','é')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#233','é')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#241;','ñ')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#241','ñ')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#211;','Ó')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#243;','Ó')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#211','Ó')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'&#243','Ó')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'realtor','REALTOR')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'REALTOR','REALTOR®') where marketCenterName not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'REALTORS','REALTORS®') where marketCenterName not like '%REALTORS®%' and marketCenterName like '%REALTORS%'
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'®®','®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'®-',' ® -')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'-®',' - ®')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,',',', ')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'  ',' ')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'  ',' ')
	update tblSuperMerge set marketCenterName=replace(marketCenterName,'®','<V>®<P>')

	--projectDesc FIELD
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#174;','®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#174','®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'(R)','®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&amp;','&')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&amp','&')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&quot;','"')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&quot','"')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#233;','é')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#233','é')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#241;','ñ')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#241','ñ')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#211;','Ó')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#243;','Ó')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#211','Ó')
	update tblSuperMerge set projectDesc=replace(projectDesc,'&#243','Ó')
	update tblSuperMerge set projectDesc=replace(projectDesc,'realtor','REALTOR')
	update tblSuperMerge set projectDesc=replace(projectDesc,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'REALTOR','REALTOR®') where projectDesc not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set projectDesc=replace(projectDesc,'REALTORS','REALTORS®') where projectDesc not like '%REALTORS®%' and projectDesc like '%REALTORS%'
	update tblSuperMerge set projectDesc=replace(projectDesc,'®®','®')
	update tblSuperMerge set projectDesc=replace(projectDesc,'®-',' ® -')
	update tblSuperMerge set projectDesc=replace(projectDesc,'-®',' - ®')
	update tblSuperMerge set projectDesc=replace(projectDesc,',',', ')
	update tblSuperMerge set projectDesc=replace(projectDesc,'  ',' ')
	update tblSuperMerge set projectDesc=replace(projectDesc,'  ',' ')
	update tblSuperMerge set projectDesc=replace(projectDesc,'®','<V>®<P>')

	--streetAddress FIELD
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#174;','®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#174','®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'(R)','®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&amp;','&')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&amp','&')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&quot;','"')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&quot','"')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#233;','é')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#233','é')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#241;','ñ')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#241','ñ')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#211;','Ó')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#243;','Ó')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#211','Ó')
	update tblSuperMerge set streetAddress=replace(streetAddress,'&#243','Ó')
	update tblSuperMerge set streetAddress=replace(streetAddress,'realtor','REALTOR')
	update tblSuperMerge set streetAddress=replace(streetAddress,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'REALTOR','REALTOR®') where streetAddress not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set streetAddress=replace(streetAddress,'REALTORS','REALTORS®') where streetAddress not like '%REALTORS®%' and streetAddress like '%REALTORS%'
	update tblSuperMerge set streetAddress=replace(streetAddress,'®®','®')
	update tblSuperMerge set streetAddress=replace(streetAddress,'®-',' ® -')
	update tblSuperMerge set streetAddress=replace(streetAddress,'-®',' - ®')
	update tblSuperMerge set streetAddress=replace(streetAddress,',',', ')
	update tblSuperMerge set streetAddress=replace(streetAddress,'  ',' ')
	update tblSuperMerge set streetAddress=replace(streetAddress,'  ',' ')
	update tblSuperMerge set streetAddress=replace(streetAddress,'®','<V>®<P>')

	--csz FIELD
	update tblSuperMerge set csz=replace(csz,'&#174;','®')
	update tblSuperMerge set csz=replace(csz,'&#174','®')
	update tblSuperMerge set csz=replace(csz,'(R)','®')
	update tblSuperMerge set csz=replace(csz,'&amp;','&')
	update tblSuperMerge set csz=replace(csz,'&amp','&')
	update tblSuperMerge set csz=replace(csz,'&quot;','"')
	update tblSuperMerge set csz=replace(csz,'&quot','"')
	update tblSuperMerge set csz=replace(csz,'&#233;','é')
	update tblSuperMerge set csz=replace(csz,'&#233','é')
	update tblSuperMerge set csz=replace(csz,'&#241;','ñ')
	update tblSuperMerge set csz=replace(csz,'&#241','ñ')
	update tblSuperMerge set csz=replace(csz,'&#211;','Ó')
	update tblSuperMerge set csz=replace(csz,'&#243;','Ó')
	update tblSuperMerge set csz=replace(csz,'&#211','Ó')
	update tblSuperMerge set csz=replace(csz,'&#243','Ó')
	update tblSuperMerge set csz=replace(csz,'realtor','REALTOR')
	update tblSuperMerge set csz=replace(csz,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set csz=replace(csz,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set csz=replace(csz,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set csz=replace(csz,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set csz=replace(csz,'REALTOR','REALTOR®') where csz not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set csz=replace(csz,'REALTORS','REALTORS®') where csz not like '%REALTORS®%' and csz like '%REALTORS%'
	update tblSuperMerge set csz=replace(csz,'®®','®')
	update tblSuperMerge set csz=replace(csz,'®-',' ® -')
	update tblSuperMerge set csz=replace(csz,'-®',' - ®')
	update tblSuperMerge set csz=replace(csz,',',', ')
	update tblSuperMerge set csz=replace(csz,'  ',' ')
	update tblSuperMerge set csz=replace(csz,'  ',' ')
	update tblSuperMerge set csz=replace(csz,'®','<V>®<P>')

	--yourName2 FIELD
	update tblSuperMerge set yourName2=replace(yourName2,'&#174;','®')
	update tblSuperMerge set yourName2=replace(yourName2,'&#174','®')
	update tblSuperMerge set yourName2=replace(yourName2,'(R)','®')
	update tblSuperMerge set yourName2=replace(yourName2,'&amp;','&')
	update tblSuperMerge set yourName2=replace(yourName2,'&amp','&')
	update tblSuperMerge set yourName2=replace(yourName2,'&quot;','"')
	update tblSuperMerge set yourName2=replace(yourName2,'&quot','"')
	update tblSuperMerge set yourName2=replace(yourName2,'&#233;','é')
	update tblSuperMerge set yourName2=replace(yourName2,'&#233','é')
	update tblSuperMerge set yourName2=replace(yourName2,'&#241;','ñ')
	update tblSuperMerge set yourName2=replace(yourName2,'&#241','ñ')
	update tblSuperMerge set yourName2=replace(yourName2,'&#211;','Ó')
	update tblSuperMerge set yourName2=replace(yourName2,'&#243;','Ó')
	update tblSuperMerge set yourName2=replace(yourName2,'&#211','Ó')
	update tblSuperMerge set yourName2=replace(yourName2,'&#243','Ó')
	update tblSuperMerge set yourName2=replace(yourName2,'realtor','REALTOR')
	update tblSuperMerge set yourName2=replace(yourName2,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName2=replace(yourName2,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName2=replace(yourName2,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName2=replace(yourName2,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set yourName2=replace(yourName2,'REALTOR','REALTOR®') where yourName2 not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set yourName2=replace(yourName2,'REALTORS','REALTORS®') where yourName2 not like '%REALTORS®%' and yourName2 like '%REALTORS%'
	update tblSuperMerge set yourName2=replace(yourName2,'®®','®')
	update tblSuperMerge set yourName2=replace(yourName2,'®-',' ® -')
	update tblSuperMerge set yourName2=replace(yourName2,'-®',' - ®')
	update tblSuperMerge set yourName2=replace(yourName2,',',', ')
	update tblSuperMerge set yourName2=replace(yourName2,'  ',' ')
	update tblSuperMerge set yourName2=replace(yourName2,'  ',' ')
	update tblSuperMerge set yourName2=replace(yourName2,'®','<V>®<P>')


	--artInstructions FIELD
	update tblSuperMerge set artInstructions=left(artInstructions,230) where len(artInstructions)>230
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#174;','®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#174','®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'(R)','®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&amp;','&')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&amp','&')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&quot;','"')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&quot','"')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#233;','é')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#233','é')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#241;','ñ')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#241','ñ')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#211;','Ó')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#243;','Ó')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#211','Ó')
	update tblSuperMerge set artInstructions=replace(artInstructions,'&#243','Ó')
	update tblSuperMerge set artInstructions=replace(artInstructions,'realtor','REALTOR')
	update tblSuperMerge set artInstructions=replace(artInstructions,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'REALTOR','REALTOR®') where artInstructions not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set artInstructions=replace(artInstructions,'REALTORS','REALTORS®') where artInstructions not like '%REALTORS®%' and artInstructions like '%REALTORS%'
	update tblSuperMerge set artInstructions=replace(artInstructions,'®®','®')
	update tblSuperMerge set artInstructions=replace(artInstructions,'®-',' ® -')
	update tblSuperMerge set artInstructions=replace(artInstructions,'-®',' - ®')
	update tblSuperMerge set artInstructions=replace(artInstructions, CHAR(13) + CHAR(10), ' ')
	update tblSuperMerge set artInstructions=replace(artInstructions,',',', ')
	update tblSuperMerge set artInstructions=replace(artInstructions,'  ',' ')
	update tblSuperMerge set artInstructions=replace(artInstructions,'  ',' ')
	update tblSuperMerge set artInstructions=replace(artInstructions,'®','<V>®<P>')



	--previousJobArt FIELD
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#174;','®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#174','®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'(R)','®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&amp;','&')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&amp','&')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&quot;','"')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&quot','"')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#233;','é')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#233','é')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#241;','ñ')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#241','ñ')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#211;','Ó')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#243;','Ó')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#211','Ó')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'&#243','Ó')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'realtor','REALTOR')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'REALTOR','REALTOR®') where previousJobArt not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'REALTORS','REALTORS®') where previousJobArt not like '%REALTORS®%' and previousJobArt like '%REALTORS%'
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'®®','®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'®-',' ® -')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'-®',' - ®')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,',',', ')
	update tblSuperMerge set previousJobArt=replace(previousJobArt, CHAR(13) + CHAR(10), ' ')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'  ',' ')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'  ',' ')
	update tblSuperMerge set previousJobArt=replace(previousJobArt,'®','<V>®<P>')


	--previousJobInfo FIELD
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#174;','®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#174','®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'(R)','®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&amp;','&')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&amp','&')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&quot;','"')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&quot','"')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#233;','é')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#233','é')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#241;','ñ')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#241','ñ')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#211;','Ó')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#243;','Ó')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#211','Ó')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'&#243','Ó')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'realtor','REALTOR')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'REALTOR-Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'REALTOR - Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'REALTOR Associate','REALTOR-ASSOCIATE®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'REALTOR','REALTOR®') where previousJobInfo not like '%REALTOR-ASSOCIATE%'
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'REALTORS','REALTORS®') where previousJobInfo not like '%REALTORS®%' and previousJobInfo like '%REALTORS%'
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'®®','®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'®-',' ® -')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'-®',' - ®')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,',',', ')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo, CHAR(13) + CHAR(10), ' ')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'  ',' ')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'  ',' ')
	update tblSuperMerge set previousJobInfo=replace(previousJobInfo,'®','<V>®<P>')


	--FIX LENGTHS (JF 032717)
	UPDATE tblSuperMerge SET overflow1 = LEFT(overflow1, 255)
	UPDATE tblSuperMerge SET overflow2 = LEFT(overflow2, 255)
	UPDATE tblSuperMerge SET overflow3 = LEFT(overflow3, 255)
	UPDATE tblSuperMerge SET overflow4 = LEFT(overflow4, 255)
	UPDATE tblSuperMerge SET overflow5 = LEFT(overflow5, 255)

	--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END--// CLEAN END

	--// Update 2 columns in the supermerge when a product is an OPC product (JF 092514)

	UPDATE tblSuperMerge
	SET overflow1 = 'OPC'
	WHERE ordersProductsID IN
		(SELECT DISTINCT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE optionCaption = 'OPC')

	UPDATE tblSuperMerge
	SET overflow2 = RIGHT(overflow2, CHARINDEX('/',REVERSE(overflow2))-1)
	WHERE overflow2 LIKE '%/%'
	AND overflow2 LIKE '%pdf%'
	AND overflow1 = 'OPC'

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