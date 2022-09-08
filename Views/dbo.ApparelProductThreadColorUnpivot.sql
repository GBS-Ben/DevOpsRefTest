CREATE view [dbo].[ApparelProductThreadColorUnpivot] as
select APLogo, thread.OptionCaption, thread.textValue 
from
(
select APLogo
,[Thread 1]
,[Thread 2]
,[Thread 3]
,[Thread 4]
,[Thread 5]
from dbo.tblApparelProductThreadColor
) as ap
unpivot
(
	textValue for OptionCaption in ([Thread 1],[Thread 2],[Thread 3],[Thread 4],[Thread 5])
) as thread