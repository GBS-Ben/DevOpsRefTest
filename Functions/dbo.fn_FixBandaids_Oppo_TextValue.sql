CREATE function [dbo].[fn_FixBandaids_Oppo_TextValue] (@optionCaption varchar(255),@optionGroupCaption varchar(255),@textValue varchar(4000))
returns varchar(4000)
as
begin
declare @returnValue varchar(4000) = @textValue

--Fix envelope color ray
if @textValue = 'ray'
	set @returnValue = 'Gray'
--Fix %|%
if @textValue like '%|%'
	set @returnValue = ''
--Fix 72 Card Sets
if @optionCaption = '72 Card Sets'
	set @returnValue = ''
--Fix %72 Card Sets%
if @optionCaption = 'Description' and @textValue like '%72 Card Sets%'
	set @returnValue = ''
--Fix <br/>
if @textValue like '%<br/>%'
	set @returnValue = replace(@returnValue,'<br/>','')
--Fix special characters &#39;
if @textValue like '%&#39;%'
	set @textValue = REPLACE(@textValue, '&#39;', '''')


return @returnValue

end