


CREATE PROC [dbo].[usp_TicTic_AP_Logo]
 @OPID int 
AS
BEGIN TRY

	declare @qrfolder varchar(255),@qrurl varchar(255)
  
	EXEC EnvironmentVariables_Get N'EMBQRFolder',@VariableValue = @qrfolder OUTPUT;
	EXEC EnvironmentVariables_Get N'EMBQRURL',@VariableValue = @qrurl OUTPUT;

	select distinct @OPID,
	max(case when oppo.optioncaption = 'canvaseditorlogo' then SUBSTRING(oppo.textvalue,1,CHARINDEX('.pdf',oppo.textvalue)) + 'png' else null end) as 'logoimage',
	max(case when oppo.optioncaption = 'Apparel Logo' then oppo.textvalue end) as 'logo',
	max(case when oppo.optioncaption = 'EMB Logo QR' then replace(oppo.textvalue,@qrfolder,@qrurl) end) as 'logoQR',
	max(ati1.thread) as 'thread1',max(ati1.hex) as 'threadhex1',max(ati1.threadname) as 'threadname1',
	max(ati2.thread) as 'thread2',max(ati2.hex) as 'threadhex2',max(ati2.threadname) as 'threadname2',
	max(ati3.thread) as 'thread3',max(ati3.hex) as 'threadhex3',max(ati3.threadname) as 'threadname3',
	max(ati4.thread) as 'thread4',max(ati4.hex) as 'threadhex4',max(ati4.threadname) as 'threadname4',
	max(ati5.thread) as 'thread5',max(ati5.hex) as 'threadhex5',max(ati5.threadname) as 'threadname5'
	from (select OPID = @OPID) op
	left join tblordersproducts_productoptions oppo on op.opid = oppo.ordersProductsID AND ordersproductsid = @OPID and (oppo.optioncaption IN ('canvaseditorlogo','Apparel Logo','EMB Logo QR') or oppo.optioncaption like 'thread%')
	left join apparelthreadinfo ati1 on ati1.thread = oppo.textvalue and oppo.optioncaption = 'thread 1'
	left join apparelthreadinfo ati2 on ati2.thread = oppo.textvalue and oppo.optioncaption = 'thread 2'
	left join apparelthreadinfo ati3 on ati3.thread = oppo.textvalue and oppo.optioncaption = 'thread 3'
	left join apparelthreadinfo ati4 on ati4.thread = oppo.textvalue and oppo.optioncaption = 'thread 4'
	left join apparelthreadinfo ati5 on ati5.thread = oppo.textvalue and oppo.optioncaption = 'thread 5'
	group by ordersProductsID

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXECUTE [dbo].[usp_StoredProcedureErrorLog]

END CATCH
GO
