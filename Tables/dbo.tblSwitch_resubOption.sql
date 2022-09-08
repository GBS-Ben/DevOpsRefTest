CREATE TABLE [dbo].[tblSwitch_resubOption]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OPID] [int] NULL,
[resubmitQTY] [int] NULL,
[resubmitChoice] [int] NULL,
[resubmitDate] [datetime] NOT NULL CONSTRAINT [DF_tblSwitch_resubOption_created_on] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitch_resubOption] ADD CONSTRAINT [PK_tblSwitch_resubOption] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]