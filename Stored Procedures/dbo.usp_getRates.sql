CREATE proc usp_getRates
@zip varchar(50),
@weight varchar(50)
as

declare 
@parsedZip varchar(50),
@zone char(10)

set @parsedZip=substring(@zip,1,3)
if @parsedZip is NULL
BEGIN
SET @parsedZip='920'
END

set @zone=(select GBSZone from tblZone where zip=@parsedZip)

if @zone is NULL
BEGIN
SET @zone='2'
END

--GRAB EACH ZONE DEPENDING ON ZONE
--//GRND, 3DAY, 2DAY, NEXT

IF @zone='2'
BEGIN
SELECT GRND2, [3DAY2], [2DAY2], NEXT2
FROM tblWeight
WHERE WEIGHT=@weight
END

IF @zone='3'
BEGIN
SELECT GRND3, [3DAY3], [2DAY3], NEXT3
FROM tblWeight
WHERE WEIGHT=@weight
END

IF @zone='4'
BEGIN
SELECT GRND4, [3DAY4], [2DAY4], NEXT4
FROM tblWeight
WHERE WEIGHT=@weight
END

IF @zone='5'
BEGIN
SELECT GRND5, [3DAY5], [2DAY5], NEXT5
FROM tblWeight
WHERE WEIGHT=@weight
END

IF @zone='6'
BEGIN
SELECT GRND6, [3DAY6], [2DAY6], NEXT6
FROM tblWeight
WHERE WEIGHT=@weight
END
IF @zone='7'
BEGIN
SELECT GRND7, [3DAY7], [2DAY7], NEXT7
FROM tblWeight
WHERE WEIGHT=@weight
END

IF @zone='8'
BEGIN
SELECT GRND8, [3DAY8], [2DAY8], NEXT8
FROM tblWeight
WHERE WEIGHT=@weight
END

IF @zone='9'
BEGIN
SELECT GRND9, [3DAY9], [2DAY9], NEXT9
FROM tblWeight
WHERE WEIGHT=@weight
END