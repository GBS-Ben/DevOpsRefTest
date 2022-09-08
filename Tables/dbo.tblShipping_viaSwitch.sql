CREATE TABLE [dbo].[tblShipping_viaSwitch]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OPID] [int] NULL,
[trackingNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackingDate] [datetime] NULL,
[isImported] [bit] NOT NULL CONSTRAINT [DF_tblShipping_viaSwitch_isImported] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblShipping_viaSwitch] ADD CONSTRAINT [PK_tblShipping_viaSwitch] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]