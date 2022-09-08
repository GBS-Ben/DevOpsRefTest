CREATE function [dbo].[fn_FixBandaids_Oppo_OptionCaption] (@optionCaption varchar(255),@optionGroupCaption varchar(255),@textValue varchar(4000))
returns varchar(4000)
as
begin
declare @returnValue varchar(4000) = @optionCaption

--Fix <br/>
if @textValue like '%<br/>%'
	set @returnValue = replace(@returnValue,'<br/>','')



return @returnValue

end