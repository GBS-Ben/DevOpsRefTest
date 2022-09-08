--04/27/21		CKB, Markful

CREATE PROCEDURE [dbo].[usp_ART_dataMerge]
AS
SET NOCOUNT ON;

	BEGIN TRY
	
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* BEGIN

--LINE RETURN PROBLEMS
-- 2667 //input1
-- 2841 //input4
-- 2927 // input4
-- 2998 //input1,2,3
-- 3956 //yourcompany
--select * from tblCustomInput_xDataSequencedBrev1_NEWHOM

--GRAB ORDERS FOR XSHEET
INSERT INTO tblCustomInput_xDataSequencedBrev1_NEWHOM (PKID)
select substring(orderNo,4,6) from tblOrders
where orderNo is NOT NULL
and orderType='Custom'
and substring(orderNo,4,6) not in
        (select distinct PKID from tblCustomInput_xDataSequencedBrev1_NEWHOM where PKID is NOT NULL)
and datediff(dd,orderDate,getdate())<160
and orderStatus<>'delivered'
and orderStatus<>'cancelled'
and orderStatus not like '%transit%'
and orderStatus not like '%DOCK%'

--ORDERNO
UPDATE tblCustomInput_xDataSequencedBrev1_NEWHOM
SET orderNo=b.orderNo
FROM tblCustomInput_xDataSequencedBrev1_NEWHOM a
INNER JOIN tblOrders b ON a.PKID=try_convert(int,substring(b.orderNo,4,6))
where a.orderNo is NULL
and ( b.orderNo like 'HOM%' or  b.orderNo like 'MRK%')

--ORDERDETAILID
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set orderDetailID=p.ordersProductsID
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where p.ordersProductsID IS NOT NULL
and a.orderDetailID is NULL
and (b.orderNo like 'HOM%' or b.orderNo like 'MRK%')


--INPUT 1 (yourname)
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set yourname=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 1:%'				--iFrame last used 5/2019
and a.yourname is NULL
and p.deleteX<>'yes'

--INPUT 2 (yourcompany)
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set yourcompany=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 2:%'				--iFrame last used 5/2019
and b.orderNo not like '%3956'
and p.deleteX<>'yes'
--and a.yourcompany is NULL


--INPUT 3 (input1)
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input1=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 3:%'				--iFrame last used 5/2019
and b.orderNo not like '%2667'
and b.orderNo not like '%2998'
and p.deleteX<>'yes'
--and a.input1 is NULL

--INPUT 4 /a
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input2=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 4:%'				--iFrame last used 5/2019
and p.deleteX<>'yes'
--and a.input2 is NULL

--INPUT 5 /a
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input3=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 5:%'				--iFrame last used 5/2019
and b.orderNo not like '%2998'
and p.deleteX<>'yes'
--and a.input3 is NULL


--INPUT 6 /a
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input4=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 6:%'				--iFrame last used 5/2019
and b.orderNo not like '%2927'
and b.orderNo not like '%2841'
and p.deleteX<>'yes'
--and a.input4 is NULL

--INPUT 7
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input5=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 7:%'				--iFrame last used 5/2019
and p.deleteX<>'yes'
--and a.input3 is NULL

--INPUT 8
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input6=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 8:%'				--iFrame last used 5/2019
and p.deleteX<>'yes'
--and a.input4 is NULL

--INPUT 9
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input7=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 9:%'				--iFrame last used 5/2019
and p.deleteX<>'yes'
--and a.input3 is NULL

--INPUT 10
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input8=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Info Line 10:%'				--iFrame last used 5/2019
and p.deleteX<>'yes'
--and a.input4 is NULL

-- 
-- marketCenterName
-- projectDesc
-- csz
-- yourName2

--marketCenterName
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set marketCenterName=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Market Center Name:%'				--iFrame last used 2013
and p.deleteX<>'yes'

--projectDesc
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set projectDesc=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Project Description:%'				--iFrame last used 2015
and p.deleteX<>'yes'


--csz
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set csz=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'City/state/zip:%'				--iFrame last used 2012
and p.deleteX<>'yes'


--yourName2
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set yourName2=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Your name:%'				--iFrame last used 2016
and p.deleteX<>'yes'

--streetAddress
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set streetAddress=convert(varchar(255), p.textValue)
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where convert(varchar(255), p.optionCaption) like 'Street address:%'			--iFrame last used 2015
and p.deleteX<>'yes'

--select * from tblOrdersProducts_ProductOptions where optionCaption like 'Your Name%'


--LOGO/PHOTO
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set logo1=convert(varchar(50),pkid)+'.logo1.eps'
where logo1 is NULL

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set logo2=convert(varchar(50),pkid)+'.logo2.eps'
where logo2 is NULL

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set photo1=convert(varchar(50),pkid)+'.photo1.eps'
where photo1 is NULL

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set photo2=convert(varchar(50),pkid)+'.photo2.eps'
where photo2 is NULL



--RANDOM FIXES
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input1='Replace: Terra Ayres- Broker/ Owner with Terra Ayres, Residential Real Estate Broker'
where orderNo like '%2667'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input4='Anna DeRosa (new) - 200'
where orderNo like '%2841'


update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input3='Email: RealEstateByDolores@yahoo.com Making A Difference One Family At A Time!'
where orderNo like '%2927'


update tblCustomInput_xDataSequencedBrev1_NEWHOM
set input1='350 Bishops Way Suite 103',
input2='Brookfield, WI 53005',
input3='(262) 796-2320'
where orderNo like '%2998'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set yourCompany='Greg Bouquet - Realtor/Appraiser'
where orderNo like '%3956'


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


update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=3			--last used 1/2019
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=4			--last used 5/2019
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=5			--last used 1/2019
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL	
and p.optionID=6			--last used 2017
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=7				--last used 2016
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=8				--last used 01/2028
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=9			--last used 2013
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=10			--last used 01/2018
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=11					--last used 01/2014
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=12					--last used 10/2018
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=13					--last used 02/2017
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=14					--last used 01/2014
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=15					--last used 2014
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=141					--last used 2017
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol1=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol1 is NULL
and p.optionID=155					--last used 2015
and p.deleteX<>'yes'

--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2--SYMBOL #2

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=3
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=4
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=5
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=6
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=7
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=8
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=9
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=10
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=11
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=12
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=13
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=14
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=15
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=141
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol2=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol2 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=155
and p.optionCaption<>a.profsymbol1
and p.deleteX<>'yes'


--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3--SYMBOL #3

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=3
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=4
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=5
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=6
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=7
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=8
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=9
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=10
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=11
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=12
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=13
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=14
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=15
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=141
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set profsymbol3=p.optionCaption
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders b
on a.orderNo=b.orderNo
INNER JOIN tblOrders_Products z on b.orderID=z.orderID
INNER JOIN tblOrdersProducts_ProductOptions p on z.[ID]=p.ordersProductsID
where a.profsymbol3 is NULL
and a.profsymbol1 is NOT NULL
and p.optionID=155
and p.optionCaption<>a.profsymbol1
and a.profsymbol2 is NOT NULL
and p.optionCaption<>a.profsymbol2
and p.deleteX<>'yes'

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


update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='A.Realtor.R.Stroke.eps' where profsymbol1 like 'A. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='A.Realtor.R.Stroke.eps' where profsymbol2 like 'A. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='A.Realtor.R.Stroke.eps' where profsymbol3 like 'A. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='B.EqualHousing.Stroke.eps' where profsymbol1 like 'B. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='B.EqualHousing.Stroke.eps' where profsymbol2 like 'B. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='B.EqualHousing.Stroke.eps' where profsymbol3 like 'B. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='C.Realtor.MLS.Stroke.eps' where profsymbol1 like 'C. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='C.Realtor.MLS.Stroke.eps' where profsymbol2 like 'C. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='C.Realtor.MLS.Stroke.eps' where profsymbol3 like 'C. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='D.abr.Stroke.eps' where profsymbol1 like 'D. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='D.abr.Stroke.eps' where profsymbol2 like 'D. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='D.abr.Stroke.eps' where profsymbol3 like 'D. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='E.crs.Stroke.eps' where profsymbol1 like 'E. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='E.crs.Stroke.eps' where profsymbol2 like 'E. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='E.crs.Stroke.eps' where profsymbol3 like 'E. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='F.gri.Stroke.eps' where profsymbol1 like 'F. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='F.gri.Stroke.eps' where profsymbol2 like 'F. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='F.gri.Stroke.eps' where profsymbol3 like 'F. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='G.crb.Stroke.eps' where profsymbol1 like 'G. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='G.crb.Stroke.eps' where profsymbol2 like 'G. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='G.crb.Stroke.eps' where profsymbol3 like 'G. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='H.WCI.Stroke.eps' where profsymbol1 like 'H. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='H.WCI.Stroke.eps' where profsymbol2 like 'H. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='H.WCI.Stroke.eps' where profsymbol3 like 'H. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='I.crp.stroke.eps' where profsymbol1 like 'I. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='I.crp.stroke.eps' where profsymbol2 like 'I. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='I.crp.stroke.eps' where profsymbol3 like 'I. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='J.MLS.Stroked.eps' where profsymbol1 like 'J. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='J.MLS.Stroked.eps' where profsymbol2 like 'J. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='J.MLS.Stroked.eps' where profsymbol3 like 'J. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='K.epro.Stroke.eps' where profsymbol1 like 'K. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='K.epro.Stroke.eps' where profsymbol2 like 'K. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='K.epro.Stroke.eps' where profsymbol3 like 'K. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='L.sres.Stroke.eps' where profsymbol1 like 'L. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='L.sres.Stroke.eps' where profsymbol2 like 'L. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='L.sres.Stroke.eps' where profsymbol3 like 'L. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='M.FDIC.Stroke.eps' where profsymbol1 like 'M. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='M.FDIC.Stroke.eps' where profsymbol2 like 'M. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='M.FDIC.Stroke.eps' where profsymbol3 like 'M. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='N.EHLender.Stroke.eps' where profsymbol1 like 'N. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='N.EHLender.Stroke.eps' where profsymbol2 like 'N. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='N.EHLender.Stroke.eps' where profsymbol3 like 'N. %'

update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol1='O.NAHREP.Stroke.eps' where profsymbol1 like 'O. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol2='O.NAHREP.Stroke.eps' where profsymbol2 like 'O. %'
update tblCustomInput_xDataSequencedBrev1_NEWHOM set profsymbol3='O.NAHREP.Stroke.eps' where profsymbol3 like 'O. %'

--BKGND

update tblCustomInput_xDataSequencedBrev1_NEWHOM
set bkgnd=x.artBackgroundImageName
from tblCustomInput_xDataSequencedBrev1_NEWHOM a INNER JOIN tblOrders_Products b
on a.orderDetailID=b.[ID]
INNER JOIN tblProducts x
on b.productID=x.productID
where a.bkgnd is NULL
and x.artBackgroundImageName is NOT NULL

-- FIX NCC ROWS
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set yourName=NULL
where orderNo in
(select orderNo from tblORders where orderID in
(select orderID from tblOrders_Products where productID in
(select productID from tblProducts where productCompany='NCC')))

--ENTERDATE
update tblCustomInput_xDataSequencedBrev1_NEWHOM
set enterDate=convert(varchar(255),datepart(month,getdate()))+'/'+convert(varchar(255),datepart(day,getdate()))+'/'+convert(varchar(255),datepart(year,getdate()))
where enterDate is NULL AND orderNo is NOT NULL

--DELETE STOCK-ONLY ORDERS
delete from tblCustomInput_xDataSequencedBrev1_NEWHOM
where orderNo in
(select distinct OrderNo from tblOrders 
where orderType='Stock')

--DELETE NULL ORDERNO'S
delete from tblCustomInput_xDataSequencedBrev1_NEWHOM
where orderNo is NULL

--DELETE UNWANTED ORDERSTATUS JOBS
delete from tblCustomInput_xDataSequencedBrev1_NEWHOM
where orderNo not in
(select distinct OrderNo from tblOrders 
where orderStatus='in house' or orderStatus like '%waiting%')

--DELETE NAMEBADGE-ONLY ORDERS

delete from tblCustomInput_xDataSequencedBrev1_NEWHOM
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


--select * from tblProducts where productID=162231
--select * from tblCustomInput_xDataSequencedBrev1_NEWHOM order by orderNo
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* 
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*

--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* 
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* 
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* 
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* 
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* 
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*
--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&*--++))__)(&&&&&&* END

	END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH