CREATE view [dbo].[ApparelProductThreadColorUnpivot_031821] as
select CompanyCode, APCode, thread.OptionCaption, thread.textValue 
from
(
select CompanyCode
,APCode
,[Thread 1]
,[Thread 2]
,[Thread 3]
,[Thread 4]
,[Thread 5]
,[Thread 6]
,[Thread 7]
from dbo.tblApparelProductThreadColor
) as ap
unpivot
(
	textValue for OptionCaption in ([Thread 1],[Thread 2],[Thread 3],[Thread 4],[Thread 5],[Thread 6],[Thread 7])
) as thread
union
select CompanyCode, APCode, 'Apparel Logo' as OptionCaption, APLogo as textValue
from dbo.tblApparelProductThreadColor