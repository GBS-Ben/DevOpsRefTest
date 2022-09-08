CREATE      proc [dbo].[usp_refresh_jobtrack]
AS
SET NOCOUNT ON;

BEGIN TRY 

--	delete from tbljobtrack
	insert into tbljobtrack(trackingnumber,jobnumber,[ups service],[pickup date],[scheduled delivery date],
	[package count])

	select distinct a.trackingnumber,a.referencenumber,b.[ups service],b.[pickup date],b.[scheduled delivery date],
	b.[package count] 
	from tbl_upsx a
	left join tbl_upsquantumviewcapture b
	on a.trackingnumber=b.[tracking number]
	where len(a.referencenumber)=14
	and substring(a.referencenumber,1,1) like '[a-z]'
	and substring(a.referencenumber,2,1) like '[a-z]'
	and substring(a.referencenumber,14,1) like '[0-9]'
	and a.referencenumber not like '% %'
	and a.trackingnumber is not null
	and a.referencenumber is not null
	and b.[ups service] is not null
	and b.[ups service] <>''

	update tbljobtrack
	set [Delivery Street Number]=b.[Delivery Street Number],
	[Delivery Street Prefix]= b.[Delivery Street Prefix] ,
	[Delivery Street Name]= b.[Delivery Street Name] ,
	[Delivery Street Type]= b.[Delivery Street Type] ,
	[Delivery Street Suffix]= b.[Delivery Street Suffix] ,
	[Delivery Building Name]= b.[Delivery Building Name] ,
	[Delivery Room/Suite/Floor]=b.[Delivery Room/Suite/Floor],
	[Delivery City]=b.[Delivery City],
	[Delivery State/Province]=b.[Delivery State/Province],
	[Delivery Postal Code]=b.[Delivery Postal Code] 
	from tbljobtrack a 
	INNER JOIN tbl_upsquantumviewcapture b ON a.[trackingnumber]= b.[tracking number]
	where b.[Delivery Street Number] <>''
	and b.[Delivery Street Number] is not null

	update tbljobtrack
	set [ups service]='' where [ups service] is null

	update tbljobtrack
	set [pickup date]='' where [pickup date] is null

	update tbljobtrack
	set [scheduled delivery date]='' where [scheduled delivery date] is null

	update tbljobtrack
	set [package count]='' where [package count] is null

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH