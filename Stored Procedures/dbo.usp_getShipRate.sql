CREATE proc usp_getShipRate

@LBS float,
@RESCOM varchar(25)

AS

if @RESCOM is NULL
BEGIN
SET @RESCOM='C'
END

set @LBS=ROUND(@LBS,0)
--print @LBS

if @RESCOM='C'
BEGIN
select COM from tblRates where @LBS=LBS and COM is NOT NULL and ZONES='2'
END

if @RESCOM='R'
BEGIN
select RES from tblRates where @LBS=LBS and RES is NOT NULL and ZONES='2'
END