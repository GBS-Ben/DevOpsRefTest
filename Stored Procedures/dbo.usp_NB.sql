CREATE PROCEDURE [dbo].[usp_NB]
as
/*
Created By: Jeremy Fifer
Created Date:  
Last Update Date: 
Affected Tables:  tblNBA, tblNBS
Usage:  Populates Name Badge tables for Art Flow.  Cursor, 2 deep.  Since each order may have multiple NB products, we have to nest a cursor to insert rows into NBS/NBA per NB product, per order.
*/
SET NOCOUNT ON

DECLARE 
--DEC UNIVERSAL VARS
@orderNo varchar(255),
--DEC NBS VARS
@contact varchar(255),
@title varchar(255),
@bkgnd varchar(255),
@sht varchar(255),
@pos varchar (255),
@COlogo varchar(255),
@COtextAll varchar(255),
@COtext1 varchar(255),
@COtext2 varchar(255),
@RO varchar(50),
--DEC NBA VARS
@Shipping_Name varchar(255),
@Shipping_Company varchar(255),
@Shipping_Street varchar(255),
@Shipping_Street2 varchar(255),
@Shipping_Suburb varchar(255),
@Shipping_State varchar(255),
@Shipping_PostCode varchar(255),
@badgeName varchar(255),
@badgeQTY varchar(255),
--DEC NESTED VARS
@productID int,
 @QTYCounter int,
@NBSCounter int,
@productCode varchar(255)

--///////////// RESET CODE IF NECESSARY

-- delete from tblNBS
-- delete from tblNBA

--///////////// RESET CODE IF NECESSARY


DECLARE cursor_NB CURSOR FOR 
--This grabs all orders that have a badge ordered and have not already popped NBS/NBA.  Every NB order prior to this proc run, will have at least 1 record in both NBS/NBA.


SELECT top 1 orderNo from tblOrders where orderID in
(select orderID from tblOrders_Products where productCode like 'NB%' and deleteX<>'Yes')
and orderStatus<>'failed' and orderStatus<>'cancelled'
and orderNo not in
(select distinct orderNo from tblNBS where orderNo is not NULL)
and orderNo not in
(select distinct orderNo from tblNBA where orderNo is not NULL)
and orderNo<>'HOM235032'
and orderNo<>'HOM237814'
and orderNo<>'HOM237487'
and orderNo<>'HOM238522'
and orderNo<>'HOM239254'





OPEN cursor_NB
FETCH NEXT FROM cursor_NB
INTO @orderNo
WHILE @@FETCH_STATUS = 0
BEGIN

IF @orderNo is  NULL
BEGIN
		FETCH NEXT FROM cursor_NB 
        INTO @orderNo
END

ELSE

--WIPE NBS VARS // per orderNo wipe.
SET @contact=NULL
SET @title=NULL
SET @bkgnd=NULL
SET @sht=NULL
SET @pos=NULL
SET @COlogo=NULL
SET @COtextAll=NULL
SET @COtext1=NULL
SET @COtext2=NULL
SET @RO=NULL
--WIPE NBA VARS
SET @Shipping_Name=NULL
SET @Shipping_Company=NULL
SET @Shipping_Street=NULL
SET @Shipping_Street2=NULL
SET @Shipping_Suburb=NULL
SET @Shipping_State=NULL
SET @Shipping_PostCode=NULL
SET @badgeName=NULL
SET @badgeQTY=NULL
--WIPE NEST VARS
SET @productID=NULL

--GRAB ALL NB PRODUCTS FOR @ORDERNO, CYCLE THRU EACH NB PRODUCTID FOR INDIV UPDATES

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGIN NEST
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGIN NEST
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGIN NEST

DECLARE cursor_NEST CURSOR FOR 
SELECT distinct productID
FROM tblOrders_products
where orderID in
(select distinct orderID from tblOrders where orderNo=@orderNo)
and deleteX<>'yes'
and productCode like 'NB%'

OPEN cursor_NEST
FETCH NEXT FROM cursor_NEST 
INTO @productID
WHILE @@FETCH_STATUS = 0
BEGIN

IF @productID is NULL
BEGIN
		FETCH NEXT FROM cursor_NEST 
        INTO @productID
END

ELSE

--WIPE NBS VARS // per productID wipe.
SET @contact=NULL
SET @title=NULL
SET @bkgnd=NULL
SET @sht=NULL
SET @pos=NULL
SET @COlogo=NULL
SET @COtextAll=NULL
SET @COtext1=NULL
SET @COtext2=NULL
SET @RO=NULL
--WIPE NBA VARS // per productID wipe.
SET @Shipping_Name=NULL
SET @Shipping_Company=NULL
SET @Shipping_Street=NULL
SET @Shipping_Street2=NULL
SET @Shipping_Suburb=NULL
SET @Shipping_State=NULL
SET @Shipping_PostCode=NULL
SET @badgeName=NULL
SET @badgeQTY=NULL

--RUN NBS SETS

--@contact
set @contact=(select textValue from tblOrdersProducts_ProductOptions where ordersProductsID in
(select [ID] from tblOrders_Products where [ID] is NOT NULL and orderID in
(select orderID from tblOrders where orderNo=@orderNo)
and productID=@productID)
and optionCaption like '%Name:%'
and deleteX<>'yes'
and textValue is NOT NULL)

--@title
set @title=(select textValue from tblOrdersProducts_ProductOptions where ordersProductsID in
(select [ID] from tblOrders_Products where [ID] is NOT NULL and orderID in
(select orderID from tblOrders where orderNo=@orderNo)
and productID=@productID)
and optionCaption like '%Title:%'
and deleteX<>'yes'
and textValue is NOT NULL)

--@bkgnd
set @bkgnd=(select productCode+'.gp' from tblOrders_Products where orderID in
(select orderID from tblOrders where orderNo=@orderNo and orderID is NOT NULL)
and productID=@productID)

--@sht, @pos, @COlogo, @COtextAll, @COtext1, COtext2
set @sht=''
set @pos=''
set @COlogo=''
set @COtextAll=''
set @COtext1=''
set @COtext2=''

--@RO  (OV/RC)
set @RO=(select substring(productCode,5,2) from tblOrders_Products where 
    substring(productCode,5,2)='OV'
    and orderID in
    (select distinct orderID from tblOrders where orderNo=@orderNo and orderID is NOT NULL)
    and productID=@productID
OR
    substring(productCode,5,2)='RC'
    and orderID in
    (select distinct orderID from tblOrders where orderNo=@orderNo and orderID is NOT NULL)
    and productID=@productID
)

--deNULL, if applicable
if @contact is NULL
begin
set @contact=''
end

if @title is NULL
begin
set @title=''
end

if @bkgnd is NULL
begin
set @bkgnd=''
end

if @sht is NULL
begin
set @sht=''
end

if @pos is NULL
begin
set @pos=''
end

if @COlogo is NULL
begin
set @COlogo=''
end

if @COtextAll is NULL
begin
set @COtextAll=''
end

if @COtext1 is NULL
begin
set @COtext1=''
end

if @COtext2 is NULL
begin
set @COtext2=''
end

if @RO is NULL
begin
set @RO=''
end

--RUN NBS INSERT
insert into tblNBS (contact, title, bkgnd, sht, pos, COlogo, COtextAll, COtext1, COtext2, RO, orderNo)
select @contact, @title, @bkgnd, @sht, @pos, @COlogo, @COtextAll, @COtext1, @COtext2, @RO, @orderNo

--RUN NBA SETS

--@Shipping_Name
set @Shipping_Name=(select replace(shipping_firstName+' '+shipping_SurName,'  ',' ') from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_firstName is NOT NULL and Shipping_surName is NOT NULL)

--@Shipping_Company
set @Shipping_Company=(select Shipping_Company from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_Company is NOT NULL)

--@Shipping_Street
set @Shipping_Street=(select Shipping_Street from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_Street is NOT NULL)

--@Shipping_Street2
set @Shipping_Street2=(select Shipping_Street2 from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_Street2 is NOT NULL)

--@Shipping_Suburb
set @Shipping_Suburb=(select Shipping_Suburb from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_Suburb is NOT NULL)

--@Shipping_State
set @Shipping_State=(select Shipping_State from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_State is NOT NULL)

--@Shipping_PostCode
set @Shipping_PostCode=(select Shipping_PostCode from tblCustomers_ShippingAddress where orderNo=@orderNo and Shipping_PostCode is NOT NULL)

--@badgeName
set @badgeName=@contact

 --@badgeQTY
set @badgeQTY=(select sum(productQuantity) from tblOrders_Products where orderID in
(select orderID from tblOrders where orderNo=@orderNo and orderID is NOT NULL)
and deleteX<>'yes'
and productCode like 'NB%')

--deNULL, if applicable
if @Shipping_Name is NULL
begin
set @Shipping_Name=''
end

if @Shipping_Company is NULL
begin
set @Shipping_Company=''
end

if @Shipping_Street is NULL
begin
set @Shipping_Street=''
end

if @Shipping_Street2 is NULL
begin
set @Shipping_Street2=''
end

if @Shipping_Suburb is NULL
begin
set @Shipping_Suburb=''
end

if @Shipping_State is NULL
begin
set @Shipping_State=''
end

if @Shipping_PostCode is NULL
begin
set @Shipping_PostCode=''
end

if @badgeName is NULL
begin
set @badgeName=''
end

if @badgeQTY is NULL
begin
set @badgeQTY=''
end

-- RUN NBA INSERT
insert into tblNBA (Shipping_Name, Shipping_Company, Shipping_Street, Shipping_Street2, Shipping_Suburb, Shipping_State, Shipping_PostCode, orderNo, badgeName, badgeQTY)
select @Shipping_Name, @Shipping_Company, @Shipping_Street, @Shipping_Street2, @Shipping_Suburb, @Shipping_State, @Shipping_PostCode, @orderNo, @badgeName, @badgeQTY
       

--POP NBA MULTI'S

-- 1.  NULL VARS
set @QTYCounter=NULL
set @NBSCounter=NULL
set @productCode=NULL

-- 2.  SET VARS
set @QTYCounter=(select sum(productQuantity) from tblOrders_Products
where productID=@productID
and deleteX<>'yes'
and orderID in
(select orderID from tblOrders where orderNo=@orderNo and orderID is NOT NULL))
IF @QTYCounter is NULL
BEGIN
    SET @QTYCounter=0
END

--moved the following statement up 1.  it was originally below the set @NBSCounter statement, which doesn't make sense,
--since the  @productCode is set to NULL on line 345 above, the following set @NBSCounter statement would never work.   JF 5/11/11.

set @productCode=(select productCode from tblProducts where productID=@productID)

set @NBSCounter=(select count(*) from tblNBS where orderNo=@orderNo and substring(bkgnd,1,10)=@productCode)
IF @NBSCounter is NULL
BEGIN
    SET @NBSCounter=0
END

IF @NBSCounter=@QTYCounter
BEGIN
		FETCH NEXT FROM cursor_NEST 
        INTO @productID
END

ELSE

WHILE (select count(*) from tblNBS where substring(bkgnd,1,10)=@productCode and orderNo=@orderNo)<>@QTYCounter
BEGIN
        --RUN NBS INSERT
insert into tblNBS (contact, title, bkgnd, sht, pos, COlogo, COtextAll, COtext1, COtext2, RO, orderNo)
select @contact, @title, @bkgnd, @sht, @pos, @COlogo, @COtextAll, @COtext1, @COtext2, @RO, @orderNo
        IF (select count(*) from tblNBS where substring(bkgnd,1,10)=@productCode and orderNo=@orderNo)=@QTYCounter
            BEGIN
                FETCH NEXT FROM cursor_NEST 
                INTO @productID
            END
            --BREAK
        ELSE
            CONTINUE
END

		FETCH NEXT FROM cursor_NEST 
        INTO @productID
END
CLOSE cursor_NEST
DEALLOCATE cursor_NEST

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END NEST
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END NEST
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END NEST

	FETCH NEXT FROM cursor_NB 
	INTO @orderNo
END
CLOSE cursor_NB
DEALLOCATE cursor_NB


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END CURSOR
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END CURSOR
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END CURSOR


--////////////// NBA FIX IT UP
--////////////// NBA FIX IT UP
--////////////// NBA FIX IT UP
--////////////// NBA FIX IT UP
--////////////// NBA FIX IT UP
--////////////// NBA FIX IT UP
--////////////// NBA FIX IT UP

--FIX NBA EXPORT DATA
--DEDUPE NBA
delete from tblNBA_DD
insert into tblNBA_DD (shipping_Name, shipping_Company, shipping_Street, shipping_Street2, shipping_suburb, 
shipping_State, shipping_postCode, orderNo, badgeName, badgeQTY)
select distinct shipping_Name, shipping_Company, shipping_Street, shipping_Street2, 
shipping_suburb, shipping_State, shipping_postCode, orderNo, badgeName, badgeQTY
from tblNBA
order by orderNo ASC

--GET SORTNO SEEDING TO START FROM SEED POSITION 1.
declare @topPKID int

set @topPKID=(select top 1 sortNo from tblNBA_DD order by sortNo asc)
set @topPKID=(@topPKID-1)

update tblNBA_DD
set sortNo_seed=sortNo-@topPKID
from tblNBA_DD
where sortNo_seed is NULL

--////////////// NBS FIX IT UP
--////////////// NBS FIX IT UP
--////////////// NBS FIX IT UP
--////////////// NBS FIX IT UP
--////////////// NBS FIX IT UP
--////////////// NBS FIX IT UP
--////////////// NBS FIX IT UP



--FIX NBS EXPORT DATA
--OV
delete from tblNBS_DD_OV
insert into tblNBS_DD_OV (contact, title, bkgnd, sht, pos, COlogo, COtextAll, COtext1, COtext2, RO, orderNo)
select contact, title, bkgnd, sht, pos, COlogo, COtextAll, COtext1, COtext2, RO, orderNo
from tblNBS 
where RO='OV' 
and orderNo<>'HOM235032'
and orderNo<>'HOM237814'
and orderNo<>'HOM237487'
and orderNo<>'HOM238522'
and orderNo<>'HOM239254'
order by orderNo ASC


--GET SORTNO SEEDING TO START FROM SEED POSITION 1.
declare @topPKID_DDOV int

set @topPKID_DDOV=(select top 1 sortNo from tblNBS_DD_OV order by sortNo asc)
set @topPKID_DDOV=(@topPKID_DDOV-1)

update tblNBS_DD_OV
set sortNo_seed=sortNo-@topPKID_DDOV
from tblNBS_DD_OV
where sortNo_seed is NULL

--RC
delete from tblNBS_DD_RC
insert into tblNBS_DD_RC (contact, title, bkgnd, sht, pos, COlogo, COtextAll, COtext1, COtext2, RO, orderNo)
select contact, title, bkgnd, sht, pos, COlogo, COtextAll, COtext1, COtext2, RO, orderNo
from tblNBS 
where RO='RC' 
and orderNo<>'HOM235032'
and orderNo<>'HOM237814'
and orderNo<>'HOM237487'
and orderNo<>'HOM238522'
and orderNo<>'HOM239254'
order by orderNo ASC

--GET SORTNO SEEDING TO START FROM SEED POSITION 1.
declare @topPKID_DDRC int

set @topPKID_DDRC=(select top 1 sortNo from tblNBS_DD_RC order by sortNo asc)
set @topPKID_DDRC=(@topPKID_DDRC-1)

update tblNBS_DD_RC
set sortNo_seed=sortNo-@topPKID_DDRC
from tblNBS_DD_RC
where sortNo_seed is NULL


--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA
--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA--MIGRATION CODE FOR NBS/NBA