-------- some envelopes only have front images?
CREATE VIEW [dbo].[vwPrintFileMover_NewFiles]
AS 

SELECT 
	 OrderID
	,OrderNo
	,OPID
	,ProductCode
	,optionCaption
	,textValue
	,PrintFileMoverRegistrationKey
	,ProductMask
	,SourcePath
	,REVERSE(SUBSTRING(REVERSE(textvalue),1,CASE WHEN CHARINDEX('\',REVERSE(textvalue)) = 0 THEN CHARINDEX('/',REVERSE(textvalue)) ELSE CHARINDEX('\',REVERSE(textvalue)) END -1)) as 'SourceFileName'
	,DestinationPath
	,DestinationFilePattern
	,f.*
FROM (
		SELECT DISTINCT 
			 o.orderid
			,o.orderno
			,op.ID as OPID
			,p.productcode
			,oppo.optionCaption as oppo_optionCaption
			,oppo.textValue
			,sfr.PrintFileMoverRegistrationKey
			,sfr.ProductMask
			,sfr.optionCaption
			,sfr.SourcePath
			,sfr.DestinationPath
			,sfr.DestinationFilePattern
			,sfr.ActiveFlag
	FROM tblOrders o 
		INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
		INNER JOIN tblProducts p ON op.productID = p.productID
		INNER JOIN tblOrdersProducts_ProductOptions oppo ON op.ID = oppo.ordersProductsID
		CROSS APPLY  tblPrintFileMoverRegistration sfr
		WHERE 
		o.archived = 0 
		--AND op.isPrinted = 0
		AND o.tabStatus NOT IN ('Failed', 'Exception')
		AND o.orderType = 'Custom' 
		AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
		--AND o.orderAck = 0		--removed 01/20/21
		AND op.deleteX <> 'yes' 
		AND op.processType = 'Custom'
		AND (
				((SUBSTRING(op.productCode, 1, 2) = 'EV' OR SUBSTRING(op.productCode, 3, 2) = 'EV') AND op.productName  LIKE '%envelope%')	-- envelopes
			  OR op.productCode LIKE 'PL%'	-- name plates
			  OR op.productCode LIKE 'LH%'	-- Letterhead
			  OR (SUBSTRING(op.productCode, 3, 2) = 'IN' AND op.productName LIKE '%insert%')
			  OR op.productCode like '__PM%' --postcard mailer
			  or op.productCode like 'fb%' -- football
			  OR (op.productCode like 'NB__S%' and op.productCode not like 'NB___U%') -- LUX NB
			  OR op.productCode LIKE 'BP%' -- Business Cards
			  OR op.productCode LIKE 'PC%' -- Postcards
			)
		AND (textvalue not like '%0[_]-1.pdf' and textvalue  not like '%0[_]0.pdf') 
		AND DATEDIFF(mi,o.orderDate,GETDATE()) >= 5
		and ((@@servername IN ('DEV-SQL03\INTRANET') and substring(o.orderno,4,1) = 'A') or db_name() NOT IN ('gbscorealpha','gbscoreqa3'))
	 ) a 
	 left join filedownloadlog f on f.OrdersProductsId = a.opid
WHERE productcode LIKE productmask 
  AND oppo_optionCaption = optionCaption 
  AND ActiveFlag = 1
  AND NOT EXISTS (SELECT * FROM tblPrintFileMoverLog l WHERE l.OrderID = a.OrderNo AND l.OPID = a.OPID AND l.SourceFile = a.SourcePath + REVERSE(SUBSTRING(REVERSE(textvalue),1,CASE WHEN CHARINDEX('\',REVERSE(textvalue)) = 0 THEN CHARINDEX('/',REVERSE(textvalue)) ELSE CHARINDEX('\',REVERSE(textvalue)) END -1)) and l.[status] IN ( 'SUCCESS','CANCELLED'))
  and  f.DownloadUNCFile = replace(a.sourcepath,'summerhall','arc') + REVERSE(SUBSTRING(REVERSE(textvalue),1,CASE WHEN CHARINDEX('\',REVERSE(textvalue)) = 0 THEN CHARINDEX('/',REVERSE(textvalue)) ELSE CHARINDEX('\',REVERSE(textvalue)) END -1)) and f.downloadurl is not null
  and f.StatusMessage not like '%fail%'