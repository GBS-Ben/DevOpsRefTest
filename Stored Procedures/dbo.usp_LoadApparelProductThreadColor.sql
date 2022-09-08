CREATE proc [dbo].[usp_LoadApparelProductThreadColor] as
begin
	declare @LoadDate datetime
	select @LoadDate = max([LoadDate]) from dbo.tblApparelProductThreadColorStage

	if (@LoadDate > (select isnull(max([LoadDate]),convert(datetime,0)) from dbo.tblApparelProductThreadColor))
	begin
		truncate table tblApparelProductThreadColor
		--Load most recent records
		insert into dbo.tblApparelProductThreadColor
		([LoadDate]
		,[CompanyName]
		,[CompanyCode]
		,[Sorting]
		,[APCode]
		,[APLogo]
		,[Thread 1]
		,[Thread 2]
		,[Thread 3]
		,[Thread 4]
		,[Thread 5]
		,[Thread 6]
		,[Thread 7]
		,[Notes]
		,[LinkToLogo]
		)

		SELECT [LoadDate]
		,[Company Name]
		,[Company Code]
		,[Sorting]
		,[AP Code]
		,[AP Logo]
		,[Thread 1]
		,[Thread 2]
		,[Thread 3]
		,[Thread 4]
		,[Thread 5]
		,[Thread 6]
		,[Thread 7]
		,[Notes]
		,[Link to Logo]
		FROM dbo.tblApparelProductThreadColorStage
		WHERE [LoadDate] = @LoadDate
			and [Company Name] is not null

		DELETE FROM dbo.tblApparelProductThreadColorStage where LoadDate < dateadd(day,-7,getdate())
		DELETE FROM dbo.tblApparelProductThreadColorStage where [Company Name] is null
	

	end

end