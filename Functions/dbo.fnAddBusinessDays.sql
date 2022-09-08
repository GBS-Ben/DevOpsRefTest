create function [dbo].[fnAddBusinessDays] (@Date Date, @NumberOfDays int)
returns date
as
begin
	declare @ReturnDate date

	select @ReturnDate = a.[Date]
	from
	(
	select [Date]
	,RowNumber = ROW_NUMBER() over (order by Date)
	from DateDimension
	where IsWeekend = 0
		and IsHoliday = 0
		and [Date] > @Date
	) a
	where RowNumber = @NumberOfDays

	return @ReturnDate
end