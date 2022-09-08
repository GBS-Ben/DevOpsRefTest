CREATE PROC [dbo].[usp_TicTic_OrderInfo]
@OPID int  
AS
BEGIN TRY
		WITH 
			cteOrder AS 
				(SELECT orderid 
				 FROM tblorders_products 
				 WHERE id = @OPID),
			ctePackValue AS 
			(	SELECT opid,cast(opidnum AS VARCHAR(10)) + ' OF ' + CAST(MAX(opidnum) OVER (PARTITION BY orderid) AS VARCHAR(10)) as packetValue
			FROM (
					SELECT osf.orderid,osf.opid,
					ROW_NUMBER() OVER (PARTITION BY osf.orderid ORDER BY opid) AS opidnum
					FROM opidswitchflow osf
					INNER JOIN cteorder o ON osf.orderid = o.orderid
					WHERE osf.switchflow like 'ap - %'
					) a
			GROUP BY orderid,opid,opidnum
			)
	SELECT o.orderID
	, o.orderDate
	, o.storeID
	, o.orderNo
	,LEFT(o.orderNo, 3) + '-' + SUBSTRING(o.orderNo, 4, 3) +  '-' + SUBSTRING(o.orderNo, 7, len(o.orderNo)) + '_' + cast(op.id as varchar(15)) AS orderNoSpecialDisplay
	,'*ON' + o.orderNo + '*' AS orderNoSpecialBarcode
	,'*OI' + cast(op.ID AS VARCHAR(15)) + '*' AS OPIDSpecialBarcode
	,o.specialInstructions
	,o.shippingMethod
	,o.shippingDesc
	,o.orderWeight
	,o.shipZone
	,o.ArrivalDate
	,o.shipping_Company
	,o.shipping_FirstName
	,o.shipping_Surname
	,o.shipping_Street
	,o.shipping_Street2
	,o.shipping_Suburb
	,o.shipping_State
	,o.shipping_PostCode
	,o.shipping_Country
	,o.shipping_Phone
	,op.productQuantity
	,substring(op.productName,1,CASE WHEN CHARINDEX('(',op.productName) > 0 THEN CHARINDEX('(',op.productName)-1 ELSE len(op.productName) END) as productName
	,op.productCode
	,p.packetValue
	FROM tblOrders o
	INNER JOIN tblOrders_Products op on o.orderID = op.orderid
	LEFT JOIN ctePackValue p on op.id = p.opid
	WHERE op.id = @OPID 

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXECUTE [dbo].[usp_StoredProcedureErrorLog]

END CATCH
GO
