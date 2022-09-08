CREATE PROCEDURE "dbo"."reportTest" @BatchID INT

AS
SELECT orderNo, OPID, uvType, qty, shipType From reportTestTable