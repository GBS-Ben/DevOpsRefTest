CREATE TABLE [dbo].[tblSwitch_BC_hardcode]
(
[opid] [int] NOT NULL CONSTRAINT [DF_tblSwitch_BC_hardcode_opid] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitch_BC_hardcode] ADD CONSTRAINT [PK_tblSwitch_BC_hardcode] PRIMARY KEY CLUSTERED  ([opid]) ON [PRIMARY]